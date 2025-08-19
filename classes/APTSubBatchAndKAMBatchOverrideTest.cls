@isTest
public class APTSubBatchAndKAMBatchOverrideTest {

    @testSetup static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        Trigger_Controller__c triggerController3 = new Trigger_Controller__c(Name='dlrs_InStoreLocationTrigger',Enabled__c=false);
        insert(triggerController3);
        Trigger_Controller__c triggerController4 = new Trigger_Controller__c(Name='dlrs_AccountActionPlanTemplateTrigger',Enabled__c=false);
        insert(triggerController4);
        
        List<Account> accountList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        insert acc;
        
        Account acc1 = new Account(Name = 'account1',CurrencyIsoCode = 'USD',
                                   Type='National Chain Retailer',
                                   ParentId = acc.id,
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
        
        Product2 p1= new Product2();
        p1.name= 'Test Items2';
        p1.Family='Accessories';
        p1.IsActive = true;
        p1.Product_Country__c = 'US';
        p1.ProductPricingFamily__c='DK';
        p1.US_E_Order_Enabled__c = true;
        insert p1;
        
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c='US';
        ca.Commercial_Activity_Status__c = true;
        ca.IsActive__c = true;
        insert ca;
        
        Assortment__c assort = new Assortment__c();
        assort.Description__c ='Testing';
        assort.Country__c = 'US';
        insert assort;
        
        AssortmentProduct__c assortProduct = new AssortmentProduct__c();
        assortProduct.AssortmentId__c= assort.id;
        assortProduct.ProductId__c = p1.id;
        assortProduct.Country__c = 'US';
        insert assortProduct;
        
        StoreAssortment__c storeAssort = new StoreAssortment__c();
        storeAssort.AccountId__c = acc.id;
        storeAssort.Active__c= true;
        storeAssort.AssortmentId__c = assort.id;
        storeAssort.Country__c = 'US';
        insert storeAssort;
 
        Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        Id promoRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Promotional Activity Process').getRecordTypeId();

        List<ActionPlanTemplate__c> aptList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestAP';
        apt.Country__c = 'US';
        apt.RecordTypeId = accountPlanRecordTypeId;
        apt.Status__c ='APT Approved & Locked';
        apt.ActionPlanType__c ='Account Plan';
        apt.AccountID__c=acc.id;
        apt.In_Store_Locations_Created__c = true;
        apt.Missions_Created__c = false;
        apt.Mass_Cascade_Flag__c = true;
        apt.CommercialActivityId__c=ca.id;
        apt.StoreAssortment__c = storeAssort.id;
        apt.Override__c = false;
        apt.STD_JUUL_Funding_Check__c = false;
        apt.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
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
        apt1.AccountId__c=acc.id;
        apt1.In_Store_Locations_Created__c = true;
        apt1.Missions_Created__c = false;
        apt1.Mass_Cascade_Flag__c = true;
        apt1.StoreAssortment__c = storeAssort.id;
		apt1.Override__c = false;
        apt1.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt1.STD_JUUL_Funding_Check__c = false;
        apt1.RequestedStartDate__c = System.today();
        apt1.RequestedEndDate__c =System.today().addDays(3);
        aptList.add(apt1);
        /*
        ActionPlanTemplate__c apt2 = new ActionPlanTemplate__c();
        apt2.Name ='TestReset';
        apt2.Country__c = 'US';
        apt2.RecordTypeId = resetRecordTypeId;
        apt2.Status__c ='Planning';
        apt2.ActionPlanType__c ='Reset Activity Process';
        apt2.AccountId__c=acc2.id;
        apt2.In_Store_Locations_Created__c = false;
        apt2.CommercialActivityId__c=ca.id;
        apt2.StoreAssortment__c = storeAssort2.id;
        apt2.RequestedStartDate__c = date.newInstance(2020, 07, 02);
        apt2.RequestedEndDate__c =date.newInstance(2020, 09, 10);
        aptList.add(apt2);
        insert aptList;
        */
		insert aptList;
        
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
        
        ActionPlanTemplateItem__c aptItem2 = new ActionPlanTemplateItem__c();
        aptItem2.ActionPlanTemplateId__c = apt1.Id;
        aptItem2.Subject__c = 'Test';
        aptItem2.Priority__c = 'Normal';
        aptiList.add(aptItem2);
        
        ActionPlanTemplateItem__c aptItem3 = new ActionPlanTemplateItem__c();
        aptItem3.ActionPlanTemplateId__c = apt1.Id;
        aptItem3.Subject__c = 'Task';
        aptItem3.Priority__c = 'High';
        aptiList.add(aptItem3);
        
        ActionPlanTemplateItem__c aptItem4 = new ActionPlanTemplateItem__c();
        aptItem4.ActionPlanTemplateId__c = apt.Id;
        aptItem4.Subject__c = 'Test';
        aptItem4.Priority__c = 'Normal';
        aptiList.add(aptItem4);
        
        ActionPlanTemplateItem__c aptItem5 = new ActionPlanTemplateItem__c();
        aptItem5.ActionPlanTemplateId__c = apt1.Id;
        aptItem5.Subject__c = 'Task';
        aptItem5.Priority__c = 'High';
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
        cai3.ProductId__c =p1.id;
        cai3.ProductType__c ='JUUL Product';
        cai3.CommercialActivityId__c = ca.id;
        cai3.Country__c = 'US';
        cai3.Min_STD_JUUL_Funding__c = 400;
        cai3.HideItemWhilePlanning__c = False;
        capList.add(cai3);
        
        CommercialActivityProduct__c cai4 = new CommercialActivityProduct__c();
        cai4.ProductId__c =p1.id;
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
        pm.Country__c = 'US';
        pm.StateTerritory__c =st.id;
        pm.ProductPricingFamily__c ='DK';
        pm.Start_Date__c = Date.Today().addDays(-5);
        pm.End_Date__c = Date.Today().addDays(25);
        pm.Start_Date__c = system.today();
        pmList.add(pm);
        
        PricingMatrix__c pm1 = new PricingMatrix__c();
        pm1.Active__c = true;
        pm1.ProductId__c= p1.id;
        pm1.Country__c = 'US';
        pm1.StateTerritory__c =st.id;
        pm1.ProductPricingFamily__c ='DK';
        pm1.Start_Date__c = Date.Today().addDays(-5);
        pm1.End_Date__c = Date.Today().addDays(25);
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
       
        
        List<Planogram__c> planoList = new List<Planogram__c>();
		 Planogram__c plano = new Planogram__c();
        plano.Name_of_POG__c = po.id;
        plano.Name ='TestPlano';
        plano.Active__c= true;
        planoList.add(plano);
        
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
        rsg.AccountId__c = acc.id;
        rsg.Pricing_State__c = acc.ShippingState;
        rsg.Name ='TestRsg';
        rsg.Country__c = 'US';
        rsg.PlanogramId__c = plano.id;
        rlgList.add(rsg);
        
        RetailLocationGroup__c rsg1= new RetailLocationGroup__c();
        rsg1.AccountId__c = acc1.id;
        rsg1.Pricing_State__c = acc1.ShippingState;
        rsg1.Name ='TestRsg1';
        rsg1.Country__c = 'US';
        rsg1.PlanogramId__c = plano.id;
       
        rlgList.add(rsg1);
        
        RetailLocationGroup__c rsg2= new RetailLocationGroup__c();
        rsg2.AccountId__c = acc1.id;
        rsg2.Pricing_State__c = acc1.ShippingState;
        rsg2.Name ='TestRsg2';
        rsg2.Country__c = 'US';
        // rsg2.PlanogramId__c = ;
        rlgList.add(rsg2);
        insert rlgList;
        
        List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
        AccountRetailStoreGroup__c arsg = new AccountRetailStoreGroup__c();
        arsg.AccountId__c = acc.id;
        arsg.RetailStoreGroupId__c = rsg.id;
        arsgList.add(arsg);
        
        AccountRetailStoreGroup__c arsg1 = new AccountRetailStoreGroup__c();
        arsg1.AccountId__c = acc1.id;
        arsg1.RetailStoreGroupId__c = rsg1.id;
        arsgList.add(arsg1);
        
        // AccountRetailStoreGroup__c arsg2 = new AccountRetailStoreGroup__c();
        // arsg2.AccountId__c = accList[2].id;
        // arsg2.RetailStoreGroupId__c = rsg2.id;
        // arsgList.add(arsg2);
        
         insert arsgList;
        
        List<AccountActionPlanTemplate__c> aaptList = new List<AccountActionPlanTemplate__c>();
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = apt.id;
        aapt.RetailLocationId__c = rsg.id;
        aapt.Account__c = acc.Id;
        aapt.Grouped_State__c = 'HI';
        aapt.cascadeToDoor__c = false;
        aapt.Active__c = true;
        aaptList.add(aapt);
        //insert aapt;
        
        AccountActionPlanTemplate__c aapt1 = new AccountActionPlanTemplate__c();
        aapt1.ActionPlanTemplateId__c = apt1.id;
        aapt1.RetailLocationId__c = rsg1.id;
		aapt1.Account__c = acc1.Id;
        aapt1.Grouped_State__c = 'HI';
        aapt1.cascadeToDoor__c = true;
        aapt1.Active__c = true;
        aaptList.add(aapt1);
        //insert aapt1;
        
        AccountActionPlanTemplate__c aapt2 = new AccountActionPlanTemplate__c();
        aapt2.ActionPlanTemplateId__c = apt.id;
        aapt2.RetailLocationId__c = rsg2.id;
        aapt2.Active__c = true;
        aapt2.Account__c = acc1.Id;
        aapt2.cascadeToDoor__c = true;
        aapt2.Grouped_State__c = 'HI';
        aaptList.add(aapt2);
        //insert aapt2;
        insert aaptList;
        
        List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acc.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c =  System.today();        
        sl.EndDate__c =System.today().addDays(3);
        sl.PlanogramId__c=plano.id;
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        ISLList.add(sl);
        //insert sl;
        
        InStoreLocation__c sl1 = new InStoreLocation__c();
        sl1.RetailStoreGroupActionPlanTemplate__c = aapt1.id;
        sl1.RetailLocationId__c = acc1.id;
        sl1.Active__c = True;
        sl1.Category__c='Promotion';
        sl1.StartDate__c = System.today();       
        sl1.EndDate__c =System.today().addDays(3);
        sl1.PlanogramId__c=plano.id;
        sl1.InStoreLocationType__c = 'Planogram Specific';
        sl1.Status__c ='Planned'; 
        ISLList.add(sl1);
        //insert sl1;
        
        InStoreLocation__c sl2 = new InStoreLocation__c();
        sl2.RetailStoreGroupActionPlanTemplate__c = aapt2.id;
        sl2.RetailLocationId__c = acc2.id;
        sl2.Active__c = True;
        sl2.Category__c='Reset';
        sl2.StartDate__c = System.today();       
        sl2.EndDate__c =System.today().addDays(3);
        sl2.PlanogramId__c=plano.id;
        sl2.InStoreLocationType__c = 'Planogram Specific';
        sl2.Status__c ='Planned'; 
        ISLList.add(sl2);
        //insert sl2;
        Insert ISLList;
        
        List<StoreProduct__c> storeProdList = new List<StoreProduct__c>();
        StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = acc.id;
        sp.ProductId__c = p.id;
        sp.Source_Product_Id__c = assortProduct.id;
        sp.InStoreLocationId__c= sl.id;
        sp.STD_JUUL_Funding__c = 500;
        sp.Active__c = true;
        storeProdList.add(sp);
        //insert sp;
        
        StoreProduct__c sp3 = new StoreProduct__c();
        sp3.RetailStoreId__c = acc1.id;
        sp3.ProductId__c = p.id;
        sp3.Source_Product_Id__c = cai.id;
        sp3.InStoreLocationId__c= sl.id;
        sp3.Active__c = true;
        sp3.STD_JUUL_Funding__c = 500;
        storeProdList.add(sp3);
        //insert sp3;
        
        StoreProduct__c sp1 = new StoreProduct__c();
        sp1.RetailStoreId__c = acc1.id;
        sp1.ProductId__c = p1.id;
        sp1.Source_Product_Id__c = ppf.id;
        sp1.InStoreLocationId__c= sl1.id;
        sp1.Active__c = true;
        sp1.STD_JUUL_Funding__c = 500;
        storeProdList.add(sp1);
        //insert sp1;
        
        StoreProduct__c sp2 = new StoreProduct__c();
        sp2.RetailStoreId__c = acc1.id;
        sp2.ProductId__c = p1.id;
        sp2.Source_Product_Id__c = ppf.id;
        sp2.InStoreLocationId__c= sl2.id;
		sp2.Active__c = true;
        sp2.STD_JUUL_Funding__c = 500;
        storeProdList.add(sp2);
        //insert sp2;

        insert storeProdList;

        Asset ass= new asset();
        ass.AccountId =  acc.id;
        ass.Product2Id =p1.Id;
        ass.name= p1.name;
        ass.Source_Product_Id__c = cai1.id;
        insert ass;
        
        Asset__c ass1 = new Asset__c();
        ass1.Account__c =  acc.id;
        ass1.Product__c = p.Id;
        ass1.Unit_Price__c = 300;
        ass1.name= 'Test';
        ass1.InStoreLocation__c = sl.Id;
        ass1.Source_Product_Id__c = 'Test';
        ass1.Quantity__c =400;
        ass1.Active__c = true;
        insert ass1;
        
         Asset__c ass2 = new Asset__c();
        ass2.Account__c =  acc.id;
        ass2.Product__c = p.Id;
        ass2.Unit_Price__c = 300;
        ass2.name= 'Test';
        ass2.InStoreLocation__c = sl1.Id;
        ass2.Source_Product_Id__c = 'Test';
        ass2.Quantity__c =400;
        ass2.Active__c = true;
        insert ass2;
        
        Mission__c ms=new Mission__c();
        ms.AccountId__c = acc.Id;
        ms.MissionType__c = 'Strategy';
        ms.Status__c = 'Planned';
        ms.RetailStoreGroupActionPlanTemplate__c = aapt.Id;
        //ms.Commercial_Activity__c = ca.Id;
        ms.StartDate__c = System.today();
        ms.EndDate__c = System.today().addDays(3);
        insert ms;
        
        Mission__c ms1=new Mission__c();
        ms1.AccountId__c = acc.Id;
        ms1.MissionType__c = 'Strategy';
        ms1.Status__c = 'Planned';
        ms1.RetailStoreGroupActionPlanTemplate__c = aapt1.Id;
        //ms.Commercial_Activity__c = ca.Id;
        ms1.StartDate__c = System.today();
        ms1.EndDate__c = System.today().addDays(3);
        insert ms1;
    }
    static testMethod void testAccountPlanning(){
        AccountTriggerHandler.skipTriggerMethodFromTestClass=false;
        Test.startTest();
        List<ActionPlanTemplate__c> accPlanTemplateList=[select id,Name from ActionPlanTemplate__c LIMIT 1];
        String s1 = KAMAccountPlanning.getALLRetailGroups(accPlanTemplateList[0].id);
		KAMAccountPlanning.WraperDataWithAPTInfo s1Wrapper = (KAMAccountPlanning.WraperDataWithAPTInfo) JSON.deserialize(s1, KAMAccountPlanning.WraperDataWithAPTInfo.class);
		s1Wrapper.CascadeFlag=true;
        List<KAMAccountPlanning.WrapperData> s1WrapperData = s1Wrapper.wraperList;
		KAMBatchOverrideProduct batch = new KAMBatchOverrideProduct(accPlanTemplateList[0].id,s1WrapperData);
		id BatchID = Database.executeBatch(batch,1);
        //Database.executeBatch(new KAMMissionBatch(),1);
        Test.stopTest();
    }

}