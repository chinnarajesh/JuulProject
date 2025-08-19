@isTest
public class iframeComponentApexTest {
      @isTest
      static void dogetAccountId(){
                ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
                  
        Account distributor= new Account(Name='Juul Test Account');
        insert distributor;
                  Contact con = new Contact(FirstName='juul',LastName='LLL',AccountId=distributor.Id);
        insert con;
              string suprofileId = [select Id,name from Profile where name = 'Juul Community Distributor Plus'].Id;
        User usr = new User();
        usr.ProfileId = suprofileId;
        usr.EmailEncodingKey = 'UTF-8'; usr.LastName = 'TestingCA'; usr.LanguageLocaleKey = 'en_US'; usr.Email = 'testuserCA@gmail.com';
        usr.Alias = 'testSA';usr.ContactId=con.id; usr.LocaleSidKey = 'en_US'; usr.Username = 'testCA@juulu.com'; usr.TimeZoneSidKey = 'America/Los_Angeles';
        insert( new Trigger_Controller__c( Name = 'DistributorRetailerLinkTrigger', Enabled__c = true ));

        insert usr;
          Test.startTest();
        iframeComponentApex.getAccountId(usr.id);
          Test.stopTest();
        
    }
}