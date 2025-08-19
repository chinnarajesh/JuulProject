/*******************************************************************************************
* @Name         Batch_UpdateSOMinOrderDateOnAccount
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         04/01/2020
* @Group        Sales Ops
* @Description  A batch job will update the SO minimum order date on account.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          04/01/2020            Initial Creation
*******************************************************************************************/
global class Batch_UpdateSOFirstOrderDateOnAccount implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**************************************************************************************
     * @Description this method generates the scope of the records in the database
     * @Param   Database.BatchableContext
     * @Return  Database.QueryLocator
     **************************************************************************************/
     Map<String, String> mapInputs =  new Map<String, String>();
     
      /*****************************************************************************/
     /* Method Name:    execute                                                   /*
     /* Description:    execute method of Schedulable Interface                   /*
     /*****************************************************************************/
     global void execute(SchedulableContext sc) {
         database.executebatch(this);
     }
     global Batch_UpdateSOFirstOrderDateOnAccount(Map<String, String> mapInputs){
         this.mapInputs = mapInputs;
     }
     global Batch_UpdateSOFirstOrderDateOnAccount(){
         
     }
     global Database.QueryLocator start(Database.BatchableContext bc) {
       String overrideQuery = '';
       String query = 'SELECT Id FROM Account';
              query += ' WHERE ';
              query += '(';
              query += 'Account.RecordType.Name=\'Regional Chain Retailer\' OR Account.RecordType.Name=\'Chain Retail\' OR Account.RecordType.Name=\'Independent Retailer\'';
              query += ')';
              query += ' AND ';
              query += 'SO_Minimum_Order_Date__c = null';

       if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
            overrideQuery = ' AND '+mapInputs.get('overrideQuery');
        }
        query += overrideQuery; 
        System.debug('query ***************** '+query);
        return Database.getQueryLocator(query);
     }
    
    /**************************************************************************************
     * @Description this method holds the processing logic for each batch of records
     * @Param    Database.BatchableContext, List<Asset>
     * @Return  --none--
     **************************************************************************************/
     global void execute(Database.BatchableContext bc, List<Account> listAccounts) {
        List<Account> listAccountToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Date> mapAccIdToMinDate = new Map<Id,Date>();
        Account accRecToUpdate = new Account();
        for(Account accRec : listAccounts){
            accountIds.add(accRec.id);   
        }
         
        AggregateResult[] results = getMinimumOrderDate(accountIds);
        
        for(AggregateResult ar : results){
                accRecToUpdate= new Account();
                accRecToUpdate.Id = (String)ar.get('Customer__c');
                accRecToUpdate.SO_Minimum_Order_Date__c = (Date)ar.get('expr0');                    
                listAccountToUpdate.add(accRecToUpdate); 
        }
    
         if(listAccountToUpdate != null && listAccountToUpdate.size()>0){
            List<Database.SaveResult> updatAccountResults = Database.Update(listAccountToUpdate, false);
            List<Database.Error> listError = new List<Database.Error>();
            for(Integer index = 0, size = updatAccountResults.size(); index < size; index++) {
                if(!updatAccountResults[index].isSuccess()){
                    listError.addAll(updatAccountResults[index].getErrors());
                  }
              }
            if (listError.size() > 0) {
              LogEventTriggerHandler.insertBatchLog(listError, 'Batch_UpdateSOFirstOrderDateOnAccount', 'execute', 'Account', 'Database.Update_Failed');  
            }
         } 
     }   
    /**************************************************************************************
     * @Description this method executes any post processing tasks
     * @Param   Database.BatchableContext
     * @Return  --none--
     **************************************************************************************/
     global void finish(Database.BatchableContext bc){
      /*  
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,  TotalJobItems  FROM AsyncApexJob  WHERE Id = : BC.getJobId()];
        if (a.NumberOfErrors > 0){
            System.abortJob(AsyncApexJob.id);
            Batch_UpdateSOFirstOrderDateOnAccount batch = new Batch_UpdateSOFirstOrderDateOnAccount();
            Database.executeBatch(batch, 20);
        }
        */
     }
/**************************************************************************************
* @Description this method get the Min Order Date using AggregateResult function
* @Param   accountIds
* @Return  AggregateResult[]
**************************************************************************************/
 public AggregateResult[] getMinimumOrderDate(Set<Id> accountIds) {
    AggregateResult[] groupedResults =  [SELECT Customer__c, MIN(Order_Date__c) FROM salesOrder__c WHERE Customer__c IN : accountIds GROUP BY Customer__c LIMIT 200];
    return groupedResults;
  }
 }