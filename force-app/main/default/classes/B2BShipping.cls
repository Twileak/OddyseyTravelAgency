global with sharing class B2BShipping implements Sfdc_Checkout.CartShippingCharges {
    global Sfdc_Checkout.IntegrationStatus startCartProcessAsync(Sfdc_Checkout.IntegrationInfo jobInfo, Id cartId) {
        Sfdc_Checkout.IntegrationStatus integStatus = new Sfdc_Checkout.IntegrationStatus();
        try {
            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId WITH SECURITY_ENFORCED][0].Id;

            Integer numberOfUniqueItems = [SELECT COUNT() FROM CartItem WHERE CartId = :cartId WITH SECURITY_ENFORCED];

            ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService(numberOfUniqueItems);

            delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId WITH SECURITY_ENFORCED];

            List<Id> orderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);

            Integer i = 0;
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
                populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                        cartDeliveryGroupId,
                        orderDeliveryMethodId,
                        cartId);
                i+=1;
            }

            integStatus.status = Sfdc_Checkout.IntegrationStatus.Status.SUCCESS;

        } catch (DmlException de) {
            Integer numErrors = de.getNumDml();
            String errorMessage = 'There were ' + numErrors + ' errors when trying to insert the charge in the CartItem: ';
            for(Integer errorIdx = 0; errorIdx < numErrors; errorIdx++) {
                errorMessage += 'Field Names = ' + de.getDmlFieldNames(errorIdx);
                errorMessage += 'Message = ' + de.getDmlMessage(errorIdx);
                errorMessage += ' , ';
            }

            return integrationStatusFailedWithCartValidationOutputError(
                    integStatus,
                    errorMessage,
                    jobInfo,
                    cartId
            );
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

    private ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService (Integer numberOfUniqueItems) {
        final Integer SuccessfulHttpRequest = 200;

        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://b2b-commerce-test.herokuapp.com/calculate-shipping-rates-winter-21');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == SuccessfulHttpRequest) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            for (Object result: results) {
                Map<String, Object> subresult = (Map<String, Object>) result;
                Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
                shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                        (String) providerAndRate.get('name'),
                        (String) providerAndRate.get('serviceCode'),
                        (Decimal) providerAndRate.get('shipmentCost') * numberOfUniqueItems, // Multiply so shipping costs can change; remove when using a real shipping provider
                        (Decimal) providerAndRate.get('otherCost'),
                        (String) providerAndRate.get('serviceName')
                ));
            }
            return shippingOptions;
        }
        else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
        }
    }
    class ShippingOptionsAndRatesFromExternalService {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;

        public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName) {
            name = someName;
            provider = someProvider;
            rate = someRate;
            otherCost = someOtherCost;
            serviceName = someServiceName;
        }

        public String getProvider() {
            return provider;
        }

        public Decimal getRate() {
            return rate;
        }

        public Decimal getOtherCost() {
            return otherCost;
        }

        public String getServiceName() {
            return serviceName;
        }

        public String getName() {
            return name;
        }
    }
    private void populateCartDeliveryGroupMethodWithShippingOptions(ShippingOptionsAndRatesFromExternalService shippingOption,
            Id cartDeliveryGroupId,
            Id deliveryMethodId,
            Id webCartId){
        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
                CartDeliveryGroupId = cartDeliveryGroupId,
                DeliveryMethodId = deliveryMethodId,
                ExternalProvider = shippingOption.getProvider(),
                Name = shippingOption.getName(),
                ShippingFee = shippingOption.getRate(),
                WebCartId = webCartId
        );
        insert(cartDeliveryGroupMethod);
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
                Type = 'Shipping'
        );
        insert(cartValidationError);
        return integrationStatus;
    }

    private Id getShippingChargeProduct2Id(Id orderDeliveryMethodId) {
        List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT ProductId FROM OrderDeliveryMethod WHERE Id = :orderDeliveryMethodId WITH SECURITY_ENFORCED];
        return orderDeliveryMethods[0].ProductId;
    }

    private List<Id> getOrderDeliveryMethods(List<ShippingOptionsAndRatesFromExternalService> shippingOptions) {
        String defaultDeliveryMethodName = 'Order Delivery Method';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();

        List<Id> orderDeliveryMethodIds = new List<Id>();
        List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
        Integer i = 1;
        for (ShippingOptionsAndRatesFromExternalService shippingOption: shippingOptions) {
            String shippingOptionNumber = String.valueOf(i);
            String name = defaultDeliveryMethodName + shippingOptionNumber;
            List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name = :name WITH SECURITY_ENFORCED];
            if (odms.isEmpty()) {
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                        Name = name,
                        Carrier = shippingOption.serviceName,
                        IsActive = true,
                        ProductId = product2IdForThisDeliveryMethod,
                        ClassOfService = shippingOption.provider
                );
                insert(defaultOrderDeliveryMethod);
                orderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
            }
            else {
                OrderDeliveryMethod existingodm = odms[0];
                if (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) {
                    existingodm.ProductId = product2IdForThisDeliveryMethod;
                    existingodm.Carrier = shippingOption.serviceName;
                    existingodm.ClassOfService = shippingOption.provider;
                    update(existingodm);
                }
                orderDeliveryMethodIds.add(existingodm.Id);
            }
            i+=1;
        }
        return orderDeliveryMethodIds;
    }

    private Id getDefaultShippingChargeProduct2Id() {
        String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name WITH SECURITY_ENFORCED];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                    IsActive = true,
                    Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
}