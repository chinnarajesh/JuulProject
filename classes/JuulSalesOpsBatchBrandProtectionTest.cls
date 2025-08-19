@isTest(seealldata = false)
public class JuulSalesOpsBatchBrandProtectionTest {
    private static Id AccntrecTypeId;
    private static Id ConrecTypeId;
    private static Id recTypeId;
    private static account acc01, acc02, acc03, acc1, acc2, acc3;
    private static contact con01, con02, con03, con1, con2, con3;
    
    public static void loadData(){
        BatchConstantValues__c sett = new BatchConstantValues__c();
        sett.Name = 'BatchBrandProtection';
        sett.X3_Strike_Enforcement_Start_Date__c= Date.newInstance(2019, 10, 1);
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
        sett.ShippingCountryList__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        ChildAccountShare__c sett1 = new ChildAccountShare__c();
      	sett1.Name = 'ChidlAccountShare';
      	sett1.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      	insert sett1;
        
        AccntrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        //ConrecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();//JTP-112
        recTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
        //recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        
        acc01 = new Account();
        acc01.Name = 'testAcc0';
        acc01.Status__c = 'Customer (Reporting)';
        acc01.ShippingCountry = 'US';
        acc01.recordTypeId = AccntrecTypeId;
        Insert acc01;
        con01 = new contact(FirstName='Test Name01',LastName='Test Name01',Email='Test01@test.com',AccountId=acc01.id
                            //,recordTypeId = ConrecTypeId//JTP-112
                           );
        Insert  con01;
        
        acc02 = new Account();
        acc02.Name = 'testAcc0';
        acc02.Status__c = 'Customer (Reporting)';
        acc02.ShippingCountry = 'US';
        acc02.recordTypeId = AccntrecTypeId;
        Insert acc02;
        con02 = new contact(FirstName='Test Name02',LastName='Test Name02',Email='Test02@test.com',AccountId=acc02.id
                            //,recordTypeId = ConrecTypeId//JTP-112
                           );
        Insert  con02;
        
        acc03 = new Account();
        acc03.Name = 'testAcc0';
        acc03.Status__c = 'Customer (Reporting)';
        acc03.ShippingCountry = 'US';
        acc03.recordTypeId = AccntrecTypeId;
        Insert acc03;
        con03 = new contact(FirstName='Test Name03',LastName='Test Name03',Email='Test03@test.com',AccountId=acc03.id
                            //,recordTypeId = ConrecTypeId//JTP-112
                            );
        Insert  con03;

    }
    
