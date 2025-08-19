@isTest
private class JuulSalesOrderNSLEmailToDistiContactTest{
    static testmethod void unitTest1(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        BatchConstantValues__c BcustomSetting = new BatchConstantValues__c();
        BcustomSetting.Name = 'BatchBrandProtection';
        BcustomSetting.X3_Strike_Account_Blacklist_Reset__c = -12;
        BcustomSetting.X3_Strike_Account_Suspension_Reset__c = -6;
        BcustomSetting.X3_Strike_Enforcement_Start_Date__c = system.today();
        BcustomSetting.Scheduler_Batch_Size__c = 100;
        BcustomSetting.X3_Strike_Admin_EmailIds__c = 'abc@gmail.com';
        insert BcustomSetting;
        
        Account personA = new Account();
        personA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        personA.LastName = 'test';   
        personA.NSL_Effective_Date__c = system.today();
        personA.CurrencyIsoCode = 'USD';
        personA.PersonEmail = 'xyz@gmail.com';
        personA.Phone = '1234567890';
        insert personA;
        
        Account businnessA = new Account();
        businnessA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        businnessA.Name = 'Test';
        businnessA.CurrencyIsoCode = 'USD';
        insert businnessA;
        
        salesOrder__c salesOrder = new salesOrder__c();
        salesOrder.Name = '012345';
        salesOrder.Customer__c = personA.Id;
        salesOrder.Distributor__c = businnessA.Id;
        salesOrder.CurrencyIsoCode = 'USD';
        salesOrder.Date__c = string.valueof(system.now()+5);
        insert salesOrder; 
        
        contact con = new contact();
        con.RecordtypeId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('JUUL Contacts').getRecordTypeId();
        con.LastName = 'Test';
        con.Communication_Type__c = 'Distributor No Sale List';
        con.accountID = businnessA.Id;
        con.Email = 'xyz@gmail.com';
        insert con;
        
        test.startTest();
        JuulSalesOrderNSLEmailToDistiContact ju = new JuulSalesOrderNSLEmailToDistiContact();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, ju); 
        test.stopTest();    
    }
    
    
    static testmethod void unitTest2(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        BatchConstantValues__c BcustomSetting = new BatchConstantValues__c();
        BcustomSetting.Name = 'BatchBrandProtection';
        BcustomSetting.X3_Strike_Account_Blacklist_Reset__c = -12;
        BcustomSetting.X3_Strike_Account_Suspension_Reset__c = -6;
        BcustomSetting.X3_Strike_Enforcement_Start_Date__c = system.today();
        BcustomSetting.Scheduler_Batch_Size__c = 100;
        BcustomSetting.X3_Strike_Admin_EmailIds__c = '123456789';
        insert BcustomSetting;
        
        Account personA = new Account();
        personA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        personA.LastName = 'test';      
        personA.NSL_Effective_Date__c = system.today();
        personA.CurrencyIsoCode = 'USD';
        personA.PersonEmail = 'xyz@gmail.com';
        personA.Phone = '1234567890';
        personA.Status__c = 'Blacklisted';
        insert personA;
        
        
        Account businnessA = new Account();
        businnessA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        businnessA.Name = 'Test';
        businnessA.CurrencyIsoCode = 'USD';
        insert businnessA;
        
        salesOrder__c salesOrder = new salesOrder__c();
        salesOrder.Name = '012345';
        salesOrder.Customer__c = personA.Id;
        salesOrder.Distributor__c = businnessA.Id;
        salesOrder.CurrencyIsoCode = 'USD';
        salesOrder.Date__c = string.valueof(system.now()+5);
        salesOrder.NSL_Email_Sent__c = false;
        salesOrder.orderType__c = 'BO';
        insert salesOrder; 
        
        contact con = new contact();
        con.RecordtypeId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('JUUL Contacts').getRecordTypeId();
        con.LastName = 'Test';
        con.Communication_Type__c = 'Distributor No Sale List';
        con.accountID = businnessA.Id;
        con.Email = 'xyz@gmail.com';
        insert con;
        
        NSLOrderCutoffDate__c nsL = new NSLOrderCutoffDate__c();
        nsL.Name = 'NSLOrderCutoffDate';
        nsL.Address__c = 'no-reply@juul.com';
        nsL.CurrentDate__c = system.today();
        insert nsL;
        
        test.startTest();
        JuulSalesOrderNSLEmailToDistiContact ju = new JuulSalesOrderNSLEmailToDistiContact();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, ju); 
        test.stopTest();    
        
        
    }
    
}