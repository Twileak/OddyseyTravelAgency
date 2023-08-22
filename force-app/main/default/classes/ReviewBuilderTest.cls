@isTest
public class ReviewBuilderTest {
    @isTest
    public static void testReviewBuilder() {
        String testAuthor = 'John Doe';
        String testComment = 'Great product!';
        Integer testRating = 5;
        Date testCreatedAt = Date.newInstance(2023, 8, 1);
        Product2 testProduct = TestDataFactory.CreateProducts(1)[0];
        String testProductId = testProduct.Id;

        Review__c review = new ReviewBuilder()
                .setAuthor(testAuthor)
                .setComment(testComment)
                .setRating(testRating)
                .setCreatedAt(testCreatedAt)
                .setProduct(testProductId)
                .build();

        System.assertEquals(testAuthor, review.Author__c);
        System.assertEquals(testComment, review.Comment__c);
        System.assertEquals(testRating, review.Rating__c);
        System.assertEquals(testCreatedAt, review.Created_At__c);
        System.assertEquals(testProductId, review.Product__c);
    }
}