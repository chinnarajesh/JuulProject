/*******************************************************************************************
* @Name         Batch_UpdateMSAExternalIDOnDocDetailTest
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         04/02/2020
* @Group        JAMS 
* @Description  Test class for Batch_UpdateMSAExternalIDOnDocDetail
*******************************************************************************************/
/* MODIFICATION LOG
* Version               Developer               Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas         03/31/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class Batch_UpdateMSAExternalIDOnDocDetailTest{ 
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    
    List<Account> testAccDataToInsert = new List<Account>();
    List<salesOrder__c> testSoDataToInsert = new List<salesOrder__c>();
    List<Sales_Data__c> testSalesDataToInsert = new List<Sales_Data__c>();
    List<Document_Details__c> testDDdataToInsert = new List<Document_Details__c>();
    
       /**** Creation of Account records *****/ 
        
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
        
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);   
        
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
    
    /****Creation of Sales Data records ****/
     for (Integer j=0;j<5;j++) {
           
                testSalesDataToInsert.add(new Sales_Data__c(Name='TestSalesName'+j,
                                     //  Date__c  =  String.ValueOf(Date.Today()),
                                        Date__c = '02/2/2020',
                                       Product__c = 'ProductTest'+j,
                                       Distributor_External_Id__c ='Ext'+j,
                                       Retailer_External_Id__c ='Ret'+j));
            
         }   
     insert testSalesDataToInsert;      
    /****End of Sales Data records ****/
    
    /**** Creation of Document Details records *****/ 
    
        
         for (Integer j=0;j<5;j++) {
            salesOrder__c so = testSoDataToInsert[j];
            Sales_Data__c sd = testSalesDataToInsert[j];
            for (Integer k=0;k<1;k++){
                testDDdataToInsert.add(new Document_Details__c(Name='TestDocumentDetails'+k,
                                       Sales_Data__c = sd.id,
                                       salesOrderNumber__c = so.id,
                                       MSA_Shipment_Line_External_ID__c = null));
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
       Batch_UpdateMSAExternalIDOnDocDetail UpdateMSA = new  Batch_UpdateMSAExternalIDOnDocDetail();
         Database.BatchableContext bc;        
         SchedulableContext sc;
            Test.StartTest();
                UpdateMSA.start(bc);              
                UpdateMSA.execute(sc);
                UpdateMSA.finish(bc);
           Test.StopTest(); 
    }
   /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createDD_Test2(){
        List<Document_Details__c> listDD = [SELECT Id, Sales_Data__r.Distributor_External_Id__c, Sales_Data__r.Retailer_External_Id__c, Sales_Data__r.Product__c, Sales_Data__r.Date__c FROM Document_Details__c LIMIT 5];
        Map<String, String> mapInputs = new Map<String, String>();
        Batch_UpdateMSAExternalIDOnDocDetail UpdateMSA = new  Batch_UpdateMSAExternalIDOnDocDetail(mapInputs);
        Database.BatchableContext bc;
            Test.StartTest();
                UpdateMSA.start(bc);
                UpdateMSA.execute(bc,listDD);
                UpdateMSA.finish(bc);
           Test.StopTest(); 
    }
    
    /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    
}