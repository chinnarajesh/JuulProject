@isTest(seealldata = false)
public class JuulGBBatchAccountResetTest {
    
    @testSetup static void setup() {
        
        Id AccntrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        // Create common test accounts
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
         Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController);
 
        
        List<Account> testAccts = new List<Account>();
        
        Account acc1 = new Account();
        acc1.Name = 'testAcc1';
        acc1.recordTypeId = AccntrecTypeId;
        acc1.Status__c = 'Suspended';
        acc1.ShippingCountry= 'GB';
        acc1.SS_Third_Violation_Date__c = system.Today().addDays(-100);
        testAccts.add(acc1);
       
         
        Account  acc2 = new Account();
        acc2.Name = 'testAcc2';
        acc2.recordTypeId = AccntrecTypeId;
        acc2.Status__c = 'Suspended';
        acc2.ShippingCountry= 'GB';
        acc2.SS_Third_Violation_Date__c = system.Today().addDays(100);
        testAccts.add(acc2);
        
         
        Account  acc3 = new Account();
        acc3.Name = 'testAcc3';
        acc3.Status__c = 'Suspended';
        acc3.ShippingCountry= 'GB';
        acc3.recordTypeId = AccntrecTypeId;
        acc3.SS_Third_Violation_Date__c = system.Today();
        testAccts.add(acc3);
        insert testAccts;  
        
        // Create Custom setting        
        BatchConstantValues__c dateCustomsetting = new BatchConstantValues__c(Name ='BatchBrandProtection', GBSuspensionResetDate__c= 90,X3_Strike_Account_Blacklist_Reset__c = 1, X3_Strike_Account_Suspension_Reset__c= 1, X3_Strike_Enforcement_Start_Date__c = System.Today(),X3_Strike_Admin_EmailIds__c='srikanth.bumhyavaram@juul.com' );
        Insert dateCustomsetting;
    }
    
    @isTest static void testAccountResetBatch() {       
        Test.startTest();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test JuulAccountResetBatch Check', sch, new JuulGBBatchAccountReset());
        Test.stopTest();
    }
}