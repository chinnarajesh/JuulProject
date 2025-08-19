@isTest
public class KAMCreateTaskForManagersTest {
    
      //Method to create test data
    @testSetup static void setup(){
    	 ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
           
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);  
    
    }
    public static testmethod void testTradeManager() {
        Account ac =  new Account();
        ac.Name=  'test account';
        insert  ac;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> userList = new List<User>();
        for (Integer i = 0; i< 5; i++) {
            // observe the same name for Opp and TSG
            USer newUser = new User(lastname = 'Test',Alias = 'Test',TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'eu_ES',EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.id,LanguageLocaleKey = 'en_US',
            userName='Test' + i + '@sdkksdhfhdsjhf.com',email='Test' + i + '@asjgdgsad.com');
            userList.add(newUser);
        }
        insert userList;

        //Create the AccountTeam
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        For (Integer i = 0; i< 5; i++) {
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = ac.ID,
		TeamMemberRole = 'Trade Marketing Manager',UserId = userList[i].ID);
        teamList.add(newTeam);
        }
        insert teamList;
        
        List<ActionPlanTemplate__c> testAPTList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c APT = new ActionPlanTemplate__c();
        APT.AccountId__c = ac.Id;
        APT.Name = 'test';
        APT.RequestedStartDate__c = System.today()+1;
        APT.RequestedEndDate__c = System.today() + 7;
        APT.ProjectType__c  = 'New Install';
        APT.TypeOfExecution__c = 'By Vendor- 3rd Party Scheduled';
        testAPTList.add(APT);
        insert testAPTList;
        KAMCreateTasksforTradeManager.createTaskforTradeCollateralManager(testAPTList);
        //Id devRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Development').getRecordTypeId();
    }
    
    public static testmethod void testVEndorManager() {
        Account ac =  new Account();
        ac.Name=  'test account';
        insert  ac;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> userList = new List<User>();
        for (Integer i = 0; i< 5; i++) {
            // observe the same name for Opp and TSG
            USer newUser = new User(lastname = 'Test',Alias = 'Test',TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'eu_ES',EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.id,LanguageLocaleKey = 'en_US',
            userName='Test' + i + '@sdkksdhfhdsjhf.com',email='Test' + i + '@asjgdgsad.com');
            userList.add(newUser);
        }
        insert userList;

        //Create the AccountTeam
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        For (Integer i = 0; i< 5; i++) {
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = ac.ID,
		TeamMemberRole = 'Vendor Manager',UserId = userList[i].ID);
        teamList.add(newTeam);
        }
        insert teamList;
        
        List<AccountTeamMember> RteamList = new List<AccountTeamMember>();
        AccountTeamMember newTeamRev = new AccountTeamMember(AccountId = ac.ID,
		TeamMemberRole = 'Revenue Finance Manager',UserId = userList[0].ID);
        RteamList.add(newTeamRev);
        insert RteamList;
        
        List<ActionPlanTemplate__c> testAPTList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c APT = new ActionPlanTemplate__c();
        APT.AccountId__c = ac.Id;
        APT.Name = 'test';
        APT.RequestedStartDate__c = System.today();
        APT.RequestedEndDate__c = System.today() + 7;
        APT.ProjectType__c  = 'New Install';
        APT.TypeOfExecution__c = 'By Vendor- 3rd Party Scheduled';
        testAPTList.add(APT);
        insert testAPTList;
        KAMCreateTasksforVendorManager.createTaskforVendorManager(testAPTList);
         KAMCreateTasksForRevenueManager.createTaskforRevenuelManager(testAPTList);
        //Id devRecordTypeId = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Development').getRecordTypeId();
    }

}