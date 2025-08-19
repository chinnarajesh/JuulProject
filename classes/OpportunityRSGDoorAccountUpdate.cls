/****************************************************************************************
*   @File Name: OpportunityRSGDoorAccountUpdate
*   @File Description: Opportunity RACS status to be updated on the newly added door 
					   accounts on RSG - Opportunity batch.
*   @author - Jyoti Choudhary
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Jyoti Choudhary            30/09/21                Created
*****************************************************************************************/
global class OpportunityRSGDoorAccountUpdate implements Database.Batchable<sObject>{
        public String class_Name ='UpdateDoorAccountsStatusBatch';
        String method_Name='Execute';
        String operationType = 'Database.Upadte_Failed';
        Map<Id, EAC_RSG__c> mapEACRSG = new Map<Id, EAC_RSG__c>();
        List<EAC_RSG__c> eacrsgWithLatestOpp = new List<EAC_RSG__c>();
        Set<Id> relatedRSG = new Set<Id>();
        Set<Id> rsgIds = new Set<Id>();
        Set<Id> AccountIDs = new Set<Id>();
        List<account> DoorAccountsToUpdate = new List<account>();
        List<AccountWrapperClass> AccountList = new List<AccountWrapperClass>();
    
    //Constructor to get the ARSGlist
    global OpportunityRSGDoorAccountUpdate(List<AccountRetailStoreGroup__c> TriggerNew){
        //AccountTriggerHandler.firstRun = false;
        
        System.debug('TriggerNew-->'+TriggerNew);
        For(AccountRetailStoreGroup__c arsg : TriggerNew){
            relatedRSG.add(arsg.RetailStoreGroupId__c);
        }
            //System.debug('relatedRSG-->'+relatedRSG);
            
        If(relatedRSG != null){            
            For(EAC_RSG__c e : [Select Id,Retail_Store_Group__c,Opportunity__r.StageName,Opportunity__c,  Opportunity__r.LastModifiedDate  
                                from EAC_RSG__c where Retail_Store_Group__c IN : relatedRSG Order by Opportunity__r.LastModifiedDate]){
                mapEACRSG.put(e.Retail_Store_Group__c,e);
                rsgIds.add(e.Retail_Store_Group__c);
            }
            //System.debug('mapEACRSG-->'+mapEACRSG.Values());
            //System.debug('rsgIds-->'+rsgIds);
            
            for(Id rsg : rsgIds){
                for(EAC_RSG__c e : mapEACRSG.values()){
                    if(rsg == e.Retail_Store_Group__c)
                    {eacrsgWithLatestOpp.add(e);}
                }
            }            
            //System.debug('eacrsgWithLatestOpp-->'+eacrsgWithLatestOpp);
            
            for(AccountRetailStoreGroup__c arsg : TriggerNew){
                for(EAC_RSG__c eacrsg : eacrsgWithLatestOpp){
                    if(arsg.RetailStoreGroupId__c == eacrsg.Retail_Store_Group__c){
                        AccountWrapperClass cWrapp = new AccountWrapperClass();
                        cWrapp.AccountRacsStatus = eacrsg.Opportunity__r.StageName;
                        cWrapp.Id = arsg.AccountId__c;
                        AccountList.add(cWrapp);
                        AccountIDs.add(arsg.AccountId__c);
                    }
                }
            }
            //System.debug('AccountList-->'+AccountList);
            //System.debug('AccountIDs-->'+AccountIDs);            
    }
        
    }
    
    //Start Method to get Accounts
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'SELECT Id,Status__c,OwnerId from Account where Id IN: AccountIDs';
        return Database.getQueryLocator(query); 
    }
    //Execute Method to Update the Accounts and create the Tasks
    global void execute(Database.BatchableContext bc, List<Account> accounts)
    {
        if(accounts != null){
            For(Account a : accounts){
                for(AccountWrapperClass awc : AccountList){
                    if(a.Id == awc.Id){                    
                        a.RACS_Status__c = awc.AccountRacsStatus;
                        DoorAccountsToUpdate.add(a);
                    }}}}        
        Try{
            //System.debug('DoorAccountsToUpdate-->'+DoorAccountsToUpdate);
            
            //update DoorAccountsToUpdate;            
            operationType = 'Database.Update_Failed';   
            If(DoorAccountsToUpdate != null && DoorAccountsToUpdate.size()>0){
                List<Database.SaveResult> DoorAccountsToUpdateResults = Database.Update(DoorAccountsToUpdate, true);
                List<Database.Error> DoorAccountsToUpdateError = new List <Database.Error>();
                for (Integer index = 0, size = DoorAccountsToUpdateResults.size(); index < size; index++) {
                    if (!DoorAccountsToUpdateResults[index].isSuccess()) {
                        DoorAccountsToUpdateError.addAll(DoorAccountsToUpdateResults[index].getErrors());                    }
                }
                if (DoorAccountsToUpdateError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(DoorAccountsToUpdateError,class_Name,method_Name, 'Account', operationType);
                    System.debug('DoorAccountsToUpdateError->'+DoorAccountsToUpdateError);
                }
            }
            }Catch(Exception e){
            System.debug('Error Message-->'+e);
            
            }
    }
    
    //Finish method
    global void finish(Database.BatchableContext bc)
    {
        //System.debug('Inside finish');
    }
    
    //Wrapper Class to get the Accounts details
    public class AccountWrapperClass {
     @AuraEnabled
     public String AccountRacsStatus {get; set;}   
     @AuraEnabled
     public Id Id {get; set;}
     
    }
}