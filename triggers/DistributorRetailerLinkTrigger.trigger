trigger DistributorRetailerLinkTrigger on Distributor_Retailer_Link__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
    Trigger_Controller__c triggerControl = Trigger_Controller__c.getInstance('DistributorRetailerLinkTrigger'); //Get Trigger Controller Setting
    
    if( triggerControl != null && triggerControl.Enabled__c ){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
               DistributorRetailerLinkTriggerHandler.handleBeforeInsert( Trigger.New );
            } 
            if (Trigger.isUpdate) {
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {
             DistributorRetailerLinkTriggerHandler.handleAfterInsert( Trigger.New );
            } 
            if (Trigger.isUpdate) {
                //Add Future Logic Here
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
    }
}