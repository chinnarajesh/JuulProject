@isTest(seealldata = false)
public class JuulSalesOpsGBBatchCaseUpdateTest {
    
    @testSetup static void setup() {
        
        BatchConstantValues__c sett = new BatchConstantValues__c();
        sett.Name = 'BatchBrandProtection';
        sett.X3_Strike_Enforcement_Start_Date__c= Date.newInstance(2018, 6, 1);
        sett.Next_Secret_Shop_Date_of_1__c= 30;
        sett.Next_Secret_Shop_Date_of_2__c= 1;
        sett.Next_Secret_Shop_Date_of_3__c= 3;
        sett.Next_Secret_Shop_Date_of_4__c= 6;
        sett.Next_Secret_Shop_Date_of_5__c= 12;
        sett.Between_Months_of_CreatedStartDT_1__c= -1;
        sett.Between_Months_of_CreatedStartDT_2__c= -2;
        sett.X3_Strike_Account_Blacklist_Reset__c=-12;
        sett.X3_Strike_Account_Suspension_Reset__c=-6;
        sett.X3_Strike_Admin_EmailIds__c='srikanth.bumhyavaram@juul.com';
        sett.GBSuspensionResetDate__c = 90;
        insert sett;
        ChildAccountShare__c sett1 = new ChildAccountShare__c();
      	sett1.Name = 'ChidlAccountShare';
      	sett1.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      	insert sett1;
        
        Id AccntrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        //Id ConrecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();
        //Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        Id recTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
        Account acc1 = new Account();
        acc1.Name = 'testAcc1';
        acc1.ShippingCountry= 'GB';
        acc1.recordTypeId = AccntrecTypeId;
        Insert acc1;
        
        Contact con1 = new contact(FirstName='Test Name1',LastName='Test Name1',Email='Test1@test.com',AccountId=acc1.id
                                   //, recordTypeId = ConrecTypeId
                                   );
        Insert  con1;
        
        Account acc2 = new Account();
        acc2.Name = 'testAcc2';
        acc2.ShippingCountry= 'GB';
        acc2.SS_First_Violation_Date__c = system.today();
        acc2.recordTypeId = AccntrecTypeId;
        Insert acc2;
        
        Contact con2 = new contact(FirstName='Test Name2',LastName='Test Name2',Email='Test2@test.com',AccountId=acc2.id
                                   //, recordTypeId = ConrecTypeId
                                  );
        Insert  con2;
        
        Account acc3 = new Account();
        acc3.Name = 'testAcc3';
        acc3.ShippingCountry= 'GB';
        acc3.SS_First_Violation_Date__c = system.today();
        acc3.SS_Second_Violation_Date__c = system.today();
        acc3.recordTypeId = AccntrecTypeId;
        Insert acc3;
        Contact con3 = new contact(FirstName='Test Name3',LastName='Test Name3',Email='Test3@test.com',AccountId=acc3.id
                                   //, recordTypeId = ConrecTypeId
                                  );
        Insert  con3;
        
        List<Case> insertCaseList = new List<Case>();
        Case c1 = new Case();
        //c1.Name = 'testc1';
        c1.AccountId = acc1.id;
        c1.ContactId = con1.id;
        c1.Market__c = 'United States';
        c1.Type = 'Mystery Shop';
        c1.Regulatory_Action__c='Promotional Funding Removed';
        c1.Sub_Type__c = 'Age Verification';
        c1.Secret_Shop_Date__c = System.today()-60;
        c1.recordTypeId = recTypeId;
        c1.status = 'Retail Case Closed';
        c1.Secret_Shop_Status__c='Fail';
        //c1.Regulatory_Action__c = 'CMP - First Warning';
        insertCaseList.add(c1);
        
        Case c11 = new Case();
        //c1.Name = 'testc1';
        c11.AccountId = acc2.id;
        c11.Secret_Shop_Status__c='Fail';
        c11.ContactId = con3.id;
        c11.Market__c = 'United States';
        c11.Type = 'Mystery Shop';
        c11.Regulatory_Action__c='Promotional Funding Removed';
        c11.Sub_Type__c = 'Age Verification';
        c11.Secret_Shop_Date__c = System.today()-40;
        c11.recordTypeId = recTypeId;
        c11.status = 'Retail Case Closed';
        //c11.Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle';
        insertCaseList.add(c11);
        
        Case c12 = new Case();
        //c1.Name = 'testc1';
        c12.AccountId = acc3.id;
        c12.ContactId = con3.id;
        c12.Market__c = 'United States';
        c12.Type = 'Mystery Shop';
        c12.Sub_Type__c = 'Age Verification';
        c12.Regulatory_Action__c='Promotional Funding Removed';
        c12.Secret_Shop_Status__c='Fail';
        c12.Secret_Shop_Date__c = System.today();
        c12.recordTypeId = recTypeId;
        c12.status = 'Retail Case Closed';
        insertCaseList.add(c12);        
        insert insertCaseList;
    }
    
    
    @isTest static void testSalesOpsBatchCaseUpdate() {
        Test.startTest();
        // for Secret_Shop_Status__c='Fail'
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test JuulSalesOpsGBBatchCaseUpdate Check', sch, new JuulSalesOpsGBBatchCaseUpdate());       Test.stopTest();
    }
    
    @isTest static void testSalesOpsBatchCaseUpdate1() {
        List<Case> caseList = [Select Id,Secret_Shop_Status__c from Case];
        for(case cs : caseList){
            cs.Regulatory_Action__c='None';
            cs.Secret_Shop_Status__c = 'Pass';
        }
        Update caseList;
        Test.startTest();
        // for Secret_Shop_Status__c='pass'
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test JuulSalesOpsGBBatchCaseUpdate Check', sch, new JuulSalesOpsGBBatchCaseUpdate());       
        Test.stopTest();
    }
}