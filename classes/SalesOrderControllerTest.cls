/*******************************************************************************************
* @Name         SalesOrderControllerTest
* @Author       Pooja Gite <pooja.gite@juul.com>
* @Description  Test class to cover SalesOrderController methods.
*******************************************************************************************/

@isTest
public class SalesOrderControllerTest {
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
        
        salesOrder__c so = new salesOrder__c();
        so.Name = 'Test';
        so.Customer__c = acc.id;
     	so.Customer_PO_Number__c = '12345';
        //so.Order_Date__c = 2021-01-30;
        insert so;
 }
     static testMethod void fetchSODetails(){
         Test.startTest();
         List<Account> accList1 = [Select ID, Name from Account];
         
         SalesOrderController.getSalesOrder(accList1[0].id);
         Test.stopTest();
     }

}