@isTest
public class ActionPlanTemplateDeleteControllerTest {
    static testMethod void testallMethos(){
         
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        insert acc;

        Account acc2 = new Account(Name = 'account1',CurrencyIsoCode = 'USD',
        Type='National Chain Retailer',
        ParentId = acc.id,
        ShippingCountry = 'US',
        ShippingState ='HI',
        BillingCountry ='USA',
        ComplianceMechanism__c='Menthol Ban');
        insert acc2;

        Account acc3 = new Account(Name = 'account2',
        CurrencyIsoCode = 'USD',
        ParentId = acc2.id,
        Type='National Chain Retailer',
        ShippingCountry = 'US',
        ShippingState ='HI',
        BillingCountry ='USA',
        ComplianceMechanism__c='Menthol Ban');
        insert acc3;

        Account acc4 = new Account(Name = 'account3',
        CurrencyIsoCode = 'USD',
        ParentId = acc3.id,
        Type='National Chain Retailer',
        ShippingCountry = 'US',
        ShippingState ='HI',
        BillingCountry ='USA',
        ComplianceMechanism__c='Menthol Ban');
        insert acc4;

        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c = 'US';
        ca.Commercial_Activity_Status__c=true;
        insert ca;

        Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestAP';
        apt.Country__c = 'US';
        apt.RecordTypeId = accountPlanRecordTypeId;
        apt.Status__c ='Planning';
        apt.ActionPlanType__c ='Account Plan';
        apt.AccountID__c=acc.id;
        apt.CommercialActivityId__c=ca.id;
        apt.RequestedStartDate__c = date.newInstance(2020, 07, 02);
        apt.RequestedEndDate__c =date.newInstance(2020, 09, 10);
        insert apt;

        // AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        // aapt.ActionPlanTemplateId__c = apt.id;
        // aapt.Account__c=acc.id;
        // aapt.Grouped_State__c = 'HI';
        // aapt.Grouped_Store_Locations__c = 17;
        // aapt.Active__c = true;
        // insert aapt;
      
        Test.startTest();
          ActionPlanTemplateDeleteController.DeleteactionPlanTemplateRecord(apt.id, true);
          // APTsInStoreLocationsBatchClass wrapp = new APTsInStoreLocationsBatchClass();
          // Database.executeBatch(wrapp,10);
        Test.stopTest();
      }
}