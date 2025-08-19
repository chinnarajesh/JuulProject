/*******************************************************************************************
* @Name         Batch_UpdateDocumentDetailsCurrencyTest
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         03/31/2020
* @Group        JAMS 
* @Description  Test class for Batch_UpdateDocumentDetailsCurrency
*******************************************************************************************/
/* MODIFICATION LOG
* Version               Developer               Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas         03/31/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class Batch_UpdateDocumentDetailsCurrencyTest{
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    
    List<Account> testAccDataToInsert = new List<Account>();
    List<salesOrder__c> testSoDataToInsert = new List<salesOrder__c>();
    List<Document_Details__c> testDDdataToInsert = new List<Document_Details__c>();
      ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
       /**** Creation of Account records *****/ 
        for(Integer i=0; i<5; i++){
            Account accRec = new Account();
            accRec.Name='TestAccount '+i;
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
            testAccDataToInsert.add(accRec);
        }
        insert testAccDataToInsert;
       /**** End of creation of Account records *****/   
       /**** Creation of Sales Order records *****/ 
        for (Integer j=0;j<5;j++) {
            Account acct = testAccDataToInsert[j];
            for (Integer k=0;k<1;k++){
                testSoDataToInsert.add(new salesOrder__c(Name='TestSalesOrder'+k,
                                       Customer__c  = acct.id,
                                       CurrencyIsoCode = 'USD',
                                       SOShipping_Country__c = 'US'));
            }
         }             
         
         insert testSoDataToInsert;      
  
    /**** End of creation of Sales Order records *****/
    
    /**** Creation of Document Details records *****/ 
    
        for (Integer j=0;j<5;j++) {
            salesOrder__c so = testSoDataToInsert[j];
            for (Integer k=0;k<1;k++){
                testDDdataToInsert.add(new Document_Details__c(Name='TestDocumentDetails'+k,
                                       salesOrderNumber__c = so.id,
                                       CurrencyIsoCode = 'CAD'));
            }
         }   
         
         for (Integer j=0;j<5;j++) {
            salesOrder__c so = testSoDataToInsert[j];
            for (Integer k=0;k<1;k++){
                testDDdataToInsert.add(new Document_Details__c(Name='TestDocumentDetails'+k,
                                       salesOrderNumber__c = so.id,
                                       CurrencyIsoCode = 'PKR'));
            }
         }       
        insert testDDdataToInsert;
    /**** End of creation of Sales Order records *****/

  }  
     /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    private static testMethod void createDD_Test1(){
       Batch_UpdateDocumentDetailsCurrency UpdateCurrencyBatch = new  Batch_UpdateDocumentDetailsCurrency();
         Database.BatchableContext bc;        
         SchedulableContext sc;
            Test.StartTest();
                UpdateCurrencyBatch.start(bc);              
                UpdateCurrencyBatch.execute(sc);
                UpdateCurrencyBatch.finish(bc);
           Test.StopTest(); 
    }
   /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createDD_Test2(){
        List<Document_Details__c> listDD = [SELECT Id, salesOrderNumber__r.CurrencyIsoCode, CurrencyIsoCode FROM Document_Details__c LIMIT 5];
        Map<String, String> mapInputs = new Map<String, String>();
        Batch_UpdateDocumentDetailsCurrency UpdateCurrencyBatch = new  Batch_UpdateDocumentDetailsCurrency(mapInputs);
        Database.BatchableContext bc;
            Test.StartTest();
                UpdateCurrencyBatch.start(bc);
                UpdateCurrencyBatch.execute(bc,listDD);
                UpdateCurrencyBatch.finish(bc);
           Test.StopTest(); 
    }
    
    /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    
}