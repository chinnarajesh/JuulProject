@isTest
public class JuulCommunityUserService_Test{

    @isTest
    public static void enableCommuntityUserForDistributor(){
                  ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='UserTrigger',Enabled__c=true);
      insert(triggerController);  
        List<User>listUsers= new List<User>();
        
        Account distributor= new Account(Name='Juul Test Account');
        insert distributor;
        Account retailer= new Account(Name='Juul Retailer one Account');
        insert retailer;
        Distributor_Retailer_Link__c  Rdl=new Distributor_Retailer_Link__c(
        Distributor__c=distributor.id,
        Retailer__c=retailer.id,
        Link_Status__c='Active'
        );
        insert Rdl;
        Account retailer2= new Account(Name='Juul Retailer  two Account');
        insert retailer2;
        Contact con = new Contact(FirstName='juul',LastName='LLL',AccountId=distributor.Id);
        insert con;

        string suprofileId = [select Id,name from Profile where name = 'Juul Community Distributor Plus'].Id;
        User usr = new User();
        usr.ProfileId = suprofileId;
        usr.EmailEncodingKey = 'UTF-8'; usr.LastName = 'TestingCA'; usr.LanguageLocaleKey = 'en_US'; usr.Email = 'testuserCA@gmail.com';
        usr.Alias = 'testSA';usr.ContactId=con.id; usr.LocaleSidKey = 'en_US'; usr.Username = 'testCA@juulu.com'; usr.TimeZoneSidKey = 'America/Los_Angeles';
        insert( new Trigger_Controller__c( Name = 'DistributorRetailerLinkTrigger', Enabled__c = true ));
        Test.startTest();
        insert usr;
        //create new retailer
        Test.stopTest();
        User currentUser = [SELECT Id, Phone,email,IsActive,profileid, ContactId FROM User WHERE Id =: usr.id LIMIT 1];
        System.assertEquals(currentUser.Email,'testuserca@gmail.com');
        List<AccountContactRelation> acr = [Select AccountId, ContactId From AccountContactRelation Where AccountId =: retailer.Id AND contactId =: con.Id];

        System.assertEquals(1, acr.size(), 'Account Contact Relation not created successfully.');

    }
      @isTest
    public static void enableCommuntityUsertoRetailer(){
                  ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='UserTrigger',Enabled__c=true);
      insert(triggerController);  
        List<User>listUsers= new List<User>();
        
        Account distributor= new Account(Name='Juul Test Account');
        insert distributor;
        Account retailer= new Account(Name='Juul Retailer one Account');
        insert retailer;
        Distributor_Retailer_Link__c  Rdl=new Distributor_Retailer_Link__c(
        Distributor__c=distributor.id,
        Retailer__c=retailer.id,
        Link_Status__c='Active'
        );
        insert Rdl;
        Account retailer2= new Account(Name='Juul Retailer  two Account');
        insert retailer2;
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
        
        //create new retailer
        Distributor_Retailer_Link__c  Rdl2=new Distributor_Retailer_Link__c(
        Distributor__c=distributor.id,
        Retailer__c=retailer2.id,
        Link_Status__c='Active'
        );
        insert Rdl2;
        Test.stopTest();
        User currentUser = [SELECT Id, Phone,email,IsActive,profileid, ContactId FROM User WHERE Id =: usr.id LIMIT 1];
        System.assertEquals(currentUser.Email,'testuserca@gmail.com');
        List<AccountContactRelation> acr = [Select AccountId, ContactId From AccountContactRelation Where AccountId =: retailer2.Id AND contactId =: con.Id];

        System.assertEquals(1, acr.size(), 'Account Contact Relation not created successfully.');

    }
}