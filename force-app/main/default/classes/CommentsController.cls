/**
 * Created by dawid.zamojda on 22.09.2023.
 */

public with sharing class CommentsController {
    @AuraEnabled(Cacheable=true)
    public static Review__c getComment(String user, Id productId){
        Review__c review = [
                SELECT Name, Author__c, Product__c, Comment__c, Rating__c, Approval_Status__c
                FROM Review__c
                WHERE Author__c = :user AND
                    Product__c = :productId AND
                    Approval_Status__c = 'Approved'
                LIMIT 1
        ];
        return review;
    }
}