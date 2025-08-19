/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        05-28-2020                     */
/* Class Name: KAMCreateMissionsatDoorTest                       */
/* Description:Test Class for KAMCreateMissionsatDoor */
/**********************************************************************/
@isTest
private class KAMCreateMissionsatDoorTest {
  //Method to create test data
    @testSetup static void setup(){
    
        /*Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.Website ='';
        acc.BillingCountry ='USA';
        insert acc;
        
        RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c=acc.id;
        insert rsgTest;
        
        RetailLocationGroup__c rsg1 = new RetailLocationGroup__c();
        rsgTest.AccountId__c=acc.id;
        insert rsg1;
        
        RetailLocationGroup__c rsg2 = new RetailLocationGroup__c();
        rsgTest.AccountId__c=acc.id;
        insert rsg2;*/
        
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
           
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);  
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c=acc.id;
        insert rsgTest;
        
        RetailLocationGroup__c rsg1 = new RetailLocationGroup__c();
        rsg1.AccountId__c=acc.id;
        insert rsg1;
        
        RetailLocationGroup__c rsg2 = new RetailLocationGroup__c();
        rsg2.AccountId__c=acc.id;
        insert rsg2;
        
        AccountRetailStoreGroup__c arsg = new AccountRetailStoreGroup__c();
        arsg.RetailStoreGroupId__c = rsg1.Id;
        arsg.AccountId__c = acc.Id;
        insert arsg;
        
        Assortment__c assort = new Assortment__c();
        assort.Name = 'Test Assortment Test';
        insert assort;
        
        StoreAssortment__c sa = new StoreAssortment__c();
        sa.AccountId__c = acc.id;
        sa.AssortmentId__c = assort.id;
        insert sa;
        
        CommercialActivity__c cai = new CommercialActivity__c();
        insert cai;
        
        Product2 prod1 = new Product2();
        //prod1.Product_Type__c = 'JUUL Product';
        prod1.Name = 'Test Class Product Juul';
        prod1.Family='Pods';
        prod1.Product_Country__c='US';
        prod1.IsActive=true;
        insert prod1;
        
        Product2 prod2 = new Product2();
        //prod2.Product_Type__c = 'Trade Collateral';
        prod2.Name = 'Test Class Product Trade';
        prod2.Family='Pods';
        prod2.Product_Country__c='US';
        prod2.IsActive=true;
        insert prod2;
        
        Product2 prod3 = new Product2();
        prod3.Product_Type__c = 'Trade Collateral';
        prod3.Name = 'Test Class Product Trade';
        prod3.Family='Pods';
        prod3.Product_Country__c='US';
        prod3.IsActive=true;
        prod3.US_E_Order_Enabled__c=true;
        insert prod3;
        
        CommercialActivityProduct__c cap = new CommercialActivityProduct__c();
        cap.CommercialActivityId__c = cai.Id;
        cap.ProductId__c = prod1.Id;
        cap.ProductType__c = 'JUUL Product';
        insert cap;
        
        CommercialActivityProduct__c cap2 = new CommercialActivityProduct__c();
        cap2.CommercialActivityId__c = cai.Id;
        cap2.ProductId__c = prod2.Id;
        cap2.ProductType__c = 'Trade Collateral';
        insert cap2;
        
        Asset asse = new Asset();
        asse.Product2Id = prod3.Id;
        asse.name = 'Test Asset Trade';
        asse.AccountId = acc.Id;
        insert asse;

        AssortmentProduct__c  assortproduct = new AssortmentProduct__c();
        assortproduct.AssortmentId__c = assort.Id;
        assortproduct.DefaultOrderQuantity__c = 1;
        assortproduct.ProductId__c = prod3.Id;
        insert assortproduct;
        system.debug('StoreAssortment__c'+sa);
        
        ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name = 'Action Plan Template 1';
        apt1.AccountId__c=acc.Id;
        apt1.StoreAssortment__c = sa.Id;
        apt1.CommercialActivityId__c = cai.Id;
        apt1.RecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        insert apt1;
       
        ActionPlanTemplate__c apt2 = new ActionPlanTemplate__c();
        apt2.Name = 'Action Plan Template 1';
        apt2.AccountId__c=acc.Id;
        apt2.StoreAssortment__c = sa.Id;
        apt2.CommercialActivityId__c = cai.Id;
        apt2.RecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByDeveloperName().get('AccountPlan').getRecordTypeId();
        insert apt2;
        
