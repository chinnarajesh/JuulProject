@isTest
public class KAMAccountMissionsControllerTest {

    //Method to create test data

    @testSetup 
    public static void setup(){
        
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.Website ='';
        acc.BillingCountry ='USA';
        insert acc;
        
        List<Mission__c> mList = new List<Mission__c>();
        Mission__c m = new Mission__c();
        m.AccountId__c= acc.id;
        m.EndDate__c = Date.valueOf('2022-12-31');
        mList.add(m);
        insert mList;
    }
    
    //Method to test mission records data
    static testMethod void getKAMAccountMissionsControllerTest(){
        test.startTest();
        
        //Testing valid scenario for Mission Records
        KAMAccountMissionsController.getMissionRecords('mList');
        //Testing invalid scenario for Mission Records
        KAMAccountMissionsController.getMissionRecords('');
        
        test.stopTest();
    }
    
}