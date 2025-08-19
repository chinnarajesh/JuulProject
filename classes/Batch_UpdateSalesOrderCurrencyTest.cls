/*******************************************************************************************
* @Name         Batch_UpdateSalesOrderCurrencyTest
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         03/10/2020
* @Group        JAMS 
* @Description  Test class for Batch_UpdateSalesOrderCurrency class
*******************************************************************************************/
/* MODIFICATION LOG
* Version               Developer               Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas         03/10/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class Batch_UpdateSalesOrderCurrencyTest{
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    
    List<Account> testAccDataToInsert = new List<Account>();
    List<salesOrder__c> testSoDataToInsert = new List<salesOrder__c>();
    
       /**** Creation of Account records *****/ 
        for(Integer i=0; i<5; i++){
            Account accRec = new Account();
            accRec.Name='TestAccount '+i;
            accRec.ShippingStreet = 'Test Street'+i;
            accRec.ShippingCity = 'Test City'+i;
            accRec.ShippingState = 'Test State'+i;
            accRec.ShippingPostalCode ='011'+i;
            accRec.ShippingCountry='US';
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(accRec);
        }
        //insert testAccDataToInsert;
       /**** End of creation of Account records *****/   
       /**** Creation of Sales Order records *****/ 
        for (Integer j=0;j<5;j++) {
            Account acct = testAccDataToInsert[j];
            for (Integer k=0;k<1;k++){
                 SalesOrder__c So  = new SalesOrder__c();
              So.Name = 'Test SalesOrder '+j;
              So.OrderType__c = 'MSA';
              So.Date__c = '2019-02-23';
              So.Customer__c = acct.id;
              So.SOBilling_City__c = 'Billing City+j'; 
              So.SOBilling_Country__c = 'Billing Country+j';
              So.SOBilling_Zip__c = '0000+j';
              So.SOBilling_State__c = 'Billing State+j';
              So.SOBilling_Address_1__c = 'BillingAddress1+j';
              So.SOBilling_Address_2__c = 'BillingAddress2+j';
              So.SOShipping_City__c = 'Shipping City+j'; 
              So.SOShipping_Country__c = 'Shipping Country+j';
              So.SOShipping_Zip__c = '0000+j';
              So.SOShipping_State__c = 'Shipping State+j';
              So.SOShipping_Address_1__c = 'ShippingAddress1+j';
              So.SOShipping_Address_2__c = 'ShippingAddress2+j';            }
         }
         
         for (Integer j=0;j<5;j++) {
            Account acct = testAccDataToInsert[j];
            for (Integer k=0;k<1;k++){
                 SalesOrder__c So1  = new SalesOrder__c();
                So1.Name = 'Test SalesOrder '+j;
              So1.OrderType__c = 'MSA';
              So1.Date__c = '2019-02-23';
              So1.Customer__c = acct.id;
              So1.SOBilling_City__c = 'Billing City+j'; 
              So1.SOBilling_Country__c = 'Billing Country+j';
              So1.SOBilling_Zip__c = '0000+j';
              So1.SOBilling_State__c = 'Billing State+j';
              So1.SOBilling_Address_1__c = 'BillingAddress1+j';
              So1.SOBilling_Address_2__c = 'BillingAddress2+j';
              So1.SOShipping_City__c = 'Shipping City+j'; 
              So1.SOShipping_Country__c = 'Shipping Country+j';
              So1.SOShipping_Zip__c = '0000+j';
              So1.SOShipping_State__c = 'Shipping State+j';
              So1.SOShipping_Address_1__c = 'ShippingAddress1+j';
              So1.SOShipping_Address_2__c = 'ShippingAddress2+j';
            }
         }
         
         for (Integer j=0;j<5;j++) {
            Account acct = testAccDataToInsert[j];
            for (Integer k=0;k<1;k++){
                 SalesOrder__c So2  = new SalesOrder__c();
                 So2.Name = 'Test SalesOrder '+j;
              So2.OrderType__c = 'MSA';
              So2.Date__c = '2019-02-23';
              So2.Customer__c = acct.id;
              So2.SOBilling_City__c = 'Billing City+j'; 
              So2.SOBilling_Country__c = 'Billing Country+j';
              So2.SOBilling_Zip__c = '0000+j';
              So2.SOBilling_State__c = 'Billing State+j';
              So2.SOBilling_Address_1__c = 'BillingAddress1+j';
              So2.SOBilling_Address_2__c = 'BillingAddress2+j';
              So2.SOShipping_City__c = 'Shipping City+j'; 
              So2.SOShipping_Country__c = 'Shipping Country+j';
              So2.SOShipping_Zip__c = '0000+j';
              So2.SOShipping_State__c = 'Shipping State+j';
              So2.SOShipping_Address_1__c = 'ShippingAddress1+j';
              So2.SOShipping_Address_2__c = 'ShippingAddress2+j';
            }
         }
         
         insert testSoDataToInsert;
         
        
        
        
  
    /**** End of creation of Sales Order records *****/
  }  
     /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    private static testMethod void createSO_Test1(){
       Batch_UpdateSalesOrderCurrency UpdateCurrencyBatch = new  Batch_UpdateSalesOrderCurrency();
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
     private static testMethod void createSO_Test2(){
        List<salesOrder__c> listSO = [SELECT Id, SOShipping_Country__c, CurrencyIsoCode FROM salesOrder__c LIMIT 5];
        Map<String, String> mapInputs = new Map<String, String>();
        Batch_UpdateSalesOrderCurrency UpdateCurrencyBatch = new  Batch_UpdateSalesOrderCurrency(mapInputs);
        Database.BatchableContext bc;
            Test.StartTest();
                UpdateCurrencyBatch.start(bc);
                UpdateCurrencyBatch.execute(bc,listSO);
                UpdateCurrencyBatch.finish(bc);
           Test.StopTest(); 
    }
    
    /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    
}