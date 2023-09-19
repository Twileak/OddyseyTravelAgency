/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class ProductComparerHandler {
    public static List<Product2> getProductNames() {
        return [
                SELECT Id, Name
                FROM Product2
        ];
    }
    public static Product2 getProductDetails(String productId) {
        return [
                SELECT Id, Name, Summary__c, Accommodation__c, Cities__c, Continent__c, Current_Members__c,
                        Is_All_Inclusive__c, Spots_Left__c, Trip_Start_End__c, Transportation__c, Duration__c
                FROM Product2
                WHERE Id = :productId
        ];
    }
    public static Map<String, Object> getReviewDetails(String productId){
        Map<String, Object> resultMap = new Map<String, Object>();

        List<AggregateResult> results =  [
                SELECT COUNT(Rating__c) Votes, AVG(Rating__c) Average
                FROM Review__c
                WHERE Product__c = :productId
        ];

        if (!(results.size() == 0)) {
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
    public static PricebookEntry getProductPrice(String productId){
        String defaultCurrency = [
                SELECT CurrencyIsoCode
                FROM WebStore
                WHERE Name = 'Oddysey'
                LIMIT 1
        ].CurrencyIsoCode;

        return [
                SELECT UnitPrice
                FROM PricebookEntry
                WHERE Product2Id = :productId AND
                CurrencyIsoCode = :defaultCurrency AND
                Pricebook2Id IN  (SELECT Id
                                FROM Pricebook2
                                WHERE Name LIKE '%Odyssey%')
        ];
    }
}