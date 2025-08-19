trigger LeadTrigger on Lead (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
    Trigger_Controller__c leadTriggerControl = Trigger_Controller__c.getInstance('LeadTrigger'); //Get Trigger Controller Setting
    LeadTriggerHandler leadHandler = new LeadTriggerHandler();
    if( leadTriggerControl != null && leadTriggerControl.Enabled__c ){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                LeadTriggerHandler.handleBeforeInsert( Trigger.New );
            } 
            if (Trigger.isUpdate) {
                LeadTriggerHandler.handleBeforeUpdate( Trigger.Old, Trigger.New );
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {
            } 
            if (Trigger.isUpdate) {
                //Add Future Logic Here
                leadHandler.updateOpptyonLeadConvert(Trigger.New,Trigger.oldMap, Trigger.operationType );
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
    }
}