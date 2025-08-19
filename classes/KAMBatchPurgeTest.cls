/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        09-07-2020                     */
/* Class Name: KamAccountPlanning                       */
/* Description:Test Class for KamAccountPlanningTest */
/**********************************************************************/
@isTest(SeeAllData=false)
public class KAMBatchPurgeTest {
    @testSetup static void setup(){
         ChildAccountShare__c sett = new ChildAccountShare__c();
            sett.Name = 'ChidlAccountShare';
            sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
            insert sett;
           
            Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
            insert(triggerController);
            Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='ActionPlanTemplateTrigger',Enabled__c=true);
            insert(triggerController2);
            Trigger_Controller__c triggerController3 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
            insert(triggerController3);
            
            Apex_Code_Controller__c KAMAlertControl = new Apex_Code_Controller__c(Name = 'KAMCreateAlertAndNotifications', Enabled__c=true);
            insert (KAMAlertControl);
        
         List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        accList.add(acc);
        
        Account Dacc1 = new Account();
        Dacc1.Name='Test 2';
        Dacc1.ShippingCountry = 'US';
        accList.add(Dacc1);
        
        Account Dacc2 = new Account();
        Dacc2.Name='Test 5';
        Dacc2.ShippingCountry = 'US';
        Dacc2.ShippingState ='HI';
        accList.add(Dacc2);
        
        insert accList;
        
        //Creating prodcts
        
        List<Product2> prodList = new List<Product2>();
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        prodList.add(p);
        
        Product2 p1= new Product2();
        p1.name= 'Test Items2';
        p1.Family='Accessories';
        p1.IsActive = true;
        p1.Product_Country__c = 'US';
        p1.ProductPricingFamily__c='DK';
        p1.US_E_Order_Enabled__c = true;
        prodList.add(p1);
        
        insert prodList;
        
        //Creating commercial activity
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c = 'US';
        insert ca;
        
        //creating commercialactivityproducts
        List<CommercialActivityProduct__c> capList = new List<CommercialActivityProduct__c>();
        
        CommercialActivityProduct__c cai2 = new CommercialActivityProduct__c();
        cai2.ProductId__c =p.id;
        cai2.ProductType__c ='Trade Collateral';
        cai2.CommercialActivityId__c = ca.id;
        cai2.Country__c = 'US';
        cai2.HideItemWhilePlanning__c = true;
        capList.add(cai2);
        
        CommercialActivityProduct__c cai3 = new CommercialActivityProduct__c();
        cai3.ProductId__c =p1.id;
        cai3.ProductType__c ='JUUL Product';
        cai3.CommercialActivityId__c = ca.id;
        cai3.Country__c = 'US';
        cai3.HideItemWhilePlanning__c = False;
        capList.add(cai3);
        
        insert capList;
        
        Assortment__c assort = new Assortment__c();
        assort.Description__c ='Testing';
        assort.Country__c = 'US';
        insert assort;
        
        AssortmentProduct__c assortProduct = new AssortmentProduct__c();
        assortProduct.AssortmentId__c= assort.id;
        assortProduct.ProductId__c = p1.id;
        assortProduct.Country__c = 'US';
        insert assortProduct;
        
        List<StoreAssortment__c> saList = new List<StoreAssortment__c>();
        StoreAssortment__c storeAssort = new StoreAssortment__c();
        storeAssort.AccountId__c = acc.id;
        storeAssort.Active__c= true;
        storeAssort.AssortmentId__c = assort.id;
        storeAssort.Country__c = 'US';
        saList.add(storeAssort);
        
        insert saList;
        
        Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        Id promoRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Promotional Activity Process').getRecordTypeId();
        Id resetRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Reset Activity Process').getRecordTypeId();
        
        List<ActionPlanTemplate__c> aptList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestAP';
        apt.Country__c = 'US';
        apt.RecordTypeId = accountPlanRecordTypeId;
        apt.Status__c ='APT Approved & Locked';
        apt.ActionPlanType__c ='Account Plan';
        apt.AccountID__c=acc.id;
        apt.CommercialActivityId__c=ca.id;
        apt.StoreAssortment__c = storeAssort.id;
        apt.RequestedStartDate__c = date.newInstance(2020, 07, 02);
        apt.RequestedEndDate__c =date.newInstance(2020, 09, 10);
        aptList.add(apt);
        
        insert aptList;
        
        List<ActionPlanTemplateItem__c> aptiList = new List<ActionPlanTemplateItem__c>();
        ActionPlanTemplateItem__c aptItem = new ActionPlanTemplateItem__c();
        aptItem.ActionPlanTemplateId__c = apt.Id;
        aptItem.Subject__c = 'Test';
        aptItem.Priority__c = 'Normal';
        aptiList.add(aptItem);
        
        insert aptiList;
        
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
        pm.Start_Date__c = Date.Today().addDays(15);
        pm.End_Date__c = Date.Today().addDays(25);
        pm.Start_Date__c = system.today();
        pmList.add(pm);
        
        insert pmList;
        
        RetailLocationGroup__c rsg= new RetailLocationGroup__c();
        rsg.AccountId__c = acc.id;
        rsg.Pricing_State__c = acc.ShippingState;
        rsg.Name ='TestRsg';
        rsg.Country__c = 'US';
        
        insert rsg;
        