        ActionPlanTemplate__c apt3 = new ActionPlanTemplate__c();
        apt3.Name = 'Action Plan Template 1';
        apt3.AccountId__c=acc.Id;
        apt3.StoreAssortment__c = sa.Id;
        apt3.CommercialActivityId__c = cai.Id;
        apt3.RecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByDeveloperName().get('PromotionalActivityProcess').getRecordTypeId();
        insert apt3;
        
        ActionPlanTemplateItem__c apti1 = new ActionPlanTemplateItem__c();
        apti1.Subject__c = 'test action plan template item';
        apti1.Priority__c = 'Low';
        apti1.Comments__c = 'Test APTI 1';
        apti1.ActionPlanTemplateId__c = apt1.Id;
        insert apti1;
        
        ActionPlanTemplateItem__c apti2 = new ActionPlanTemplateItem__c();
        apti2.Subject__c = 'test item';
        apti2.Priority__c = 'High';
        apti2.Comments__c = 'Test APTI 2';
        apti2.ActionPlanTemplateId__c = apt1.Id;
        insert apti2;
        
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c =apt1.id;
        aapt.RetailLocationId__c = rsgTest.id;
        insert aapt;
        
        AccountActionPlanTemplate__c aapt1 = new AccountActionPlanTemplate__c();
        aapt1.ActionPlanTemplateId__c =apt2.id;
        aapt1.RetailLocationId__c = rsg1.id;
        insert aapt1;
        
