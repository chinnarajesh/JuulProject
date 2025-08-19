/*******************************************************************************************
* @Name         Batch_UpdateSOFirstOrderDateOnDRlink
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         04/01/2020
* @Group        Sales Ops
* @Description  A batch job will update the First Sales Order Date on Distributor Retailer Link object.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          04/01/2020            Initial Creation
*******************************************************************************************/
global class Batch_UpdateSOFirstOrderDateOnDRlink implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**************************************************************************************
     * @Description this method generates the scope of the records in the database
     * @Param   Database.BatchableContext
     * @Return  Database.QueryLocator
     **************************************************************************************/
     Map<String, String> mapInputs =  new Map<String, String>();
     List<Account> listAccountToUpdate = new List<Account>();
      /*****************************************************************************/
     /* Method Name:    execute                                                   /*
     /* Description:    execute method of Schedulable Interface                   /*
     /*****************************************************************************/
     global void execute(SchedulableContext sc) {
         database.executebatch(this);
     }
     global Batch_UpdateSOFirstOrderDateOnDRlink(Map<String, String> mapInputs){
         this.mapInputs = mapInputs;
     }
     global Batch_UpdateSOFirstOrderDateOnDRlink(){
         
     }
     global Database.QueryLocator start(Database.BatchableContext bc){
       String overrideQuery = '';
       String query = 'SELECT Id, Distributor__c, Retailer__c,External_ID__c,First_Sales_Order_Date__c FROM Distributor_Retailer_Link__c';
              query += ' WHERE';
              query += ' First_Sales_Order_Date__c = null';
              query += ' AND';
              query += ' Distributor__c <> NULL';
              query += ' AND';
              query += ' Retailer__c <> NULL';

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
     global void execute(Database.BatchableContext bc, List<Distributor_Retailer_Link__c> listDRLink) {
        Set<Id> distAccIds = new Set<Id>();
        Set<Id> retailAccIds = new Set<Id>();
        AggregateResult[] results;
        Map<String, Date> mapUpdateDistiRetailerLink = new Map<String, Date>();
        List<Distributor_Retailer_Link__c> listDRLinkToUpdate = new List<Distributor_Retailer_Link__c>();
        for(Distributor_Retailer_Link__c drLinkRec : listDRLink){
            distAccIds.add(drLinkRec.Distributor__c);
            retailAccIds.add(drLinkRec.Retailer__c);   
        }
        if(distAccIds.size() > 0 && retailAccIds.size() > 0){
            results = getMinimumOrderDate(distAccIds,retailAccIds);
        }
        if(results != null && results.size()>0){
           for(AggregateResult ar : results) {
                mapUpdateDistiRetailerLink.put((String)ar.get('Distributor__c')+'_'+(String)ar.get('Customer__c'), (Date)ar.get('expr0'));
            }
        } 
        for(Distributor_Retailer_Link__c drLinkRec : listDRLink){
            if(mapUpdateDistiRetailerLink.get(drLinkRec.External_ID__c) != null){
                drLinkRec.First_Sales_Order_Date__c =  Date.ValueOf(mapUpdateDistiRetailerLink.get(drLinkRec.External_ID__c));
                listDRLinkToUpdate.add(drLinkRec);
            }  
        } 
        if(listDRLinkToUpdate != null && listDRLinkToUpdate.size()>0){
            List<Database.SaveResult> updateDRLinkResults = Database.Update(listDRLinkToUpdate, false); 
            List<Database.Error> listError = new List<Database.Error>();
            for(Integer index = 0, size = updateDRLinkResults.size(); index < size; index++) {
                if(!updateDRLinkResults[index].isSuccess()){
                    listError.addAll(updateDRLinkResults[index].getErrors());
                }
            }
            LogEventTriggerHandler.insertBatchLog(listError, 'Batch_UpdateSOFirstOrderDateOnDRlink', 'execute', 'Distributor_Retailer_Link__c', 'Database.Update_Failed');
        }     
     }   
    /**************************************************************************************
     * @Description this method executes any post processing tasks
     * @Param   Database.BatchableContext
     * @Return  --none--
     **************************************************************************************/
     global void finish(Database.BatchableContext bc){

     }
/**************************************************************************************
* @Description this method get the Min Order Date using AggregateResult function
* @Param   accountIds
* @Return  AggregateResult[]
**************************************************************************************/
 public AggregateResult[] getMinimumOrderDate(Set<Id> distAccIds, Set<Id> retailAccIds) {
    AggregateResult[] groupedResults =  [SELECT Distributor__c, Customer__c, MIN(Order_Date__c) FROM salesOrder__c WHERE Customer__c IN : retailAccIds
                                         AND Distributor__c IN : distAccIds GROUP BY Distributor__c,Customer__c];
    return groupedResults;
  }
 }