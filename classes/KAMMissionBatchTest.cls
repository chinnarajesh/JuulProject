/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Shreya Raut        02-20-2021                     */
/* Class Name: KAMMissionBatchTest                       */
/* Description: Code Coverage for ScheduleKAMMissionBatch  and KAMMissionBatch */
/**********************************************************************/
@isTest
public class KAMMissionBatchTest {
   
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
       
        
        Assortment__c assort = new Assortment__c();
        assort.Description__c ='Testing';
        assort.Country__c='US';
        insert assort;
        
        AssortmentProduct__c assortProduct = new AssortmentProduct__c();
        assortProduct.AssortmentId__c= assort.id;
        assortProduct.ProductId__c = p1.id;
        assortProduct.Country__c='US';
        insert assortProduct;
        
        List<StoreAssortment__c> saList = new List<StoreAssortment__c>();
        StoreAssortment__c storeAssort = new StoreAssortment__c();
        storeAssort.AccountId__c = acct.id;
        storeAssort.Active__c= true;
        storeAssort.Country__c='US';
        storeAssort.AssortmentId__c = assort.id;
        saList.add(storeAssort);
        
        StoreAssortment__c storeAssort1 = new StoreAssortment__c();
        storeAssort1.AccountId__c = acct.id;
        storeAssort1.Active__c= true;
        storeAssort1.Country__c='US';
        storeAssort1.AssortmentId__c = assort.id;
        saList.add(storeAssort1);
        
        StoreAssortment__c storeAssort2 = new StoreAssortment__c();
        storeAssort2.AccountId__c = acct.id;
        storeAssort2.Active__c= true;
        storeAssort2.Country__c='US';
        storeAssort2.AssortmentId__c = assort.id;
        saList.add(storeAssort2);
        insert saList;
        
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
        apt.Mass_Cascade_Flag__c = true;
        apt.CommercialActivityId__c=ca.id;
        apt.StoreAssortment__c = storeAssort.id;
        apt.Override__c = false;
        apt.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt.STD_JUUL_Funding_Check__c = false;
        apt.RequestedStartDate__c = System.today();
        apt.RequestedEndDate__c =System.today().addDays(3);
        aptList.add(apt);
        
         ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name ='TestPromo';
        apt1.Country__c = 'US';
        apt1.RecordTypeId = promoRecordTypeId;
        apt1.Status__c ='APT Approved & Locked';
        apt1.ActionPlanType__c ='Promotional Activity Process';
        apt1.CommercialActivityId__c=ca.id;
        apt1.AccountId__c=acct.id;
        apt1.In_Store_Locations_Created__c = true;
        apt1.Missions_Created__c = false;
        apt1.Mass_Cascade_Flag__c = true;
        apt1.StoreAssortment__c = storeAssort1.id;
		apt1.Override__c = false;
        apt1.STD_JUUL_Funding_Check__c = false;
        apt1.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt1.RequestedStartDate__c = System.today();
        apt1.RequestedEndDate__c =System.today().addDays(3);
        aptList.add(apt1);
        System.debug('RDate is'+apt1.RequestedStartDate__c);
        insert aptList;
       /* ActionPlanTemplate__c apt2 = new ActionPlanTemplate__c();
        apt2.Name ='TestReset';
        apt2.RecordTypeId = resetRecordTypeId;
        apt2.Status__c ='APT Approved & Locked';
        apt2.ActionPlanType__c ='Reset Activity Process';
        apt2.AccountId__c=acc2.id;
        apt2.CommercialActivityId__c=ca.id;
        apt2.StoreAssortment__c = storeAssort2.id;
        apt2.Country__c='US';
        //apt2.RequestedEndDate__c = system.today().addDays(15);
        //apt2.RequestedEndDate__c =system.today().addDays(25);
        aptList.add(apt2);
        insert aptList;*/
        
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
        cai1.ProductId__c =p1.id;
        cai1.ProductType__c ='JUUL Product';
        cai1.Product_bundle_Description__c='Test';
        cai1.Product_Bundle__c ='Combo';
        cai1.CommercialActivityId__c = ca.id;
        cai1.Min_STD_JUUL_Funding__c = 400;
        cai1.HideItemWhilePlanning__c = true;
        cai1.Country__c = 'US';
        capList.add(cai1);
        
