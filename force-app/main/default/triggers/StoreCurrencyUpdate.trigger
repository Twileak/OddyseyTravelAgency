trigger StoreCurrencyUpdate on Edit_Default_Currency__e (after insert) {
    if(CheckRecursive.runOnce()){
        TriggerDispatcher.run(new PlatformEventTriggerHandler());
    }
}