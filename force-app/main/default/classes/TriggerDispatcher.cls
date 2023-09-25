public with sharing class TriggerDispatcher {
    public static void run(ITriggerHandler handler){
        if(PlatformEventTriggerHandler.isFromTrigger) {
            return;
        }
        if(Trigger.isBefore){
            handler.bulkBefore();
            if(Trigger.isInsert) {
                handler.beforeInsert(Trigger.new);
            }
            if(Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if(Trigger.isDelete) {
                handler.beforeDelete(Trigger.oldMap);
            }
        }
        else {
            handler.bulkBefore();
            if(Trigger.isInsert){
                handler.afterInsert(Trigger.newMap);
            }
            if(Trigger.isUpdate) {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if(Trigger.isDelete) {
                handler.afterDelete(Trigger.oldMap);
            }
            if(Trigger.isUndelete) {
                handler.afterUndelete(Trigger.oldMap);
            }
        }
        handler.andFinally();
    }
}