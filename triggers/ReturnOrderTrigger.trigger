trigger ReturnOrderTrigger on Return_Order__c (before insert, before update) {
   Trigger_Controller__c ReturnDocDetailTriggerControl = Trigger_Controller__c.getInstance('ReturnOrderTrigger'); //Get Trigger Controller Setting
   if(ReturnDocDetailTriggerControl != null && ReturnDocDetailTriggerControl.Enabled__c ){  
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ReturnOrderTriggerHandler.updateSODocumentDetail(Trigger.New[0], Trigger.oldMap, Trigger.isUpdate, Trigger.isBefore);
        }
      }
    }
}