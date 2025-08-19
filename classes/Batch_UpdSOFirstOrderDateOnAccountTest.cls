/*******************************************************************************************
* @Name         Batch_UpdSOFirstOrderDateOnAccountTest
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         04/03/2020
* @Group        JAMS 
* @Description  Test class for Batch_UpdSOFirstOrderDateOnAccount
*******************************************************************************************/
/* MODIFICATION LOG
* Version               Developer               Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas         04/03/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class Batch_UpdSOFirstOrderDateOnAccountTest{
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    
    List<Account> testAccDataToInsert = new List<Account>();
    List<SalesOrder__c> testSODataToInsert = new List<SalesOrder__c>();
    Set<Account> myset = new Set<Account>();
     ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
    
       /**** Creation of Account records *****/ 
        for(Integer i=0; i<5; i++){
            Account accRec = new Account();
            accRec.SO_Minimum_Order_Date__c = null;
            accRec.Name='TestAccount '+i;
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Regional Chain Retailer').getRecordTypeId();
            testAccDataToInsert.add(accRec);
        }
        insert testAccDataToInsert;
       /**** End of creation of Account records *****/   
       
        /**** Creation of SalesOrder records *****/ 
            for(Integer j=0; j<5; j++){
              SalesOrder__c SO = new SalesOrder__c();
              SO.Name='TestSalesOrder'+j;
              SO.Customer__c = testAccDataToInsert[0].id;
              SO.Date__c = '2019-07-13';
              testSODataToInsert.add(SO);
            } 
        
        insert testSODataToInsert;
       /**** End of creation of SalesOrder records *****/   
      

  }  
     /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    private static testMethod void createDD_Test1(){
       Batch_UpdateSOFirstOrderDateOnAccount UpdateSOFirstOrderDate = new  Batch_UpdateSOFirstOrderDateOnAccount();
         Database.BatchableContext bc;        
         SchedulableContext sc;
            Test.StartTest();
                UpdateSOFirstOrderDate.start(bc);              
                UpdateSOFirstOrderDate.execute(sc);
                UpdateSOFirstOrderDate.finish(bc);
           Test.StopTest(); 
    }
   /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createDD_Test2(){
        List<Account> listAcc = [SELECT Id, SO_Minimum_Order_Date__c FROM Account LIMIT 5];
        Map<String, String> mapInputs = new Map<String, String>();
        Batch_UpdateSOFirstOrderDateOnAccount UpdateSOFirstOrderDate = new  Batch_UpdateSOFirstOrderDateOnAccount(mapInputs);
        Database.BatchableContext bc;
            Test.StartTest();
                UpdateSOFirstOrderDate.start(bc);
                UpdateSOFirstOrderDate.execute(bc,listAcc);
                UpdateSOFirstOrderDate.finish(bc);
           Test.StopTest(); 
    }
    
    /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    
}