        CommercialActivityProduct__c cai2 = new CommercialActivityProduct__c();
        cai2.ProductId__c =p1.id;
        cai2.ProductType__c ='Trade Collateral';
        cai2.CommercialActivityId__c = ca.id;
        cai2.Country__c = 'US';
        cai2.Min_STD_JUUL_Funding__c = 400;
        cai2.HideItemWhilePlanning__c = true;
        capList.add(cai2);
        
        CommercialActivityProduct__c cai3 = new CommercialActivityProduct__c();
        cai3.ProductId__c =p2.id;
        cai3.ProductType__c ='JUUL Product';
        cai3.CommercialActivityId__c = ca.id;
        cai3.Country__c = 'US';
        cai3.Min_STD_JUUL_Funding__c = 400;
        cai3.HideItemWhilePlanning__c = False;
        capList.add(cai3);
        
        CommercialActivityProduct__c cai4 = new CommercialActivityProduct__c();
        cai4.ProductId__c =p2.id;
        cai4.ProductType__c ='Trade Collateral';
        cai4.CommercialActivityId__c = ca.id;
        cai4.Country__c = 'US';
        cai4.Min_STD_JUUL_Funding__c = 400;
        cai4.HideItemWhilePlanning__c = False;
        capList.add(cai4);
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

        Commercial_Activity_Product_Pricing__c capp2 = new Commercial_Activity_Product_Pricing__c();
        capp2.Commercial_Activity_Product__c=capList[3].id;
        capp2.Price__c=80.00;
        capp2.State_ISO2__c='AK';
        capp2.State__c = 'Albar';
        cappList.add(capp2);
        insert cappList;
         
       /* Mission__c  MS = new Mission__c ();
        MS.AccountId__c = acc.Id;
        //MS.Name = 'test';
        MS.Status__c = 'Planned';
        insert MS;
         */
        
         
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
               
       List<PricingMatrix__c> pmList = new List<PricingMatrix__c>();
        PricingMatrix__c pm = new PricingMatrix__c();
        pm.Active__c = true;
        
        pm.ProductId__c= p.id;
        pm.StateTerritory__c =st.id;
        pm.country__c='US';
        pm.Start_Date__c = system.today().addDays(15);
        pm.End_Date__c =system.today().addDays(25);
        pm.ProductPricingFamily__c ='DK';
        pmList.add(pm);
        
        PricingMatrix__c pm1 = new PricingMatrix__c();
        pm1.Active__c = true;
       
        pm1.ProductId__c= p1.id;
        pm1.StateTerritory__c =st.id;
        pm1.country__c='US';
        pm1.Start_Date__c = system.today().addDays(15);
        pm1.End_Date__c = system.today().addDays(25);
        pm1.ProductPricingFamily__c ='DK';
        pmList.add(pm1);
        insert pmList;
        
        List<POGs__c> pogList = new List<POGs__c>();
        POGs__c po= new POGs__c();
        po.Name ='Test';
        pogList.add(po);
        
        POGs__c po1= new POGs__c();
        po1.Name ='Test';
        pogList.add(po1);
        insert pogList;
            
        //List<Planogram__c> planoList = new List<Planogram__c>();
        Planogram__c plano = new Planogram__c();
        plano.Name_of_POG__c = po.id;
        plano.Name ='TestPlano';
        plano.Active__c= true;
        insert plano;
        
        List<Planogram__c> planoList = new List<Planogram__c>();
        Planogram__c plano1 = new Planogram__c();
        plano1.Name_of_POG__c = po1.id;
        plano1.Name ='TestPlano1';
        plano1.Active__c= true;
        plano1.Country__c = 'US';
        planoList.add(plano1);
        insert planoList;
        

