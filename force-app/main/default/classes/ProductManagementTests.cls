@isTest
private class ProductManagementTests {
    @isTest
    static void testGetProducts() {
        List<Product2> productsToInsert = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            productsToInsert.add(new Product2(Name = 'Product ' + i, Member_Limit__c=5));
        }
        Test.startTest();
        insert productsToInsert;
        Test.stopTest();

        List<Product2> products = ProductManagementController.getProducts();

        System.assertEquals(5, products.size(), 'Expected 5 Product records');
    }

    @isTest
    static void testSaveProduct() {
        Product2 testProduct = new Product2(Name = 'Test Product', Member_Limit__c=5);

        Test.startTest();
        List<Product2> products = ProductManagementController.saveProduct(testProduct);
        Test.stopTest();

        System.assertEquals(1, products.size(), 'Expected 1 Product record');
        System.assertNotEquals(null, testProduct.Id, 'Product should have been inserted');
    }

    @isTest
    static void testDeleteProductRecord() {
        Product2 testProduct = new Product2(Name = 'Test Product', Member_Limit__c=5);
        insert testProduct;

        Test.startTest();
        Id productId = ProductManagementController.deleteProductRecord(testProduct.Id);
        Test.stopTest();

        System.assertEquals(testProduct.Id, productId, 'Product should have been deleted');
    }
}