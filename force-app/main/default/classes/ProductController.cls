/**
 * Created by dawid.zamojda on 11.07.2023.
 */

public with sharing class ProductController {
    public ProductController(){

    }

    @AuraEnabled(cacheable=true)
    public static String getAllProducts(){
        List<Product2> listOfProducts = [SELECT Name, Transportation__c, Description, Duration__c, Accommodation__c, Cities__c, Is_All_Inclusive__c, Continent__c, Start_Date__c, End_Date__c, Member_Limit__c, Current_Members__c, Summary__c
                                        FROM Product2];
        List<ProductWrapper> wrappedProducts =  new List<ProductWrapper>();

        for(Product2 prod : listOfProducts){
            ProductWrapper product = new ProductWrapper(prod);
            System.debug(JSON.serialize(product));
            wrappedProducts.add(product);
        }
        System.debug(JSON.serialize(wrappedProducts));
        return JSON.serialize(wrappedProducts);
    }
}