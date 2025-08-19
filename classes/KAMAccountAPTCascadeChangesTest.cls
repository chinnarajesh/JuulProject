@isTest(SeeAllData=false)
public class KAMAccountAPTCascadeChangesTest {
    @isTest
    public static void testCascadeChanges() {
        // Create an APT record
         ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
            Account acc = new Account();
            acc.Name  = 'Test Account';
            acc.Email__c = 'abc'+'@test.com';
            acc.Phone = '1238901234';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert acc;
        ActionPlanTemplate__c testAPT = new ActionPlanTemplate__c();
        testAPT.Name = 'Test APT';
        insert testAPT;
        
        RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c = acc.Id;
        rsgTest.Pricing_State__c = 'AK';
        insert rsgTest;
       
        AccountRetailStoreGroup__c accrsg = new AccountRetailStoreGroup__c();
        accrsg.AccountId__c = acc.Id;
        accrsg.RetailStoreGroupId__c = rsgTest.id;
        insert accrsg;
        
        AccountActionPlanTemplate__c testAccountAPT = new AccountActionPlanTemplate__c();
        testAccountAPT.ActionPlanTemplateId__c = testAPT.Id;
        testAccountAPT.RetailLocationId__c = rsgTest.Id;
        insert testAccountAPT;
        
        KAMAccountAPTCascadeChanges.CascadeChanges(testAPT.Id);
        
        AsyncApexJob batchJob = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' LIMIT 1];
        //System.assertEquals('Completed', batchJob.Status);
    }
}