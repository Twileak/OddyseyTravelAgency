public without sharing class CurrencyPickerController {

    @AuraEnabled(Cacheable=true)
    public static String selectCurrentCurrency() {
        try {
            return CurrencyPickerHandler.selectCurrentCurrency();
        } catch (Exception e){
            throw new AuraHandledException('An error occurred while getting currency: ' + e.getMessage());
        }
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