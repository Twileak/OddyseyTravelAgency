public with sharing class ProductManagementController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [SELECT
                Id,
                Name,
                Cities__c,
                Accommodation__c,
                Duration__c,
                Start_Date__c,
                End_Date__c,
                Continent__c,
                Is_All_Inclusive__c,
                Transportation__c,
                Member_Limit__c,
                Current_Members__c,
                Summary__c,
                Description
        FROM Product2];
    }

    @AuraEnabled
    public static List<Product2> saveProduct(Product2 product) {
        if (product.Id != null) {
            update product;
        } else {
            insert product;
        }
        return getProducts();
    }

    @AuraEnabled
    public static Id deleteProductRecord(Id productId) {
        Id result = null;
        try {
            delete new Product2(Id = productId);
            result = productId;
        } catch (DmlException e) {
            result = null;
            throw new AuraHandledException('Error occured while deleting the record');

        }
        return result;
    }
}