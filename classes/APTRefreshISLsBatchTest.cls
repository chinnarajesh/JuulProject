@isTest
public class APTRefreshISLsBatchTest {
	@testSetup static void setup(){
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
        acct.Type='HQ';
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
                                   Type='National Chain Retailer',
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
        
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        p.US_E_Order_Enabled__c = true;
        insert p;
       
        
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c = 'US';
        ca.Commercial_Activity_Status__c = true;
        insert ca;
        
        
        Id promoRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Promotional Activity Process').getRecordTypeId();
        //Id resetRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Reset Activity Process').getRecordTypeId();
        
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestAP';
        apt.Country__c = 'US';
        apt.RecordTypeId = promoRecordTypeId;
        apt.Status__c ='APT Approved & Locked';
        apt.ActionPlanType__c ='Account Plan';
        apt.AccountID__c=acct.id;
        apt.In_Store_Locations_Created__c = true;
        apt.Missions_Created__c = false;
        apt.Mass_Cascade_Flag__c = true;
        apt.CommercialActivityId__c=ca.id;
       // apt.StoreAssortment__c = storeAssort.id;
        apt.Override__c = false;
        apt.STD_JUUL_Funding_Check__c = false;
        apt.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt.RequestedStartDate__c = System.today();
        apt.RequestedEndDate__c =System.today().addDays(3);
        insert apt;
        
        
        List<ActionPlanTemplateItem__c> aptiList = new List<ActionPlanTemplateItem__c>();
        ActionPlanTemplateItem__c aptItem = new ActionPlanTemplateItem__c();
        aptItem.ActionPlanTemplateId__c = apt.Id;
        aptItem.Subject__c = 'Test';
        aptItem.Priority__c = 'Normal';
        aptiList.add(aptItem);
        
        ActionPlanTemplateItem__c aptItem1 = new ActionPlanTemplateItem__c();
        aptItem1.ActionPlanTemplateId__c = apt.Id;
        aptItem1.Subject__c = 'Task';
        aptItem1.Priority__c = 'High';
        aptiList.add(aptItem1);
        insert aptiList;
        
        List<CommercialActivityProduct__c> capList = new List<CommercialActivityProduct__c>();
        CommercialActivityProduct__c cai = new CommercialActivityProduct__c();
        cai.ProductId__c = p.id;
        cai.ProductType__c ='JUUL Product';
        cai.Product_bundle_Description__c='Test';
        cai.Product_Bundle__c ='Combo';
        cai.CommercialActivityId__c = ca.id;
        cai.Country__c = 'US';
        cai.Min_STD_JUUL_Funding__c = 400;
        cai.HideItemWhilePlanning__c = true;
        capList.add(cai);
        
        CommercialActivityProduct__c cai1 = new CommercialActivityProduct__c();
        cai1.ProductId__c =p.id;
        cai1.ProductType__c ='JUUL Product';
        cai1.Product_bundle_Description__c='Test';
        cai1.Product_Bundle__c ='Combo';
        cai1.CommercialActivityId__c = ca.id;
        cai1.Min_STD_JUUL_Funding__c = 400;
        cai1.HideItemWhilePlanning__c = true;
        cai1.Country__c = 'US';
        capList.add(cai1);
        insert capList;
        
        List<Commercial_Activity_Product_Pricing__c> cappList = new List<Commercial_Activity_Product_Pricing__c>();
        Commercial_Activity_Product_Pricing__c capp = new Commercial_Activity_Product_Pricing__c();
        capp.Commercial_Activity_Product__c=capList[0].id;
        capp.Price__c=80.00;
        capp.State_ISO2__c='AP';
        capp.State__c = 'Andra';
        cappList.add(capp);

        Commercial_Activity_Product_Pricing__c capp1 = new Commercial_Activity_Product_Pricing__c();
        capp1.Commercial_Activity_Product__c=capList[1].id;
        capp1.Price__c=80.00;
        capp1.State_ISO2__c='AL';
        capp1.State__c = 'Alziria';
        cappList.add(capp1);
        insert cappList;
        
        List<AccountActionPlanTemplate__c> aaptList = new List<AccountActionPlanTemplate__c>();
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = apt.id;
        //aapt.RetailLocationId__c = rsg.id;
        aapt.Account__c = acct.Id;
        aapt.Grouped_State__c = 'HI';
        aapt.cascadeToDoor__c = false;
        aapt.Active__c = true;
        aaptList.add(aapt);
        insert aaptList;
        
        List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acct.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c =  System.today();        
        sl.EndDate__c =System.today().addDays(3);
        sl.Status__c ='Planned'; 
        ISLList.add(sl);
        //insert sl;
        
        InStoreLocation__c sl1 = new InStoreLocation__c();
        sl1.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl1.RetailLocationId__c = acct.id;
        sl1.Active__c = True;
        sl1.Category__c='Promotion';
        sl1.StartDate__c = System.today();       
        sl1.EndDate__c =System.today().addDays(3);
        sl1.Status__c ='Planned'; 
        ISLList.add(sl1);
        //insert sl1;
        
        InStoreLocation__c sl2 = new InStoreLocation__c();
        sl2.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl2.RetailLocationId__c = acct.id;
        sl2.Active__c = True;
        sl2.Category__c='Reset';
        sl2.StartDate__c = System.today();       
        sl2.EndDate__c =System.today().addDays(3);
        sl2.Status__c ='Planned'; 
        ISLList.add(sl2);
        //insert sl2;

        InStoreLocation__c sl3 = new InStoreLocation__c();
        sl3.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl3.RetailLocationId__c = acc1.id;
        sl3.Active__c = True;
        sl3.Category__c='Reset';
        sl3.StartDate__c = System.today();       
        sl3.EndDate__c =System.today().addDays(3);
        sl3.Status__c ='Planned'; 
        ISLList.add(sl3);

        InStoreLocation__c sl4 = new InStoreLocation__c();
        sl4.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl4.RetailLocationId__c = acc2.id;
        sl4.Active__c = True;
        sl4.Category__c='Reset';
        sl4.StartDate__c = System.today();       
        sl4.EndDate__c =System.today().addDays(3);
        sl4.Status__c ='Planned'; 
        ISLList.add(sl4);

        Insert ISLList;
        
        List<StoreProduct__c> storeProdList = new List<StoreProduct__c>();
        StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = acct.id;
        sp.ProductId__c = p.id;
        //sp.Source_Product_Id__c = assortProduct.id;
        sp.InStoreLocationId__c= sl.id;
        sp.STD_JUUL_Funding__c = 500;
        sp.Active__c = true;
        storeProdList.add(sp);
        //insert sp;
        
        StoreProduct__c sp3 = new StoreProduct__c();
        sp3.RetailStoreId__c = acct.id;
        sp3.ProductId__c = p.id;
        sp3.Source_Product_Id__c = cai.id;
        sp3.InStoreLocationId__c= sl.id;
        sp3.Active__c = true;
        sp3.STD_JUUL_Funding__c = 500;
        storeProdList.add(sp3);
        //insert sp3;
        
        StoreProduct__c sp1 = new StoreProduct__c();
        sp1.RetailStoreId__c = acct.id;
        sp1.ProductId__c = p.id;
        sp1.InStoreLocationId__c= sl1.id;
        sp1.Active__c = true;
        sp1.STD_JUUL_Funding__c = 500;
        storeProdList.add(sp1);
        //insert sp1;
        
        StoreProduct__c sp2 = new StoreProduct__c();
        sp2.RetailStoreId__c = acct.id;
        sp2.ProductId__c = p.id;
        sp2.InStoreLocationId__c= sl2.id;
		    sp2.Active__c = true;
        sp2.STD_JUUL_Funding__c = 500;
        storeProdList.add(sp2);
        //insert sp2;

        // StoreProduct__c sp4 = new StoreProduct__c();
        // sp4.RetailStoreId__c = acc1.id;
        // sp4.ProductId__c = p.id;
        // sp4.InStoreLocationId__c= sl2.id;
		    // sp4.Active__c = true;
        // sp4.STD_JUUL_Funding__c = 500;
        // storeProdList.add(sp4);

        // StoreProduct__c sp5 = new StoreProduct__c();
        // sp5.RetailStoreId__c = acc2.id;
        // sp5.ProductId__c = p.id;
        // sp5.InStoreLocationId__c= sl2.id;
		    // sp5.Active__c = true;
        // sp5.STD_JUUL_Funding__c = 500;
        // storeProdList.add(sp5);

        insert storeProdList;

        Asset ass= new asset();
        ass.AccountId =  acct.id;
        ass.Product2Id =p.Id;
        ass.name= p.name;
        ass.Source_Product_Id__c = cai1.id;
        insert ass;

        Asset standass= new asset();
        standass.AccountId =  acc1.id;
        standass.Product2Id =p.Id;
        standass.name= p.name;
        standass.Source_Product_Id__c = cai1.id;
        insert standass;

        List<Asset__c> customAssetList = new List<Asset__c>();
        
        Asset__c ass1 = new Asset__c();
        ass1.Account__c =  acct.id;
        ass1.Product__c = p.Id;
        ass1.Unit_Price__c = 300;
        ass1.name= 'Test';
        ass1.InStoreLocation__c = sl.Id;
        ass1.Source_Product_Id__c = 'Test';
        ass1.Quantity__c =400;
        ass1.Active__c = true;
        customAssetList.add(ass1);
        
        Asset__c ass2 = new Asset__c();
        ass2.Account__c =  acct.id;
        ass2.Product__c = p.Id;
        ass2.Unit_Price__c = 300;
        ass2.name= 'Test2';
        ass2.InStoreLocation__c = sl1.Id;
        ass2.Source_Product_Id__c = 'Test';
        ass2.Quantity__c =400;
        ass2.Active__c = true;
        customAssetList.add(ass2);

        // Asset__c ass3 = new Asset__c();
        // ass3.Account__c =  acc1.id;
        // ass3.Product__c = p.Id;
        // ass3.Unit_Price__c = 300;
        // ass3.name= 'Test2';
        // ass3.InStoreLocation__c = sl1.Id;
        // ass3.Source_Product_Id__c = 'Test';
        // ass3.Quantity__c =400;
        // ass3.Active__c = true;
        // customAssetList.add(ass3);

        // Asset__c ass4 = new Asset__c();
        // ass4.Account__c =  acc2.id;
        // ass4.Product__c = p.Id;
        // ass4.Unit_Price__c = 300;
        // ass4.name= 'Test2';
        // ass4.InStoreLocation__c = sl1.Id;
        // ass4.Source_Product_Id__c = 'Test';
        // ass4.Quantity__c =400;
        // ass4.Active__c = true;
        // customAssetList.add(ass4);

        insert customAssetList;
        
        Mission__c ms=new Mission__c();
        ms.AccountId__c = acct.Id;
        ms.MissionType__c = 'Strategy';
        ms.Status__c = 'Planned';
        ms.RetailStoreGroupActionPlanTemplate__c = aapt.Id;
        ms.StartDate__c = System.today();
        ms.EndDate__c = System.today().addDays(3);
        insert ms;
      
    }
    
    @isTest
    static void testAPTRefresh(){
        ActionPlanTemplate__c accPlanTemplateList=[SELECT Id,In_Store_Locations_Created__c FROM ActionPlanTemplate__c LIMIT 1];
        accPlanTemplateList.In_Store_Locations_Created__c = true;
        update accPlanTemplateList;
          test.startTest();
            Database.executeBatch(new APTRefreshISLsBatch(),10);

            // ScheduleAPTRefreshISLsBatch scheduleWrapp1 = new ScheduleAPTRefreshISLsBatch();
            // String sch1 = '0 0 23 * * ?';
            // System.schedule('ScheduleAPTRefreshISLsBatch', sch1, scheduleWrapp1);


            // ScheduleAPTsMissionsBatchClass scheduleWrapp = new ScheduleAPTsMissionsBatchClass();
            // String sch = '0 0 23 * * ?';
            // System.schedule('ScheduleAPTsMissionsBatchClass', sch, scheduleWrapp);


          test.stopTest();
    }
    
}