        List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
        AccountRetailStoreGroup__c arsg = new AccountRetailStoreGroup__c();
        arsg.AccountId__c = Dacc2.id;
        arsg.RetailStoreGroupId__c = rsg.id;
        arsgList.add(arsg);
        
        AccountRetailStoreGroup__c arsg2 = new AccountRetailStoreGroup__c();
        arsg2.AccountId__c = Dacc1.id;
        arsg2.RetailStoreGroupId__c = rsg.id;
        arsgList.add(arsg2);
        
        insert arsgList;
        
        List<AccountActionPlanTemplate__c> aaptList = new List<AccountActionPlanTemplate__c>();
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = apt.id;
        aapt.RetailLocationId__c = rsg.id;
        aaptList.add(aapt);
        insert aaptList;
        
        List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acc.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c = date.newInstance(2020, 07, 02);        
        sl.EndDate__c =date.newInstance(2020, 09, 10);
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        ISLList.add(sl);
        
        InStoreLocation__c sl2 = new InStoreLocation__c();
        sl2.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl2.RetailLocationId__c = Dacc1.id;
        sl2.Active__c = True;
        sl2.Category__c='Account Plan';
        sl2.StartDate__c = date.newInstance(2020, 07, 02);        
        sl2.EndDate__c =date.newInstance(2020, 09, 10);
        sl2.InStoreLocationType__c = 'Planogram Specific';
        sl2.Status__c ='Planned'; 
        ISLList.add(sl2);
        
        InStoreLocation__c sl3 = new InStoreLocation__c();
        sl3.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl3.RetailLocationId__c = Dacc1.id;
        sl3.Active__c = True;
        sl3.Category__c='Account Plan';
        sl3.StartDate__c = date.newInstance(2020, 07, 02);        
        sl3.EndDate__c =date.newInstance(2020, 09, 10);
        sl3.InStoreLocationType__c = 'Planogram Specific';
        sl3.Status__c ='Planned'; 
        ISLList.add(sl3);
        
        insert ISLList;
        
        StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = acc.id;
        sp.ProductId__c = p.id;
        sp.Source_Product_Id__c = assortProduct.id;
        sp.InStoreLocationId__c= sl.id;
        insert sp;
        
        StoreProduct__c sp1 = new StoreProduct__c();
        sp1.RetailStoreId__c = Dacc1.id;
        sp1.ProductId__c = p.id;
        sp1.Source_Product_Id__c = assortProduct.id;
        sp1.InStoreLocationId__c= sl.id;
        insert sp1;
        
        StoreProduct__c sp2 = new StoreProduct__c();
        sp2.RetailStoreId__c = Dacc2.id;
        sp2.ProductId__c = p.id;
        sp2.Source_Product_Id__c = assortProduct.id;
        sp2.InStoreLocationId__c= sl.id;
        insert sp2;
        
        Asset ass= new asset();
        ass.AccountId =  acc.id;
        ass.Product2Id =p1.Id;
        ass.name= p1.name;
        ass.Source_Product_Id__c = cai2.id;
        insert ass;
        
        Asset__C assc1= new asset__c();
        assc1.Account__c =  acc.id;
        assc1.Product__c =p1.Id;
        assc1.name= p1.name;
        assc1.Source_Product_Id__c = cai2.id;
      
        insert assc1;
        
        Asset ass2= new asset();
        ass2.AccountId =  acc.id;
        ass2.Product2Id =p1.Id;
        ass2.name= p1.name;
        ass2.Source_Product_Id__c = cai2.id;
        insert ass2;
        
        Asset__C assc2= new asset__c();
        assc2.Account__c =  acc.id;
        assc2.Product__c =p1.Id;
        assc2.name= p1.name;
        assc2.Source_Product_Id__c = cai2.id;
        insert assc2;
        
        Mission__c m = new Mission__c();
        m.AccountId__c= acc.id;
        m.RetailStoreGroupActionPlanTemplate__c =aapt.id;
        insert m;
        
        Mission__c m1 = new Mission__c();
        m1.AccountId__c= Dacc1.id;
        m1.RetailStoreGroupActionPlanTemplate__c =aapt.id;
        insert m1;
        
        Mission__c m2 = new Mission__c();
        m2.AccountId__c= Dacc2.id;
        m2.RetailStoreGroupActionPlanTemplate__c =aapt.id;
        insert m2;
       /* 
        ActionPlan__c ap = new ActionPlan__c();
        ap.Mission__c= m.id;
        ap.ActionPlanTemplateId__c = apt.Id;
        insert ap;
        
        ActionPlan__c ap1 = new ActionPlan__c();
        ap1.Mission__c= m1.id;
        ap1.ActionPlanTemplateId__c = apt.Id;
        insert ap1;
        
        ActionPlan__c ap2 = new ActionPlan__c();
        ap2.Mission__c= m2.id;
        ap2.ActionPlanTemplateId__c = apt.Id;
        insert ap2;
        */
    }
    static testMethod void testAccountPlanning(){
       test.startTest(); 
       List<ActionPlanTemplate__c> accPlanTemplateList=[select id from ActionPlanTemplate__c];
       accPlanTemplateList[0].status__c ='Execution';
        update accPlanTemplateList;
        accPlanTemplateList[0].status__c ='Recalled';
        update accPlanTemplateList;
       test.stopTest();
    }
    
    
}