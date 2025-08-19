trigger DocumentDetailTrigger on Document_Details__c (before insert, before update) {
    Trigger_Controller__c DocumentDetailTriggerControl = Trigger_Controller__c.getInstance('DocumentDetailTrigger');
    if(DocumentDetailTriggerControl != null && DocumentDetailTriggerControl.Enabled__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                DocumentDetailTriggerHandler.updateTotalQuantity(Trigger.New, Trigger.OldMap, Trigger.operationType);
            }
            if(Trigger.isUpdate){
                DocumentDetailTriggerHandler.updateTotalQuantity(Trigger.New, Trigger.OldMap, Trigger.operationType);
            }
        } 
    }
}