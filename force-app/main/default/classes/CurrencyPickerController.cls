public without sharing class CurrencyPickerController {

    @AuraEnabled(Cacheable=true)
    public static String selectCurrentCurrency() {
        return CurrencyPickerHandler.selectCurrentCurrency();
    }

    @AuraEnabled
    public static void updateCurrency(String cur) {
        try {
            CurrencyPickerHandler.updateCurrency(cur);
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while updating the currency: ' + e.getMessage());
        }
    }
}