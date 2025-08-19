@IsTest
public with sharing class LightningLoginFormControllerTest {
 @testSetup 
 static void setupdata(){
        
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
       Account distributor= new Account(Name='Juul Test Account',Store_Locator_ID__c=12345);
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
    }
 @IsTest
 static void testLoginWithInvalidCredentials() {
     
  System.assertEquals(null, LightningLoginFormController.login('testUser', 'fakepwd', null,'12345'));
 }
     @IsTest
 static void testLoginWithvalidCredentials() {
     
  System.assertEquals(null, LightningLoginFormController.login('testCA@juulu.com', 'fakepwd', null,'12345'));
 }

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
    @isTest
    static void testSetExpId() {
        String result = LightningLoginFormController.setExperienceId('asd24');
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testForgottenPasswd() {
        String passwdUrl = LightningLoginFormController.getForgotPasswordUrl();
        System.debug(passwdUrl);
    }
    	@isTest
    static void testCheckUserEmail() {
        
        // call method with unexistant username
        Boolean firstCall = LightningLoginFormController.checkUserEmail('testuser123@gamil124.de');
        System.assertEquals(false, firstCall);
        
    	// create user
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Alias = 'tstu';
        u.Username = 'testuser123@gamil124.de';
        u.Email = 'testuser123@gamil124.de';
        u.CommunityNickname = 'testuser123';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        Boolean secondCall = LightningLoginFormController.checkUserEmail('testuser123@gamil124.de');
        System.assertEquals(true, secondCall);
    }
}