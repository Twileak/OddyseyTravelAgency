@IsTest
public class CurrencyPickerControllerTest {

    @IsTest
    static void testSelectCurrentCurrency() {
        WebStore testStore = new WebStore(Name = 'TestStore', CurrencyIsoCode = 'USD');
        insert testStore;

        Test.startTest();

        String currentCurrency = CurrencyPickerController.selectCurrentCurrency();

        System.assertEquals('USD', currentCurrency);

        Test.stopTest();
    }
}