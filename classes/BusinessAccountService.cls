/*******************************************************************************************
* @Name         BusinessAccountService
* @Author       Naveen Gunda <Naveen.Gunda@juul.com>
* @Date         11/26/2019
* @Group        Customer Service
* @Description  Handler for Case Trigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Naveen          11/26/2019          Initial Creation
*******************************************************************************************/
public class BusinessAccountService{
   
    /**
     Added by Naveen.
     Reference:  SFDC - 0000000722   
    **/
     public static void updateAccountStatus(List<Case> newCaseList, Map<Id, Case> oldMap){
         Set<Id> accountIdSet = new Set<Id>();
         Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
         List<Account> accListToUpdate = new List<Account>();
         
           for(Case cseRec : newCaseList){
                String oldMapStatus = oldMap==null?'':oldMap.get(cseRec.Id).Status;
                if(cseRec.RecordTypeId == B2BSupportCaseRecordTypeId && cseRec.AccountId != null 
                && cseRec.Status == 'Retail Case Closed' && cseRec.Status != oldMapStatus && cseRec.Type == 'Brand Protection' && 
                cseRec.Sub_Type__c == 'Residential Address' && cseRec.Regulatory_Action__c == 'No-Sale-List'){
                    accountIdSet.add(cseRec.AccountId);
                }     
        }
        
        if(accountIdSet != null && accountIdSet.size() > 0){
            for(Account accRec : [Select Id, Status__c from Account where Id IN : accountIdSet]){
                if(accRec.Status__c != 'Suspended'){
                    accRec.Status__c = 'Suspended';
                    accListToUpdate.add(accRec);
                  }
               }
           }
         if(accListToUpdate!= null && accListToUpdate.size() > 0){
             update accListToUpdate;
             List<Database.SaveResult> updateAccountResults = Database.Update(accListToUpdate, false);
             List<Database.Error> listError = new List<Database.Error>();
             for(Integer index = 0, size = updateAccountResults.size(); index < size; index++) {
               if(!updateAccountResults[index].isSuccess()){
                   listError.addAll(updateAccountResults[index].getErrors());
               }
           }
               LogEventTriggerHandler.insertBatchLog(listError, 'CaseHandler', 'updateAccountStatus', 'Account', 'Database.Update_Failed');  
             }
          }
         //JTP-272
     public static void updateCaseStatus(List<Case> newCaseList){
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
        for(Case cseRec : newCaseList){
                if(cseRec.RecordTypeId == B2BSupportCaseRecordTypeId && cseRec.Status != 'Retail Case Closed' && cseRec.Type == 'Brand Protection'){
                    cseRec.Status = 'Retail Case Closed';
                }     
        }
    }
  

}