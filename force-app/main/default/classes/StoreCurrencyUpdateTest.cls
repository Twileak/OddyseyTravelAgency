@IsTest
public class StoreCurrencyUpdateTest{
    @IsTest
    static void testTriggerWhenStoreIsChangedToUSD() {
        WebStore testWebStore = new WebStore(Name = 'Oddysey', CurrencyIsoCode = 'PLN', SupportedCurrencies ='USD;PLN');
        insert testWebStore;

        Test.startTest();
        Edit_Default_Currency__e testEvent = new Edit_Default_Currency__e();
        testEvent.Store_Id__c = testWebStore.Id;
        testEvent.NewCurrency__c = 'USD';
        EventBus.publish(testEvent);
        Test.stopTest();

        WebStore updatedWebStore = [SELECT CurrencyIsoCode FROM WebStore WHERE Id = :testWebStore.Id LIMIT 1];
        System.assertEquals('USD', updatedWebStore.CurrencyIsoCode);
    }

    @IsTest
    static void testTriggerWhenStoreIsChangedToPLN() {
        WebStore testWebStore = new WebStore(Name = 'Oddysey', CurrencyIsoCode = 'USD', SupportedCurrencies = 'PLN;USD');
        insert testWebStore;



        Test.startTest();
        Edit_Default_Currency__e testEvent = new Edit_Default_Currency__e(
                Store_Id__c = testWebStore.Id,
                NewCurrency__c = 'PLN'
        );
        EventBus.publish(testEvent);
        Test.stopTest();

        WebStore updatedWebStore = [SELECT CurrencyIsoCode FROM WebStore WHERE Id = :testWebStore.Id LIMIT 1];
        System.assertEquals('PLN', updatedWebStore.CurrencyIsoCode);
    }

    @IsTest
    static void testTriggerWhenThereIsChangedToOtherCurrency() {
        WebStore testWebStore = new WebStore(Name = 'Test WebStore', CurrencyIsoCode = 'USD', SupportedCurrencies = 'PLN;USD');
        insert testWebStore;

        Test.startTest();
        Edit_Default_Currency__e testEvent = new Edit_Default_Currency__e(
                Store_Id__c = testWebStore.Id,
                NewCurrency__c = 'GBP'
        );
        EventBus.publish(testEvent);
        Test.stopTest();

        WebStore updatedWebStore = [SELECT CurrencyIsoCode FROM WebStore WHERE Id = :testWebStore.Id LIMIT 1];
        System.assertEquals('USD', updatedWebStore.CurrencyIsoCode);
    }
}