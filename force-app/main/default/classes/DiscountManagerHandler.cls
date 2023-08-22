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

    public static List<Product2> getSelectedProductsByCategory(String categoryName){
        ProductCategory category = [
                SELECT Id
                FROM ProductCategory
                WHERE Name = :categoryName
        ];
        String categoryId = category.Id;

        return [
                SELECT Id, Name
                FROM Product2
                WHERE Id IN (
                        SELECT ProductId
                        FROM ProductCategoryProduct
                        WHERE ProductCategoryId = :categoryId)
        ];
    }
}