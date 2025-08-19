/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Shreya Raut             04-09-2021                     */
/* Class Name: EACOpportunityBatchTest                      */
/* Description: Test class for EACOpportunityBatch SFDC - 0000004243 */ 
/**********************************************************************/
@isTest(SeeAllData = False)
public class EACOpportunityBatchTest {

    
    @isTest  
    public static void makeData(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        List<OpportunityContactRole> listOppConRoleToInsert = new List<OpportunityContactRole>();
        Account accRec= new Account();
        accRec.Name = 'Test Account_Distributor';
        accRec.Ready_Date_Confirmed__c = system.today().addDays(15);
        accRec.Ready_Date_Estimated__c = system.today().addDays(20);
        accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert accRec;
        
        Account acctRec= new Account();
        acctRec.Name = 'Test Account_Distributor';
        acctRec.Ready_Date_Confirmed__c = system.today().addDays(15);
        acctRec.Ready_Date_Estimated__c = system.today().addDays(20);
        acctRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert acctRec;
        
        Account accRecd= new Account();
        accRecd.Name = 'Test Account_Door';
        accRecd.Ready_Date_Confirmed__c = system.today().addDays(15);
        accRecd.Ready_Date_Estimated__c = system.today().addDays(20);
        accRecd.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert accRecd;
        
        Opportunity oppRec = new Opportunity();
            oppRec.Name = 'Test Opportunity';
            oppRec.AccountId = accRec.id;
            oppRec.CloseDate = System.Today();
            oppRec.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('EAC').getRecordTypeId();
            oppRec.StageName = 'Committed';
        insert oppRec;
        
        Opportunity oppRecd = new Opportunity();
            oppRecd.Name = 'Test Opportunity record';
            oppRecd.AccountId = accRec.id;
            oppRecd.CloseDate = System.Today();
            oppRecd.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('EAC').getRecordTypeId();
            oppRecd.StageName = 'Ready';
        insert oppRecd;
        
        RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c = accRec.Id;
        rsgTest.Pricing_State__c = 'AK';
        insert rsgTest;
       
        AccountRetailStoreGroup__c accrsg = new AccountRetailStoreGroup__c();
        accrsg.AccountId__c = accRecd.Id;
        accrsg.RetailStoreGroupId__c = rsgTest.id;
        insert accrsg;
       
        
        EAC_RSG__c  eac = new EAC_RSG__c ();
        eac.Opportunity__c = oppRec.id;
        eac.Retail_Store_Group__c = rsgTest.id;
        insert eac;
        
        EAC_RSG__c  eac1 = new EAC_RSG__c ();
        eac1.Opportunity__c = oppRecd.id;
        eac1.Retail_Store_Group__c = rsgTest.id;
        insert eac1;
 
        test.startTest(); 
        EACOpportunityBatch e = new EACOpportunityBatch(eac.id,oppRec);
        Database.executeBatch(e);
        Opportunity o =[select id,Ready_Start_date__c,name from opportunity where name='Test Opportunity'];
        System.assertEquals('Test Opportunity',o.name );
        test.stopTest();
     }
}