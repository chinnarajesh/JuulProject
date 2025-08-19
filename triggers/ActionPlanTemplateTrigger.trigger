trigger ActionPlanTemplateTrigger on ActionPlanTemplate__c (after insert,after update,after delete, before update,before insert) {
    Trigger_Controller__c APTTriggerControl = Trigger_Controller__c.getInstance('ActionPlanTemplateTrigger'); //Get Trigger Controller Setting
    
    
    if( APTTriggerControl != null && APTTriggerControl.Enabled__c ){
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {
                ActionPlanTemplateHandler.handleAfterInsert(Trigger.newMap, Trigger.oldMap);  
                //UpdateActionPlanTemplateFundingRate.updateFundingRateonUpdate(null,null,Trigger.new); 
            } 
            if (Trigger.isUpdate) {
                System.debug('Inside trigeer.afterupdate');
                ActionPlanTemplateHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);   
            }
            
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        if(Trigger.IsBefore){
            if (Trigger.isInsert) {
                ActionPlanTemplateHandler.handleBeforeInsert(Trigger.New);           
            } 
            if (Trigger.isUpdate) {
                ActionPlanTemplateHandler.handleBeforeUpdate(Trigger.New, Trigger.oldMap);                 
            }
        }
    }
}