@isTest(SeeAllData = FALSE)
public class LeadTriggerHandlerTest {

/****** Old Code : Commented by Anil
    static testmethod void TestTerritoryPopulation(){         
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='LeadTrigger',Enabled__c=true);
        Lead l = new Lead(FirstName='Test',LastName='Test',Company='Test',State='California',Country='United States');
        insert(l);
        
    }
 End of Old Code ***********/
  @TestSetup
    public static void makeData(){
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='LeadTrigger',Enabled__c=true);
        insert(triggerController);
        Lead leRec = new Lead();
            leRec.FirstName = 'Test First';
            leRec.LastName = 'Test Last';
            leRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('RACS Independent Lead').getRecordTypeId();
            leRec.Company = 'Juul Labs';
        insert leRec;    
    }    
    public static testMethod void LeadTriggerHandler_Test1(){
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
        
        Account a = new Account(LastName='Test',
                                BillingCountry='US',
                                BillingState='ca',
                                BillingPostalCode='95000-1234',
                                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
                                BirthdateText__c='11/30/1963 00:00:00'
                                );
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
    }
    public static testMethod void LeadTriggerHandler_Test2(){
        Lead leRec = [Select Id from Lead LIMIT 1];
        Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leRec.id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

    }
}