public without sharing class CurrencyPickerController {

    @AuraEnabled(Cacheable=true)
    public static String selectCurrentCurrency() {
        return CurrencyPickerHandler.selectCurrentCurrency();
    }

    @AuraEnabled(Cacheable=true)
    public static String getSupportedCurrencies(){
        return CurrencyPickerHandler.getSupportedCurrencies();
    }

    @AuraEnabled
    public static void updateCurrency(String cur) {
        try {
            CurrencyPickerHandler.updateCurrency(cur);
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.Error_on_currency_update + e.getMessage());
        }
    }
}