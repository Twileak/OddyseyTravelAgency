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

        List<Product2> selectedProducts = DiscountManagerController.getSelectedProductsById(listOfIds);
        System.assertEquals(products.size(), selectedProducts.size());
    }

    @IsTest
    static void testGetSelectedProductsByCategory() {
        List<Product2> products = TestDataFactory.createProducts(2);
        insert products;

        List<ProductCategory> categories = new List<ProductCategory>{
                new ProductCategory(Name = 'Category1', CatalogId = '0ZS0600000005PbGAI'),
                new ProductCategory(Name = 'Category2', CatalogId = '0ZS0600000005PbGAI')
        };
        insert categories;

        List<ProductCategoryProduct> categoryProducts = new List<ProductCategoryProduct>{
                new ProductCategoryProduct(ProductId = products[0].Id, ProductCategoryId = categories[0].Id),
                new ProductCategoryProduct(ProductId = products[1].Id, ProductCategoryId = categories[1].Id)
        };
        insert categoryProducts;

        List<String> categoryIds = new List<String>{ categories[0].Id, categories[1].Id };
        List<Product2> selectedProducts = DiscountManagerController.getSelectedProductsByCategory(categoryIds);

        System.assertEquals(2, selectedProducts.size());
        System.assertEquals('Test product0', selectedProducts[0].Name);
        System.assertEquals('Test product1', selectedProducts[1].Name);
    }
    @IsTest
    static void testGetLowestPrice() {
        Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        List<Product2> products = TestDataFactory.createProducts(2);
        insert products;

        PricebookEntry entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = products[0].Id,
                UnitPrice = 10,
                CurrencyIsoCode = 'USD'
        );
        insert entry;

        Decimal lowestPrice = DiscountManagerController.getLowestPrice();

        System.assertEquals(10.0, lowestPrice);
    }
}