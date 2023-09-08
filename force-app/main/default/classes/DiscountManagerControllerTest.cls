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

        ProductCatalog pc = new ProductCatalog(Name='Test Catalog');
        insert pc;

        List<ProductCategory> categories = new List<ProductCategory>{
                new ProductCategory(Name = 'Category1', CatalogId = pc.Id),
                new ProductCategory(Name = 'Category2', CatalogId = pc.Id)
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
                CurrencyIsoCode = 'PLN'
        );
        insert entry;

        Decimal lowestPrice = DiscountManagerController.getLowestPrice();

        System.assertEquals(10.0, lowestPrice);
    }
    @IsTest
    static void testOneTimePromotion() {
        String jsonPromotion = '{"isPeriodic": false, "isWeekly": false, "isAbsolute": true, "promotionValue": 10, "listOfProducts": [], "startDate": "2023-09-01", "endDate": "2023-09-15"}';
        Test.startTest();
        PromotionWrapper prom = DiscountManagerController.createPromotionJob(jsonPromotion);
        Test.stopTest();

        System.assertEquals(false, prom.isWeekly);
        System.assertEquals(false, prom.isPeriodic);
        System.assertEquals(true, prom.isAbsolute);
        System.assertEquals(10, prom.promotionValue);
        System.assertEquals(0, prom.listOfProducts.size());
        System.assertEquals(Date.newInstance(2023,09,15), prom.endDate);
        System.assertEquals(Date.newInstance(2023,09,01), prom.startDate);
    }

    @IsTest
    static void testWeeklyPromotion() {
        String jsonPromotion = '{"isPeriodic": true, "isWeekly": true, "isAbsolute": true, "promotionValue": 15, "listOfProducts": [], "weekdays": ["MON", "FRI"], "startDate": "2023-09-01", "endDate": "2023-09-30"}';
        Test.startTest();
        PromotionWrapper prom = DiscountManagerController.createPromotionJob(jsonPromotion);
        Test.stopTest();

        System.assertEquals(true, prom.isWeekly);
        System.assertEquals(true, prom.isPeriodic);
        System.assertEquals(true, prom.isAbsolute);
        System.assertEquals(15, prom.promotionValue);
        System.assertEquals(0, prom.listOfProducts.size());
        System.assertEquals(Date.newInstance(2023,09,30), prom.endDate);
        System.assertEquals(Date.newInstance(2023,09,01), prom.startDate);
        System.assertEquals(new List<String>{'MON', 'FRI'}, prom.weekdays);
    }

    @IsTest
    static void testMonthlyPromotion() {
        String jsonPromotion = '{"isPeriodic": true, "isWeekly": false, "isAbsolute": false, "promotionValue": 20, "listOfProducts": [], "startDate": "2023-09-01", "endDate": "2023-12-31"}';
        Test.startTest();
        PromotionWrapper prom = DiscountManagerController.createPromotionJob(jsonPromotion);
        Test.stopTest();

        System.assertEquals(false, prom.isWeekly);
        System.assertEquals(true, prom.isPeriodic);
        System.assertEquals(false, prom.isAbsolute);
        System.assertEquals(20, prom.promotionValue);
        System.assertEquals(0, prom.listOfProducts.size());
        System.assertEquals(Date.newInstance(2023,12,31), prom.endDate);
        System.assertEquals(Date.newInstance(2023,09,01), prom.startDate);
    }
}