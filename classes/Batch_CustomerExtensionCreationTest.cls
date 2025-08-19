@isTest
public class Batch_CustomerExtensionCreationTest {

    
   static testMethod  void setup(){
       ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=false);
        insert(triggerController1);
       
       	cgcloud__Account_Template__c  accTemp1 = new cgcloud__Account_Template__c();
        accTemp1.cgcloud__Active__c = true;
        accTemp1.cgcloud__Sales_Org__c = '0001';
        accTemp1.cgcloud__Description_Language_1__c = 'Customer (Canada Global)';
        accTemp1.cgcloud__Description_Language_2__c = 'Client (Canada Global)';
        //accTemp.cgcloud__Description__c = 'Customer (Canada Global)';
        accTemp1.Name = 'JUUL HQ or Door';
        accTemp1.cgcloud__Available_Product_Level__c = 'Category;Brand';
        insert accTemp1;
        
       	cgcloud__Org_Unit__c OU = new cgcloud__Org_Unit__c();
       	OU.cgcloud__Sales_Org__c = '0001';
        OU.Zip_Code__c = '002';
       	OU.Name = 'test';
        insert OU;
       
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
       	acc.ShippingPostalCode='002';
        acc.BillingCountry ='USA';
       	//acc.cgcloud__Account_Template__c  = null;
       	acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        acc.ComplianceMechanism__c='Menthol Ban';
        insert acc;
        
        Account acc2 = new Account(Name = 'account1',CurrencyIsoCode = 'USD',
        Type='National Chain Retailer',
        ParentId = acc.id,
        ShippingCountry = 'US',
        ShippingState ='HI',
        BillingCountry ='USA',
        //ShippingPostalCode='002',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId(),                           
        //cgcloud__Account_Template__c  = null,
        ComplianceMechanism__c='Menthol Ban');
        insert acc2;

        Account acc3 = new Account(Name = 'account2',
        CurrencyIsoCode = 'USD',
        ParentId = acc.id,
        Type='National Chain Retailer',
        ShippingCountry = 'US',
        //ShippingPostalCode='002',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId(),                           
        ShippingState ='HI',
        BillingCountry ='USA',
        //cgcloud__Account_Template__c  = null,                         
        ComplianceMechanism__c='Menthol Ban');
        insert acc3;

        Account acc4 = new Account(Name = 'account3',
        CurrencyIsoCode = 'USD',
        ParentId = acc.id,
        //ShippingPostalCode='002',                           
        Type='National Chain Retailer',
        ShippingCountry = 'US',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId(),                           
        ShippingState ='HI',
        BillingCountry ='USA',
       //cgcloud__Account_Template__c  =,                          
        ComplianceMechanism__c='Menthol Ban');
        insert acc4;
       
       // System.debug('test44 '+acc4.IsPersonAccount+' '+acc4.ShippingCountry);
        Sheduler_TemplateOrgUnitExtensionBatch scheduler = new Sheduler_TemplateOrgUnitExtensionBatch();
         //Batch_CustomerExtensionCreation customerBatch = new Batch_CustomerExtensionCreation();
       	 //Batch_CreateOrgUnit createOrg = new Batch_CreateOrgUnit();
        Test.startTest();
        scheduler.execute(null); 
        Test.stopTest();
    }
    
}