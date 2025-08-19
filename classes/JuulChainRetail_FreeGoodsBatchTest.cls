/*******************************************************************************************
* @Name         JuulChainRetail_FreeGoodsBatchTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         05/15/2019
* @Group        Sales Ops
* @Description  Test class for JuulChainRetail_FreeGoodsBatch class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil         05/11/2019         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class JuulChainRetail_FreeGoodsBatchTest{
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    List<Account> testAccDataToInsert = new List<Account>();
     List<Asset> testAssetDataToInsert = new List<Asset>();
     List<Product2> testProdDataToInsert = new List<Product2>();
       /**** Creation of Account records *****/ 
         ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        for(Integer i=0; i<49; i++){
            Account accRec = new Account();
            accRec.Name='TestAccount '+i;
            accRec.ShippingStreet = 'Test Street'+i;
            accRec.ShippingCity = 'Test City'+i;
            accRec.ShippingState = 'Test State'+i;
            accRec.ShippingPostalCode ='945'+i;
            accRec.ShippingCountry='US';
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(accRec);
        }
        insert testAccDataToInsert;
       /**** End of creation of Account records *****/    
       /**** Creation of Product records *****/
        Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Family ='Marketing Assets';
            p.isActive = true;
        testProdDataToInsert.add(p);
         Product2 p1 = new Product2();
            p1.Name = 'Test Product';
            p1.Family ='Marketing Assets';
            p1.isActive = false;
        testProdDataToInsert.add(p1);
        insert testProdDataToInsert;
       /**** End of creation of Product records *****/  
       /**** Creation of Asset records *****/ 
        for (Integer j=0;j<49;j++) {
            Account acct = testAccDataToInsert[j];
            for (Integer k=0;k<1;k++){
                testAssetDataToInsert.add(new Asset(Name=acct.Name + ' Asset ' + k,
                                       Quantity = 10,
                                       BDF_Flow__c = true,
                                       Status = 'Approved',
                                       Product2Id =testProdDataToInsert[0].id,
                                       AccountId=acct.Id));
            }
             for (Integer m=0;m<1;m++){
                testAssetDataToInsert.add(new Asset(Name=acct.Name + ' Asset ' + m,
                                       Quantity = 10,
                                       BDF_Flow__c = true,
                                       Status = 'Approved',
                                       Product2Id =testProdDataToInsert[1].id,
                                       AccountId=acct.Id));
            }
        }
        insert testAssetDataToInsert;
      /**** End of creation of Asset records *****/  
    }
   /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    private static testMethod void createFreeGoods_Test1(){
        List<Asset> listAsset = [Select Id, Asset_Request_Item_Id__c, Product2Id, AccountId, Account.Name, Account.Phone, Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,
                                    Account.ShippingCountry,Account.ShippingPostalCode,Quantity from Asset LIMIT 50];
        JuulChainRetail_FreeGoodsBatch freeGoodBatch = new  JuulChainRetail_FreeGoodsBatch();
         Database.BatchableContext bc;
         SchedulableContext sc;
            Test.StartTest();
                freeGoodBatch.start(bc);
                freeGoodBatch.execute(bc,listAsset);
                freeGoodBatch.execute(sc);
                freeGoodBatch.finish(bc);
           Test.StopTest(); 
    }
   /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createFreeGoods_Test2(){
        List<Asset> listAsset = [Select Id, Asset_Request_Item_Id__c, Product2Id, AccountId, Account.Name, Account.Phone, Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,
                                    Account.ShippingCountry,Account.ShippingPostalCode,Quantity from Asset LIMIT 50];
        Map<String, String> mapInputs = new Map<String, String>();
        JuulChainRetail_FreeGoodsBatch freeGoodBatch = new  JuulChainRetail_FreeGoodsBatch(mapInputs);
         Database.BatchableContext bc;
            Test.StartTest();
                freeGoodBatch.start(bc);
                freeGoodBatch.execute(bc,listAsset);
                freeGoodBatch.finish(bc);
           Test.StopTest(); 
    }
}