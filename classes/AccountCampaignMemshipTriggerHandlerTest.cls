/*************************************************************************/
/* VERSION     AUTHOR                     DATE                           */
/*     1.0     Jyoti Choudhary          12-04-2021                       */
/* Class Name: AccountCampaignMemshipTriggerHandlerTest                  */
/* Description: Code Coverage for AccountCampaignMembershipTriggerHandler*/
/*************************************************************************/
@isTest
public class AccountCampaignMemshipTriggerHandlerTest {

 @testSetup
    public static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);
 
}

    static testMethod void testAccountCampaignMembers(){
        List<Account> listAcc = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Joeys Vape Shop';
        acc.ShippingCity= 'Walnut Creek';
        acc.ShippingPostalCode='94596';
        acc.ShippingState='CA';
        acc.ShippingStreet='1196 Walker Ave Unit 411';
        listAcc.add(acc);        
        insert listAcc;
        
        Account_Campaigns__c  ac = new Account_Campaigns__c();
        ac.Name = 'test Account Campaigns';
        insert ac;
        
        List<Account_Campaign_Members__c> listACM = new List<Account_Campaign_Members__c>();
        Account_Campaign_Members__c acm = new Account_Campaign_Members__c();
        acm.Account__c=acc.id;
        acm.Promotion__c = ac.Id;
        listACM.add(acm);
        
        Account_Campaign_Members__c acm1 = new Account_Campaign_Members__c();
        acm1.Account__c=acc.id;
        acm1.Promotion__c = ac.Id;
        listACM.add(acm1);
        insert listACM;
        
        test.startTest();
        AccountCampaignMembershipTriggerHandler.UpdateShippingAddress(listACM);
        AccountCampaignMembershipTriggerHandler.UniqueACMOnAccount(listACM);
        List<Account_Campaign_Members__c> listACMResult = [Select Id,Account__c,Shipping_Street__c,Shipping_City__c,Shipping_State__c,Shipping_Zip_Postal_Code__c from Account_Campaign_Members__c];
        //System.debug('listACMResult ==>'+listACMResult);
        System.assertEquals(listACMResult[0].Shipping_Street__c,'1196 Walker Ave Unit 411');
        test.stopTest();
        }
    }