        AccountActionPlanTemplate__c aapt2 = new AccountActionPlanTemplate__c();
        aapt2.ActionPlanTemplateId__c =apt3.id;
        aapt2.RetailLocationId__c = rsg2.id;
        insert aapt2;

    }  
    //Method to test creation of missions along with action plans, action plan items and mission tasks.
    static testMethod void createMissions(){
        List<ActionPlanTemplate__c> apt = [Select id, name from ActionPlanTemplate__c];
        
        List<KAMCreateMissionsatDoor.Items> aptiList = new List<KAMCreateMissionsatDoor.Items>();
        List<ActionPlanTemplateItem__c> apti = new List<ActionPlanTemplateItem__c>([Select id,Name,Priority__c, Subject__c,ActionPlanTemplateId__c,ActionPlanTemplateId__r.Name from ActionPlanTemplateItem__c]);
            for(ActionPlanTemplateItem__c aptItem : apti){
                KAMCreateMissionsatDoor.Items aptiWrapp = new KAMCreateMissionsatDoor.Items();
                aptiWrapp.id = aptItem.id;
                aptiWrapp.name = aptItem.Name ;
                aptiWrapp.priority =aptItem.Priority__c;
                aptiWrapp.subject =aptItem.Subject__c;
                aptiList.add(aptiWrapp);
            }
        
        List<AccountActionPlanTemplate__c> AAPT = new List<AccountActionPlanTemplate__c>(
            [SELECT Id,ActionPlanTemplateId__c,ActionPlanTemplateId__r.StoreAssortment__c ,ActionPlanTemplateId__r.StoreAssortment__r.AssortmentId__c,ActionPlanTemplateId__r.CommercialActivityId__c from AccountActionPlanTemplate__c]
        );
        
        List<KAMCreateMissionsatDoor.Products> productItemList = new List<KAMCreateMissionsatDoor.Products>();
        List<AssortmentProduct__c> apIds = new List<AssortmentProduct__c>([select id,ProductId__c ,ProductId__r.Name,AssortmentId__c from AssortmentProduct__c]);
        List<Id> productIds = new List<Id>();
        for(AssortmentProduct__c ids : apIds){         
            KAMCreateMissionsatDoor.Products productsWrapp = new KAMCreateMissionsatDoor.Products();
            productsWrapp.id = ids.ProductId__c;
            productsWrapp.name = ids.ProductId__r.Name ;  
            productItemList.add(productsWrapp);
            productIds.add(ids.ProductId__c);
        }
        
        List<KAMCreateMissionsatDoor.CommercialActivityItems> commItemList = new List<KAMCreateMissionsatDoor.CommercialActivityItems>();
        List<CommercialActivityProduct__c> cil = new List<CommercialActivityProduct__c>([Select ProductId__c ,ProductId__r.Name, ProductType__c from CommercialActivityProduct__c]);
        for(CommercialActivityProduct__c cap : cil){                
            KAMCreateMissionsatDoor.CommercialActivityItems ciWrapp = new KAMCreateMissionsatDoor.CommercialActivityItems();
            ciWrapp.id = cap.ProductId__c;
            ciWrapp.name = cap.ProductId__r.Name ; 
            ciWrapp.productType = cap.ProductType__c;
            commItemList.add(ciWrapp);
         }
        
        List<KAMCreateMissionsatDoor.APTWrapper> aptWrapList = new List<KAMCreateMissionsatDoor.APTWrapper>();
        for(ActionPlanTemplate__c aptID : apt){
            KAMCreateMissionsatDoor.APTWrapper aptWraper = new KAMCreateMissionsatDoor.APTWrapper();             
            aptWraper.id = aptID.id; 
            aptWraper.expanded = false;
            aptWraper.items = aptiList; 
            aptWraper.products = productItemList;
            aptWraper.commercialActivityItems = commItemList;
            aptWrapList.add(aptWraper);
        } 
        
  
       
        
        List<RetailLocationGroup__c> rsg = [Select id from RetailLocationGroup__c];
        
        List<ActionPlanTemplate__c> aptnull = new List<ActionPlanTemplate__c>([Select id,name from ActionPlanTemplate__c where name ='Rsg']);
        List<ActionPlanTemplateItem__c> aptinull = new List<ActionPlanTemplateItem__c>([Select id,name from ActionPlanTemplateItem__c where name ='Rsg']);
        
        List<AssortmentProduct__c> apIdsnull = new List<AssortmentProduct__c>([select ProductId__c from AssortmentProduct__c where name ='Rsg']);
        List<Id> productIdsNull = new List<Id>();
        for(AssortmentProduct__c ids : apIds){                
            productIds.add(ids.ProductId__c);
         }
        
        List<KAMCreateMissionsatDoor.CommercialActivityItems> commItemListNull = new List<KAMCreateMissionsatDoor.CommercialActivityItems>();
        List<CommercialActivityProduct__c> cilnull = new List<CommercialActivityProduct__c>([Select ProductId__c ,ProductId__r.Name from CommercialActivityProduct__c where name ='Rsg']);
        for(CommercialActivityProduct__c cap : cilnull){                
            KAMCreateMissionsatDoor.CommercialActivityItems ciWrapp = new KAMCreateMissionsatDoor.CommercialActivityItems();
            ciWrapp.id = cap.ProductId__c;
            ciWrapp.name = cap.ProductId__r.Name ; 
            ciWrapp.productType = cap.ProductType__c;
            commItemListNull.add(ciWrapp);
         }

        List<CommercialActivityProduct__c> capnull = new List<CommercialActivityProduct__c>([Select id,name from CommercialActivityProduct__c where name ='Rsg']);

 

        
        //Commented out to move to QA- please update with thecorrect method so I no longer rercieve the following error:
        //Error: KAMCreateMissionsatDoorTest [ApexClass] -- Method does not exist or incorrect signature: void getAllAPTWithItems(Id) from the type KAMCreateMissionsatDoor
        test.startTest();
        KAMCreateMissionsatDoor.getAllAPTWithItemsProducts(rsg[0].Id, 'ResetActivityProcess');
        KAMCreateMissionsatDoor.getAllAPTWithItemsProducts(rsg[1].Id, 'AccountPlan');
        KAMCreateMissionsatDoor.getAllAPTWithItemsProducts(rsg[2].Id, 'PromotionalActivityProcess');
        KAMCreateMissionsatDoor.getAllAPTWithItemsProducts(null, null);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[0].Id, apt, apti, productIds, commItemList);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[1].Id, aptnull, aptinull, productIdsNull, commItemListNull);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[1].Id, aptnull, apti, productIds, commItemList);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[1].Id, apt, aptinull, productIds, commItemList);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[1].Id, apt, apti, productIdsNull, commItemList);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[1].Id, apt, apti, productIds, commItemListNull);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[0].Id, apt, apti, productIds, commItemList);
        KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts(rsg[0].Id, aptnull, aptinull, productIdsNull, commItemListNull);
        test.stopTest();
    }

}