/*******************************************************************************************
* @Name         FetchProductRecordControllerTest
* @Author       Pooja Gite <pooja.gite@juul.com>
* @Date         11/10/2021
* @Description  Test class to cover FetchProductRecordController methods.
*******************************************************************************************/

@isTest
public class FetchProductRecordControllerTest {
    @testSetup static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        accList.add(acc);
        insert accList;
        
        /*Contact cList= new Contact();
        contact c=new Contact();
        c.LastName='Test';
        c.AccountId=acc.Id;
        //cList.add(c);
        insert c;*/
        
        salesOrder__c so = new salesOrder__c();
        so.Name = 'Test';
        so.Customer__c = acc.id;
        insert so;
        
        List<Product2> prList = new List<Product2>();
        Product2 pr = new   Product2();
        pr.Name = 'CA Basic Device Kit Slate';
        prList.add(pr);
        insert prList;
        
        List<Document_Details__c> ddList = new List<Document_Details__c>();
        Document_Details__c doc = new Document_Details__c();
        //doc.Product_Name__c = 'Test';
        doc.Product__c = pr.Id;
        doc.unitPrice__c = 20;
        doc.Update_Quantity__c = 10;
        doc.salesOrderNumber__c = so.id;
        ddList.add(doc);
        insert ddList;
        
        List<FetchProductRecordController.DataWrap> dataWrapList = new List<FetchProductRecordController.DataWrap>();
        FetchProductRecordController.DataWrap dw = new FetchProductRecordController.DataWrap();
        
        List<FetchProductRecordController.Requests> wrapRequestList = new List<FetchProductRecordController.Requests>();
        FetchProductRecordController.Requests req = new FetchProductRecordController.Requests();     
    }
    
    static testMethod void fetchDocDetail(){
        Test.startTest();
        
        List<Document_Details__c> ddList1 = [Select Id,Product__c, Product_Name__c,unitPrice__c,Quantity__c,Update_Quantity__c,Product_Description__c From Document_Details__c];
		FetchProductRecordController.Requests  ddList = new FetchProductRecordController.Requests ();
        ddList.inputCollection = ddList1;
        
        
        FetchProductRecordController.getDocDetails(ddList1[0].id);
        //FetchProductRecordController.fetchRecords(ddList1);
        
        FetchProductRecordController.fetchRecords (new List<FetchProductRecordController.Requests> {ddList});
        
		Test.stopTest();
    }
}