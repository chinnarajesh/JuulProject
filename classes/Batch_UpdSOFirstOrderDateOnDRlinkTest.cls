/*******************************************************************************************
* @Name         Batch_UpdSOFirstOrderDateOnDRlink
* @Author       Preetha Barnabas <Preetha.Barnabas@juul.com>
* @Date         04/03/2020
* @Group        JAMS 
* @Description  Test class for Batch_UpdateSOFirstOrderDateOnDRlink
*******************************************************************************************/
/* MODIFICATION LOG
* Version               Developer               Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Preetha Barnabas         04/03/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class Batch_UpdSOFirstOrderDateOnDRlinkTest{
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    
    List<Account> testRetailerDataToInsert = new List<Account>();
    List<Account> testDistributorDataToInsert = new List<Account>();
    List<Distributor_Retailer_Link__c> testDisRetDataToInsert = new List<Distributor_Retailer_Link__c>();
    List<SalesOrder__c> testSODataToInsert = new List<SalesOrder__c>();
    List<SalesOrder__c> testSOToInsertData = new List<SalesOrder__c>();
     ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
    
       /**** Creation of Retailer records *****/ 
        for(Integer i=0; i<5; i++){
            Account accRec = new Account();
            accRec.Name='TestAccountRetailer '+i;
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Regional Chain Retailer').getRecordTypeId();
            testRetailerDataToInsert.add(accRec);
        }
        insert testRetailerDataToInsert;
       /**** End of creation of Retailer records *****/   
       
        /**** Creation of Distributor records *****/ 
        for(Integer i=0; i<5; i++){
            Account accRec = new Account();
            accRec.Name='TestAccountDistributor'+i;
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
            testDistributorDataToInsert.add(accRec);
        }
        insert testDistributorDataToInsert;
       /**** End of creation of Distributor records *****/   
       
       /**** Creation of DistributorRetailerLink records *****/ 
            
                for(Integer i=0; i<5; i++){
                 Account actRet = testRetailerDataToInsert[i];
                 Account actDis = testDistributorDataToInsert[i];
                   Distributor_Retailer_Link__c DRL = new Distributor_Retailer_Link__c();
                   DRL.Distributor__c= testDistributorDataToInsert[i].id;
                   DRL.Retailer__c = testRetailerDataToInsert[i].id;
                   DRL.First_Sales_Order_Date__c = null;
                   DRL.Link_Status__c = 'Active';
                   DRL.External_ID__c = testDistributorDataToInsert[i].id+'_'+testRetailerDataToInsert[i].id;
                   testDisRetDataToInsert.add(DRL);
                } 
            
        insert testDisRetDataToInsert;
       /**** End of creation of DistributorRetailerLink records *****/   
       
        /**** Creation of SalesOrder records *****/ 
            for(Integer j=0; j<5; j++){
              Account actRet = testRetailerDataToInsert[j];
              Account actDis = testDistributorDataToInsert[j];
                for(Integer i=0; i<5; i++){
                  SalesOrder__c SO = new SalesOrder__c();
                  SO.Name='TestSalesOrderRetailer'+i;
                  SO.Customer__c = actRet.id;
                  SO.Distributor__c = actDis.id;
                  SO.Date__c = '2019-07-13';
                  testSODataToInsert.add(SO);
                } 
            }
        insert testSODataToInsert;
        
       
        
       /**** End of creation of SalesOrder records *****/   
       
       /**** Creation of SalesOrder records *****/ 
           for(Integer j=0; j<5; j++){
              Account actRet = testRetailerDataToInsert[j];
              Account actDis = testDistributorDataToInsert[j];
                for(Integer i=0; i<5; i++){
                  SalesOrder__c SO = new SalesOrder__c();
                  SO.Name='TestSalesOrderDistributor'+i;
                  SO.Customer__c = actDis.id;
                  SO.Distributor__c = actDis.id;
                  SO.Date__c = '2019-07-10';
                  testSOToInsertData.add(SO);
                } 
            }
        insert testSOToInsertData;
       /**** End of creation of SalesOrder records *****/   
       
      
      

  }  
     /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    private static testMethod void createDD_Test1(){
       Batch_UpdateSOFirstOrderDateOnDRlink UpdateDRlink = new  Batch_UpdateSOFirstOrderDateOnDRlink();
         Database.BatchableContext bc;        
         SchedulableContext sc;
            Test.StartTest();
                UpdateDRlink.start(bc);              
                UpdateDRlink.execute(sc);
                UpdateDRlink.finish(bc);
           Test.StopTest(); 
    }
   /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createDD_Test2(){
        List<Distributor_Retailer_Link__c> listDrl = [SELECT Distributor__c, Retailer__c,External_ID__c,First_Sales_Order_Date__c FROM Distributor_Retailer_Link__c LIMIT 5];
        Map<String, String> mapInputs = new Map<String, String>();
        Batch_UpdateSOFirstOrderDateOnDRlink UpdateDRlink = new  Batch_UpdateSOFirstOrderDateOnDRlink();
        Database.BatchableContext bc;
            Test.StartTest();
                UpdateDRlink.start(bc);
                UpdateDRlink.execute(bc,listDrl);
                UpdateDRlink.finish(bc);
           Test.StopTest(); 
    }
    
    /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    
}