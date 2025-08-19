@isTest(SeeAllData=false)
public class TerritoryUtilityTest {

    @isTest
    static void testStandardizeField() {
        // Create test data
          ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        
        List<Account> accList = new List<Account>();
        Account testAcct = new Account();
        testAcct.Name='Test';
        testAcct.Type='HQ';
        testAcct.ShippingState ='HI';
        testAcct.BillingCountry ='USA';
         testAcct.ShippingCountry ='USA';
        testAcct.ComplianceMechanism__c='Menthol Ban';
        accList.add(testAcct);
        insert accList;
        
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

        // Test standardize field for BillingCountry
        Map<String,Object> params = new Map<String,Object>();
        List<sObject> objectList = new List<sObject>();
        objectList.add(testAcct);
        TerritoryUtility.standardizeField('Country', 'BillingCountry', params, objectList);
        testAcct = [SELECT BillingCountry FROM Account WHERE Id = :testAcct.Id];
        System.assertEquals('USA', testAcct.BillingCountry);

        // Test standardize field for ShippingCountry
        objectList.clear();
        objectList.add(testAcct);
        TerritoryUtility.standardizeField('Country', 'ShippingCountry', params, objectList);
        testAcct = [SELECT ShippingCountry FROM Account WHERE Id = :testAcct.Id];
     
        delete testAcct;
        
       
}
}