global with sharing class B2BInventory implements Sfdc_Checkout.CartInventoryValidation {
    global Sfdc_Checkout.IntegrationStatus startCartProcessAsync(Sfdc_Checkout.IntegrationInfo jobInfo, Id cartId) {
        Sfdc_Checkout.IntegrationStatus integStatus = new Sfdc_Checkout.IntegrationStatus();
        try {
            Map<String, Decimal> quantitiesFromSalesforce = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, Quantity FROM CartItem WHERE CartId = :cartId AND Type = 'Product' WITH SECURITY_ENFORCED]) {
                if (String.isBlank(cartItem.Sku)) {
                    String errorMessage = 'The SKUs for all products in your cart must be defined.';
                    return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                    );
                }
                quantitiesFromSalesforce.put(cartItem.Sku, cartItem.Quantity);
            }
            if (quantitiesFromSalesforce.isEmpty()) {
                String errorMessage = 'Looks like your cart is empty.';
                return integrationStatusFailedWithCartValidationOutputError(
                        integStatus,
                        errorMessage,
                        jobInfo,
                        cartId
                );
            }
            Map<String, Object> quantitiesFromExternalService = getQuantitiesFromExternalService(quantitiesFromSalesforce.keySet());

            for (String sku : quantitiesFromSalesforce.keySet()) {
                Decimal quantityFromSalesforce = quantitiesFromSalesforce.get(sku);
                Decimal quantityFromExternalService = (Decimal)quantitiesFromExternalService.get(sku);
                if (quantityFromExternalService == null){
                    String errorMessage = 'The product with sku ' + sku + ' could not be found in the external system';
                    return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                    );
                }
                else if (quantityFromExternalService < quantityFromSalesforce){
                    String errorMessage = 'Insufficient quantity for the product with sku ' + sku + ': '
                            + quantityFromSalesforce + ' needed, but only '
                            + quantityFromExternalService + ' available.';
                    return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                    );
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

    private Map<String, Object> getQuantitiesFromExternalService (Set<String> skus) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;
        Set<String> encodedSkus = new Set<String>();
        for (String sku : skus) {
            encodedSkus.add(EncodingUtil.urlEncode(sku, 'UTF-8'));
        }

        request.setEndpoint('https://b2b-commerce-test.herokuapp.com/get-inventory?skus=' + JSON.serialize(encodedSkus));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == SuccessfulHttpRequest) {
            Map<String, Object> quantitiesFromExternalService = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return quantitiesFromExternalService;
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
                Type = 'Inventory'
        );
        insert(cartValidationError);
        return integrationStatus;
    }
}