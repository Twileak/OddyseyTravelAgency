/**
 * Created by dawid.zamojda on 06.09.2023.
 */

public without sharing class CurrencyPickerHandler {

    public static String selectCurrentCurrency() {
        WebStore store = [
                SELECT Id, CurrencyIsoCode, SupportedCurrencies, Name
                FROM WebStore
                WHERE Name = 'Oddysey'
                LIMIT 1];
        return store.CurrencyIsoCode;
    }

    public static void updateCurrency(String cur) {
        WebStore store = [
                SELECT Id,Name
                FROM WebStore
                WHERE Name = 'Oddysey'
                LIMIT 1];
        try{
            Edit_Default_Currency__e event = new Edit_Default_Currency__e();
            event.NewCurrency__c = cur;
            event.Store_Id__c = store.Id;
            EventBus.publish(event);
        }catch(Exception e){
            throw new AuraHandledException('An error occurred while updating the currency: ' + e.getMessage());
        }
    }
}