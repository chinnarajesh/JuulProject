/************************************************************************/
/* VERSION     AUTHOR                  	DATE                           	*/
/*     1.0     Pushkar			        07-07-2020                     	*/
/* Class Name: KAMApexSharingTest  		               					*/
/* Description:Test Class for KAMApexSharing					 		*/
/************************************************************************/
@isTest
public class KAMApexSharingTest {
    
    @testSetup static void setup(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
        
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);   
      Trigger_Controller__c AGAtriggerController = new Trigger_Controller__c(Name='AccountOrGroupAlertTrigger',Enabled__c=true);
      insert(AGAtriggerController);   

        
        Account ac =  new Account();
        ac.Name=  'test account';
        insert  ac;
        
         Account ac2 =  new Account();
        ac2.Name=  'test account 2';
        insert  ac2;
        
        
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
        
    }
    
    static testMethod void testSharings(){
        Account ac = [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
         Account ac2 = [SELECT Id FROM Account WHERE Name='test account 2' LIMIT 1];
        List<AccountTeamMember> teamList = [SELECT Id, AccountId, UserID FROM AccountTeamMember WHERE AccountID = :ac.Id];
        List<ActionPlanTemplate__c> testAPTList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c APT = new ActionPlanTemplate__c();
        APT.AccountId__c = ac.Id;
        APT.Name = 'test';
        APT.RequestedStartDate__c = System.today()+1;
        APT.RequestedEndDate__c = System.today() + 7;
        APT.ProjectType__c  = 'New Install';
        APT.TypeOfExecution__c = 'By Vendor- 3rd Party Scheduled';
        testAPTList.add(APT);
        Test.StartTest();
        insert testAPTList;
        
        List<Id> missionListId = new List<Id>();
        Mission__c mission = new Mission__c();
        mission.AccountId__c =  ac.Id;
        insert mission;
        missionListId.add(mission.ID);
        KAMApexSharing.shareMissionRecords(missionListId);
        
        Account acChild = new Account();
		acChild.ParentId = ac.Id;
		acChild.Name= 'test';
		insert acChild;   
        acChild.ParentId = ac2.Id;
        Update acChild;
        Test.stopTest();     

        Alert__c alert = new Alert__c();
        alert.AlertType__c = 'Hierarchy Addition';  
        alert.Body__c = 'Test alert';  
        alert.Subject__c = 'Test alert Description.';  
        insert alert;
        AccountOrGroupAlert__c aga = new AccountOrGroupAlert__c();
        aga.AccountId__c = acChild.Id;
        aga.AlertId__c = alert.Id;
        Insert aga;
        aga.AccountId__c = ac.Id;
        Update aga;
        
    }

}