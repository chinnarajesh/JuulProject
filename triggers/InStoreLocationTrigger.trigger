trigger InStoreLocationTrigger on InStoreLocation__c (after insert,after update) {
    Trigger_Controller__c InStoreLocationTriggerController = Trigger_Controller__c.getInstance('InStoreLocationTrigger'); //Get Trigger Controller Setting
    
    
     if (Trigger.IsAfter && (InStoreLocationTriggerController.Enabled__c  || Test.isRunningTest())) {
            if (Trigger.isInsert) {
                InStoreLocationTriggerHandler.addRetailStoreGrouponInsert(Trigger.new);
            } 
             if (Trigger.isUpdate) {
                InStoreLocationTriggerHandler.addRetailStoreGrouponUpdate(Trigger.new,Trigger.oldMap);             
            }
            
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
    }
}