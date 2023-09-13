@IsTest
public class StoreCurrencyUpdateTest{
    @IsTest
    static void testTriggerPLN() {
        WebStore testWebStore = new WebStore(Name = 'Test WebStore', CurrencyIsoCode = 'USD');
        insert testWebStore;

        Edit_Default_Currency__e testEvent = new Edit_Default_Currency__e(
                Store_Id__c = testWebStore.Id,
                NewCurrency__c = 'PLN'
        );

        Test.startTest();
        EventBus.publish(testEvent);
        WebStore updatedWebStore = [SELECT CurrencyIsoCode FROM WebStore WHERE Id = :testWebStore.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals('USD', updatedWebStore.CurrencyIsoCode);
    }

    @IsTest
    static void testTriggerUSD() {
        WebStore testWebStore = new WebStore(Name = 'Test WebStore', CurrencyIsoCode = 'USD');
        insert testWebStore;

        Edit_Default_Currency__e testEvent = new Edit_Default_Currency__e(
                Store_Id__c = testWebStore.Id,
                NewCurrency__c = 'USD'
        );

        Test.startTest();
        EventBus.publish(testEvent);
        WebStore updatedWebStore = [SELECT CurrencyIsoCode FROM WebStore WHERE Id = :testWebStore.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals('USD', updatedWebStore.CurrencyIsoCode);
    }

    @IsTest
    static void testTriggerOtherCurrency() {
        WebStore testWebStore = new WebStore(Name = 'Test WebStore', CurrencyIsoCode = 'USD');
        insert testWebStore;

        Edit_Default_Currency__e testEvent = new Edit_Default_Currency__e(
                Store_Id__c = testWebStore.Id,
                NewCurrency__c = 'GBP'
        );

        Test.startTest();
        EventBus.publish(testEvent);
        WebStore updatedWebStore = [SELECT CurrencyIsoCode FROM WebStore WHERE Id = :testWebStore.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals('USD', updatedWebStore.CurrencyIsoCode);
    }
}