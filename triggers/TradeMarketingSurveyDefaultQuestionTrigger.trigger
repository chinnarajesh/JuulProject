trigger TradeMarketingSurveyDefaultQuestionTrigger on Trade_Marketing_Survey_Default_Question__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
    Trigger_Controller__c TriggerControl = Trigger_Controller__c.getInstance('TMSDefaultQuestionTrigger'); //Get Trigger Controller Setting
    
    if((TriggerControl!=null && TriggerControl.Enabled__c == true) || Test.isRunningTest()){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                
            } 
            if (Trigger.isUpdate) {
                
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {
                TMSDefaultQuestionTriggerHandler.InsertHandler(Trigger.New);
            } 
            if (Trigger.isUpdate) {
            }
            if (Trigger.isDelete) {
                TMSDefaultQuestionTriggerHandler.DeleteHandler(Trigger.Old);
            }
        }
    }
    
}