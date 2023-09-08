@IsTest
public class B2BTaxTest {
    @TestSetup static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        CartItem cartItem = new CartItem(
                CartId=cart.Id,
                Sku='SKU_Test1',
                Quantity=3.0,
                Type='Product',
                Name='TestProduct',
                CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
    }

    @IsTest static void testCartTaxForCartItemSuccessfullyInserted() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetTaxesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        B2BTax apexSample = new B2BTax();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        Id cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1].Id;
        Sfdc_Checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(null, webCartId);

        System.assertEquals(Sfdc_Checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId];
        System.assertEquals(1, cartTaxesForCartItem.size());
        Test.stopTest();
    }

    @IsTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsCreated() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetInventoryResource');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        B2BTax apexSample = new B2BTax();
        Sfdc_Checkout.IntegrationInfo integInfo = new Sfdc_Checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Sfdc_Checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        System.assertEquals(Sfdc_Checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        Test.stopTest();
    }

    @IsTest static void testProductsWithNoSkuHasError() {
        Test.startTest();

        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :webCart.Id LIMIT 1];

        CartItem cartItemWithNoSku = new CartItem(
                CartId=webCart.Id,
                Quantity=1.0,
                Type='Product',
                Name='TestProductNoSku',
                CartDeliveryGroupId=cartDeliveryGroups.get(0).Id
        );
        insert cartItemWithNoSku;

        B2BTax apexSample = new B2BTax();
        Sfdc_Checkout.IntegrationInfo integInfo = new Sfdc_Checkout.IntegrationInfo();
        integInfo.jobId = null;
        Sfdc_Checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        System.assertEquals(Sfdc_Checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());

        System.assertEquals('The SKUs for all products in your cart must be defined.', cartValidationOutputs.get(0).Message);
        Test.stopTest();

        delete cartItemWithNoSku;
    }
}