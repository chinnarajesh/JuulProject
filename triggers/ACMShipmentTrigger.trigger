trigger ACMShipmentTrigger on ACM_Shipment__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
    Trigger_Controller__c ACMShipmentTriggerControl = Trigger_Controller__c.getInstance('ACMShipmentTrigger'); //Get Trigger Controller Setting
    
    if( ACMShipmentTriggerControl != null && ACMShipmentTriggerControl.Enabled__c ){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                ACMShipmentTriggerHandler.handleBeforeInsert( Trigger.New );
            } 
            if (Trigger.isUpdate) {
                ACMShipmentTriggerHandler.handleBeforeUpdate( Trigger.Old, Trigger.New );
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
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
    }
}