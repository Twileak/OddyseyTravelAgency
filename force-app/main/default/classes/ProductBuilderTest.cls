/**
 * Created by dawid.zamojda on 22.08.2023.
 */

@isTest
public class ProductBuilderTest {
    @isTest
    public static void testProductBuilder() {
        String testName = 'Test Product';
        String testSummary = 'Test summary';
        String testAccommodation = 'Hotel';
        String testCities = 'City1, City2';
        String testContinent = 'North America';
        Integer testCurrentMembers = 50;
        Date testStartDate = Date.newInstance(2023, 8, 1);
        Date testEndDate = Date.newInstance(2023, 8, 15);
        Boolean testIsAllInclusive = true;
        Integer testMemberLimit = 100;
        String testTransportation = 'Flight';

        Product2 product = new ProductBuilder()
                .setName(testName)
                .setSummary(testSummary)
                .setAccommodation(testAccommodation)
                .setCities(testCities)
                .setContinent(testContinent)
                .setCurrentMembers(testCurrentMembers)
                .setStartDate(testStartDate)
                .setEndDate(testEndDate)
                .setIsAllInclusive(testIsAllInclusive)
                .setMemberLimit(testMemberLimit)
                .setTransportation(testTransportation)
                .build();

        System.assertEquals(testName, product.Name);
        System.assertEquals(testSummary, product.Summary__c);
        System.assertEquals(testAccommodation, product.Accommodation__c);
        System.assertEquals(testCities, product.Cities__c);
        System.assertEquals(testContinent, product.Continent__c);
        System.assertEquals(testCurrentMembers, product.Current_Members__c);
        System.assertEquals(testStartDate, product.Start_Date__c);
        System.assertEquals(testEndDate, product.End_Date__c);
        System.assertEquals(testIsAllInclusive, product.Is_All_Inclusive__c);
        System.assertEquals(testMemberLimit, product.Member_Limit__c);
        System.assertEquals(testTransportation, product.Transportation__c);
    }
}