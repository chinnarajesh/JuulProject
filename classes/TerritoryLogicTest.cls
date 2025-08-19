@isTest
public class TerritoryLogicTest{
    public static testMethod void testTerritoryLogic(){
        String stateCountryLabel = System.Label.StateCountryLabel;
        stateCountryLabel = 'New';
        
        Id targetRecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Target').getRecordTypeId();
        Id sourceRecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Source').getRecordTypeId();

        ISO2_Country__c usaTarget = new ISO2_Country__c();
        usaTarget.Name__c = 'US-CA';
        usaTarget.Country__c = 'US';
        usaTarget.State_Province__c = 'CA';
        usaTarget.recordtypeid = targetRecordTypeId;
        Insert usaTarget;
        
        ISO2_Country__c usaSource = new ISO2_Country__c();      
        usaSource.Country__c = 'usa';
        usaSource.State_Province__c = 'ca';
        usaSource.TargetID__c = usaTarget.id;
        usaSource.recordtypeid = sourceRecordTypeId;
        Insert usaSource;
        
        List<String> triggerList = new List<String>{'AccountTrigger','LeadTrigger','ContactTrigger','ACMShipmentTrigger','SalesOrderTrigger'};

        for(String triggerName : triggerList)
            insert(new Trigger_Controller__c(Enabled__c=true,Name=triggerName));

        Account a = new Account(LastName='Test',BillingCountry='US',BillingState='ca',BillingPostalCode='95000-1234',RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Account' AND Name ='Person Account' LIMIT 1].Id,BirthdateText__c='11/30/1963 00:00:00');
        insert(a);

        a.BillingCountry = 'USA';
        a.BirthdateText__c='1963-01-01 00:00:00';
        update(a);
        
        
        Account a2 = new Account(Name='Test',BillingCountry='usa',BillingState='ca',BillingPostalCode='95000-1234');
        insert(a2);

        a2.BillingCountry = 'USA';
        update(a2);
        
        Lead l = new Lead(FirstName='Test',LastName='Test',Company='Test',State='ca',PostalCode='95000-1234');
        insert(l);

        l.Country = 'USA';
        update(l);
        
        Contact c = new Contact(FirstName='Test',LastName='Test',MailingState='ca',MailingPostalCode='95000-1234');
        insert(c);

        c.MailingCountry = 'USA';
        update(c);
        
        

        salesOrder__c so = new salesOrder__c(SOBilling_State__c='ca',Customer__c=a.Id);
        insert(so);

        so.SOShipping_Country__c = 'USA';
        update(so);
        
        ACM_Shipment__c acm = new ACM_Shipment__c(Sales_Order_Number__c=so.Id, State__c='ca',Zip__c='95000-1234');
        insert(acm);

        acm.Country__c = 'USA';
        update(acm);
    }    
}