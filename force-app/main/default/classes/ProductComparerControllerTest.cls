@isTest
private class ProductComparerControllerTest {

    @isTest
    static void testGetProductNames() {
        List<Product2> products = new List<Product2>{
                new Product2(Name = 'Product 1', Member_Limit__c = 10),
                new Product2(Name = 'Product 2', Member_Limit__c = 10)
        };
        insert products;

        Test.startTest();
        List<Product2> results = productComparerController.getProductNames();
        Test.stopTest();

        System.assertEquals(products.size(), results.size());
    }

    @isTest
    static void testGetProductDetails() {
        Product2 testProduct = new Product2(
                Name = 'Test Product',
                Summary__c = 'Product summary',
                Member_Limit__c =10
                );
        insert testProduct;

        Test.startTest();
        Product2 result = productComparerController.getProductDetails(testProduct.Id);
        Test.stopTest();

        System.assertEquals(testProduct.Name, result.Name);
        System.assertEquals(testProduct.Summary__c, result.Summary__c);
    }

    @isTest
    static void testGetReviewDetails() {
        Product2 testProduct = new Product2(Name = 'Test Product', Member_Limit__c=10);
        insert testProduct;

        Review__c testReview = new Review__c(Product__c = testProduct.Id, Rating__c = 4, Author__c = 'Dawid Żamojda');
        insert testReview;

        Test.startTest();
        Map<String, Object> resultMap = productComparerController.getReviewDetails(testProduct.Id);
        Test.stopTest();

        System.assertEquals(1, resultMap.get('Votes'));
        System.assertEquals(4.00, resultMap.get('Average'));
    }
}