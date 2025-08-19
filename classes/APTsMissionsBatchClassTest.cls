@isTest
public class APTsMissionsBatchClassTest {

   @testsetup
    static void setup(){
		 ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=false);
        insert(triggerController1);
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=false);
        insert(triggerController2);
        Trigger_Controller__c triggerController3 = new Trigger_Controller__c(Name='dlrs_InStoreLocationTrigger',Enabled__c=false);
        insert(triggerController3);
        Trigger_Controller__c triggerController4 = new Trigger_Controller__c(Name='dlrs_AccountActionPlanTemplateTrigger',Enabled__c=false);
        insert(triggerController4);
        Trigger_Controller__c triggerController5 = new Trigger_Controller__c(Name='CommercialActivityPrdTrigger',Enabled__c=false);
        insert(triggerController5);
         
      Account acct = new Account();
        acct.Name='Test';
        acct.Type='National Chain Retailer';
        acct.ShippingCountry = 'US';
        acct.ShippingState ='HI';
        acct.BillingCountry ='USA';
        acct.ComplianceMechanism__c='Menthol Ban';
        insert acct;
        
        Account acc1 = new Account(Name = 'account1',CurrencyIsoCode = 'USD',
                                   Type='National Chain Retailer',
                                   ParentId = acct.id,
                                   ShippingCountry = 'US',
                                   ShippingState ='HI',
                                   BillingCountry ='USA',
                                   ComplianceMechanism__c='Menthol Ban');
        insert acc1;
        Account acc2 = new Account(Name = 'account2',
                                   CurrencyIsoCode = 'USD',
                                   ParentId = acc1.id,
                                   Type='HQ',
                                   ShippingCountry = 'US',
                                   ShippingState ='HI',
                                   BillingCountry ='USA',
                                   ComplianceMechanism__c='Menthol Ban');
        insert acc2;
        
        Account acc3 = new Account(Name = 'account3',
                                   CurrencyIsoCode = 'USD',
                                   ParentId = acc2.id,
                                   Type='National Chain Retailer',
                                   ShippingCountry = 'US',
                                   ShippingState ='HI',
                                   BillingCountry ='USA',
                                   ComplianceMechanism__c='Menthol Ban');
        insert acc3;
        System.debug('acc1++ '+acc1);
        System.debug('acc2++ '+acc2);
        System.debug('acc3++ '+acc3);

         
         List<Product2> prodList = new List<Product2>();
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        p.cgcloud__Description_1_Language_1__c = 'test';
        prodList.add(p);
        
        Product2 p1= new Product2();
        p1.name= 'Test Items2';
        p1.Family='Accessories';
        p1.IsActive = true;
        p1.Product_Country__c = 'US';
        p1.ProductPricingFamily__c='DK';
        p1.US_E_Order_Enabled__c = true;
        p1.cgcloud__Description_1_Language_1__c = 'test';
        prodList.add(p1);
		
        Product2 p2= new Product2();
        p2.name= 'Test Items3';
        p2.Family='Accessories';
        p2.IsActive = true;
        p2.Product_Country__c = 'US';
        p2.ProductPricingFamily__c='DK';
        p2.US_E_Order_Enabled__c = true;
        p2.cgcloud__Description_1_Language_1__c = 'test';
        prodList.add(p2);
        insert prodList;
        
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c='US';
        ca.IsActive__c = true;
        ca.Commercial_Activity_Status__c = true;
        insert ca;
       
        
        
        Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        Id promoRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Promotional Activity Process').getRecordTypeId();
        //Id resetRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Reset Activity Process').getRecordTypeId();
        
        List<ActionPlanTemplate__c> aptList = new List<ActionPlanTemplate__c>();
         ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestAP';
        apt.Country__c = 'US';
        apt.RecordTypeId = accountPlanRecordTypeId;
        apt.Status__c ='APT Approved & Locked';
        apt.ActionPlanType__c ='Account Plan';
        apt.AccountID__c=acct.id;
        apt.In_Store_Locations_Created__c = true;
        apt.Missions_Created__c = false;
        apt.In_Store_Locations_Refreshed__c=true;
        apt.Mass_Cascade_Flag__c = true;
        apt.CommercialActivityId__c=ca.id;
        //apt.StoreAssortment__c = storeAssort.id;
        apt.Override__c = false;
        apt.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt.STD_JUUL_Funding_Check__c = false;
        apt.RequestedStartDate__c = System.today().addDays(10);
        apt.RequestedEndDate__c =System.today().addDays(30);
        apt.Total_Mission__c=10;
        apt.Total_Instorelocations__c=10;
        //aptList.add(apt);
        System.debug('RDate1 is'+apt.RequestedStartDate__c);
        insert apt;
        System.debug('apt++'+apt);
        
         ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name ='TestPromo';
        apt1.Country__c = 'US';
        apt1.RecordTypeId = promoRecordTypeId;
        apt1.Status__c ='APT Approved & Locked';
        apt1.ActionPlanType__c ='Promotional Activity Process';
        apt1.CommercialActivityId__c=ca.id;
        apt1.AccountId__c=acc2.id;
        apt1.In_Store_Locations_Created__c = true;
        apt1.Missions_Created__c = false;
        apt1.In_Store_Locations_Refreshed__c=true;
        apt1.Mass_Cascade_Flag__c = true;
        //apt1.StoreAssortment__c = storeAssort1.id;
		apt1.Override__c = false;
        apt1.STD_JUUL_Funding_Check__c = false;
        apt1.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt1.RequestedStartDate__c = System.today().addDays(10);
        apt1.RequestedEndDate__c =System.today().addDays(30);
        apt1.Total_Mission__c=20;
        apt1.Total_Instorelocations__c=10;
        //aptList.add(apt1);
        System.debug('RDate is'+apt1.RequestedStartDate__c);
        insert apt1;
         System.debug('apt1++'+apt1);
              
         List<ActionPlanTemplateItem__c> aptiList = new List<ActionPlanTemplateItem__c>();
        ActionPlanTemplateItem__c aptItem = new ActionPlanTemplateItem__c();
        aptItem.ActionPlanTemplateId__c = apt1.Id;
        aptItem.Subject__c = 'Test';
        aptItem.Priority__c = 'Normal';
        aptItem.Required__c = true;
        aptItem.Description__c = 'test';
        aptItem.Comments__c = 'test';
        //aptItem.CurrencyIsoCode = 
        aptiList.add(aptItem);
        
        ActionPlanTemplateItem__c aptItem1 = new ActionPlanTemplateItem__c();
        aptItem1.ActionPlanTemplateId__c = apt1.Id;
        aptItem1.Subject__c = 'Task';
        aptItem1.Priority__c = 'High';
        aptItem1.Required__c = true;
        aptItem1.Description__c = 'test';
        aptItem1.Comments__c = 'test';
        aptiList.add(aptItem1);
        
        ActionPlanTemplateItem__c aptItem2 = new ActionPlanTemplateItem__c();
        aptItem2.ActionPlanTemplateId__c = apt1.Id;
        aptItem2.Subject__c = 'Test';
        aptItem2.Priority__c = 'Normal';
        aptItem2.Required__c = true;
        aptItem2.Description__c = 'test';
        aptItem2.Comments__c = 'test';
        aptiList.add(aptItem2);
        
        ActionPlanTemplateItem__c aptItem3 = new ActionPlanTemplateItem__c();
        aptItem3.ActionPlanTemplateId__c = apt1.Id;
        aptItem3.Subject__c = 'Task';
        aptItem3.Priority__c = 'High';
        aptItem3.Required__c = true;
        aptItem3.Description__c = 'test';
        aptItem3.Comments__c = 'test';
        aptiList.add(aptItem3);
        
        ActionPlanTemplateItem__c aptItem4 = new ActionPlanTemplateItem__c();
        aptItem4.ActionPlanTemplateId__c = apt1.Id;
        aptItem4.Subject__c = 'Test';
        aptItem4.Priority__c = 'Normal';
        aptItem4.Required__c = true;
        aptItem4.Description__c = '<p>asdf</p>';
        aptItem4.Comments__c = 'test';
        aptItem4.Sequence__c = 12;
        aptiList.add(aptItem4);
        
        ActionPlanTemplateItem__c aptItem5 = new ActionPlanTemplateItem__c();
        aptItem5.ActionPlanTemplateId__c = apt1.Id;
        aptItem5.Subject__c = 'Task';
        aptItem5.Priority__c = 'High';
        aptItem5.Required__c = true;
        aptItem5.Description__c = 'test';
        aptItem5.Comments__c = 'test';
        aptiList.add(aptItem5);
        insert aptiList;
       
        ActionPlan__c  AP = new ActionPlan__c ();
        AP.ActionPlanTemplateId__c = apt.Id;
        AP.Status__c = 'Planned';
        insert AP;
         
        
        
        StateTerritory__c st = new StateTerritory__c();
        st.Country__c = 'US';
        st.StateTerritoryName__c = 'Hawaii';
        st.Name = 'Hawaii';
        st.StateISO2__c='HI';
        insert st;
        
         List<AccountActionPlanTemplate__c> aaptList = new List<AccountActionPlanTemplate__c>();
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = apt.id;
        //aapt.RetailLocationId__c = rsg.id;
        aapt.Account__c = acct.Id;
        aapt.Grouped_State__c = 'HI';
        aapt.cascadeToDoor__c = false;
        aapt.Active__c = true;
        //aaptList.add(aapt);
        insert aapt;
        System.debug('aapt Id++ '+aapt);
        
        AccountActionPlanTemplate__c aapt1 = new AccountActionPlanTemplate__c();
        aapt1.ActionPlanTemplateId__c = apt.id;
        //aapt1.RetailLocationId__c = rsg1.id;
		    aapt1.Account__c = acct.Id;
        aapt1.Grouped_State__c = 'HI';
        aapt1.cascadeToDoor__c = true;
        aapt1.Active__c = true;
        //aaptList.add(aapt1);
        insert aapt1;
        
        AccountActionPlanTemplate__c aapt2 = new AccountActionPlanTemplate__c();
        aapt2.ActionPlanTemplateId__c = apt.id;
        //aapt2.RetailLocationId__c = rsg2.id;
        aapt2.Active__c = true;
         aapt2.Grouped_State__c = 'HI';
         aapt2.cascadeToDoor__c = true;
        aapt2.Account__c = acct.Id;
        aaptList.add(aapt2);
        insert aapt2;
        System.debug('aapt1++ '+aapt1);
        System.debug('aapt2++ '+aapt2);
        //insert aaptList;
       
        List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acct.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c = system.today();        
        sl.EndDate__c =System.today().addDays(3);
        //sl.PlanogramId__c=plano.id;
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        //ISLList.add(sl);
        insert sl;
        System.debug('Sl Id++ '+sl);
        
        InStoreLocation__c sl1 = new InStoreLocation__c();
        sl1.RetailStoreGroupActionPlanTemplate__c = aapt1.id;
        sl1.RetailLocationId__c = acc2.id;
        sl1.Active__c = True;
        sl1.Category__c='Promotion';
        sl1.StartDate__c = system.today();        
        sl1.EndDate__c =System.today().addDays(3);
       // sl1.PlanogramId__c=plano.id;
        sl1.InStoreLocationType__c = 'Planogram Specific';
        sl1.Status__c ='Planned'; 
        //ISLList.add(sl1);
        insert sl1;
        
        InStoreLocation__c sl2 = new InStoreLocation__c();
        sl2.RetailStoreGroupActionPlanTemplate__c = aapt2.id;
        sl2.RetailLocationId__c = acc2.id;
        sl2.Active__c = True;
        sl2.Category__c='Reset';
        sl2.StartDate__c = system.today();         
        sl2.EndDate__c =System.today().addDays(3);
        //sl2.PlanogramId__c=plano.id;
        sl2.InStoreLocationType__c = 'Planogram Specific';
        sl2.Status__c ='Planned'; 
        ISLList.add(sl2);
        insert sl2;
        System.debug('sl1++ '+sl1);
        System.debug('sl2++ '+sl2);
        
    }
     @istest
    static void executetestmethod(){

         test.startTest(); 
        List<ActionPlanTemplate__c> accPlanTemplateList = [SELECT Id,CommercialActivityId__c, In_Store_Locations_Created__c, CascadeFlag__c,Missions_Created__c, RequestedStartDate__c, AccountID__c,Total_Instorelocations__c,Total_Mission__c FROM ActionPlanTemplate__c LIMIT 2];
        for(ActionPlanTemplate__c apt : accPlanTemplateList){
        apt.In_Store_Locations_Created__c = true;
        apt.CascadeFlag__c = false;
        apt.Missions_Created__c = false;
         apt.RequestedStartDate__c = System.today().addDays(15);
         apt.RequestedEndDate__c = System.today().addDays(18);
         //apt.Total_Mission__c=20;
         //apt.Total_Instorelocations__c=10;
        update apt;  
        }
        
		APTsMissionsBatchClass AptMssionBatch = new APTsMissionsBatchClass();
        Database.executeBatch(AptMssionBatch, 10);
        
         List<ActionPlanTemplate__c> accPlanTemplateList1 = [SELECT Id,CommercialActivityId__c, In_Store_Locations_Created__c, CascadeFlag__c,Missions_Created__c, RequestedStartDate__c, AccountID__c,Total_Instorelocations__c,Total_Mission__c FROM ActionPlanTemplate__c LIMIT 2];
        for(ActionPlanTemplate__c apt : accPlanTemplateList1){
        apt.In_Store_Locations_Created__c = true;
        apt.CascadeFlag__c = false;
        apt.Missions_Created__c = false;
         apt.RequestedStartDate__c = System.today().addDays(15);
         apt.RequestedEndDate__c = System.today().addDays(18);
         //apt.Total_Mission__c=20;
         //apt.Total_Instorelocations__c=10;
        update apt;  
        }
        
        APTsMissionsBatchClass AptMssionBatch1 = new APTsMissionsBatchClass();
        Database.executeBatch(AptMssionBatch1, 10);
        
        test.stopTest();   
    }
}