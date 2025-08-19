@isTest
private class CallLWCFromAPTTest {

    @isTest
    static void testTriggerLogic() {
        ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
          
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController); 
        
        Account acct = new Account();
        acct.Name='Test';
        acct.Type='National Chain Retailer';
        acct.ShippingCountry = 'US';
        acct.ShippingState ='HI';
        acct.BillingCountry ='USA';
        acct.ComplianceMechanism__c='Menthol Ban';
        insert acct;
        
		Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestAP';
        apt.Country__c = 'US';
        apt.RecordTypeId = accountPlanRecordTypeId;
        apt.Status__c ='APT Approved & Locked';
        apt.ActionPlanType__c ='Account Plan';
        apt.AccountID__c=acct.id;
        apt.In_Store_Locations_Created__c = true;
        apt.Missions_Created__c = false;
        apt.Mass_Cascade_Flag__c = true;
        apt.Override__c = false;
        apt.STD_JUUL_Funding_Check__c = false;
        apt.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        insert apt;

        /* AccountActionPlanTemplate__c aapt2 = new AccountActionPlanTemplate__c();
        aapt2.ActionPlanTemplateId__c = apt.id;
        aapt2.Active__c = true;
        aapt2.cascadeToDoor__c = true;
        aapt2.Account__c = acct.Id;
		insert aapt2;
        */
        ActionPlanTemplate__c oldAPT = [Select Id,RequestedStartDate__c,RequestedEndDate__c From ActionPlanTemplate__c where id =:apt.id];
        oldAPT.RequestedEndDate__c = System.today().addDays(3);
        oldAPT.RequestedStartDate__c = System.today();
        

        Test.startTest();
        update oldAPT;
        Test.stopTest();

    }
}