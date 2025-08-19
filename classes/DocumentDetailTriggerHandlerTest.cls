/*******************************************************************************************
* @Name         DocumentDetailTriggerHandlerTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         08/07/2019
* @Group        Sales Ops
* @Description  Test class for DocumentDetailTriggerHandler class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil         08/07/2019        Initial Creation
*******************************************************************************************/
@isTest(SEEALLDATA = FALSE)
public class DocumentDetailTriggerHandlerTest {
  
  @testSetup static void prepData(){
         Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='DocumentDetailTrigger',Enabled__c=true);
        insert(triggerController);
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
            if(i==1){
                p.Flavor_Family__c = 'Multipack';
            }else{
            p.Flavor_Family__c = 'Virginia Tobacco';
            } 
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
     private static testMethod void DocumentDetailsInsert_Test1(){
       List<Product2> listProds = [Select Id from Product2 LIMIT 5];
       salesOrder__c so = [Select Id from salesOrder__c LIMIT 1];
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
  private static testMethod void DocumentDetailsUpdate_Test1(){
       List<Document_Details__c> listDocDetailsToUpdate = new List<Document_Details__c>();
        List<Document_Details__c> listDocDetails = [Select Id, Flavor_Family__c, Pod_Pack_Size__c,Quantity__c,TotalQuantity__c,
                    Total_Flavor_Family_Quantity__c from Document_Details__c LIMIT 5];
        for(Document_Details__c ddRec : listDocDetails){
            ddRec.Quantity__c = 8;
            listDocDetailsToUpdate.add(ddRec);
        }
        update listDocDetailsToUpdate;
    }
}