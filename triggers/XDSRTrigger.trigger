trigger XDSRTrigger on XDSR__c (before insert, before update){
    Trigger_Controller__c XDSRTriggerControl = Trigger_Controller__c.getInstance('XDSRTrigger'); //Get Trigger Controller Setting
    if( XDSRTriggerControl != null && XDSRTriggerControl.Enabled__c ){
        if (Trigger.isBefore){
            if (Trigger.isInsert){
                XDSRTriggerHandler.XDSRAssignmentOnInsert(Trigger.New, Trigger.oldMap, Trigger.operationType);
            }
         }
     }    
}