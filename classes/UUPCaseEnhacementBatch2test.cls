@istest
public class UUPCaseEnhacementBatch2test {
    


    @testSetup
    public static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA,UK';
        insert sett;
        
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController); 
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='CaseTrigger',Enabled__c=true);
        insert(triggerController2);
        
        Account acc = new Account();
        acc.Name = 'Juul Account1';
        acc.Email__c = 'testacc@juul.com';
        acc.ShippingCountry = 'US';
        acc.ShippingStreet = '1';
        acc.ShippingPostalCode='001';
        acc.ShippingCity='Lyonn';
        acc.Type = 'Independent Retailer';
        acc.Status__c='Blacklisted';
        insert acc;
    }
    
    static testMethod void testUUPCaseEnhancement(){
        
        Account acc = [Select id, name,Email__c,ShippingCountry,ShippingStreet,ShippingPostalCode,ShippingCity FROM Account WHERE Name='Juul Account1' LIMIT 1];
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
        Contact con = new Contact();
        con.FirstName = 'Test Juul1';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        
        vz__Print_Mail_Content__c printMail = new vz__Print_Mail_Content__c();
        printMail.Name = 'template-b'; 
        insert printMail;
            
        Case c = new Case();
        c.accountId = acc.Id;
        c.contactId = con.Id;
        c.Subject = 'Age Verification Compliance Audit';
        c.Type = 'Mystery Shop';
        c.Sub_Type__c = 'Product Quantity Limits';
        c.Regulatory_Action__c = 'No-Sale-List';
        c.Secret_Shop_Group__c = 'Re-shop 1';
        c.Secret_Shop_Status__c = 'Fail';
        c.status = 'Retail Case Closed';
        //c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        c.RecordTypeId = B2BSupportCaseRecordTypeId;
        insert c;
        
    }
    
    static testMethod void testUUPCaseEnhancement2(){
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
        Account acc = new Account();
        acc.Name = 'Juul Account1';
        acc.Email__c = 'testacc@juul.com';
        acc.ShippingCountry = 'US';
        acc.ShippingStreet = '1';
        acc.ShippingPostalCode='001';
        acc.ShippingCity='Lyonn';
        acc.Type='Independent Retailer';
        insert acc;        
        Contact con = new Contact();
        con.FirstName = 'Test Juul1';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        
        vz__Print_Mail_Content__c printMail = new vz__Print_Mail_Content__c();
        printMail.Name = 'template-b'; 
        insert printMail;
            
        Case c = new Case();
        c.accountId = acc.Id;
        c.contactId = con.Id;
        c.Subject = 'Quantity Purchase Limits Mystery Shop';
        c.Type = 'Mystery Shop';
        c.Sub_Type__c = 'Product Quantity Limits';
        c.Regulatory_Action__c = 'No-Sale-List';
        c.Secret_Shop_Group__c = 'Re-shop 1';
        c.Secret_Shop_Status__c = 'Fail';
        c.status = 'Retail Case Closed';
        //c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        c.RecordTypeId = B2BSupportCaseRecordTypeId;
        insert c;
        
    }

}