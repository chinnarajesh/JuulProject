@isTest(SeeAllData = false)
public class AccountPlan_ControllerTest {
    
    public static testmethod void  testMethod1(){
        List<Account> Acclist = new List<Account> ();
       Account accRec = new Account();
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        accRec.Name='TestAccount';
        accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
       Acclist.add(accRec);
        
        List<Opportunity> listOpp = new List<Opportunity> ();
        Opportunity oppRecd = new Opportunity();
            oppRecd.Name = 'Test Opportunity record';
            oppRecd.AccountId = accRec.id;
            oppRecd.CloseDate = System.Today();
            oppRecd.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('EAC').getRecordTypeId();
            oppRecd.StageName = 'Ready';
        insert oppRecd;
            listOpp.add(oppRecd);
        //update oppRec;
            ApexPages.StandardController sc = new ApexPages.StandardController(oppRecd);
            AccountPlan_Controller testAccPlan = new AccountPlan_Controller(sc);
            testAccPlan.editPage();
            testAccPlan.savePage();
            testAccPlan.cancelPage();
        
          }    
}