public with sharing class RefundButtonController {

    @AuraEnabled(Cacheable=true)
    public static String getCurrentStatus(Id orderId) {
        return RefundButtonHandler.getCurrentStatus(orderId);
    }
    @AuraEnabled
    public static void refundOrder(Id orderId) {
        RefundButtonHandler.refundOrder(orderId);
    }
}