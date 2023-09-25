
public interface ITriggerHandler {
    void bulkBefore();
    void bulkAfter();
    void beforeInsert(List<SObject> newRecord);
    void beforeUpdate(Map<Id, SObject> newRecord, Map<Id, SObject> oldItems);
    void beforeDelete(Map<Id, SObject> newRecord);
    void afterInsert(Map<Id, SObject> newRecord);
    void afterUpdate(Map<Id, SObject> newRecord, Map<Id, SObject> oldRecord);
    void afterDelete(Map<Id,SObject> oldRecord);
    void afterUndelete(Map<Id, SObject> oldRecord);
    void andFinally();
}