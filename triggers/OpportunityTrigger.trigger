/************************************************************************************************************************************* 
Apex Trigger: OpportunityTrigger
Purpose :  Run Opportunity Trigger Handler Logic
Test Class : TestOpportunityTrigger
**************************************************************************************************************************************  
History:
DEVELOPER   DATE            CHANGE
Vivek       02/09/2017      V1 - Calls Insert/BeforeUpdate
*************************************************************************************************************************************/
trigger OpportunityTrigger on Opportunity (before insert, after insert,before update, after update,before delete, after delete) {
    Trigger_Controller__c OpportunityTriggerControl = Trigger_Controller__c.getInstance('OpportunityTrigger'); //Get Trigger Controller Setting
    OpportunityTriggerHandler OpptyHandler = new OpportunityTriggerHandler();
    if(OpportunityTriggerControl != null && OpportunityTriggerControl.Enabled__c){
        if (Trigger.isBefore) {
            if (Trigger.isInsert){
                OpptyHandler.validationRACS(Trigger.New, Trigger.OldMap, Trigger.isInsert, Trigger.isBefore);
                //Added by Shreya for  SFDC - 0000004243
                if(!OpportunityTriggerHandler.isFirstTime){
                OpportunityTriggerHandler.isFirstTime = true;
                OpportunityTriggerHandler.validateRACOpp(Trigger.new);
                }
            } 
            if (Trigger.isUpdate){
                OpptyHandler.validationRACS(Trigger.New, Trigger.OldMap, Trigger.isUpdate, Trigger.isBefore);
                 //Added by Shreya for  SFDC - 0000004243
                   if(!OpportunityTriggerHandler.isFirstTime){
                OpportunityTriggerHandler.isFirstTime = true;
                OpportunityTriggerHandler.validateRACOpp(Trigger.new);
                }
            }
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert){
                OpptyHandler.SendChatterNotificationToAccount(Trigger.New, null, false);
            } 
            if (Trigger.isUpdate){
                OpptyHandler.createRACSInstallationCase(Trigger.New, Trigger.OldMap, Trigger.isUpdate, Trigger.isAfter); 
                OpptyHandler.SendChatterNotificationToAccount(Trigger.New, Trigger.OldMap, true);
                //Modified UpdateRSGAccount code for SFDC - 0000004243 
                if(!OpportunityTriggerHandler.isBatchFirstTime){
                OpportunityTriggerHandler.isBatchFirstTime = true;
                OpptyHandler.UpdateOppAccount(Trigger.New, Trigger.OldMap);
                OpptyHandler.UpdateRSGsAccount(Trigger.New, Trigger.OldMap);  
                }
               
            }
        }
    }
}