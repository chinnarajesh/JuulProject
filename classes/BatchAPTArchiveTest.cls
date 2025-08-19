@isTest
public class BatchAPTArchiveTest {

    public static testMethod  void setUpMethod(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=false);
        insert(triggerController1);
       
       	cgcloud__Account_Template__c  accTemp1 = new cgcloud__Account_Template__c();
        accTemp1.cgcloud__Active__c = true;
        accTemp1.cgcloud__Sales_Org__c = '0001';
        accTemp1.cgcloud__Description_Language_1__c = 'Customer (Canada Global)';
        accTemp1.cgcloud__Description_Language_2__c = 'Client (Canada Global)';
        //accTemp.cgcloud__Description__c = 'Customer (Canada Global)';
        accTemp1.Name = 'JUUL HQ or Door';
        accTemp1.cgcloud__Available_Product_Level__c = 'Category;Brand';
        insert accTemp1;
        
       	cgcloud__Org_Unit__c OU = new cgcloud__Org_Unit__c();
       	OU.cgcloud__Sales_Org__c = '0001';
        OU.Zip_Code__c = '002';
       	OU.Name = 'test';
        insert OU;
       
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
       	acc.ShippingPostalCode='002';
        acc.BillingCountry ='USA';
       	//acc.cgcloud__Account_Template__c  = null;
       	acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        acc.ComplianceMechanism__c='Menthol Ban';
        insert acc;
        
        Account acc2 = new Account(Name = 'account1',CurrencyIsoCode = 'USD',
        Type='National Chain Retailer',
        ParentId = acc.id,
        ShippingCountry = 'US',
        ShippingState ='HI',
        BillingCountry ='USA',
        //ShippingPostalCode='002',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId(),                           
        //cgcloud__Account_Template__c  = null,
        ComplianceMechanism__c='Menthol Ban');
        insert acc2;

        Account acc3 = new Account(Name = 'account2',
        CurrencyIsoCode = 'USD',
        ParentId = acc.id,
        Type='National Chain Retailer',
        ShippingCountry = 'US',
        //ShippingPostalCode='002',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId(),                           
        ShippingState ='HI',
        BillingCountry ='USA',
        //cgcloud__Account_Template__c  = null,                         
        ComplianceMechanism__c='Menthol Ban');
        insert acc3;

        Account acc4 = new Account(Name = 'account3',
        CurrencyIsoCode = 'USD',
        ParentId = acc.id,
        //ShippingPostalCode='002',                           
        Type='National Chain Retailer',
        ShippingCountry = 'US',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId(),                           
        ShippingState ='HI',
        BillingCountry ='USA',
       //cgcloud__Account_Template__c  =,                          
        ComplianceMechanism__c='Menthol Ban');
        insert acc4;
        
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
        storeAssort.AccountId__c = acc.id;
        storeAssort.Active__c= true;
        storeAssort.Country__c='US';
        storeAssort.AssortmentId__c = assort.id;
        saList.add(storeAssort);
        
        StoreAssortment__c storeAssort1 = new StoreAssortment__c();
        storeAssort1.AccountId__c = acc.id;
        storeAssort1.Active__c= true;
        storeAssort1.Country__c='US';
        storeAssort1.AssortmentId__c = assort.id;
        saList.add(storeAssort1);
        
        StoreAssortment__c storeAssort2 = new StoreAssortment__c();
        storeAssort2.AccountId__c = acc.id;
        storeAssort2.Active__c= true;
        storeAssort2.Country__c='US';
        storeAssort2.AssortmentId__c = assort.id;
        saList.add(storeAssort2);
        insert saList;
        
        Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        Id promoRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Promotional Activity Process').getRecordTypeId();
        
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
        apt.Mass_Cascade_Active_Flag_Date__c = System.today().addDays(-1);
        apt.STD_JUUL_Funding_Check__c = false;
        apt.RequestedStartDate__c = System.today().addDays(-2);
        apt.RequestedEndDate__c =System.today().addDays(-1);
        insert apt;
        
        BatchAPTArchive batchAPT = new BatchAPTArchive();
        Test.startTest();
         Database.executeBatch(batchAPT);
        Test.stopTest();
    }
}