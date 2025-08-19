@isTest(seealldata = false)
public class JuulSalesOpsBatch3StrikesAccntResetTest {
    private static Id AccntrecTypeId;
    private static Id ConrecTypeId;
    private static Id recTypeId;
    private static account acc1, acc2, acc3;
    private static contact con1, con2, con3;
    public static void loadData(){
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
        insert sett;
        
        ChildAccountShare__c sett1 = new ChildAccountShare__c();
      	sett1.Name = 'ChidlAccountShare';
      	sett1.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      	insert sett1;
        
        AccntrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        //ConrecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();
        //recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        recTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
        acc1 = new Account();
        acc1.Name = 'testAcc1';
        acc1.recordTypeId = AccntrecTypeId;
        Insert acc1;
        con1 = new contact(FirstName='Test Name1',LastName='Test Name1',Email='Test1@test.com',AccountId=acc1.id
                           //, recordTypeId = ConrecTypeId
                          );
        Insert  con1;
         
        acc2 = new Account();
        acc2.Name = 'testAcc2';
        acc2.recordTypeId = AccntrecTypeId;
        Insert acc2;
        con2 = new contact(FirstName='Test Name2',LastName='Test Name2',Email='Test2@test.com',AccountId=acc2.id
                           //, recordTypeId = ConrecTypeId
                           );
        Insert  con2;
         
        acc3 = new Account();
        acc3.Name = 'testAcc3';
        acc3.recordTypeId = AccntrecTypeId;
        Insert acc3;
        con3 = new contact(FirstName='Test Name3',LastName='Test Name3',Email='Test3@test.com',AccountId=acc3.id
                           //, recordTypeId = ConrecTypeId
                          );
        Insert  con3;
     }
    
        public static testMethod void TestBatch3StrikesAccntResetTest1() { 
        Test.startTest();
        loadData();
        
        Account objAccnt = new Account(id=acc1.id,Status__c='Suspended');
        contact objCon = new contact(id=con1.id,X1st_Failed_Case_Regulatory_Action__c='CMP - First Warning',Date_of_1st_Violation_AV_or_CMP__c = system.today() - 300, 
                                                X2nd_Failed_Case_Regulatory_Action__c='CMP - Suspended - 2 Promo Cycle',Date_of_2nd_Violation_AV_or_CMP__c=system.today() - 250);
        update objAccnt;
        update objCon;
        List<Case> insertCaseList = new List<Case>();
        Case c1 = new Case();
        //c1.Name = 'testc1';
        c1.AccountId = objAccnt.id;
        c1.ContactId = objCon.id;
        c1.Market__c = 'United States';
        c1.Type = 'Brand Protection';
        c1.Regulatory_Action__c='No-Sale-List';
        c1.Secret_Shop_Status__c = 'Fail';
        c1.Sub_Type__c = 'Counterfeit Sales';
        c1.Secret_Shop_Date__c = System.today()-300;
        c1.recordTypeId = recTypeId;
        c1.status = 'Retail Case Closed';
        //c1.Regulatory_Action__c = 'CMP - First Warning';
        insertCaseList.add(c1);
        
        Case c11 = new Case();
        //c1.Name = 'testc1';
        c11.AccountId = objAccnt.id;
        c11.ContactId = objCon.id;
        c11.Market__c = 'United States';
        c11.Type = 'Brand Protection';
        c11.Regulatory_Action__c='No-Sale-List';
        c11.Secret_Shop_Status__c = 'Fail';
        c11.Sub_Type__c = 'Counterfeit Sales';
        c11.Secret_Shop_Date__c = System.today()-250;
        c11.recordTypeId = recTypeId;
        c11.status = 'Retail Case Closed';
        //c11.Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle';
        insertCaseList.add(c11);
         
        Case c12 = new Case();
        //c1.Name = 'testc1';
        c12.AccountId = acc1.id;
        c12.ContactId = objCon.id;
        c12.Market__c = 'United States';
        c12.Type = 'Brand Protection';
        c12.Regulatory_Action__c='No-Sale-List';
        c12.Secret_Shop_Status__c = 'Fail';
        c12.Sub_Type__c = 'Counterfeit Sales';
        c12.Secret_Shop_Date__c = System.today();
        c12.recordTypeId = recTypeId;
        c12.status = 'Retail Case Closed';
        insertCaseList.add(c12);
        
        insert insertCaseList;
 
        Map<String, String> mapInputs =  new Map<String, String>();
        String overrideQuery = 'AccountId IN (\''+acc1.id+'\')' ;
        mapInputs.put('overrideQuery',overrideQuery);
        system.debug('mapInputs:' + mapInputs);
        JuulSalesOpsBatch3StrikesAccntReset bat = new JuulSalesOpsBatch3StrikesAccntReset(mapInputs);
        Id batExecute = DataBase.executeBatch(bat,50);
        Test.stopTest();
    }
    
