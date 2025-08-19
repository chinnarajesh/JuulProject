trigger ContactTrigger on Contact (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
    Trigger_Controller__c ContactTriggerControl = Trigger_Controller__c.getInstance('ContactTrigger'); //Get Trigger Controller Setting
    
    if( ContactTriggerControl != null && ContactTriggerControl.Enabled__c ){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                ContactTriggerHandler.handleBeforeInsert( Trigger.New );
            } 
            if (Trigger.isUpdate) {
                ContactTriggerHandler.handleBeforeUpdate( Trigger.Old, Trigger.New );
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {

            } 
            if (Trigger.isUpdate) {
               ContactTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
    }
}