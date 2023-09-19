@IsTest
public class B2BInventoryTest {
    @TestSetup static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        insertCartItem(cart.Id, cartDeliveryGroup.Id);
    }

    @IsTest static void testWhenExternalServiceQuantityIsLargerThanTheCartItemQuantityASuccessStatusIsReturned() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetInventoryResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        B2BInventory apexSample = new B2BInventory();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Sfdc_Checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(null, webCart.Id);
        System.assertEquals(Sfdc_Checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }

    @IsTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsCreated() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetInventoryResource');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        B2BInventory apexSample = new B2BInventory();
        Sfdc_Checkout.IntegrationInfo integInfo = new Sfdc_Checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Sfdc_Checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        System.assertEquals(Sfdc_Checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        Test.stopTest();
    }
    @IsTest static void testEmptyCartHasError() {
        deleteCartItem();
        Test.startTest();

        B2BInventory apexSample = new B2BInventory();
        Sfdc_Checkout.IntegrationInfo integInfo = new Sfdc_Checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Sfdc_Checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        System.assertEquals(Sfdc_Checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        System.assertEquals('Looks like your cart is empty.', cartValidationOutputs.get(0).Message);
        Test.stopTest();

        insertCartItem(webCart.Id);
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

        B2BInventory apexSample = new B2BInventory();
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

    static void insertCartItem(String cartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];

        insertCartItem(cartId, cartDeliveryGroups.get(0).Id);
    }

    static void insertCartItem(String cartId, String cartDeliveryGroupId) {
        CartItem cartItem = new CartItem(
                CartId=cartId,
                Sku='SKU_Test1',
                Quantity=3.0,
                Type='Product',
                Name='TestProduct',
                CartDeliveryGroupId=cartDeliveryGroupId
        );
        insert cartItem;
    }

    static void deleteCartItem() {
        CartItem cartItem = [SELECT Id FROM CartItem WHERE Name = 'TestProduct' LIMIT 1];
        delete cartItem;
    }
}