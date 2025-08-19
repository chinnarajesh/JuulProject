@isTest
public class GetAccountHierarchyRecordsGroupTest {

    @testsetup
    public static void actionPlanMethod(){

		ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        
        Account acc = new Account(Name = 'account1',CurrencyIsoCode = 'USD',Type='HQ',ShippingCountry = 'US',ShippingState ='HI',BillingCountry ='USA',ComplianceMechanism__c='Menthol Ban');
        insert acc;
        Account acc1 = new Account(Name = 'account2',CurrencyIsoCode = 'USD',ParentId = acc.id,Type='Distributor',ShippingCountry = 'US',ShippingState ='HI',BillingCountry ='USA',ComplianceMechanism__c='Menthol Ban');
        insert acc1;
        Account acc2 = new Account(Name = 'account3',CurrencyIsoCode = 'USD',ParentId = acc1.id,Type='Authorized',ShippingCountry = 'US',ShippingState ='HI',BillingCountry ='USA',ComplianceMechanism__c='Menthol Ban');
        insert acc2;
        
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        p.US_E_Order_Enabled__c = true;
        p.cgcloud__Description_1_Language_1__c = 'test';
        insert p;
        
         Assortment__c assort = new Assortment__c();
        assort.Description__c ='Testing';
        assort.Country__c='US';
        insert assort;
        
        AssortmentProduct__c assortProduct = new AssortmentProduct__c();
        assortProduct.AssortmentId__c= assort.id;
        assortProduct.ProductId__c = p.id;
        assortProduct.Country__c='US';
        insert assortProduct;

        Id accountPlanRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        
        ActionPlanTemplate__c  apt = new ActionPlanTemplate__c (AccountID__c = acc.id,Name='Test APT',Associate_States_Group__c= '{  "WA" : 2,  "OR" : 3,  "AZ" : 4,  "UT" : 2,  "ID" : 66}', Status__c ='Planning',RecordTypeId = accountPlanRecordTypeId,Country__c ='US',RequestedStartDate__c=System.today().addDays(-1),RequestedEndDate__c =System.today().addDays(1),RACSInformationForChain__c ='Not Certified' ,MerchandiseExecutionMethod__c = 'Chain Self Print/Chain Self Merch');
        insert apt;
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c(ActionPlanTemplateId__c = apt.id,Grouped_State__c = 'SD',Grouped_Store_Locations__c = 17);
        insert aapt;
        
      
        
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acc.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c = date.newInstance(2020, 07, 02);        
        sl.EndDate__c =date.newInstance(2020, 09, 10);
        //sl.PlanogramId__c=plano.id;
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        insert sl;
        
          StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = acc.id;
        sp.ProductId__c = p.id;
        sp.Source_Product_Id__c = assortProduct.id;
        sp.InStoreLocationId__c= sl.id;
        insert sp;
        
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
        
        Mission__c ms=new Mission__c();
        ms.AccountId__c = acc.Id;
        ms.MissionType__c = 'Strategy';
        ms.Status__c = 'Planned';
        ms.RetailStoreGroupActionPlanTemplate__c = aapt.Id;
        //ms.Commercial_Activity__c = ca.Id;
        ms.StartDate__c = date.newInstance(2020, 07, 02);
        ms.EndDate__c = date.newInstance(2020, 09, 10);
        insert ms;
    }
    
    @istest
    static void fetchBatchAssociateStateDataTest(){
        ActionPlanTemplate__c apt = [Select Id,AccountId__c from ActionPlanTemplate__c Where Name = 'Test APT' ];
        //GetAccountHierarchyRecordsGroupByState ghrg = new GetAccountHierarchyRecordsGroupByState();
        //Account acc = new 
        AccountActionPlanTemplate__c aapt = [Select Id From AccountActionPlanTemplate__c LIMIT 1];
        delete aapt;
        Map<String, String> selectedStates = new Map<String, String>{
            'SD' => '17',
            'SD' => '17'
        };

        Map<String, String> unselectedStates = new Map<String, String>{
            'SD' => '17',
            'SD' => '17'
        };
        //AccountHierarchyStateBatchClass accBatch = new AccountHierarchyStateBatchClass(apt.AccountID__c, apt.id);
        Test.startTest();
        System.assertNotEquals(null, GetAccountHierarchyRecordsGroupByState.fetchBatchAssociateStateData(apt.Id));
        GetAccountHierarchyRecordsGroupByState.getStateBasedAccounts(apt.Id);
        //Database.execute(accBatch,200);
        System.assertNotEquals(null, GetAccountHierarchyRecordsGroupByState.associateStateGroupsOnApt(apt.Id, selectedStates, unselectedStates));
        Test.stopTest();
    }
}