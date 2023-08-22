/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class ReviewBuilder {
    private String author;
    private String comment;
    private Date createdAt;
    private Integer rating;
    private String product;
    public ReviewBuilder() {}
    public ReviewBuilder setAuthor(String author) {
        this.author = author;
        return this;
    }
    public ReviewBuilder setRating(Integer rating) {
        this.rating = rating;
        return this;
    }
    public ReviewBuilder setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
        return this;
    }
    public ReviewBuilder setComment(String comment) {
        this.comment = comment;
        return this;
    }
    public ReviewBuilder setProduct(String product) {
        this.product = product;
        return this;
    }
    public Review__c build() {
        Review__c review = new Review__c();
        review.Author__c = author;
        review.Rating__c = rating;
        review.Created_At__c = createdAt;
        review.Comment__c = comment;
        review.Product__c = product;

        return review;
    }
}