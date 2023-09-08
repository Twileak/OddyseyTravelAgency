public with sharing class AllReviewsController {
    @AuraEnabled(Cacheable=true)
    public static List<Review__c> getReviews(Id productId) {
        return [
                SELECT Id, Author__c, Comment__c, Rating__c, Created_At__c
                FROM Review__c
                WHERE Product__c = :productId
                ORDER BY Created_At__c DESC
        ];
    }
}