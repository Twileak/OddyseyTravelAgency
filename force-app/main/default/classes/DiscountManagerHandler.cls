/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class DiscountManagerHandler {
    public static List<Product2> getProducts() {
        return [
                SELECT Id, Name
                FROM Product2
        ];
    }

    public static List<ProductCategory> getCategories() {
        return [
                SELECT Id, Name
                FROM ProductCategory
        ];
    }

    public static List<Product2> getSelectedProductsById(List<String> listOfIds) {
        return [
                SELECT Id, Name
                FROM Product2
                WHERE Id IN :listOfIds
        ];
    }

    public static List<Product2> getSelectedProductsByCategory(List<String> categoryIds){
        return [
                SELECT Id, Name
                FROM Product2
                WHERE Id IN (
                        SELECT ProductId
                        FROM ProductCategoryProduct
                        WHERE ProductCategoryId IN :categoryIds)
        ];
    }

    public static Decimal getLowestPrice() {
        List<AggregateResult> cheapestProduct = [
                SELECT MIN(UnitPrice) lowestPrice
                FROM PricebookEntry
        ];
        return (Decimal)cheapestProduct[0].get('lowestPrice');
    }

    public static PromotionWrapper createPromotionJob(String stringPromotion) {
        PromotionWrapper promotion = (PromotionWrapper) JSON.deserialize(stringPromotion, PromotionWrapper.class);
        String jobNameStart = '';
        String cronExpressionStart = '';
        String jobNameEnd = '';
        String cronExpressionEnd = '';
        DiscountManagerScheduler jobToScheduleStart = new DiscountManagerScheduler(promotion.isAbsolute, promotion.promotionValue, promotion.listOfProducts);
        DiscountManagerReturnScheduler jobToScheduleEnd = new DiscountManagerReturnScheduler(promotion.listOfProducts);

        if(!promotion.isPeriodic){
            jobNameStart = 'Start_Of_One_Time_Promotion';
            cronExpressionStart = '0 0 0 ' + promotion.startDate.day() + ' ' + promotion.startDate.month() + ' ? ' + promotion.startDate.year();

            jobNameEnd = 'End_Of_One_Time_Promotion';
            cronExpressionEnd = '0 0 0 ' + promotion.endDate.day() + ' ' + promotion.endDate.month() + ' ? ' + promotion.endDate.year();
        } else if(promotion.isWeekly){
            String weekdays = String.join(promotion.weekdays, ',');

            jobNameStart = 'Start_Of_Weekly_Promotion';
            cronExpressionStart = '0 0 0 ? * ' + weekdays + ' *';

            jobNameEnd = 'End_Of_Weekly_Promotion';
            cronExpressionEnd = '0 59 23 ? * ' + weekdays + ' *';
        } else {
            jobNameStart = 'Start_Of_Monthly_Promotion';
            cronExpressionStart = '0 0 0 ' + promotion.startDate.day() + ' 1/1 ? *';

            jobNameEnd = 'End_Of_Monthly_Promotion';
            cronExpressionEnd = '0 0 0 ' + promotion.endDate.day() + ' 1/1 ? *';
        }

        if(!Test.isRunningTest()) {
            System.schedule(jobNameStart, cronExpressionStart, jobToScheduleStart);
            System.schedule(jobNameEnd, cronExpressionEnd, jobToScheduleEnd);
        }


        return promotion;
    }

    public class DiscountManagerScheduler implements Schedulable{
        public Boolean isAbsolute {get; set;}
        public Decimal discount {get; set;}
        public List<String> listOfIds {get; set;}

        public DiscountManagerScheduler(){
            this.isAbsolute = true;
            this.discount = 0;
            this.listOfIds = new List<String>();
        }

        public DiscountManagerScheduler(Boolean isAbsolute, Decimal discount, List<String> listOfIds){
            this.isAbsolute = isAbsolute;
            this.discount = discount;
            this.listOfIds = listOfIds;
        }
        public void execute(SchedulableContext SC) {
            String defaultCurrency = [
                    SELECT CurrencyIsoCode
                    FROM WebStore
                    WHERE Name = 'Oddysey'
                    LIMIT 1
            ].CurrencyIsoCode;

            Map<Id, PricebookEntry> newPricesMap = new Map<Id, PricebookEntry>([
                    SELECT Id, UnitPrice
                    FROM PricebookEntry
                    WHERE Product2Id IN :this.listOfIds AND
                    CurrencyIsoCode = :defaultCurrency AND
                    Pricebook2Id IN (SELECT Id
                                    FROM Pricebook2
                                    WHERE Name LIKE '%Odyssey%')
            ]);

            if(this.isAbsolute){
                for (Id entryId : newPricesMap.keySet()) {
                    PricebookEntry entry = newPricesMap.get(entryId);
                    Decimal newUnitPrice = entry.UnitPrice - this.discount;
                    entry.UnitPrice = newUnitPrice;
                }
            } else {
                for (Id entryId : newPricesMap.keySet()) {
                    PricebookEntry entry = newPricesMap.get(entryId);
                    Decimal newUnitPrice = entry.UnitPrice*this.discount;
                    entry.UnitPrice = newUnitPrice;
                }
            }
        }
    }

    public class DiscountManagerReturnScheduler implements Schedulable{
        public List<String> listOfIds {get; set;}

        public DiscountManagerReturnScheduler(){
            this.listOfIds = new List<String>();
        }

        public DiscountManagerReturnScheduler(List<String> listOfIds){
            this.listOfIds = listOfIds;
        }
        public void execute(SchedulableContext SC) {
            String defaultCurrency = [
                    SELECT CurrencyIsoCode
                    FROM WebStore
                    WHERE Name = 'Oddysey'
                    LIMIT 1
            ].CurrencyIsoCode;

            Map<Id, PricebookEntry> standardPricesMap = new Map<Id, PricebookEntry>([
                    SELECT Id, UnitPrice
                    FROM PricebookEntry
                    WHERE Product2Id IN :this.listOfIds AND
                    CurrencyIsoCode = :defaultCurrency AND
                    Pricebook2Id IN (SELECT Id
                                    FROM Pricebook2
                                    WHERE IsActive = TRUE)
            ]);
            Map<Id, PricebookEntry> newPricesMap = new Map<Id, PricebookEntry>([
                    SELECT Id, UnitPrice
                    FROM PricebookEntry
                    WHERE Product2Id IN :this.listOfIds AND
                    CurrencyIsoCode = :defaultCurrency AND
                    Pricebook2Id IN (SELECT Id
                                    FROM Pricebook2
                                    WHERE Name LIKE '%Odyssey%')
            ]);

            for (Id entryId : newPricesMap.keySet()) {
                PricebookEntry entry = newPricesMap.get(entryId);
                PricebookEntry standardEntry = standardPricesMap.get(entryId);
                Decimal newUnitPrice = standardEntry.UnitPrice;
                entry.UnitPrice = newUnitPrice;
            }
        }
    }
}