public with sharing class productComparerController {
    @AuraEnabled(Cacheable=true)
    public static List<Product2> getProductNames() {
        return ProductComparerHandler.getProductNames();
    }
    @AuraEnabled(Cacheable=true)
    public static Product2 getProductDetails(String productId) {
        return ProductComparerHandler.getProductDetails(productId);
    }
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getReviewDetails(String productId){
       return ProductComparerHandler.getReviewDetails(productId);
    }
    @AuraEnabled(Cacheable=true)
    public static PricebookEntry getProductPrice(String productId){
        return ProductComparerHandler.getProductPrice(productId);
    }
}