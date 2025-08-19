/*******************************************************************************************
* @Name         Batch_UpdateMSAExternalIDOnDocDetail
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         04/01/2020
* @Group        Sales Ops
* @Description  A batch job will update the MSA_Shipment_Line_External_ID__c field on Document Details object.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          04/01/2020            Initial Creation
*******************************************************************************************/
global class Batch_UpdateMSAExternalIDOnDocDetail implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
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
     global Batch_UpdateMSAExternalIDOnDocDetail(Map<String, String> mapInputs){
         this.mapInputs = mapInputs;
     }
     global Batch_UpdateMSAExternalIDOnDocDetail(){
         
     }
     global Database.QueryLocator start(Database.BatchableContext bc) {
       String overrideQuery = '';
       String query = 'SELECT Id, Sales_Data__r.Distributor_External_Id__c, Sales_Data__r.Retailer_External_Id__c, Sales_Data__r.Product__c, Sales_Data__r.Date__c  FROM Document_Details__c';
              query += ' WHERE ';
              query += 'MSA_Shipment_Line_External_ID__c = null';
              query += ' AND ';
              query += 'Sales_Data__r.Distributor_External_Id__c != null';
              query += ' AND ';
              query += 'Sales_Data__r.Retailer_External_Id__c != null';
              query += ' AND ';
              query += 'Sales_Data__r.Product__c != null';
              query += ' AND ';
              query += 'Sales_Data__r.Date__c != null';
              query += ' AND ';
              query += 'Sales_Data__c != null';

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
     global void execute(Database.BatchableContext bc, List<Document_Details__c> listDocDetails) {
        List<Document_Details__c> listDocDetailsToUpdate = new List<Document_Details__c>();
      //  Date SDDate;
        List<String> listStr;
         for(Document_Details__c  ddRec : listDocDetails) {
            if(ddRec.Sales_Data__r.Date__c != null){
              listStr = ddRec.Sales_Data__r.Date__c.split('/');
            }
            String YYYY = listStr[2].length() == 2 ? '20'+listStr[2] : listStr[2];
            String MM = listStr[0].length() == 1 ? '0'+listStr[0] : listStr[0];
            String DD = listStr[1].length() == 1 ? '0'+listStr[1] : listStr[1];
            
            
            listDocDetailsToUpdate.add(new Document_Details__c(Id= ddRec.Id,
                                                              MSA_Shipment_Line_External_ID__c = ddRec.Sales_Data__r.Distributor_External_Id__c
                                                                                               + ddRec.Sales_Data__r.Retailer_External_Id__c 
                                                                                               + ddRec.Sales_Data__r.Product__c
                                                                                               + (YYYY+MM+DD)
                                                              ));
             } 
            if(listDocDetailsToUpdate != null && listDocDetailsToUpdate.size()>0){
                List<Database.SaveResult> updateDocDetailResults = Database.Update(listDocDetailsToUpdate, false); 
                List<Database.Error> listError = new List<Database.Error>();
                for(Integer index = 0, size = updateDocDetailResults.size(); index < size; index++) {
                    if(!updateDocDetailResults[index].isSuccess()){
                        listError.addAll(updateDocDetailResults[index].getErrors());
                    }
                }
                LogEventTriggerHandler.insertBatchLog(listError, 'Batch_UpdateMSAExternalIDOnDocDetail', 'execute', 'Document_Details__c', 'Database.Update_Failed');
            }     
     }   
    /**************************************************************************************
     * @Description this method executes any post processing tasks
     * @Param   Database.BatchableContext
     * @Return  --none--
     **************************************************************************************/
     global void finish(Database.BatchableContext bc){
       
     }
 }