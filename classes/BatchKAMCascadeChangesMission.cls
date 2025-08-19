/*****************************************************************************/
/* VERSION     AUTHOR                  DATE                                  */
/*     1.0     Shreya Raut             06-17-2020                            */
/* Class Name: BatchKAMCascadeChangesMission                                     */
/* Description: To ISL records with requested start and end date             */
/*****************************************************************************/
    public class BatchKAMCascadeChangesMission implements Database.Batchable<sobject>{ 
    ID apt;
    ID RSGID;
    ActionPlanTemplate__c selectedAPTQueried = new ActionPlanTemplate__c();
    Public String class_Name ='BatchKAMCascadeChangesMission';
    String method_Name='Execute';
    Public BatchKAMCascadeChangesMission(Id apt1,ID RSGIDs)
    {
        RSGID=RSGIDs;
        apt=apt1;
        String queryAPT = 'Select Id,Batch_Details__c,APT_Changes__c,RequestedStartDate__c,RequestedEndDate__c,ExecutionNotes__c From ActionPlanTemplate__c Where id =:apt ORDER BY ID ';
        selectedAPTQueried =Database.query(queryAPT);
    }
    Public Database.Querylocator start (Database.BatchableContext BC) {
        System.debug('Inside Missios Start');
         String query = 'select id, StartDate__c, EndDate__c from Mission__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c=: apt and RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c =:RSGID ORDER BY RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c ';
        return Database.getQueryLocator(query);
    }
    Public void execute (Database.BatchableContext BC,List<Mission__c> MRecords ) {
        System.debug('inside Mission execute');
        List<Mission__c> MissionList = new List<Mission__c>();
       for(Mission__c m : MRecords){
            m.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
            m.EndDate__c = selectedAPTQueried.RequestedEndDate__c;
            MissionList.add(m);
       }
      //Update Instorelocations and Missions
        if (MissionList != null && MissionList.size() > 0) {
            System.debug('Inside Insupdate'+MissionList.size());
            List<Database.SaveResult> MissionToUpdateResults = Database.Update(MissionList, true);
            List<Database.Error> MissionToUpdateError = new List <Database.Error> ();
            for (Integer index = 0, size = MissionToUpdateResults.size(); index < size; index++) {
                if (!MissionToUpdateResults[index].isSuccess()) {
                    MissionToUpdateError.addAll(MissionToUpdateResults[index].getErrors());
                    
                }
            }
            if (MissionToUpdateError.size() > 0) {
                System.debug('Inside Error MissionUpdate');
                LogEventTriggerHandler.insertBatchLog(MissionToUpdateError, class_Name,method_Name, 'Mission', 'Database.update_Failed');
            }
        }
        
    }
    
    
    Public void finish(Database.BatchableContext BC){
          AsyncApexJob j = [Select Id, Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
        //Added by shreya for ticket SFDC - 0000004466 
        if(j.NumberOfErrors > 0)
         {
          selectedAPTQueried.Batch_Details__c ='Mission APT Date changes Failed '+j.CompletedDate; 
             System.debug('Inside failed batch details');
         }
        else if(j.Status == 'Completed' && j.NumberOfErrors == 0)
        {
           selectedAPTQueried.Batch_Details__c ='Mission APT Date changes completed '+j.CompletedDate; 
             System.debug('Inside success batch details');
        }
        selectedAPTQueried.APT_Changes__c=false;
        update selectedAPTQueried;
    }
    
    
}