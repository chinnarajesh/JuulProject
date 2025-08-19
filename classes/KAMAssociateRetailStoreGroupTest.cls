@isTest
public class KAMAssociateRetailStoreGroupTest {
    //Method to create test data
    @testSetup static void setup(){
        
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
       
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);  
        
        Account hqAcc = new Account();
        hqAcc.Name='Test HQ';
        hqAcc.Type='HQ';
        insert hqAcc;
        
        Account regionalAcc = new Account();
        regionalAcc.Name='Test Regional';
        regionalAcc.Ultimate_Parent_Account__c = hqAcc.Id;
        regionalAcc.ParentId = hqAcc.Id;
        regionalAcc.Type='HQ';
        insert regionalAcc;
        
        Account corporateAcc = new Account();
        corporateAcc.Name='Test Corporate';
        corporateAcc.Type='HQ';
        insert corporateAcc;
        
        RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c = regionalAcc.Id;
        insert rsgTest;
        
        RetailLocationGroup__c rsgTest1 = new RetailLocationGroup__c();
        rsgTest1.AccountId__c = corporateAcc.Id;
        insert rsgTest1;
    
    
        ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name = 'Action Plan Template 1';
        apt1.AccountId__c = regionalAcc.Id;
        apt1.RecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        apt1.RequestedStartDate__c = system.today() + 1;
        apt1.RequestedEndDate__c = system.today() + 7;
        apt1.StrategyStartDate__c = system.today() + 1;
        insert apt1;
        
        ActionPlanTemplate__c apt2 = new ActionPlanTemplate__c();
        apt2.Name = 'Action Plan Template 2';
        apt2.AccountId__c = corporateAcc.Id;
        apt2.RecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        apt2.RequestedStartDate__c = system.today() + 1;
        apt2.RequestedEndDate__c = system.today() + 7;
        apt2.StrategyStartDate__c = system.today() + 1;
        insert apt2;

        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c =apt1.id;
        aapt.RetailLocationId__c = rsgTest.id;
        insert aapt;
    }  
    
    static testMethod void getAllRSG(){
        List<ActionPlanTemplate__c> APT = new List<ActionPlanTemplate__c>(
            [SELECT Id, Name, ActionPlanType__c, AccountId__c from ActionPlanTemplate__c]
        );
       
        Map<id,RetailLocationGroup__c> rsgList = new Map<id,RetailLocationGroup__c>(
            [Select id, Name, Description__c, CurrencyIsoCode, NumberOfStoreLocations__c, AccountId__c from RetailLocationGroup__c]
        );
        
        List<Id> rsgIds = new List<Id>();
        rsgIds.addAll(rsgList.keyset());
        
        test.startTest();
            KAMAssociateRetailStoreGroup.getAllRetailStoreGroups(APT[0].Id);
            KAMAssociateRetailStoreGroup.getAllRetailStoreGroups(APT[1].Id);
            KAMAssociateRetailStoreGroup.getAllRetailStoreGroups(null);
            KAMAssociateRetailStoreGroup.associateRetailStoreGroupsOnApt(APT[0].Id, rsgIds);
            KAMAssociateRetailStoreGroup.associateRetailStoreGroupsOnApt(APT[1].Id, rsgIds);
        test.stopTest();
    }
}