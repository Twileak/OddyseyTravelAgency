public with sharing class productComparerController {
    @AuraEnabled(Cacheable=true)
    public static List<Product2> getProductNames() {
        return [
                SELECT Id, Name
                FROM Product2
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static Product2 getProductDetails(String productId) {
        return [
                SELECT Id, Name, Summary__c, Accommodation__c, Cities__c, Continent__c, Current_Members__c,
                        Is_All_Inclusive__c, Spots_Left__c, Trip_Start_End__c, Transportation__c, Duration__c
                FROM Product2
                WHERE Id = :productId
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getReviewDetails(String productId){
        Map<String, Object> resultMap = new Map<String, Object>();

        List<AggregateResult> results =  [
          SELECT COUNT(Rating__c) Votes, AVG(Rating__c) Average
          FROM Review__c
          WHERE Product__c = :productId
        ];

        if (!results.isEmpty()) {
            AggregateResult result = results[0];

            Integer votes = (Integer) result.get('Votes');
            Decimal average = (Decimal) result.get('Average');

            resultMap.put('Votes', votes != null ? votes : 0);
            resultMap.put('Average', average != null ? average.setScale(2) : 0.00);
        } else {
            resultMap.put('Votes', 0);
            resultMap.put('Average', 0.00);
        }
        return resultMap;
    }
    @AuraEnabled(Cacheable=true)
    public static PricebookEntry getProductPrice(String productId){
        return [
                SELECT UnitPrice
                FROM PricebookEntry
                WHERE Product2Id = :productId AND Pricebook2Id = '01s06000006AF0WAAW'
        ];
    }
}