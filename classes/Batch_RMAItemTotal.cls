/*******************************************************************************************
* @Name         Batch_RMAItemTotal
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         09/17/2019
* @Group        Sales Ops
* @Description  A batch job will RMA Total field on Case object
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          09/17/2019           Initial Creation
*******************************************************************************************/
global class Batch_RMAItemTotal implements Database.Batchable<sObject>, Database.Stateful{
 global Map<String, String> mapInputs =  new Map<String, String>();
 List<Case> listCaseToUpdate = new List<Case>();
  /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
 global Database.QueryLocator start(Database.BatchableContext bc){
     String overrideQuery = '';
     String query = 'Select Id, Case__c, Case__r.RMA_Total__c, RMA_Item_Total__c from B2B_RMA_Item__c Where RMA_Item_Total__c != null';
            query += ' AND ';
            query += 'Case__c <> NULL';
        if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
            overrideQuery = ' AND '+mapInputs.get('overrideQuery');
        }
       query += overrideQuery;      
    return Database.getQueryLocator(query);
 }
    /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Asset>
    * @Return  --none--
    **************************************************************************************/
 global void execute(Database.BatchableContext bc, List<B2B_RMA_Item__c> listB2BRMAItems){
     Set<Id> caseIds = new Set<Id>();
     Map<Id,Decimal> mapCaseIdToRMATotal = new Map<Id,Decimal>();
     for(B2B_RMA_Item__c B2BRMAItemRec : listB2BRMAItems){
         if(B2BRMAItemRec.Case__c <> NULL){
            caseIds.add(B2BRMAItemRec.Case__c);
         }
     }
    AggregateResult[] results = getRMAItemTotal(caseIds);
    for(AggregateResult ar : results) {
        mapCaseIdToRMATotal.put((String)ar.get('Case__c'), (Double)ar.get('expr0'));
    }
    for(Id caseId : caseIds){
         Case caRecToUpdate= new Case(Id = caseId);
         if(mapCaseIdToRMATotal != null && mapCaseIdToRMATotal.containsKey(caseId)){
             caRecToUpdate.RMA_Total__c = mapCaseIdToRMATotal.get(caseId);
             listCaseToUpdate.add(caRecToUpdate); 
         } 
     }
 }
/**************************************************************************************
* @Description this method executes any post processing tasks
* @Param   Database.BatchableContext
* @Return  --none--
**************************************************************************************/
 global void finish(Database.BatchableContext bc){
     if(listCaseToUpdate != null && listCaseToUpdate.size()>0){
         Set<Case> myset = new Set<Case>();
         List<Case> result = new List<Case>();
         myset.addAll(listCaseToUpdate);
         result.addAll(myset);
         List<Database.SaveResult> updatCaseResults = Database.Update(result, false);
         List<Database.Error> listError = new List<Database.Error>();
         for(Integer index = 0, size = updatCaseResults.size(); index < size; index++) {
             if(!updatCaseResults[index].isSuccess()){
                 listError.addAll(updatCaseResults[index].getErrors());
               }
           }
         LogEventTriggerHandler.insertBatchLog(listError, 'Batch_RMAItemTotal', 'execute', 'Case', 'Database.Update_Failed');  
       } 
 }
/**************************************************************************************
* @Description this method get the RMA Item Total using AggregateResult function
* @Param   caseIds
* @Return  AggregateResult[]
**************************************************************************************/
 public AggregateResult[] getRMAItemTotal(Set<Id> caseIds) {
    AggregateResult[] groupedResults =  [select Case__c, SUM(RMA_Item_Total__c) from B2B_RMA_Item__c Where Case__c IN : caseIds group by Case__c];
    return groupedResults;
  }
}