        PlanogramProductFacing__c ppf = new PlanogramProductFacing__c();
        ppf.PlanogramName__c = plano.id;
        ppf.ProductName__c = p1.id;
        insert ppf;
        
        
          List<RetailLocationGroup__c> rlgList = new List<RetailLocationGroup__c>();
        RetailLocationGroup__c rsg= new RetailLocationGroup__c();
        rsg.AccountId__c = acct.id;
        rsg.Pricing_State__c = acct.ShippingState;
        rsg.Name ='TestRsg';
        rsg.Country__c = 'US';
        rsg.PlanogramId__c = plano.id;
        rlgList.add(rsg);
        
        RetailLocationGroup__c rsg1= new RetailLocationGroup__c();
        rsg1.AccountId__c = acct.id;
        rsg1.Pricing_State__c = acct.ShippingState;
        rsg1.Name ='TestRsg1';
        rsg1.Country__c = 'US';
        rsg1.PlanogramId__c = plano.id;
       
        rlgList.add(rsg1);
        
        RetailLocationGroup__c rsg2= new RetailLocationGroup__c();
        rsg2.AccountId__c = acct.id;
        rsg2.Pricing_State__c = acct.ShippingState;
        rsg2.Name ='TestRsg2';
        rsg2.Country__c = 'US';
        // rsg2.PlanogramId__c = ;
        rlgList.add(rsg2);
        insert rlgList;
        
        List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
        AccountRetailStoreGroup__c arsg = new AccountRetailStoreGroup__c();
        arsg.AccountId__c = acct.id;
        arsg.RetailStoreGroupId__c = rsg.id;
        arsgList.add(arsg);
        
        AccountRetailStoreGroup__c arsg1 = new AccountRetailStoreGroup__c();
        arsg1.AccountId__c = acct.id;
        arsg1.RetailStoreGroupId__c = rsg1.id;
        arsgList.add(arsg1);
        
        AccountRetailStoreGroup__c arsg2 = new AccountRetailStoreGroup__c();
        arsg2.AccountId__c = acct.id;
        arsg2.RetailStoreGroupId__c = rsg2.id;
        arsgList.add(arsg2);
        insert arsgList;
        
         List<AccountActionPlanTemplate__c> aaptList = new List<AccountActionPlanTemplate__c>();
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = apt.id;
        aapt.RetailLocationId__c = rsg.id;
        aapt.Account__c = acct.Id;
        aapt.Grouped_State__c = 'HI';
        aapt.cascadeToDoor__c = false;
        aapt.Active__c = true;
        aaptList.add(aapt);
        //insert aapt;
        
        AccountActionPlanTemplate__c aapt1 = new AccountActionPlanTemplate__c();
        aapt1.ActionPlanTemplateId__c = apt1.id;
        aapt1.RetailLocationId__c = rsg1.id;
		aapt1.Account__c = acct.Id;
        aapt1.Grouped_State__c = 'HI';
        aapt1.cascadeToDoor__c = true;
        aapt1.Active__c = true;
        aaptList.add(aapt1);
        //insert aapt1;
        
        AccountActionPlanTemplate__c aapt2 = new AccountActionPlanTemplate__c();
        aapt2.ActionPlanTemplateId__c = apt.id;
        aapt2.RetailLocationId__c = rsg2.id;
        aapt2.Active__c = true;
        aapt2.Account__c = acct.Id;
        aaptList.add(aapt2);
        //insert aapt2;
        insert aaptList;
       
        List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acct.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c = system.today();        
        sl.EndDate__c =System.today().addDays(3);
        sl.PlanogramId__c=plano.id;
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        ISLList.add(sl);
        //insert sl;
        
