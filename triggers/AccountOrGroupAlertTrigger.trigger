trigger AccountOrGroupAlertTrigger on AccountOrGroupAlert__c (after insert,after update) {      
     
    Trigger_Controller__c AccountOrGroupAlertTriggerControl = Trigger_Controller__c.getInstance('AccountOrGroupAlertTrigger'); //Get Trigger Controller Setting
    System.debug('AccountOrGroupAlertTriggerControl'+AccountOrGroupAlertTriggerControl);
    if (Trigger.IsAfter && AccountOrGroupAlertTriggerControl !=null && AccountOrGroupAlertTriggerControl.Enabled__c /* || Test.isRunningTest()*/) {
            if (Trigger.isInsert) {
                AccountOrGroupAlertHandler.handleAfterInsert(Trigger.newMap, Trigger.oldMap);
            } 
             if (Trigger.isUpdate) {
                AccountOrGroupAlertHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);             
            }
            
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
}