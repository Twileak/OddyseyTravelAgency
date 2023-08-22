@isTest
private class ProductBuilderTest {
    @isTest
    static void testProductBuilder() {
        Product2 product = new ProductBuilder()
                .setAccommodation('Resort')
                .setCities('New York,Los Angeles')
                .setContinent('North America')
                .setCurrentMembers(5)
                .setStartDate(Date.newInstance(2023, 9, 1))
                .setEndDate(Date.newInstance(2023, 9, 10))
                .setIsAllInclusive(true)
                .setMemberLimit(20)
                .setTransportation('Airplane')
                .setName('Vacation Trip')
                .setSummary('Amazing vacation')
                .setDuration(10)
                .build();

        System.assertEquals('Vacation Trip', product.Name);
        System.assertEquals('Resort', product.Accommodation__c);
        System.assertEquals('New York,Los Angeles', product.Cities__c);
        System.assertEquals('North America', product.Continent__c);
        System.assertEquals(5, product.Current_Members__c);
        System.assertEquals(Date.newInstance(2023, 9, 1), product.Start_Date__c);
        System.assertEquals(Date.newInstance(2023, 9, 10), product.End_Date__c);
        System.assertEquals(true, product.Is_All_Inclusive__c);
        System.assertEquals(20, product.Member_Limit__c);
        System.assertEquals('Airplane', product.Transportation__c);
        System.assertEquals('Amazing vacation', product.Summary__c);
        System.assertEquals(10, product.Duration__c);
    }
}