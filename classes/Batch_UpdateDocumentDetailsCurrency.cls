/*******************************************************************************************
* @Name         Batch_UpdateDocumentDetailsCurrency
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         3/23/2020
* @Group        JAMS 
* @Description  The batch job gets all the Document Details record and assigns the Relevant Currency code based 
                on its related SalesOrder Currency.
*******************************************************************************************/
/* MODIFICATION LOG
* Version              Developer                  Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas          3/23/2020            Initial Creation
*******************************************************************************************/

global class Batch_UpdateDocumentDetailsCurrency implements Database.Batchable<sObject>, Schedulable {
    /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
     
    List<Document_Details__c> UpdateDDList = new List<Document_Details__c>();
    Map<String, String> mapInputs =  new Map<String, String>();

     
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }           
    
    global Batch_UpdateDocumentDetailsCurrency(Map<String, String> mapInputs){
        this.mapInputs = mapInputs;
    }
    
    global Batch_UpdateDocumentDetailsCurrency(){
        
    }
   

    global Database.QueryLocator start(Database.BatchableContext BC) {            
                       
      String overrideQuery = '';
      String query = 'SELECT Id, salesOrderNumber__r.CurrencyIsoCode, CurrencyIsoCode FROM Document_Details__c';                                
      if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND '+mapInputs.get('overrideQuery');
       }
       query += overrideQuery;  
       return Database.getQueryLocator(query);
        
    }
    
    /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<salesOrder__c>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Document_Details__c> DocDList){       
        if(DocDList!= null && DocDList.size() > 0){
          for(Document_Details__c DOD : DocDList){  
             if(DOD.CurrencyIsoCode != DOD.salesOrderNumber__r.CurrencyIsoCode){
                 DOD.CurrencyIsoCode = DOD.salesOrderNumber__r.CurrencyIsoCode;
                 UpdateDDList.add(DOD);
                 System.debug('***DOD***'+DOD);       

             }
          }                     
        }
       if(UpdateDDList != null && UpdateDDList.size()>0){
              Database.SaveResult[] srList = Database.update(UpdateDDList,false);
              List<Database.Error> listError = new List<Database.Error>();
              for(Integer index = 0, size = srList.size(); index < size; index++) {
                  if(!srList[index].isSuccess()){
                     listError.addAll(srList[index].getErrors());
                  }
              }
              
           LogEventTriggerHandler.insertBatchLog(listError, 'Batch_UpdateDocumentDetailsCurrency', 'execute', 'Document_Details__c', 'Database.Update_Failed');  
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
}