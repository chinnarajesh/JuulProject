@isTest(SeeAllData=false)
public class StoreAssortmentTriggerHandlerTest {
    static testMethod void checkActiveStoreAssortmentonAccountTest(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
       
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);  
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='StoreAssortmentTrigger',Enabled__c=true);
        insert(triggerController2);  
        Assortment__c assort1 = new Assortment__c();
        assort1.Name = 'test assort 1';
        insert assort1;
        Assortment__c assort2 = new Assortment__c();
        assort2.Name = 'test assort 2';
        insert assort2;
        Account ac = new Account();
        ac.Name= 'test';
        insert ac;
        StoreAssortment__c sa1 = new StoreAssortment__c();
        sa1.AccountId__c = ac.Id;
        sa1.AssortmentId__c = assort1.ID;
        sa1.Active__c = true;
        insert sa1;
        sa1.Active__c = False;
        update sa1;
        StoreAssortment__c sa2 = new StoreAssortment__c();
        sa2.AccountId__c = ac.Id;
        sa2.AssortmentId__c = assort2.ID;
        sa2.Active__c = true;
        Test.startTest();
        insert sa2;
        Test.stopTest();
    }

}