        InStoreLocation__c sl1 = new InStoreLocation__c();
        sl1.RetailStoreGroupActionPlanTemplate__c = aapt1.id;
        sl1.RetailLocationId__c = acct.id;
        sl1.Active__c = True;
        sl1.Category__c='Promotion';
        sl1.StartDate__c = system.today();        
        sl1.EndDate__c =System.today().addDays(3);
        sl1.PlanogramId__c=plano.id;
        sl1.InStoreLocationType__c = 'Planogram Specific';
        sl1.Status__c ='Planned'; 
        ISLList.add(sl1);
        //insert sl1;
        
       /* InStoreLocation__c sl2 = new InStoreLocation__c();
        sl2.RetailStoreGroupActionPlanTemplate__c = aapt2.id;
        sl2.RetailLocationId__c = acc2.id;
        sl2.Active__c = True;
        sl2.Category__c='Reset';
        sl2.StartDate__c = date.newInstance(2020, 07, 02);        
        sl2.EndDate__c =date.newInstance(2020, 09, 10);
        sl2.PlanogramId__c=plano.id;
        sl2.InStoreLocationType__c = 'Planogram Specific';
        sl2.Status__c ='Planned'; 
        ISLList.add(sl2);*/
        //insert sl2;
        Insert ISLList;
       /* 
        StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = acc1.id;
        sp.ProductId__c = p.id;
        sp.Source_Product_Id__c = assortProduct.id;
        sp.InStoreLocationId__c= sl.id;
        insert sp;
        
        StoreProduct__c sp3 = new StoreProduct__c();
        sp3.RetailStoreId__c = acc1.id;
        sp3.ProductId__c = p.id;
        sp3.Source_Product_Id__c = cai.id;
        sp3.InStoreLocationId__c= sl.id;
        insert sp3;
        
        StoreProduct__c sp1 = new StoreProduct__c();
        sp1.RetailStoreId__c = acc1.id;
        sp1.ProductId__c = p1.id;
        sp1.Source_Product_Id__c = ppf.id;
        sp1.InStoreLocationId__c= sl1.id;
        insert sp1;
        
        StoreProduct__c sp2 = new StoreProduct__c();
        sp2.RetailStoreId__c = acc1.id;
        sp2.ProductId__c = p1.id;
        sp2.Source_Product_Id__c = ppf.id;
        sp2.InStoreLocationId__c= sl2.id;
        insert sp2;
          */
          Asset ass= new asset();
        ass.AccountId =  acct.id;
        ass.Product2Id =p1.Id;
        ass.name= p1.name;
        ass.Source_Product_Id__c = cai1.id;
        insert ass;
        
        Asset__c ass1 = new Asset__c();
        ass1.Account__c =  acct.id;
        ass1.Product__c = p.Id;
        ass1.Unit_Price__c = 300;
        ass1.name= 'Test';
        ass1.InStoreLocation__c = sl.Id;
        ass1.Source_Product_Id__c = 'Test';
        ass1.Quantity__c =400;
        ass1.Active__c = true;
        insert ass1;
       
