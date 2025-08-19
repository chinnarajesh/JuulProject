/*******************************************************************************************
* @Name         Batch_UpdateSalesOrderCurrency
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         2/27/2020
* @Group        JAMS 
* @Description  The batch job gets all the Sales Order record and assigns the Relevant Currency code based on the Shipping country. 
                Country code is retrived from the Custom Metadata 'Currency Code'.
*******************************************************************************************/
/* MODIFICATION LOG
* Version              Developer                  Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas          2/27/2020            Initial Creation
*******************************************************************************************/

global class Batch_UpdateSalesOrderCurrency implements Database.Batchable<sObject>, Schedulable {
    /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
     
    List<salesOrder__c> listsalesOrderToUpdate = new List<salesOrder__c>();
    List<salesOrder__c> UpdateSOList = new List<salesOrder__c>();
    Map<String, String> mapInputs =  new Map<String, String>();
    Map<String,String> mapCountryCurrency = new Map<String,String>(); 
    String loadOneTime = 'N'; 
     
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }           
    
    global Batch_UpdateSalesOrderCurrency(Map<String, String> mapInputs){
        this.mapInputs = mapInputs;
    }
    global Batch_UpdateSalesOrderCurrency(){
        
    }
   

    global Database.QueryLocator start(Database.BatchableContext BC) {                          
         
      String overrideQuery = '';
      String query = 'SELECT Id, SOShipping_Country__c, CurrencyIsoCode FROM salesOrder__c';
             query += ' WHERE';
             query += ' SOShipping_Country__c != NULL';                             
      if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND '+mapInputs.get('overrideQuery');
       }
       
       query += overrideQuery; 
       System.debug('query query *************** '+query); 
       return Database.getQueryLocator(query);
        
    }
    
    /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<salesOrder__c>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<salesOrder__c> SOList) {
    List<Database.Error> listCountryMismatch = new List<Database.Error>();
    if(loadOneTime == 'N'){ 
        loadOneTime = 'Y'; 
        List<Currency_Code__mdt> cCode = getCurrencyCode();
        if(cCode != null && cCode.size() > 0){
           for(Currency_Code__mdt cur : cCode){
               mapCountryCurrency.put(cur.Country_Code__c,cur.Currency_Code__c);
           }
         }
       }  
        System.debug(mapCountryCurrency+'*****mapCountryCurrency******');
        if(SOList != null && SOList.size() > 0 && mapCountryCurrency.size() > 0){
          for(salesOrder__c SO : SOList){  
             if(mapCountryCurrency.containsKey(SO.SOShipping_Country__c)){      
                 if(mapCountryCurrency.get(SO.SOShipping_Country__c) != null && SO.CurrencyIsoCode != mapCountryCurrency.get(SO.SOShipping_Country__c)){
                     SO.CurrencyIsoCode = mapCountryCurrency.get(SO.SOShipping_Country__c);
                     UpdateSOList.add(SO);
                } 
             }                     
          }
        }
        
       if(UpdateSOList != null && UpdateSOList.size()>0){
              Database.SaveResult[] srList = Database.update(UpdateSOList,false);
              List<Database.Error> listError = new List<Database.Error>();
              for(Integer index = 0, size = srList.size(); index < size; index++) {
               if(!srList[index].isSuccess()){
                 listError.addAll(srList[index].getErrors());
               }
           }
              
           LogEventTriggerHandler.insertBatchLog(listError, 'Batch_UpdateSalesOrderCurrency', 'execute', 'salesOrder__c', 'Database.Update_Failed');  
          }
        }
          
        
        
      
     /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
    //execute any post-processing operations
     
  }
  public static List<Currency_Code__mdt> getCurrencyCode(){
      return [select Country_Code__c, Currency_Code__c from Currency_Code__mdt];
  }
}