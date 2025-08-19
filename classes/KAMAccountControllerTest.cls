@isTest
private class KAMAccountControllerTest {
    //Method to create test data
    
    
    
    @testSetup 
    public static void setup(){
        
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=false);
        insert(triggerController);  
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
        acc.Type='HQ';
        acc.Website ='';
        acc.BillingCountry ='USA';
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name='Test 1';
        acc1.ShippingCountry = 'US';
        acc1.ShippingState ='HI';
        acc1.Type='HQ';
        acc1.Website ='';
        acc1.BillingCountry ='USA';
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name='Test 2';
        acc2.ShippingCountry = 'US';
        acc2.ShippingState ='HI';
        acc2.Type='HQ';
        acc2.Website ='';
        acc2.BillingCountry ='USA';
        accList.add(acc2);
        
        insert accList;
        
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
        
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c = 'US';
        ca.IsActive__c = true;
        insert ca;
        
        List<CommercialActivityProduct__c> capList = new List<CommercialActivityProduct__c>();
        CommercialActivityProduct__c cai = new CommercialActivityProduct__c();
        cai.ProductId__c = p.id;
        cai.ProductType__c ='JUUL Product';
        cai.Product_bundle_Description__c='Test';
        cai.Product_Bundle__c ='Combo';
        cai.CommercialActivityId__c = ca.id;
        cai.Country__c = 'US';
        capList.add(cai);
        
        CommercialActivityProduct__c cai1 = new CommercialActivityProduct__c();
        cai1.ProductId__c =p1.id;
        cai1.ProductType__c ='JUUL Product';
        cai1.Product_bundle_Description__c='Test';
        cai1.Product_Bundle__c ='Combo';
        cai1.CommercialActivityId__c = ca.id;
        cai1.Country__c = 'US';
        capList.add(cai1);
        
        insert capList;
        
        Id promotionalRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Promotional Activity Process').getRecordTypeId();
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name ='TestClone';
        apt.Country__c = 'US';
        apt.RecordTypeId = promotionalRecordTypeId;
        apt.Status__c ='Planning';
        apt.ActionPlanType__c ='Promotional Activity Process';
        apt.AccountID__c=acc.id;
        apt.CommercialActivityId__c=ca.id;
        apt.RequestedStartDate__c = system.today() + 1;
        apt.RequestedEndDate__c = system.today() + 7;
        apt.StrategyStartDate__c = system.today();
        apt.StrategyEndDate__c = system.today() + 7;
        insert apt;

        ActionPlanTemplateItem__c aptItem = new ActionPlanTemplateItem__c();
        aptItem.ActionPlanTemplateId__c = apt.Id;
        aptItem.Subject__c = 'Test';
        aptItem.Priority__c = 'Normal';
        insert aptItem;
        
        ActionPlanTemplateItem__c aptItem1 = new ActionPlanTemplateItem__c();
        aptItem1.ActionPlanTemplateId__c = apt.Id;
        aptItem1.Subject__c = 'Task';
        aptItem1.Priority__c = 'High';
        insert aptItem1;
    }  
    //Method to test account creation,cloning of APT and APT Items
    static testMethod void getKAMAccountControllerTest(){
        
        
        test.startTest();
        CommercialActivity__c selectedAPTQueried = [Select Id,Country__c from CommercialActivity__c LIMIT 1];
        KAMAccountControllerClone.getAccountRecords(selectedAPTQueried.Id);
        List<id> acList = new List<id>();
        
        for(Account acc :[select id from Account]){
            acList.add(acc.id);
        }
        List<CommercialActivity__c> accPlanTemplateList=[select id from CommercialActivity__c];
        
        //Testing valid scenario for APT
        KAMAccountControllerClone.ReturnResponseWrapper testresponse=KAMAccountControllerClone.cloneRecords(accPlanTemplateList[0].id,acList);
        //KAMAccountControllerClone.ReturnResponseWrapper testresponse1=KAMAccountControllerClone.cloneRecords(accPlanTemplateList[1].id,acList);
        //KAMAccountControllerClone.ReturnResponseWrapper testresponse2=KAMAccountControllerClone.cloneRecords(accPlanTemplateList[2].id,acList);
        //KAMAccountControllerClone.ReturnResponseWrapper testresponse3=KAMAccountControllerClone.cloneRecords(accPlanTemplateList[3].id,acList);
        
        //Testing bad data scenario for APT
        KAMAccountControllerClone.ReturnResponseWrapper testresponse4 = KAMAccountControllerClone.cloneRecords(null,null);
        
        //Testing negative scenario for failed insertion of APTItems by providing bad data.
        KAMAccountControllerClone.cloneAPTItems(UserInfo.getuserId() ,accPlanTemplateList[0].id);
        test.stopTest();
    }
    
    
    
}