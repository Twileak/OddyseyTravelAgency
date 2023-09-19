global with sharing class B2BTax implements Sfdc_Checkout.CartTaxCalculations {
    global Sfdc_Checkout.IntegrationStatus startCartProcessAsync(Sfdc_Checkout.IntegrationInfo jobInfo, Id cartId) {
        Sfdc_Checkout.IntegrationStatus integStatus = new Sfdc_Checkout.IntegrationStatus();
        try {
            Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId WITH SECURITY_ENFORCED][0].CartDeliveryGroupId;
            CartDeliveryGroup deliveryGroup = [SELECT DeliverToState, DeliverToCountry FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId WITH SECURITY_ENFORCED][0];

            Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
            Map<String, Decimal> cartItemTotalPriceBySKU = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = :cartId WITH SECURITY_ENFORCED]) {
                String cartItemSKU = '';
                if (cartItem.Type == 'Product') {
                    if (String.isBlank(cartItem.Sku)) {
                        String errorMessage = 'The SKUs for all products in your cart must be defined.';
                        return integrationStatusFailedWithCartValidationOutputError(
                                integStatus,
                                errorMessage,
                                jobInfo,
                                cartId
                        );
                    }
                    cartItemSKU = cartItem.Sku;
                }
                else if (cartItem.Type == 'Charge') {

                    cartItemSKU = 'ChargeSKU';
                }
                cartItemIdsBySKU.put(cartItemSKU, cartItem.Id);
                cartItemTotalPriceBySKU.put(cartItemSKU, cartItem.TotalPrice);
            } Map<String, TaxDataFromExternalService> rateAndAmountFromExternalServicePerSku = getTaxRatesAndAmountsFromExternalService(
                    cartItemTotalPriceBySKU, deliveryGroup.DeliverToState, deliveryGroup.DeliverToCountry
            );List<Id> cartItemIds = cartItemIdsBySKU.values();
            delete [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds WITH SECURITY_ENFORCED];  CartTax[] cartTaxestoInsert = new CartTax[]{};
            for (String sku : cartItemIdsBySKU.keySet()) {
                TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(sku);
                if (rateAndAmountFromExternalService == null){
                    return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            'The product with sku ' + sku + ' could not be found in the external system',
                            jobInfo,
                            cartId
                    );
                }
                CartTax tax = new CartTax(
                        Amount = rateAndAmountFromExternalService.getAmount(),
                        CartItemId = cartItemIdsBySKU.get(sku),
                        Name = rateAndAmountFromExternalService.getTaxName(),
                        TaxCalculationDate = Date.today(),
                        TaxRate = rateAndAmountFromExternalService.getRate(),
                        TaxType = 'Actual'
                );
                cartTaxestoInsert.add(tax);
            }
            insert(cartTaxestoInsert);
            integStatus.status = Sfdc_Checkout.IntegrationStatus.Status.SUCCESS;
        } catch(Exception e) {
            return integrationStatusFailedWithCartValidationOutputError(
                    integStatus,
                    'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                    jobInfo,
                    cartId
            );
        }
        return integStatus;
    }

    private Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService (
            Map<String, Decimal> cartItemTotalAmountBySKU, String state, String country) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;
        String encodedState = (state == null) ? '' : EncodingUtil.urlEncode(state, 'UTF-8').replace('+', '%20');
        String encodedCountry = (country == null) ? '' : EncodingUtil.urlEncode(country, 'UTF-8').replace('+', '%20');

        Map<String, Decimal> encodedCartItemTotalAmountBySKU = new Map<String, Decimal>();
        for(String sku: cartItemTotalAmountBySKU.keySet()) {
            encodedCartItemTotalAmountBySKU.put(EncodingUtil.urlEncode(sku, 'UTF-8'), cartItemTotalAmountBySKU.get(sku));
        }String requestURL = 'https://b2b-commerce-test.herokuapp.com/get-tax-rates?state=' + encodedState
                + '&country=' + encodedCountry
                + '&amountsBySKU=' + JSON.serialize(encodedCartItemTotalAmountBySKU);
        request.setEndpoint(requestURL);
        request.setMethod('GET');
        HttpResponse response = http.send(request); if (response.getStatusCode() == SuccessfulHttpRequest) {
            Map<String, Object> resultsFromExternalServiceBySKU = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
            for (String sku : resultsFromExternalServiceBySKU.keySet()) {
                Map<String, Object> rateAndAmountFromExternalService = (Map<String, Object>) resultsFromExternalServiceBySKU.get(sku);
                taxDataFromExternalServiceBySKU.put(sku, new TaxDataFromExternalService(
                        (Decimal)rateAndAmountFromExternalService.get('taxRate'),
                        (Decimal)rateAndAmountFromExternalService.get('taxAmount'),
                        (String)rateAndAmountFromExternalService.get('taxName')
                ));
            }
            return taxDataFromExternalServiceBySKU;
        }
        else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
        }
    }
    class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;

        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }

        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }

        public Decimal getRate() {
            return rate;
        }

        public Decimal getAmount() {
            return amount;
        }

        public String getTaxName() {
            return taxName;
        }
    }

    private Sfdc_Checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
            Sfdc_Checkout.IntegrationStatus integrationStatus, String errorMessage, Sfdc_Checkout.IntegrationInfo jobInfo, Id cartId) {
        integrationStatus.status = Sfdc_Checkout.IntegrationStatus.Status.FAILED;
        CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Taxes'
        );
        insert(cartValidationError);
        return integrationStatus;
    }
}