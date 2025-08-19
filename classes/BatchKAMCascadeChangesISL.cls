/*****************************************************************************/
/* VERSION     AUTHOR                  DATE                                  */
/*     1.0     Shreya Raut             06-17-2020                            */
/* Class Name: BatchKAMCascadeChangesISL                                     */
/* Description: To ISL records with requested start and end date             */
/*****************************************************************************/
public class BatchKAMCascadeChangesISL  implements Database.Batchable<sobject>{

    ID apt;
    ID RSGID;
    ActionPlanTemplate__c selectedAPTQueried = new ActionPlanTemplate__c();
    Public String class_Name ='BatchKAMCascadeChangesISL';
    String method_Name='Execute';
    Public BatchKAMCascadeChangesISL(Id apt1,ID RSGIDs)
    {
        RSGID=RSGIDs;
        apt=apt1;
        String queryAPT = 'Select Id,Batch_Details__c,RequestedStartDate__c,RequestedEndDate__c,APT_Changes__c From ActionPlanTemplate__c Where id =:apt ORDER BY ID';
        selectedAPTQueried =Database.query(queryAPT);
      
       // update   selectedAPTQueried;
    }
    Public Database.Querylocator start (Database.BatchableContext BC) {
        System.debug('Inside ISL Start');
        return Database.getQueryLocator('select id, StartDate__c, EndDate__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c=: apt and RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c =:RSGID ORDER BY RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c ');
    }
    
    Public void execute (Database.BatchableContext BC,List<InStoreLocation__c> ISLRecords ) {
        System.debug('inside ISL execute');
        Map<ID, InStoreLocation__c > ISLMap = new Map<ID,InStoreLocation__c  >();
         List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
          //selectedAPTQueried.APT_Changes__c = true;
        //update   selectedAPTQueried;
       for(InStoreLocation__c is :ISLRecords){
           
            is.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
            is.EndDate__c = selectedAPTQueried.RequestedEndDate__c;
            ISLList.add(is);
       }
      
      //Update Instorelocations and Missions
       if (ISLList != null && ISLList.size() > 0) {
            System.debug('Inside Insupdate');
            List<Database.SaveResult> ISLToUpdateResults = Database.Update(ISLList, true);
            List<Database.Error> ISLToUpdateError = new List <Database.Error> ();
            for (Integer index = 0, size = ISLToUpdateResults.size(); index < size; index++) {
                if (!ISLToUpdateResults[index].isSuccess()) {
                    ISLToUpdateError.addAll(ISLToUpdateResults[index].getErrors());
                    
                }
            }
            if (ISLToUpdateError.size() > 0) {
                System.debug('Inside Error ISLUpdate');
                LogEventTriggerHandler.insertBatchLog(ISLToUpdateError, class_Name,method_Name, 'Instorelocation', 'Database.update_Failed');
            }
        }
   }
    
    
    Public void finish(Database.BatchableContext BC){
          AsyncApexJob j = [Select Id, Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
        //Added by shreya for ticket SFDC - 0000004466 
        if(j.NumberOfErrors > 0)
         {
          selectedAPTQueried.Batch_Details__c ='ISL APT Date changes Failed '+j.CompletedDate; 
             System.debug('Inside failed batch details');
         }
         else if(j.Status == 'Completed' && j.NumberOfErrors == 0)
        {
           selectedAPTQueried.Batch_Details__c ='ISL APT Date changes completed '+j.CompletedDate;   
        }
          selectedAPTQueried.APT_Changes__c = true;
        update selectedAPTQueried;
        BatchKAMCascadeChangesMission b = new BatchKAMCascadeChangesMission(apt,RSGID);
        Database.executeBatch(b);
    }
    
    
}