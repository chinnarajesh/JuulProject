/*******************************************************************************************
* @Name         BatchAddChildAccountsAccessOnetime
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         12/17/2019
* @Group        Sales Ops
* @Description  Onetime batch job - Based on Account Parent Id of Source Accounts, this job
*               to enable the apex sharing to all the child Accounts. 
*               Source Accounts to filter using map input variable 'overrideQuery'
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Anil/Srikanth      12/17/2019         Initial Creation
*******************************************************************************************/
global class BatchAddChildAccountsAccessOnetime implements Database.Batchable<sObject>, Database.Stateful {
    global Map<Id,Id> resultOldMap = new Map<Id,Id>();
    global Map<Id,Id> resultNewMap = new Map<Id,Id>();
    global Map<Id,Account> AccountOldTrigger = new Map<Id,Account>();
    global Set<Id> ParentIDs = new Set<Id>();
    global string operationtype ='';
    global Map<String, String> mapInputs =  new Map<String, String>();
    global ChildAccountShare__c settingsConst;
    global List<String> shippingCountryList;
    public static string batchname = '';
    global BatchAddChildAccountsAccessOnetime(Map<String, String> mapInputs){
       this.mapInputs = mapInputs; 
       settingsConst = ChildAccountShare__c.getinstance('ChidlAccountShare');
       shippingCountryList = String.valueOf(settingsConst.Shipping_Country_List__c).split(',');
    }
/**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String overrideQuery = '';
        String query = 'SELECT Id, ParentId  FROM Account Where ParentId != NULL AND ShippingCountry IN :shippingCountryList AND ';
        if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
            overrideQuery = mapInputs.get('overrideQuery');
        }
        query += overrideQuery; 
        system.debug('Query##'+query); 
        return Database.getQueryLocator(query);
     }
   /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Account>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Account> listAcc) {
      for(Account acc : listAcc){
          resultNewMap.put(acc.Id, acc.ParentId);
      }
    }
   /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new BatchAddChildAccountsAccessParentId(resultNewMap, resultOldMap,AccountOldTrigger,ParentIDs,operationtype ));
    }
}