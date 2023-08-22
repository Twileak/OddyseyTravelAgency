/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class DiscountManagerController {
    @AuraEnabled(Cacheable=true)
    public static List<Product2> getProducts() {
        return DiscountManagerHandler.getProducts();
    }

    @AuraEnabled(Cacheable=true)
    public static List<ProductCategory> getCategories(){
        return DiscountManagerHandler.getCategories();
    }
}