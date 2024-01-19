/**
 * Created by dawid.zamojda on 22.09.2023.
 */

public with sharing class CommentsController {
    @AuraEnabled(Cacheable=true)
    public static Review__c getComment(String user, Id productId){
        Review__c review = [
                SELECT Id, Name, Author__c, Product__c, Comment__c, Rating__c, Approval_Status__c
                FROM Review__c
                WHERE Author__c = :user AND
                    Product__c = :productId AND
                    Approval_Status__c = 'Approved'
                LIMIT 1
        ];
        return review;
    }

    @AuraEnabled
    public static String deleteReview(String recordId, String author){
        Review__c review = [
                SELECT Id, Comment__c, Rating__c, Approval_Status__c
                FROM Review__c
                WHERE Product__c = :recordId
                AND Author__c = :author
                AND Approval_Status__c = 'Approved'
                LIMIT 1
        ];
        delete review;
        return review.Id;
    }
}