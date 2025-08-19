/*****************************************************************************************************/
/* Mehod Name : fetchDocumentDetailsTest
/* Description : Test class for fetchDocumentDetails.
/* Added By : Pooja Gite
/*****************************************************************************************************/
@isTest
public class fetchDocumentDetailsTest {
     @testSetup static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        
       
     }
 	static testMethod void fetchDocDetail(){
        Test.startTest();
         List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        acc.ShippingCountry= 'US';
        accList.add(acc);
        insert accList;
        
        //Lisst<Contact> cList= new Contact();
        contact c=new Contact();
        c.LastName='Test';
        c.AccountId=acc.Id;
        //cList.add(c);
        insert c;
        
        salesOrder__c so = new salesOrder__c();
        so.Name = 'Test';
        so.Customer__c = acc.id;
        so.Customer_PO_Number__c = '1234';
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
        List<ID> ddIds = new List<ID>();
        for(Document_Details__c d : ddList)
        {
            ddIds.add(d.id);
        }
        
        List<Case> newCases = new List<Case>();
        Case cs = new Case();
			cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B RMA').getRecordTypeId();
            cs.Sales_Order__c = so.Id;
            cs.Description = '4-hrs';
            cs.Return_Reason__c = 'Overage';
            cs.Type = 'Overage';
            cs.AccountId = acc.id;
			cs.Total_Shipment_Weight__c = 6;
            cs.Status = 'Approved';
            cs.ContactId =c.id ;
            cs.Market__c = So.Customer__r.ShippingCountry;
            newCases.add(cs);
        if(newCases!=null)
        	insert newCases;
        
        List<Return_Order__c> roList = new List<Return_Order__c>();
        Return_Order__c ro = new Return_Order__c();
            if(cs.id!=null)
        	ro.Case__c = cs.Id;
            ro.PO__c = So.Customer_PO_Number__c;
            ro.Quantity_of_Boxes__c = 7;
            ro.Quantity_of_Pallets__c = 5;
            roList.add(ro);
        	insert roList;
        
		List<Return_Document_Detail__c> RDDList = new List<Return_Document_Detail__c>();
        Return_Document_Detail__c rdd = new Return_Document_Detail__c();
       		rdd.Return_Order__c = ro.Id;
            rdd.Return_Product__c = doc.product__c;
            rdd.Reported_Quantity__c = doc.Update_Quantity__c;
            rdd.Reported_Unit_Price__c = doc.unitPrice__c;
            RDDList.add(rdd);
        	insert RDDList;     
        
        fetchDocumentDetails.getDocDetails(so.Id);
       	//fetchDocumentDetails.createCase(so.Id,List<Id> ddList);
       	String PLvalue = 'Overage';
        String radioVal ='Yes';
        String totalweight ='1';
        String totalpallet ='2';
         String pickUpHrs = '1';
        String totalBox ='1';
        fetchDocumentDetails.createCase(so.Id, ddIds, PLvalue, radioVal, totalBox, totalweight, totalpallet,  pickUpHrs);
        
        Test.stopTest();
 }

}