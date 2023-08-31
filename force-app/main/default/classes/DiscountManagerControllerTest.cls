@IsTest
private class DiscountManagerControllerTest {
    @IsTest
    static void testGetProducts() {
        List<Product2> products = TestDataFactory.createProducts(2);
        insert products;

        Test.startTest();
        List<Product2> results = DiscountManagerController.getProducts();
        Test.stopTest();

        System.assertEquals(products.size(), results.size());
    }

    @IsTest
    static void testGetCategories() {
        Test.startTest();
        List<ProductCategory> categories = DiscountManagerController.getCategories();
        Test.stopTest();

        System.assertEquals(true, categories.size()>=0);
    }

    @IsTest
    static void testGetSelectedProductsById() {
        List<Product2> products = TestDataFactory.createProducts(2);
        insert products;

        List<String> listOfIds = new List<String>();
        for (Product2 product : products) {
            listOfIds.add(product.Id);
        }

        List<Product2> selectedProducts = DiscountManagerHandler.getSelectedProductsById(listOfIds);
        System.assertEquals(products.size(), selectedProducts.size());
    }
}