        public static testMethod void TestBatch3StrikesAccntResetTest2() { 
        Test.startTest();
        loadData();
        Account objAccnt = new Account(id=acc1.id,Status__c='Blacklisted');
        update objAccnt;
        contact objCon = new contact(id=con1.id,X1st_Failed_Case_Regulatory_Action__c='CMP - First Warning',Date_of_1st_Violation_AV_or_CMP__c = system.today() - 450, 
                                                X2nd_Failed_Case_Regulatory_Action__c='AV - First Warning',Date_of_2nd_Violation_AV_or_CMP__c=system.today() - 400,
                                                X3rd_Failed_Case_Regulatory_Action__c='CMP - Suspended - 2 Promo Cycle',Date_of_3rd_Violation_AV_or_CMP__c=system.today() - 390);
        update objCon;
        
        List<Case> insertCaseList = new List<Case>();
        Case c1 = new Case();
        //c1.Name = 'testc1';
        c1.AccountId = objAccnt.id;
        c1.ContactId = objCon.id;
        c1.Market__c = 'United States';
        c1.Type = 'Brand Protection';
        c1.Regulatory_Action__c='No-Sale-List';
        c1.Secret_Shop_Status__c = 'Fail';
        c1.Sub_Type__c = 'Counterfeit Sales';
        c1.Secret_Shop_Date__c = System.today()-450;
        c1.recordTypeId = recTypeId;
        c1.status = 'Retail Case Closed';
        //c1.Regulatory_Action__c = 'CMP - First Warning';
        insertCaseList.add(c1);
        
        Case c11 = new Case();
        //c1.Name = 'testc1';
        c11.AccountId = objAccnt.id;
        c11.ContactId = objCon.id;
        c11.Market__c = 'United States';
        c11.Type = 'Brand Protection';
        c11.Regulatory_Action__c='No-Sale-List';
        c11.Secret_Shop_Status__c = 'Fail';
        c11.Sub_Type__c = 'Counterfeit Sales';
        c11.Secret_Shop_Date__c = System.today()-290;
        c11.recordTypeId = recTypeId;
        c11.status = 'Retail Case Closed';
        //c11.Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle';
        insertCaseList.add(c11);
        
        Case c2 = new Case();
        c2.AccountId = acc1.id;
        c2.ContactId = con1.id;
        c2.Type = 'Secret Shopper';
        c2.Sub_Type__c = 'Age Verification';
        c2.Regulatory_Action__c='Promotional Funding Removed';
        c2.Secret_Shop_Status__c = 'Fail';
        c2.Secret_Shop_Date__c = System.today()-400;
        c2.recordTypeId = recTypeId;
        c2.status = 'Retail Case Closed';
        insertCaseList.add(c2);
        
        //insert insertCaseList;
 
        Map<String, String> mapInputs =  new Map<String, String>();
        String overrideQuery = 'AccountId IN (\''+acc1.id+'\')' ;
        mapInputs.put('overrideQuery',overrideQuery);
        system.debug('mapInputs:' + mapInputs);
        JuulSalesOpsBatch3StrikesAccntReset bat = new JuulSalesOpsBatch3StrikesAccntReset(mapInputs);
        Id batExecute = DataBase.executeBatch(bat,50);
        Test.stopTest();
    }

}