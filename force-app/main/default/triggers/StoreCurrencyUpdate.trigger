trigger StoreCurrencyUpdate on Edit_Default_Currency__e (after insert) {

    Set<Id> storeIds = new Set<Id>();

    Map<Id, String> storeIdToNewCurrencyMap = new Map<Id, String>();

    for (Edit_Default_Currency__e event : Trigger.new) {
        if (event.NewCurrency__c == 'PLN' || event.NewCurrency__c == 'USD') {
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