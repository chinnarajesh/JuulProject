@isTest
public class KAMEmailWeeklyAlertReportBatchTest {
    
    //Method to create test data
    @testSetup static void setup(){
    	 ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
            
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);  
        
        Trigger_Controller__c tControl =  new Trigger_Controller__c(Name='AccountOrGroupAlertTrigger',Enabled__c=true);
    	insert tControl;
    }
    
   public static testmethod void test() {
       	Account ac = new Account();
       	ac.Name= 'test acccount';
       	insert ac;
       
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
		TeamMemberRole = 'KAPM',UserId = userList[i].ID);
        teamList.add(newTeam);
        }
        insert teamList;
        
       	Alert__c alert = new Alert__c();
       	alert.AlertType__c = 'Hierarchy Addition';
      	insert alert;
       
       	AccountOrGroupAlert__c gAlert = new AccountOrGroupAlert__c();
       	gAlert.AccountId__c = ac.ID;
       	galert.AlertId__c = alert.Id;
       	insert gAlert;
		    
		Test.startTest();
		KAMEmailWeeklyAlertReportBatch c = new KAMEmailWeeklyAlertReportBatch();
		Database.executeBatch(c);
       	KAMEmailWeeklyReportSchedule batchSch=new KAMEmailWeeklyReportSchedule();
		String sch='0 0 6 ? * MON';
		System.schedule('Weekly Email Schedule', sch , batchSch);
		Test.stopTest();
	}
}