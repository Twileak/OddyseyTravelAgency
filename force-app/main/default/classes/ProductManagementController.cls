public with sharing class ProductManagementController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [SELECT Id, Name, Cities__c, Accommodation__c, Duration__c, Start_Date__c, End_Date__c FROM Product2];
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
    public static List<Product2> deleteProduct(Id productId) {
        delete new Product2(Id = productId);
        return getProducts();
    }
}