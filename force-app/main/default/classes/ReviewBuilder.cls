/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class ReviewBuilder {
    private Review__c review;
    public ReviewBuilder() {
        review = new Review__c(
                Author__c = 'Test Author',
                Rating__c = 3,
                Approval_Status__c = 'Approved'
        );
    }
    public ReviewBuilder setAuthor(String author) {
        review.Author__c = author;
        return this;
    }
    public ReviewBuilder setRating(Integer rating) {
        review.Rating__c = rating;
        return this;
    }
    public ReviewBuilder setCreatedAt(Date createdAt) {
        review.Created_At__c = createdAt;
        return this;
    }
    public ReviewBuilder setComment(String comment) {
        review.Comment__c = comment;
        return this;
    }
    public ReviewBuilder setProduct(String product) {
        review.Product__c = product;
        return this;
    }
    public Review__c build() {
        return review;
    }

    public Review__c buildAndSave() {
        insert review;
        return review;
    }
}