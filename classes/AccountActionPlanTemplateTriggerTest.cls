/************************************************************************/
/* VERSION     AUTHOR                   DATE                            */
/*     1.0     Pushkar                  07-07-2020                      */
/* Class Name: AccountActionPlanTemplateTriggerTest                     */
/* Description:Test Class for AccountActionPlanTemplateTrigger          */
/************************************************************************/
@isTest
public class AccountActionPlanTemplateTriggerTest {
    @testSetup static void setup(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
          
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);  
        
        Account ac =  new Account();
        ac.Name=  'test account';
        ac.ShippingCountry='US';
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
    }
    
    public static testMethod void  validationDeletionOnExecuteStage(){
        Account ac = [SELECT Id FROM Account LIMIT 1];
        Id RecordTypeIdAP = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
          ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name ='TestPromo';
        //apt1.RecordTypeId = promoRecordTypeId;
        apt1.Status__c ='APT Approved & Locked';
        apt1.ActionPlanType__c ='Promotional Activity Process';
        //apt1.CommercialActivityId__c=ca.id;
        apt1.AccountId__c=ac.id;
        //apt1.StoreAssortment__c = storeAssort1.id;
        apt1.RequestedStartDate__c = date.newInstance(2020, 07, 02);
        apt1.RequestedEndDate__c =date.newInstance(2020, 09, 10);
        apt1.Country__c='US';
        insert apt1;
        
 RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c = ac.Id;
        rsgTest.Pricing_State__c = 'AK';
        rsgTest.Country__c='US';
        insert rsgTest;
        
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c= apt1.Id;
        aapt.RetailLocationId__c = rsgTest.Id;
        insert aapt;
        apt1.Status__c = 'Execution';
        //update apt1;
        try {
            Database.delete(aapt);
        }catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        
    }

}