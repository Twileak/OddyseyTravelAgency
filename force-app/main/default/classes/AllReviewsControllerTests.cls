@isTest
private class AllReviewsControllerTests {

    @isTest
    static void testGetReviews() {
        Product2 testProduct = new Product2(Name = 'Test Product', Member_Limit__c=5);
        insert testProduct;

        Review__c review1 = new Review__c(
                Product__c = testProduct.Id,
                Author__c = 'John Doe',
                Comment__c = 'Great product!',
                Rating__c = 5,
                Created_At__c = System.today().addDays(-1),
                Approval_Status__c = 'Approved'
        );
        Review__c review2 = new Review__c(
                Product__c = testProduct.Id,
                Author__c = 'Jane Smith',
                Comment__c = 'Could be better.',
                Rating__c = 3,
                Created_At__c = System.today().addDays(-1),
                Approval_Status__c = 'Approved'
        );
        insert new List<Review__c>{review1, review2};

        List<Review__c> reviews = AllReviewsController.getReviews(testProduct.Id);

        System.assertEquals(2, reviews.size(), 'Incorrect number of reviews');
        System.assertEquals('John Doe', reviews[0].Author__c, 'Incorrect author for review 1');
        System.assertEquals('Great product!', reviews[0].Comment__c, 'Incorrect comment for review 1');
        System.assertEquals(5, reviews[0].Rating__c, 'Incorrect rating for review 1');

        System.assertEquals('Jane Smith', reviews[1].Author__c, 'Incorrect author for review 2');
        System.assertEquals('Could be better.', reviews[1].Comment__c, 'Incorrect comment for review 2');
        System.assertEquals(3, reviews[1].Rating__c, 'Incorrect rating for review 2');
    }
}