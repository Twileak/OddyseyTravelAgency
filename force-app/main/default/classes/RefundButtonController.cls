public with sharing class RefundButtonController {

    @AuraEnabled(Cacheable=true)
    public static String getCurrentStatus(Id orderId) {
        OrderSummary order = [
                SELECT Status
                FROM OrderSummary
                WHERE Id = :orderId
                LIMIT 1];

        return order.Status;
    }
    @AuraEnabled
    public static void refundOrder(Id orderId) {
        OrderSummary orderToUpdate = [
                SELECT Id, Status
                FROM OrderSummary
                WHERE Id = :orderId
                LIMIT 1];

        if (orderToUpdate != null) {
            orderToUpdate.Status = 'Reviewed for refund';
            update orderToUpdate;
        }
    }
}