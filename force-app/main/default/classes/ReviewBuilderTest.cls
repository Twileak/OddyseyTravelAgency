@isTest
public class ReviewBuilderTest {
    @IsTest
    public static void testReviewBuilderBuild() {
        Product2 testProduct = TestDataFactory.CreateProducts(1)[0];
        String testProductId = testProduct.Id;

        Review__c review = new ReviewBuilder()
                .setAuthor('John Doe')
                .setRating(5)
                .setCreatedAt(Date.newInstance(2023, 8, 20))
                .setComment('Excellent product!')
                .setProduct(testProductId)
                .build();

        System.assertEquals('John Doe', review.Author__c);
        System.assertEquals(5, review.Rating__c);
        System.assertEquals(Date.newInstance(2023, 8, 20), review.Created_At__c);
        System.assertEquals('Excellent product!', review.Comment__c);
        System.assertEquals(testProductId, review.Product__c);
    }

    @IsTest
    public static void testReviewBuilderBuildAndSave(){
        Product2 testProduct = TestDataFactory.CreateProducts(1)[0];
        String testProductId = testProduct.Id;

        Review__c review = new ReviewBuilder()
                .setAuthor('John Doe')
                .setRating(5)
                .setCreatedAt(Date.newInstance(2023, 8, 20))
                .setComment('Excellent product!')
                .setProduct(testProductId)
                .buildAndSave();

        System.assertNotEquals(null, review.Id);
    }
}