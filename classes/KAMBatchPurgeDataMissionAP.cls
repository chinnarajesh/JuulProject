/******************************************************
  Purpose:
   -------
   To purge KAM related records Mission and Action Plan
   ======================================================
   Test Class : KAMBatchPurgeDataMissionAP
   ======================================================
   History
   -------
   VERSION  AUTHOR    DATE             Description
   1.0      Shreya    20th Dec,2021    Created 
 *******************************************************/
public class KAMBatchPurgeDataMissionAP implements Database.Batchable<sobject>{
    Public ID AptID;
    ActionPlanTemplate__c selectedAPTQueried = new ActionPlanTemplate__c();
    
    Public KAMBatchPurgeDataMissionAP(ID Apt){
        AptID = Apt;
        selectedAPTQueried =[Select Id,Batch_Details__c From ActionPlanTemplate__c Where id =:AptID];
    }
    
    Public List<sObject> start (Database.BatchableContext BC) {
        List<sObject> scope = new List<sObject>();
        scope.addAll([select id from mission__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c  =: AptID and AccountId__r.Type !='HQ']);
        scope.addAll([select id from ActionPlan__c where Mission__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c =: AptID and Mission__r.AccountId__r.Type!='HQ'  ]);
        return scope;
    }
    public void execute(Database.BatchableContext c, List<sObject> scope)
    {
        List<Mission__c> MissionList = new List<Mission__c>();
        List<ActionPlan__c > ActionPlanList = new List<ActionPlan__c >();
        
       for(sObject obj : scope)
        {
            switch on obj
            {
                when Mission__c ms
                {
                    MissionList.add(ms);
                }
                when ActionPlan__c Ap
                {
                    ActionPlanList.add(Ap);
                }
             }
         }
        if(MissionList.size()>0){
            try{
        Delete MissionList;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
        }
         if(ActionPlanList.size()>0){
            try{
         Delete ActionPlanList;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
         }
         
    }
    Public void finish(Database.BatchableContext BC){
           AsyncApexJob j = [Select Id, Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
        //Added by shreya for ticket SFDC - 0000004466 
        if(j.NumberOfErrors > 0)
         {
          selectedAPTQueried.Batch_Details__c ='Mission Recall Batch Failed '+j.CompletedDate; 
             System.debug('Inside failed batch details');
         }
         else if(j.Status == 'Completed' && j.NumberOfErrors == 0)
        {
           selectedAPTQueried.Batch_Details__c ='Mission Recall Batch completed '+j.CompletedDate;   
        }
        update selectedAPTQueried;
    }
       
}