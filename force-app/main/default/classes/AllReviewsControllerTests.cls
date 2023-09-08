@IsTest
private class AllReviewsControllerTests {

    @IsTest
    static void testGetReviews() {
        Product2 testProduct = TestDataFactory.createProducts(1)[0];
        insert testProduct;

        List<Review__c> testReviews = TestDataFactory.createReviews(2, testProduct.Id);
        System.debug(testReviews);

        insert testReviews;

        List<Review__c> reviews = AllReviewsController.getReviews(testProduct.Id);
        System.debug(reviews);

        System.assertEquals(2, reviews.size(), 'Incorrect number of reviews');
        System.assertEquals('Test Author0', reviews[0].Author__c, 'Incorrect author for review 1');
        System.assertEquals(3, reviews[0].Rating__c, 'Incorrect rating for review 1');

        System.assertEquals('Test Author1', reviews[1].Author__c, 'Incorrect author for review 2');
        System.assertEquals(3, reviews[1].Rating__c, 'Incorrect rating for review 2');
    }

    @IsTest
    static void testGetReviewsWithNoReviews() {
        Product2 testProduct1 = TestDataFactory.createProducts(1)[0];
        insert testProduct1;

        Product2 testProduct2 = TestDataFactory.createProducts(1)[0];
        insert testProduct2;

        List<Review__c> testReviews = TestDataFactory.createReviews(2, testProduct1.Id);

        insert testReviews;

        List<Review__c> reviews = AllReviewsController.getReviews(testProduct2.Id);
        System.debug(reviews);

        System.assertEquals(0, reviews.size(), 'Incorrect number of reviews');
    }
}