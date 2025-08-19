@isTest(SeeAllData=False)
public class BusinessAccountServiceTest {
     
    public static testMethod void testupdateAccountStatus(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
        Map<Id, Case> oldMap = new Map<Id, Case>();
            User u = new User(
            ProfileId = [Select Id from Profile Where Name='Sales Ops Admin - EMEA'].id,
            LastName = 'Test User1',
            Email = 'TestUser1@gmail.com',
            Username = 'Tst1User123456@gmail.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'TstUser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            Insert u;
        System.runAs(u){
        
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            newAccountObj.Name = 'testAcc1';
            newAccountObj.ShippingCountry = 'US';
            newAccountObj.CurrencyISOCode = 'USD';
            newAccountObj.Status__c = 'Prospect';
            insert newAccountObj;
            
            //system.debug(accountListUS);
            List<Case> testaccCases = new List<Case>();
            Case c = new Case();
            c.AccountId = newAccountObj.ID;
            c.RecordTypeId = B2BSupportCaseRecordTypeId;
            c.First_Queue_Owner__c = 'Test';
            c.Status = 'Retail Case pending';
            c.Type = 'Brand Protection';
            c.Sub_Type__c ='Residential Address';
            c.Regulatory_Action__c ='No-Sale-List';
            testaccCases.add(c);
        
            insert testaccCases;
             
                 
        
        system.debug(testaccCases);
        oldMap= new Map<ID,Case>(testaccCases);
        system.debug(oldMap);
        for(case cu : testaccCases){
            cu.Status ='Retail Case Closed';
        }
        update testaccCases;
        
        BusinessAccountService.updateAccountStatus(testaccCases,  oldMap); 
       }
    }
    public static testMethod void testupdateCaseStatus(){
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
        List<Case> testCases = new List<Case>();
            Case c = new Case();
            c.First_Queue_Owner__c = 'Test';
            c.RecordTypeId = B2BSupportCaseRecordTypeId;
            c.Status = 'Retail Case Pending';
            c.Type = 'Brand Protection';
            c.Sub_Type__c ='Residential Address';
            c.Regulatory_Action__c ='No-Sale-List';
            testCases.add(c);
        
           BusinessAccountService.updateCaseStatus(testCases);
    }
}