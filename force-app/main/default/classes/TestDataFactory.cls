@IsTest
public with sharing class TestDataFactory {
    private static ProductBuilder createProduct(){
       return new ProductBuilder();
    }
    public static List<Product2> createProducts(Integer count) {
        List<Product2> products = new List<Product2>();

        for(Integer i=0; i<count; i++) {
            Product2 product = createProduct()
                    .setName('Test product' + i)
                    .setMemberLimit(5 + i)
                    .setIsAllInclusive(false)
                    .build();

            products.add(product);
        }

        return products;
    }

    private static ReviewBuilder createReview(){
        return new ReviewBuilder();
    }

    public static List<Review__c> createReviews(Integer count, String productId) {
        List<Review__c> reviews = new List<Review__c>();

        for(Integer i=0; i<count; i++) {
            Review__c review = createReview()
                    .setProduct(productId)
                    .setComment('Test comment' + i)
                    .setAuthor('Test Author' + i)
                    .setRating(3)
                    .build();

            reviews.add(review);
        }

        return reviews;
    }
}