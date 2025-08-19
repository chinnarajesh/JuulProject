/*******************************************************************************************
* @Name         Batch_UpdateDocumentDetails
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         08/07/2019
* @Group        Sales Ops
* @Description  A batch job will update Total Quantity fields at document details.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          08/07/2019            Initial Creation
*******************************************************************************************/
global class Batch_UpdateDocumentDetails implements Database.Batchable<sObject>, Database.Stateful{
    Map<String, String> mapInputs =  new Map<String, String>();
    global Batch_UpdateDocumentDetails(Map<String, String> mapInputs){
        this.mapInputs = mapInputs;
    }
    global Batch_UpdateDocumentDetails(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
      String overrideQuery = '';
      String query = 'Select Id, Flavor_Family__c, Pod_Pack_Size__c,Quantity__c,TotalQuantity__c,Total_Flavor_Family_Quantity__c from Document_Details__c ';
             query += 'WHERE ';
             query += 'salesOrderNumber__r.CreatedDate = LAST_N_DAYS : '+Label.Last_No_of_Days;
             query += ' AND ';
             query += 'Flavor_Family__c != null';
             query += ' AND ';
             query += 'Pod_Pack_Size__c != null';
             query += ' AND ';
             query += '(';
             query += 'TotalQuantity__c = null OR Total_Flavor_Family_Quantity__c = null';
             query += ')';
         if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND '+mapInputs.get('overrideQuery');
        }
       query += overrideQuery;      
       System.debug('query ***************** '+query);
       return Database.getQueryLocator(query);
    }
   

    global void execute(Database.BatchableContext bc, List<Document_Details__c> listDoc) {
        List<Document_Details__c> listDocToUpdate = new List<Document_Details__c>();
        for(Document_Details__c docDetailRec : listDoc){
            if(docDetailRec.Quantity__c <> NULL && docDetailRec.Flavor_Family__c <> NULL){
                if(docDetailRec.Flavor_Family__c== 'Multipack'){
                    docDetailRec.TotalQuantity__c =  Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;
                    docDetailRec.Total_Flavor_Family_Quantity__c = docDetailRec.Quantity__c;  
                 }else{
                    docDetailRec.TotalQuantity__c =  Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;
                    docDetailRec.Total_Flavor_Family_Quantity__c = Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;  
                 } 
                 listDocToUpdate.add(docDetailRec);
              } 
         }
         if(listDocToUpdate != null && listDocToUpdate.size()>0){
             Database.Update(listDocToUpdate, false);
         }
     }   
    global void finish(Database.BatchableContext bc){
   
    }
}