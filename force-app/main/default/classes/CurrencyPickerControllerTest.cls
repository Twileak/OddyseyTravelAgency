@IsTest
public class CurrencyPickerControllerTest {

    @IsTest
    static void testSelectCurrentCurrency() {
        WebStore testStore = new WebStore(Name = 'Oddysey', CurrencyIsoCode = 'USD');
        insert testStore;

        Test.startTest();
            String currentCurrency = CurrencyPickerController.selectCurrentCurrency();
        Test.stopTest();

        System.assertEquals('USD', currentCurrency);
    }
}