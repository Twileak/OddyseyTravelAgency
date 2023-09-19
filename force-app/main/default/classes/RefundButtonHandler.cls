/**
 * Created by dawid.zamojda on 08.09.2023.
 */

public with sharing class RefundButtonHandler {
    public static String getCurrentStatus(Id orderId) {
        OrderSummary order = [
                SELECT Status
                FROM OrderSummary
                WHERE Id = :orderId
                LIMIT 1
        ];

        return order.Status;
    }
    public static void refundOrder(Id orderId) {
        OrderSummary orderToUpdate = [
                SELECT Id, Status
                FROM OrderSummary
                WHERE Id = :orderId
                LIMIT 1
        ];

        if (orderToUpdate != null) {
            orderToUpdate.Status = System.Label.Reviewed_for_refund;
            update orderToUpdate;
        }
    }
}