        Mission__c ms=new Mission__c();
        ms.AccountId__c = acct.Id;
        ms.MissionType__c = 'Strategy';
        ms.Status__c = 'Planned';
        ms.RetailStoreGroupActionPlanTemplate__c = aapt.Id;
        //ms.Commercial_Activity__c = ca.Id;
        ms.StartDate__c = system.today();
        ms.EndDate__c = System.today().addDays(3);
        insert ms; 
        MissionTask__c MT = new MissionTask__c();
        MT.Subject__c = 'MissionTask__c';
        MT.Status__c = 'Planned';
        MT.ParentId__c = ms.Id;
        insert MT;
        ActionPlanItem__c API = new ActionPlanItem__c();
        API.Status__c = 'Planned ';
        API.ActionPlanTemplateItemId__c = aptItem.Id;
        API.ActionPlanId__c = AP.Id;
        API.MissionTaskId__c = MT.Id;
        insert API;
		
    }
    static testMethod void testResetPlanning(){
        test.startTest(); 
        System.debug('Insise method');
        ActionPlanTemplate__c accPlanTemplateList=[select id,In_Store_Locations_Created__c,status__c,RequestedStartDate__c from ActionPlanTemplate__c Limit 1];
        ActionPlanTemplateItem__c aptitem = [select id,subject__c from ActionPlanTemplateItem__c where subject__c='Test' Limit 1];
        String s1 = KAMAccountPlanning.getALLRetailGroups(accPlanTemplateList.id);
        Planogram__c plano = [select id from Planogram__c where name ='TestPlano'];
        RetailLocationGroup__c rsg = [select id from RetailLocationGroup__c where name ='TestRsg'];
        System.debug('Insise method 2');
        KAMAccountPlanning.WraperDataWithAPTInfo s1Wrapper = (KAMAccountPlanning.WraperDataWithAPTInfo) JSON.deserialize(s1, KAMAccountPlanning.WraperDataWithAPTInfo.class);
        s1Wrapper.CascadeFlag=true;
        System.debug('s1Wrapper'+s1Wrapper);
        List<KAMAccountPlanning.WrapperData> s1WrapperData = s1Wrapper.wraperList;
        KAMAccountPlanning.saveData(accPlanTemplateList.id, s1WrapperData);
        KAMAccountPlanning.getBatchJobStatus(accPlanTemplateList.id);
        KAMAccountPlanning.createProductsAssets(accPlanTemplateList.id, s1WrapperData);
        String d = Label.Days;
        
        Date oldDate = system.today().addDays(Integer.valueof(d));
		set<ID> AccIDs = new set<ID>();
        for (Account acc : [SELECT Id FROM Account LIMIT 1]) AccIDs.add(acc.Id);
        Boolean CascadeChanges = true;
		accPlanTemplateList.In_Store_Locations_Created__c = true;
        accPlanTemplateList.CascadeFlag__c = false;
        accPlantemplateList.Missions_Created__c = false;
        //accPlantemplateList.Status__c = 'Execution';
        update accPlanTemplateList;
		//KAMBatchAccountPlanning batchacc = new KAMBatchAccountPlanning(accPlanTemplateList.id,s1WrapperData,AccIDs,CascadeChanges);
        //id BatchID = Database.executeBatch(batchacc,10);
		//KamBatchAccountPlanningforProducts k = new KamBatchAccountPlanningforProducts(accPlanTemplateList.id,s1WrapperData,AccIDs,AccIDs,CascadeChanges);
        //Id Batch = Database.executeBatch(k,10);
        //Database.executeBatch(new KAMMissionBatch());
        test.stopTest();   
    }

	 static testMethod void ResetPlanning(){   
         test.startTest(); 
         ActionPlanTemplate__c accPlanTemplateList=[select id,In_Store_Locations_Created__c,status__c,RequestedStartDate__c,RequestedEndDate__c from ActionPlanTemplate__c Limit 1];
		accPlanTemplateList.In_Store_Locations_Created__c = true;
        accPlanTemplateList.CascadeFlag__c = false;
        accPlantemplateList.Missions_Created__c = false;
         accPlantemplateList.RequestedStartDate__c = System.today().addDays(15);
         accPlantemplateList.RequestedEndDate__c = System.today().addDays(18);
        update accPlanTemplateList;  
         Account childAcc = [Select Id,ShippingState from Account Where Name = 'account1'];
         childAcc.ShippingState = 'AP';
         update childAcc;
         KAMMissionBatch.Items wrap = new KAMMissionBatch.Items();
         wrap.name = 'test';
         wrap.Id = childAcc.Id;
         wrap.parentId = accPlantemplateList.Id;
         wrap.priority = 'sldkfjsf';
         wrap.selected = true;
         wrap.subject = 'something';
 
         Database.executeBatch(new KAMMissionBatch(),1);
         Test.stopTest();
     }
    
}