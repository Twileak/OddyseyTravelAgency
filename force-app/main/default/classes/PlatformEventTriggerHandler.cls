/**
 * Created by dawid.zamojda on 19.09.2023.
 */

public with sharing class PlatformEventTriggerHandler implements ITriggerHandler{
    public static Boolean isFromTrigger = false;

    public void bulkBefore() {
    }

    public void bulkAfter() {
    }

    public void beforeInsert(List<Edit_Default_Currency__e> newItems) {

    }

    public void beforeUpdate(Map<Id, SObject> newRecord, Map<Id, SObject> oldItems) {
    }

    public void beforeDelete(Map<Id, SObject> newRecord) {
    }

    public void afterInsert(Map<Id, SObject> newRecord) {
        Set<Id> storeIds = new Set<Id>();

        Map<Id, String> storeIdToNewCurrencyMap = new Map<Id, String>();

        WebStore store = [
                SELECT Name, SupportedCurrencies
                FROM WebStore
                WHERE Name = 'Oddysey'];

        List<String> supportedCurrencies = store.SupportedCurrencies.split(';');

        for (Edit_Default_Currency__e event : (List<Edit_Default_Currency__e>)newRecord.values()) {
            if (supportedCurrencies.contains(event.NewCurrency__c)) {
                storeIds.add(event.Store_Id__c);
                storeIdToNewCurrencyMap.put(event.Store_Id__c, event.NewCurrency__c);
            }
        }

        Map<Id, WebStore> webStoresMap = new Map<Id, WebStore>([
                SELECT Id, Name, CurrencyIsoCode
                FROM WebStore
                WHERE Id IN :storeIds
        ]);

        List<WebStore> webStoresToUpdate = new List<WebStore>();
        for (Id storeId : storeIds) {
            if (webStoresMap.containsKey(storeId)) {
                WebStore webStore = webStoresMap.get(storeId);
                webStore.CurrencyIsoCode = storeIdToNewCurrencyMap.get(storeId);
                webStoresToUpdate.add(webStore);
            }
        }

        if (!webStoresToUpdate.isEmpty()) {
            update webStoresToUpdate;
        }
    }

    public void afterUpdate(Map<Id, SObject> newRecord, Map<Id, SObject> oldRecord) {
    }

    public void afterDelete(Map<Id, SObject> oldRecord) {
    }

    public void afterUndelete(Map<Id, SObject> oldRecord) {
    }

    public void andFinally() {
    }
}