    public static testMethod void testNewCasesWithNoExistingCases() {
        Test.startTest();
        loadData();

        List<Case> insertCaseList = new List<Case>();
        
        Case c01 = new Case(); 
        c01.AccountId = acc01.id;
        c01.ContactId = con01.id;
        c01.Type = 'FDA Retailer Compliance Check';        
        c01.Sub_Type__c = 'Sale Involving a Minor';
        c01.Regulatory_Action__c = 'Warning';
        c01.Secret_Shop_Status__c = 'Fail';
        c01.Secret_Shop_Date__c = System.today();
        c01.recordTypeId = recTypeId;
        c01.status = 'Retail Case Closed';
        insertCaseList.add(c01);   
        
        Case c02 = new Case(); 
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Age Verification'; 
        c02.Regulatory_Action__c = 'None';
        c02.Secret_Shop_Status__c = 'Pass';
        c02.Secret_Shop_Date__c = System.today(); 
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed'; 
        insertCaseList.add(c02);
     
        Case c021 = new Case();
        c021.AccountId = acc02.Id;
        c021.ContactId = con02.id;
        c021.Type = 'Mystery Shop';
        c021.Sub_Type__c = 'Product Quantity Limits'; 
        c021.Regulatory_Action__c = 'None';
        c021.Secret_Shop_Status__c = 'Pass';
        c021.Secret_Shop_Date__c = System.today();
        c021.recordTypeId = recTypeId;
        c021.status = 'Retail Case Closed';
        insertCaseList.add(c021);  
        
        Case c03 = new Case(); 
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification'; 
        c03.Regulatory_Action__c = 'Warning';
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today();
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed'; 
        insertCaseList.add(c03);
        
        Case c031 = new Case();
        c031.AccountId = acc03.Id;
        c031.ContactId = con03.id;
        c031.Type = 'Mystery Shop';
        c031.Sub_Type__c = 'Product Quantity Limits';
        c031.Regulatory_Action__c = 'Promotional Funding Removed';
        c031.Secret_Shop_Status__c = 'Fail';
        c031.Secret_Shop_Date__c = System.today();
        c031.recordTypeId = recTypeId;
        c031.status = 'Retail Case Closed';
        insertCaseList.add(c031); 
        
        Case c010 = new Case(); 
        c010.AccountId = acc01.id;
        c010.ContactId = con01.id;
        c010.Type = 'FDA Retailer Compliance Check';        
        c010.Sub_Type__c = 'Sale Involving a Minor';
        c010.Regulatory_Action__c = 'Warning';
        c010.Secret_Shop_Status__c = 'Fail';
        c010.Secret_Shop_Date__c = System.today();
        c010.recordTypeId = recTypeId;
        c010.status = 'Retail Case Closed';
        insertCaseList.add(c010); 

         
       
        insert insertCaseList; 
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20); 
        Test.stopTest();
    }
    
    public static testMethod void testNewCasesWithOneExistingCases() {
        Test.startTest();
        loadData();
        
        con01.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con01.X1st_Failed_Case_Regulatory_Action__c = 'CMP - First Warning';
        con02.BP_First_Warning_Violation_Date__c = System.today().addDays(-10);
        con03.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con03.X1st_Failed_Case_Regulatory_Action__c = 'AV - First Warning';
        update  con01;
        update  con02;
        update  con03;
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c010 = new Case(); 
        c010.AccountId = acc01.id;
        c010.ContactId = con01.id;
        c010.Type = 'Brand Protection';   
        c010.Sub_Type__c = 'Online Sales';
        c010.Regulatory_Action__c = 'Warning';
        c010.Secret_Shop_Status__c = 'Fail';
        c010.Secret_Shop_Date__c = System.today().addDays(-10);
        c010.recordTypeId = recTypeId;
        c010.status = 'Retail Case Closed';
        insertCaseList.add(c010);
        
        Case c01 = new Case(); 
        c01.AccountId = acc01.id;
        c01.ContactId = con01.id;
        c01.Type = 'Brand Protection';   
        c01.Sub_Type__c = 'Online Sales';
        c01.Regulatory_Action__c = 'Warning';
        c01.Secret_Shop_Status__c = 'Fail';
        c01.Secret_Shop_Date__c = System.today();
        c01.recordTypeId = recTypeId;
        c01.status = 'Retail Case Closed';
        insertCaseList.add(c01);   
        
        Case c020 = new Case(); 
        c020.AccountId = acc02.id;
        c020.ContactId = con02.id;
        c020.Type = 'Mystery Shop';
        c020.Sub_Type__c = 'Product Quantity Limits';
        c020.Regulatory_Action__c = 'Promotional Funding Removed';
        c020.Secret_Shop_Status__c = 'Fail';
        c020.Secret_Shop_Date__c = System.today().addDays(-10);
        c020.recordTypeId = recTypeId;
        c020.status = 'Retail Case Closed'; 
        insertCaseList.add(c020);
     
        Case c02 = new Case();
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Product Quantity Limits';
        c02.Regulatory_Action__c = 'Promotional Funding Removed';
        c02.Secret_Shop_Status__c = 'Fail'; 
        c02.Secret_Shop_Date__c = System.today();
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed'; 
        insertCaseList.add(c02); 
        
        Case c030 = new Case(); 
        c030.AccountId = acc03.id;
        c030.ContactId = con03.id;
        c030.Type = 'Mystery Shop';
        c030.Sub_Type__c = 'Age Verification'; 
        c030.Regulatory_Action__c = 'Promotional Funding Removed';
        c030.Secret_Shop_Status__c = 'Fail';
        c030.Secret_Shop_Date__c = System.today().addDays(-10);
        c030.recordTypeId = recTypeId;
        c030.status = 'Retail Case Closed'; 
        insertCaseList.add(c030);
        
        Case c03 = new Case();
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification';
        c03.Regulatory_Action__c = 'Promotional Funding Removed';
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today();
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed'; 
        insertCaseList.add(c03); 
       
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection();
        DataBase.executeBatch(bat1, 20); 
        Test.stopTest();
    }
    
    public static testMethod void testCMPNewCasesWithTwoExistingCases() {
        Test.startTest();
        loadData();
        
        acc01.Status__c = 'Suspended'; 
        update acc01; 
        con01.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con01.X1st_Failed_Case_Regulatory_Action__c = 'CMP - First Warning';
        con01.Date_of_2nd_Violation_AV_or_CMP__c = System.today().addDays(-5);
        con01.X2nd_Failed_Case_Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle'; 
        update  con01; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c010 = new Case(); 
        c010.AccountId = acc01.id;
        c010.ContactId = con01.id;
        c010.Type = 'Brand Protection';   
        c010.Sub_Type__c = 'Online Sales';
        c010.Regulatory_Action__c = 'Warning';
        c010.Secret_Shop_Status__c = 'Fail';
        c010.Secret_Shop_Date__c = System.today().addDays(-10);
        c010.recordTypeId = recTypeId;
        c010.status = 'Retail Case Closed';
        insertCaseList.add(c010);
        
        Case c011 = new Case(); 
        c011.AccountId = acc01.id;
        c011.ContactId = con01.id;
        c011.Type = 'Brand Protection';   
        c011.Sub_Type__c = 'Online Sales';
        c011.Regulatory_Action__c = 'Warning';
        c011.Secret_Shop_Status__c = 'Fail';
        //c011.Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle';
        c011.Secret_Shop_Date__c = System.today().addDays(-5);
        c011.recordTypeId = recTypeId;
        c011.status = 'Retail Case Closed';
        insertCaseList.add(c011);
        
        Case c01 = new Case(); 
        c01.AccountId = acc01.id;
        c01.ContactId = con01.id;
        c01.Type = 'Brand Protection';   
        c01.Sub_Type__c = 'Online Sales';
        c01.Regulatory_Action__c = 'Warning';
        c01.Secret_Shop_Status__c = 'Fail';
        c01.Secret_Shop_Date__c = System.today();
        c01.recordTypeId = recTypeId;
        c01.status = 'Retail Case Closed';
        insertCaseList.add(c01);   
        
        //insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
          
        Map<String, String> mapInputs =  new Map<String, String>();   
        String overrideQuery = 'Id != NULL' ; 
        mapInputs.put('overrideQuery',overrideQuery); 
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(mapInputs);
        DataBase.executeBatch(bat1, 20);

        Test.stopTest();
    }
    
    public static testMethod void testCMPNewCasesWithTwoMixedExistingCases() {
        Test.startTest();
        loadData();
        
        acc01.Status__c = 'Suspended'; 
        update acc01; 
        con01.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con01.X1st_Failed_Case_Regulatory_Action__c = 'AV - First Warning';
        con01.Date_of_2nd_Violation_AV_or_CMP__c = System.today().addDays(-5);
        con01.X2nd_Failed_Case_Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle'; 
        update  con01; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c010 = new Case(); 
        c010.AccountId = acc01.id;
        c010.ContactId = con01.id;
        c010.Type = 'Mystery Shop';   
        c010.Sub_Type__c = 'Age Verification';
        c010.Regulatory_Action__c = 'Warning';
        c010.Secret_Shop_Date__c = System.today().addDays(-10);
        c010.Secret_Shop_Status__c = 'Fail';
        c010.recordTypeId = recTypeId;
        c010.status = 'Retail Case Closed';
        insertCaseList.add(c010);
        
        Case c011 = new Case(); 
        c011.AccountId = acc01.id;
        c011.ContactId = con01.id;
        c011.Type = 'Brand Protection';   
        c011.Sub_Type__c = 'Online Sales';
        c011.Regulatory_Action__c = 'Warning';
        c011.Secret_Shop_Status__c = 'Fail';
        c011.Secret_Shop_Date__c = System.today().addDays(-5);
        c011.recordTypeId = recTypeId;
        c011.status = 'Retail Case Closed';
        insertCaseList.add(c011);
        
        Case c01 = new Case(); 
        c01.AccountId = acc01.id;
        c01.ContactId = con01.id;
        c01.Type = 'Brand Protection';   
        c01.Sub_Type__c = 'Online Sales';
        c01.Regulatory_Action__c = 'Warning';
        c01.Secret_Shop_Status__c = 'Fail';
        c01.Secret_Shop_Date__c = System.today();
        c01.recordTypeId = recTypeId;
        c01.status = 'Retail Case Closed';
        insertCaseList.add(c01);   
        
        //insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
        //System.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20);
        Test.stopTest();
    }
    
    public static testMethod void testBPNewCasesWithTwoExistingCases() {
        Test.startTest();
        loadData();
        
        con02.BP_First_Warning_Violation_Date__c = System.today().addDays(-10);
        con02.BP_Suspended_1_Promo_CY_Violation_Date__c = System.today().addDays(-5);
        
        update  con02; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c020 = new Case(); 
        c020.AccountId = acc02.id;
        c020.ContactId = con02.id;
        c020.Type = 'Mystery Shop';
        c020.Sub_Type__c = 'Product Quantity Limits';
        c020.Regulatory_Action__c = 'Warning';
        c020.Secret_Shop_Status__c = 'Fail';
        c020.Secret_Shop_Date__c = System.today().addDays(-10);
        c020.recordTypeId = recTypeId;
        c020.status = 'Retail Case Closed'; 
        insertCaseList.add(c020);
 
        Case c021 = new Case(); 
        c021.AccountId = acc02.id;
        c021.ContactId = con02.id;
        c021.Type = 'Mystery Shop';
        c021.Sub_Type__c = 'Product Quantity Limits';
        c021.Regulatory_Action__c = 'Warning';
        c021.Secret_Shop_Status__c = 'Fail';
        c021.Secret_Shop_Date__c = System.today().addDays(-5);
        c021.recordTypeId = recTypeId;
        c021.status = 'Retail Case Closed'; 
        insertCaseList.add(c021);
        
        Case c02 = new Case(); 
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Product Quantity Limits'; 
        c02.Regulatory_Action__c = 'Warning';
        c02.Secret_Shop_Status__c = 'Fail'; 
        c02.Secret_Shop_Date__c = System.today();
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed';
        insertCaseList.add(c02); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20);
        Test.stopTest();
    }
     
    public static testMethod void testBPNewCasesWithTwoFailExistingCases() {
        Test.startTest();
        loadData();
        
        con02.BP_First_Warning_Violation_Date__c = System.today().addDays(-10);
        con02.BP_Suspended_1_Promo_CY_Violation_Date__c = System.today().addDays(-5);
        
        update  con02; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c020 = new Case(); 
        c020.AccountId = acc02.id;
        c020.ContactId = con02.id;
        c020.Type = 'Mystery Shop';
        c020.Sub_Type__c = 'Product Quantity Limits';
        c020.Regulatory_Action__c = 'Warning';
        c020.Secret_Shop_Status__c = 'Fail';
        c020.Secret_Shop_Date__c = System.today().addDays(-10);
        c020.recordTypeId = recTypeId;
        c020.status = 'Retail Case Closed'; 
        insertCaseList.add(c020);
           
        Case c022 = new Case(); 
        c022.AccountId = acc02.id;
        c022.ContactId = con02.id;
        c022.Type = 'Mystery Shop';
        c022.Sub_Type__c = 'Product Quantity Limits';
        c022.Regulatory_Action__c = 'Warning';
        c022.Secret_Shop_Status__c = 'Fail';
        c022.Secret_Shop_Date__c = System.today().addDays(-5);
        c022.recordTypeId = recTypeId;
        c022.status = 'Retail Case Closed'; 
        insertCaseList.add(c022);
        
        Case c02 = new Case(); 
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Product Quantity Limits'; 
        c02.Regulatory_Action__c = 'Warning';
        c02.Secret_Shop_Status__c = 'Fail'; 
        c02.Secret_Shop_Date__c = System.today();
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed'; 
        insertCaseList.add(c02); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20);
        Test.stopTest();
    }
    
    public static testMethod void testBPNewCasesWithTwoMixedExistingCases() {
        Test.startTest();
        loadData();
        
        con02.BP_First_Warning_Violation_Date__c = System.today().addDays(-10);
        con02.BP_Suspended_1_Promo_CY_Violation_Date__c = System.today().addDays(-5);
        
        update  con02; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c020 = new Case(); 
        c020.AccountId = acc02.id;
        c020.ContactId = con02.id;
        c020.Type = 'Mystery Shop';
        c020.Sub_Type__c = 'Product Quantity Limits';
        c020.Regulatory_Action__c = 'Warning';
        c020.Secret_Shop_Status__c = 'Fail';
        c020.Secret_Shop_Date__c = System.today().addDays(-10);
        c020.recordTypeId = recTypeId;
        c020.status = 'Retail Case Closed'; 
        insertCaseList.add(c020);
 
        Case c021 = new Case(); 
        c021.AccountId = acc02.id;
        c021.ContactId = con02.id;
        c021.Type = 'Mystery Shop';
        c021.Sub_Type__c = 'Product Quantity Limits';
        c021.Regulatory_Action__c = 'None';
        c021.Next_Secret_Shop_Date__c = System.today().addDays(30);
        c021.Secret_Shop_Status__c = 'Pass';
        c021.Secret_Shop_Date__c = System.today().addDays(-8);
        c021.recordTypeId = recTypeId;
        c021.status = 'Retail Case Closed'; 
        insertCaseList.add(c021);
           
        Case c022 = new Case(); 
        c022.AccountId = acc02.id;
        c022.ContactId = con02.id;
        c022.Type = 'Mystery Shop';
        c022.Sub_Type__c = 'Product Quantity Limits';
        c022.Regulatory_Action__c = 'Warning';
        c022.Secret_Shop_Status__c = 'Fail';
        c022.Secret_Shop_Date__c = System.today().addDays(-5);
        c022.recordTypeId = recTypeId;
        c022.status = 'Retail Case Closed'; 
        insertCaseList.add(c022);
        
        Case c02 = new Case(); 
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Product Quantity Limits';
        c02.Regulatory_Action__c = 'Warning';
        c02.Secret_Shop_Status__c = 'Fail'; 
        c02.Secret_Shop_Date__c = System.today();
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed'; 
        insertCaseList.add(c02); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20);
        Test.stopTest();
    }
    
    public static testMethod void testBPNewCasesWithTwoFailMixedExistingCases1() {
        Test.startTest();
        loadData();
        
        con02.BP_First_Warning_Violation_Date__c = System.today().addDays(-10);
        con02.BP_Suspended_1_Promo_CY_Violation_Date__c = System.today().addDays(-5);
        
        update  con02; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c020 = new Case(); 
        c020.AccountId = acc02.id;
        c020.ContactId = con02.id;
        c020.Type = 'Mystery Shop';
        c020.Sub_Type__c = 'Product Quantity Limits';
        c020.Regulatory_Action__c = 'Warning';
        c020.Secret_Shop_Status__c = 'Fail';
        c020.Secret_Shop_Date__c = System.today().addDays(-10);
        c020.recordTypeId = recTypeId;
        c020.status = 'Retail Case Closed'; 
        insertCaseList.add(c020);
 
        Case c021 = new Case(); 
        c021.AccountId = acc02.id;
        c021.ContactId = con02.id;
        c021.Type = 'Mystery Shop';
        c021.Sub_Type__c = 'Age Verification';
        c021.Regulatory_Action__c = 'None';
        c021.Next_Secret_Shop_Date__c = System.today().addDays(30);
        c021.Secret_Shop_Status__c = 'Pass';
        c021.Secret_Shop_Date__c = System.today().addDays(-12);
        c021.recordTypeId = recTypeId;
        c021.status = 'Retail Case Closed'; 
        insertCaseList.add(c021);
           
        Case c022 = new Case(); 
        c022.AccountId = acc02.id;
        c022.ContactId = con02.id;
        c022.Type = 'Mystery Shop';
        c022.Sub_Type__c = 'Product Quantity Limits';
        c022.Regulatory_Action__c = 'Warning';
        c022.Secret_Shop_Status__c = 'Fail';
        c022.Secret_Shop_Date__c = System.today().addDays(-8);
        c022.recordTypeId = recTypeId;
        c022.status = 'Retail Case Closed'; 
        insertCaseList.add(c022);
        
        Case c02 = new Case(); 
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Product Quantity Limits';
        c02.Regulatory_Action__c = 'Warning';
        c02.Secret_Shop_Status__c = 'Fail'; 
        c02.Secret_Shop_Date__c = System.today();
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed'; 
        insertCaseList.add(c02); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20);
        Test.stopTest();
    }
    
    public static testMethod void testBPNewCasesWithTwoFailMixedExistingCases2() {
        Test.startTest();
        loadData();
        
        con02.BP_First_Warning_Violation_Date__c = System.today().addDays(-10);
        con02.BP_Suspended_1_Promo_CY_Violation_Date__c = System.today().addDays(-5);
        
        update  con02; 
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c020 = new Case(); 
        c020.AccountId = acc02.id;
        c020.ContactId = con02.id;
        c020.Type = 'Mystery Shop';
        c020.Sub_Type__c = 'Product Quantity Limits';
        c020.Regulatory_Action__c = 'Warning';
        c020.Secret_Shop_Status__c = 'Fail';
        c020.Secret_Shop_Date__c = System.today().addDays(-10);
        c020.recordTypeId = recTypeId;
        c020.status = 'Retail Case Closed'; 
        insertCaseList.add(c020);
 
        Case c021 = new Case(); 
        c021.AccountId = acc02.id;
        c021.ContactId = con02.id;
        c021.Type = 'Mystery Shop';
        c021.Sub_Type__c = 'Product Quantity Limits';
        c021.Regulatory_Action__c = 'None';
        //c021.Sub_Type__c = 'Bulk Purchasing';
        c021.Next_Secret_Shop_Date__c = System.today().addDays(30);
        c021.Secret_Shop_Status__c = 'Pass';
        c021.Secret_Shop_Date__c = System.today().addDays(-5);
        c021.recordTypeId = recTypeId;
        c021.status = 'Retail Case Closed'; 
        insertCaseList.add(c021);
           
        Case c022 = new Case(); 
        c022.AccountId = acc02.id;
        c022.ContactId = con02.id;
        c022.Type = 'Mystery Shop';
        c022.Sub_Type__c = 'Product Quantity Limits';
        c022.Regulatory_Action__c = 'Warning';
        c022.Secret_Shop_Status__c = 'Fail';
        c022.Secret_Shop_Date__c = System.today().addDays(-8);
        c022.recordTypeId = recTypeId;
        c022.status = 'Retail Case Closed'; 
        insertCaseList.add(c022);
        
        Case c02 = new Case(); 
        c02.AccountId = acc02.id;
        c02.ContactId = con02.id;
        c02.Type = 'Mystery Shop';
        c02.Sub_Type__c = 'Product Quantity Limits';
        c02.Regulatory_Action__c = 'Promotional Funding Removed';
        c02.Secret_Shop_Status__c = 'Fail'; 
        c02.Secret_Shop_Date__c = System.today();
        c02.recordTypeId = recTypeId;
        c02.status = 'Retail Case Closed'; 
        insertCaseList.add(c02); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        DataBase.executeBatch(bat1, 20);
        Test.stopTest();
    }
    
    /*public static testMethod void testAVNewCasesWithTwoExistingCases() {
        Test.startTest();
        loadData();
        
        acc03.Status__c = 'Suspended';
        update acc03;
        con03.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con03.X1st_Failed_Case_Regulatory_Action__c = 'AV - First Warning';
        con03.Date_of_2nd_Violation_AV_or_CMP__c = System.today().addDays(-5);
        con03.X2nd_Failed_Case_Regulatory_Action__c = 'AV - Report to FDA';

        update  con03;
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c030 = new Case(); 
        c030.AccountId = acc03.id;
        c030.ContactId = con03.id;
        c030.Type = 'Mystery Shop';
        c030.Sub_Type__c = 'Age Verification'; 
        c030.Regulatory_Action__c = 'Warning';
        c030.Secret_Shop_Status__c = 'Fail';
        c030.Secret_Shop_Date__c = System.today().addDays(-10);
        c030.recordTypeId = recTypeId;
        c030.status = 'Retail Case Closed'; 
        insertCaseList.add(c030);
        
        Case c031 = new Case(); 
        c031.AccountId = acc03.id;
        c031.ContactId = con03.id;
        c031.Type = 'Mystery Shop';
        c031.Sub_Type__c = 'Age Verification'; 
        c031.Regulatory_Action__c = 'Warning';
        c031.Secret_Shop_Status__c = 'Fail';
        c031.Secret_Shop_Date__c = System.today().addDays(-5);
        c031.recordTypeId = recTypeId;
        c031.status = 'Retail Case Closed'; 
        insertCaseList.add(c031);
        
        Case c03 = new Case();
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification'; 
        c03.Regulatory_Action__c = 'Warning';
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today();
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed'; 
        insertCaseList.add(c03); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        bat1.executeOrderUpdate();
        Test.stopTest();
    }   */
    
    /*public static testMethod void testAVNewCasesWithTwoMixedExistingCases() {
        Test.startTest();
        loadData();
        
        acc03.Status__c = 'Suspended';
        update acc03;
        con03.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con03.X1st_Failed_Case_Regulatory_Action__c = 'CMP - First Warning';
        con03.Date_of_2nd_Violation_AV_or_CMP__c = System.today().addDays(-5);
        con03.X2nd_Failed_Case_Regulatory_Action__c = 'AV - Report to FDA';

        update  con03;
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c030 = new Case(); 
        c030.AccountId = acc03.id;
        c030.ContactId = con03.id;
        c030.Type = 'Brand Protection';
        c030.Sub_Type__c = 'Online Sales';
		c030.Regulatory_Action__c = 'Warning';
        c030.Secret_Shop_Status__c = 'Fail';
        c030.Secret_Shop_Date__c = System.today().addDays(-10);
        c030.recordTypeId = recTypeId;
        c030.status = 'Retail Case Closed';
        insertCaseList.add(c030);
        
        Case c031 = new Case(); 
        c031.AccountId = acc03.id;
        c031.ContactId = con03.id;
        c031.Type = 'Mystery Shop';
        c031.Sub_Type__c = 'Age Verification'; 
        c031.Regulatory_Action__c = 'Promotional Funding Removed';
        c031.Secret_Shop_Status__c = 'Fail';
        c031.Secret_Shop_Date__c = System.today().addDays(-5);
        c031.recordTypeId = recTypeId;
        c031.status = 'Retail Case Closed'; 
        insertCaseList.add(c031);
        
        Case c03 = new Case();
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification'; 
        c03.Regulatory_Action__c = 'Promotional Funding Removed';
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today();
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed'; 
        insertCaseList.add(c03); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        bat1.executeOrderUpdate();
        Test.stopTest();
    } */
    
    public static testMethod void testCMPAVNewCases() {
        Test.startTest();
        loadData();  
        List<Case> insertCaseList = new List<Case>();
        
        Case c031 = new Case(); 
        c031.AccountId = acc03.id;
        c031.ContactId = con03.id;
        c031.Type = 'Brand Protection';
        c031.Sub_Type__c = 'Online Sales';
        c031.Regulatory_Action__c = 'Warning';
        c031.Secret_Shop_Status__c = 'Fail';
        c031.Secret_Shop_Date__c = System.today()-1;
        c031.recordTypeId = recTypeId;
        c031.status = 'Retail Case Closed'; 
        insertCaseList.add(c031);
        
        Case c03 = new Case();
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification';
        c03.Regulatory_Action__c = 'Promotional Funding Removed';
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today();
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed'; 
        insertCaseList.add(c03); 
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
       // system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        bat1.executeOrderUpdate();
        Test.stopTest();
    } 
    
    public static testMethod void testCMPAVNewCasesWithOneExisting() {
        Test.startTest();
        loadData();
        con03.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con03.X1st_Failed_Case_Regulatory_Action__c = 'CMP - First Warning'; 

        update  con03;
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c030 = new Case(); 
        c030.AccountId = acc03.id;
        c030.ContactId = con03.id;
        c030.Type = 'Brand Protection';
        c030.Sub_Type__c = 'Online Sales'; 
        c030.Regulatory_Action__c = 'Warning';
        c030.Secret_Shop_Status__c = 'Fail';
        c030.Secret_Shop_Date__c = System.today()-10;
        c030.recordTypeId = recTypeId;
        c030.status = 'Retail Case Closed'; 
        insertCaseList.add(c030);
        
        Case c031 = new Case(); 
        c031.AccountId = acc03.id;
        c031.ContactId = con03.id;
        c031.Type = 'Brand Protection';
        c031.Sub_Type__c = 'Online Sales'; 
        c031.Regulatory_Action__c = 'Warning';
        c031.Secret_Shop_Status__c = 'Fail'; 
        c031.Secret_Shop_Date__c = System.today()-1;
        c031.recordTypeId = recTypeId;
        c031.status = 'Retail Case Closed'; 
        insertCaseList.add(c031);
        
        Case c03 = new Case();
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification';
        c03.Regulatory_Action__c = 'Promotional Funding Removed'; 
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today();
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed'; 
        insertCaseList.add(c03); 
        
        insert insertCaseList;
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        bat1.executeOrderUpdate();
        Test.stopTest();
    }  
    
    public static testMethod void testAVCMPNewCasesWithOneExisting() {
        Test.startTest();
        loadData();
        con03.Date_of_1st_Violation_AV_or_CMP__c = System.today().addDays(-10);
        con03.X1st_Failed_Case_Regulatory_Action__c = 'CMP - First Warning'; 

        update  con03;
        
        List<Case> insertCaseList = new List<Case>();
        
        Case c030 = new Case(); 
        c030.AccountId = acc03.id;
        c030.ContactId = con03.id;
        c030.Type = 'Brand Protection';
        c030.Sub_Type__c = 'Online Sales';
        c030.Regulatory_Action__c = 'Warning';
        c030.Secret_Shop_Status__c = 'Fail'; 
        c030.Secret_Shop_Date__c = System.today()-10;
        c030.recordTypeId = recTypeId;
        c030.status = 'Retail Case Closed'; 
        insertCaseList.add(c030);
        
        Case c031 = new Case(); 
        c031.AccountId = acc03.id;
        c031.ContactId = con03.id;
        c031.Type = 'Brand Protection';
        c031.Sub_Type__c = 'Online Sales';
        c031.Regulatory_Action__c = 'Warning';
        c031.Secret_Shop_Status__c = 'Fail';
        c031.Secret_Shop_Date__c = System.today();
        c031.recordTypeId = recTypeId;
        c031.status = 'Retail Case Closed'; 
        insertCaseList.add(c031);
        
        Case c03 = new Case();
        c03.AccountId = acc03.id;
        c03.ContactId = con03.id;
        c03.Type = 'Mystery Shop';
        c03.Sub_Type__c = 'Age Verification';
        c03.Regulatory_Action__c = 'Promotional Funding Removed';
        c03.Secret_Shop_Status__c = 'Fail';
        c03.Secret_Shop_Date__c = System.today()-2;
        c03.recordTypeId = recTypeId;
        c03.status = 'Retail Case Closed';
        insertCaseList.add(c03);
        
        insert insertCaseList;
        //String sch = '0 0 23 * * ?'; 
        //System.schedule('Test Territory Check', sch, new JuulSalesOpsBatchBrandProtection());
        
        JuulSalesOpsBatchBrandProtection bat1 = new JuulSalesOpsBatchBrandProtection(new map<string,string>());
        bat1.executeOrderUpdate();
        Test.stopTest();
    }
}