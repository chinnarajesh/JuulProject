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
global class Batch_MSASalesOrderExternalIDUpdate implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
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
      //  Map<String,String> mapInputs1 = new Map<String,String>();
      //  mapInputs1.put('overrideQuery','Id!=null LIMIT 100000');
      //  Database.executeBatch(new Batch_MSASalesOrderExternalIDUpdate(mapInputs), 200);
         database.executebatch(this);
     }
     global Batch_MSASalesOrderExternalIDUpdate(Map<String, String> mapInputs){
         this.mapInputs = mapInputs;
     }
     global Batch_MSASalesOrderExternalIDUpdate(){
         
     }
     global Database.QueryLocator start(Database.BatchableContext bc) {
       String overrideQuery = '';
       String query = 'SELECT Id, MSA_Sales_Order_External_ID__c, Order_Date__c, ';
              query += '(';
              query += 'SELECT Sales_Data__r.Distributor_External_Id__c,Sales_Data__r.Retailer_External_Id__c FROM Document_Details__r where MSA_Shipment_Line_External_ID__c !=null';
              query += ' AND Sales_Data__r.Distributor_External_Id__c <> NULL AND Sales_Data__r.Retailer_External_Id__c <> NULL LIMIT 1';
              query +=')';
              query +=' FROM salesOrder__c';
              query += ' WHERE ';
              query += 'MSA_Sales_Order_External_ID__c = null';
              query += ' AND ';
              query += 'OrderType__c = \'MSA\'';
              query += ' AND ';
              query += 'Order_Date__c != null';
              query += ' AND ';
              query += 'Customer__r.ShippingCountry = \'US\'';
              
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
     global void execute(Database.BatchableContext bc, List<salesOrder__c> listSalesOrder) {
        List<salesOrder__c> listSOToUpdate = new List<salesOrder__c>();
        Document_Details__c ddRec;
        String MM,DD;
        System.debug('listSalesOrder.size() ************* '+listSalesOrder.size());
         for(salesOrder__c  soRec : listSalesOrder){
            System.debug('soRec soRec ********** '+soRec);
            System.debug('soRec.Document_Details__r *********** '+soRec.Document_Details__r);
            System.debug('soRec.Document_Details__r.size() *********** '+soRec.Document_Details__r.size());
            
            if(soRec.Document_Details__r != null && soRec.Document_Details__r.size()>0 ){
                ddRec = soRec.Document_Details__r;
                System.debug('ddRec *************** '+ddRec);
                 MM = String.ValueOf(soRec.Order_Date__c.month()).length() == 1 ? '0'+String.ValueOf(soRec.Order_Date__c.month()) : String.ValueOf(soRec.Order_Date__c.month());
                 DD = String.ValueOf(soRec.Order_Date__c.day()).length() == 1 ? '0'+String.ValueOf(soRec.Order_Date__c.day()) : String.ValueOf(soRec.Order_Date__c.day());
            listSOToUpdate.add(new SalesOrder__c(Id= soRec.Id,
                                                                MSA_Sales_Order_External_ID__c = ddRec.Sales_Data__r.Distributor_External_Id__c
                                                                                               + ddRec.Sales_Data__r.Retailer_External_Id__c 
                                                                                               + String.ValueOf(soRec.Order_Date__c.year())
                                                                                               + MM
                                                                                               + DD
                                                           ));
            }
         } 
         System.debug('listSOToUpdate ************* '+listSOToUpdate);
        if(listSOToUpdate != null && listSOToUpdate.size()>0){
            List<Database.SaveResult> updateSOResults = Database.Update(listSOToUpdate, false); 
            List<Database.Error> listError = new List<Database.Error>();
            for(Integer index = 0, size = updateSOResults.size(); index < size; index++) {
                if(!updateSOResults[index].isSuccess()){
                    listError.addAll(updateSOResults[index].getErrors());
                }
            }
            LogEventTriggerHandler.insertBatchLog(listError, 'Batch_MSASalesOrderExternalIDUpdate', 'execute', 'salesOrders__c', 'Database.Update_Failed');
        }    
    }  
     global void finish(Database.BatchableContext bc){
       
     }
 }