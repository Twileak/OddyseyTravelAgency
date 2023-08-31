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

    @AuraEnabled(Cacheable=true)
    public static Decimal getLowestPrice(){
        return DiscountManagerHandler.getLowestPrice();
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getSelectedProductsByCategory(List<String> categoryIds) {
        return DiscountManagerHandler.getSelectedProductsByCategory(categoryIds);
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getSelectedProductsById(List<String> listOfIds){
        return DiscountManagerHandler.getSelectedProductsById(listOfIds);
    }

    @AuraEnabled(Cacheable=true)
    public static void createPromotionJob(String stringPromotion) {
        DiscountManagerHandler.createPromotionJob(stringPromotion);
    }
}