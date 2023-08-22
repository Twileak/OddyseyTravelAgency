/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class ReviewBuilder {
    private String author;
    private String comment;
    private Date createdAt;
    private Integer rating;
    private String product;
    public ReviewBuilder() {
        this.author = 'Test Author';
        this.comment = 'Test Comment';
        this.createdAt = Date.NewInstance(2023, 8, 22);
        this.rating = 3;
        this.product = '';
    }
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
        return new Review__c(
                Author__c = this.author,
                Rating__c = this.rating,
                Created_At__c = this.createdAt,
                Comment__c = this.comment,
                Product__c = this.product
        );
    }
}