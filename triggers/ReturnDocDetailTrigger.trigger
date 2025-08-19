trigger ReturnDocDetailTrigger on Return_Document_Detail__c (before insert, before update){
    Trigger_Controller__c AccountTriggerControl = Trigger_Controller__c.getInstance('ReturnDocDetailTrigger');
     if( AccountTriggerControl != null && AccountTriggerControl.Enabled__c ){  
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                    ReturnDocDetailTriggerHandler.updateSODocumentDetail(Trigger.New[0],Trigger.oldMap);
                }
                if(Trigger.isUpdate){
                    if(Trigger.New[0].Return_Product__c <> Trigger.oldMap.get(Trigger.New[0].id).Return_Product__c){
                        ReturnDocDetailTriggerHandler.updateSODocumentDetail(Trigger.New[0],Trigger.oldMap);
                    }
                }
            }  
        }   
}