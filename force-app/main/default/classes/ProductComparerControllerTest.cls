@IsTest
private class ProductComparerControllerTest {
    @IsTest
    static void testGetProductNames() {
        List<Product2> products = TestDataFactory.createProducts(2);

        insert products;

        Test.startTest();
        List<Product2> results = productComparerController.getProductNames();
        Test.stopTest();

        System.assertEquals(products.size(), results.size());
    }
    @IsTest
    static void testGetProductDetails() {
        Product2 testProduct = TestDataFactory.createProducts(1)[0];
        insert testProduct;

        Test.startTest();
        Product2 result = productComparerController.getProductDetails(testProduct.Id);
        Test.stopTest();

        System.assertEquals(testProduct.Name, result.Name);
        System.assertEquals(testProduct.Summary__c, result.Summary__c);
    }
    @IsTest
    static void testGetReviewDetails() {
        Product2 testProduct = TestDataFactory.createProducts(1)[0];
        insert testProduct;

        Review__c testReview = TestDataFactory.createReviews(1, testProduct.Id)[0];
        insert testReview;

        Test.startTest();
        Map<String, Object> resultMap = productComparerController.getReviewDetails(testProduct.Id);
        Test.stopTest();

        System.assertEquals(1, resultMap.get('Votes'));
        System.assertEquals(3.00, resultMap.get('Average'));
    }
}