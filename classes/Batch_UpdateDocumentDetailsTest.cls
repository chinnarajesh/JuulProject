/*******************************************************************************************
* @Name         Batch_UpdateDocumentDetailsTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         08/07/2019
* @Group        Sales Ops
* @Description  Test class for Batch_UpdateDocumentDetails class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil         05/11/2019         Initial Creation
*******************************************************************************************/
@isTest(SEEALLDATA = FALSE)
public class Batch_UpdateDocumentDetailsTest {
    @testSetup static void prepData(){
         Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='DocumentDetailTrigger',Enabled__c=true);
        insert(triggerController);
         ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
            Account acc = new Account();
            acc.Name  = 'Test Account';
            acc.Email__c = 'abc'+'@test.com';
            acc.Phone = '1238901234';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert acc;
        List<Product2> listProds = new List<Product2>();
        for(Integer i=0;i<5;i++){
         Product2 p = new Product2();
            p.Name = 'CA Pods Virginia Tobacco 5.0% 2.8ml 4pack';
            p.IsActive = true;
            p.Pod_Strength__c = '5%';
            p.Pod_Pack_Size__c = '4';
            p.Family = 'Pods';
            p.Flavor_Family__c = 'Virginia Tobacco';
        listProds.add(p);    
        }
        insert listProds;
        List<salesOrder__c> listSalesOrdr = new List<salesOrder__c>();
            salesOrder__c so = new salesOrder__c();
            so.Name ='SalesOrdertest';
            so.Customer__c = acc.Id;
            so.Date__c = '04/15/2019';//String.ValueOf(Date.today().addDays(CSValidationPeriod));
         
        insert so;
        List<Document_Details__c> listDDRec = new List<Document_Details__c>();
        for(Integer i=0; i<5;i++){
            Document_Details__c ddRec = new Document_Details__c();
            ddRec.Name='Test Document Detail '+i;
            ddRec.Quantity__c = 4;
            ddRec.Product__c = listProds[i].id;
            ddRec.salesOrderNumber__c = so.id;
            listDDRec.add(ddRec);
        }
        insert listDDRec;
    }
     private static testMethod void updateDocumentDetails_Test1(){
         List<Document_Details__c> listDocDetails = [Select Id, Flavor_Family__c, Pod_Pack_Size__c,Quantity__c,TotalQuantity__c,
                    Total_Flavor_Family_Quantity__c from Document_Details__c LIMIT 5];
         Map<String, String> mapInputs = new Map<String, String>();
        Batch_UpdateDocumentDetails freeGoodBatch = new  Batch_UpdateDocumentDetails(mapInputs);
         Database.BatchableContext bc;
            Test.StartTest();
                freeGoodBatch.start(bc);
                freeGoodBatch.execute(bc,listDocDetails);
                freeGoodBatch.finish(bc);
           Test.StopTest(); 
     }    
}