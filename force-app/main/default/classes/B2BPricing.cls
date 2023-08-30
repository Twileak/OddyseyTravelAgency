global with sharing class B2BPricing implements Sfdc_Checkout.CartPriceCalculations {
    global Sfdc_Checkout.IntegrationStatus startCartProcessAsync(Sfdc_Checkout.IntegrationInfo jobInfo, Id cartId) {
        Sfdc_Checkout.IntegrationStatus integStatus = new Sfdc_Checkout.IntegrationStatus();
        try {
            Id customerId = [SELECT OwnerId FROM WebCart WHERE Id = :cartId WITH SECURITY_ENFORCED][0].OwnerId;
            Map<String, Decimal> salesPricesFromSalesforce = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, SalesPrice FROM CartItem WHERE CartId = :cartId AND Type = 'Product' WITH SECURITY_ENFORCED]) {
                if (String.isBlank(cartItem.Sku)) {
                    String errorMessage = 'The SKUs for all products in your cart must be defined.';
                    return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                    );
                }
                salesPricesFromSalesforce.put(cartItem.Sku, cartItem.SalesPrice);
            }

            Map<String, Object> salesPricesFromExternalService = getSalesPricesFromExternalService(salesPricesFromSalesforce.keySet(), Id.valueOf(customerId));

            for (String sku : salesPricesFromSalesforce.keySet()) {
                Decimal salesPriceFromSalesforce = salesPricesFromSalesforce.get(sku);
                Decimal salesPriceFromExternalService = (Decimal)salesPricesFromExternalService.get(sku);
                if (salesPriceFromExternalService == null){
                    String errorMessage = 'The product with sku ' + sku + ' could not be found in the external system';
                    return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                    );
                }
                else if (salesPriceFromExternalService != salesPriceFromSalesforce){
                    if (salesPriceFromExternalService == 0.00){
                        integStatus.status = Sfdc_Checkout.IntegrationStatus.Status.SUCCESS;
                    }
                    else {
                        String errorMessage = 'The sale price has changed for the product with sku ' + sku + ': was '
                                + salesPriceFromSalesforce + ', but now is '
                                + salesPriceFromExternalService + '.';
                        return integrationStatusFailedWithCartValidationOutputError(
                                integStatus,
                                errorMessage,
                                jobInfo,
                                cartId
                        );
                    }
                }
                else {
                    integStatus.status = Sfdc_Checkout.IntegrationStatus.Status.SUCCESS;
                }
            }
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

    private Map<String, Object> getSalesPricesFromExternalService (Set<String> skus, String customerId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;
        Set<String> encodedSkus = new Set<String>();
        for (String sku : skus) {
            encodedSkus.add(EncodingUtil.urlEncode(sku, 'UTF-8'));
        }
        request.setEndpoint('https://b2b-commerce-test.herokuapp.com/get-sales-prices?customerId='
                + customerId + '&skus=' + JSON.serialize(encodedSkus));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == SuccessfulHttpRequest) {
            Map<String, Object> salesPricesFromExternalService = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return salesPricesFromExternalService;
        }
        else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
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
                Type = 'Pricing'
        );
        insert(cartValidationError);
        return integrationStatus;
    }
}