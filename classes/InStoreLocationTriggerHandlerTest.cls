@isTest(seeAllData=false)
public class InStoreLocationTriggerHandlerTest {

    @testSetup static void setup(){
    
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
      
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController1);
        
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        insert ca;
        
        Account acc1 = new Account();
        acc1.Name='Test 1';
        acc1.Type='HQ';
        acc1.ShippingState ='HI';
        acc1.BillingCountry ='USA';
        insert acc1;
        
        Assortment__c assort = new Assortment__c();
        assort.Description__c ='Testing';
        insert assort;
        
        StoreAssortment__c storeAssort1 = new StoreAssortment__c();
        storeAssort1.AccountId__c = acc1.id;
        storeAssort1.Active__c= true;
        storeAssort1.AssortmentId__c = assort.id;
        insert storeAssort1;
        
           List<ActionPlanTemplate__c> testAPTList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.AccountId__c = acc1.Id;
        apt1.Name = 'test';
        apt1.RequestedStartDate__c = System.today()+1;
        apt1.RequestedEndDate__c = System.today() + 7;
        apt1.ProjectType__c  = 'New Install';
        apt1.TypeOfExecution__c = 'By Vendor- 3rd Party Scheduled';
        testAPTList.add(apt1);
        Test.StartTest();
        insert testAPTList;
        POGs__c po= new POGs__c();
        po.Name ='Test';
        insert po;
        
        POGs__c po1= new POGs__c();
        po.Name ='Test 1';
        insert po1;
        
        
        Planogram__c plano = new Planogram__c();
        plano.Name_of_POG__c = po.id;
        plano.Name ='TestPlano';
        plano.Active__c= true;
        insert plano;
        
        Planogram__c plano1 = new Planogram__c();
        plano1.Name_of_POG__c = po1.id;
        plano1.Name ='TestPlano1';
        plano1.Active__c= true;
        insert plano1;
        
        RetailLocationGroup__c rsg1= new RetailLocationGroup__c();
        rsg1.AccountId__c = acc1.id;
        rsg1.Name ='TestRsg1';
        rsg1.PlanogramId__c = plano.id;
        rsg1.Pricing_State__c = acc1.ShippingState;
        insert rsg1;
        
        AccountActionPlanTemplate__c aapt1 = new AccountActionPlanTemplate__c();
        aapt1.ActionPlanTemplateId__c = apt1.id;
        aapt1.RetailLocationId__c = rsg1.id;
        insert aapt1;
        
        List<InStoreLocation__c> Islist = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        sl.RetailStoreGroupActionPlanTemplate__c = aapt1.id;
        sl.RetailLocationId__c = acc1.id;
        sl.Active__c = true;
        sl.Category__c = 'Reset';
        sl.StartDate__c = date.newInstance(2020, 07, 02);
        sl.EndDate__c =date.newInstance(2020, 09, 10);
        sl.PlanogramId__c=plano.id;
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        Islist.add(sl);
        insert Islist;
        
        sl.Status__c ='Executed';
        sl.PlanogramId__c=plano1.id;
        update sl;

    }
    
    static testMethod void getInStoreLocationTriggerHandlerTest(){
     test.startTest();
    List<InStoreLocation__c> apt = [Select id, name from InStoreLocation__c];

     //Testing valid scenario for APT
     InStoreLocationTriggerHandler.addRetailStoreGrouponInsert(apt);
     System.assertNotEquals(null,apt);
     
     //Testing bad data scenario for APT
     InStoreLocationTriggerHandler.addRetailStoreGrouponInsert(null);
     InStoreLocationTriggerHandler.addRetailStoreGrouponUpdate(null,null);
      
     
     
     test.stopTest();
    
    }

}