/**
 * Created by dawid.zamojda on 13.09.2023.
 */

trigger StoreCurrencyUpdate on Edit_Default_Currency__e (after insert) {

    List<WebStore> webStoresToUpdate = new List<WebStore>();

    for (Edit_Default_Currency__e event : Trigger.New){
        if(event.NewCurrency__c == 'PLN' || event.NewCurrency__c == 'USD'){
            WebStore webStore = [
                    SELECT Id, Name, CurrencyIsoCode
                    FROM WebStore
                    WHERE Id = :event.Store_Id__c
                    LIMIT 1];
            webStore.CurrencyIsoCode = event.NewCurrency__c;

            webStoresToUpdate.add(webStore);
        }
    }

    update webStoresToUpdate;
}