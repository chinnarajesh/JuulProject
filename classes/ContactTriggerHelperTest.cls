/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        06-01-2020                     */
/* Class Name: ContactTriggerHelperTest                       */
/* Description:Test Class for ContactTriggerHelper */
/**********************************************************************/
@isTest
public class ContactTriggerHelperTest {
    //Method to set test data
    @testSetup static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);  
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='ContactTrigger',Enabled__c=true);
        insert(triggerController); 
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name='Test1';
        insert acc1;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.id;
        con.Type__c = 'Buyer';
        con.email='testing@abc.com';
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName= 'Alert';
        con1.LastName = 'Test1';
        con1.AccountId = acc.id;
        con1.Type__c = 'Buyer';
        con1.email='testing@abc.com';
        insert con1;
        
        Contact con2 = new Contact();
        con2.Salutation ='Ms.';
        con2.LastName = 'Test2';
        con2.AccountId = acc1.id;
        con2.Type__c = 'Buyer';
        con1.Title = 'Buyer';
        con2.email='testing@abc.com';
        insert con2;
    }
    //Method to test CreateAlerts functionality on contact update.
    static testMethod void updateContact(){
        List<Contact> conList = [Select id,Salutation,FirstName,email,MobilePhone,Title from contact];
        conList[0].email ='Test@abc.com';
        conList[1].MobilePhone = '7890986700';
        conList[1].FirstName ='TestingAlerts';
        conList[2].Title ='Test';
        conList[2].Salutation ='Dr.';
        
        update conList;
    }

}