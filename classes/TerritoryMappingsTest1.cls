@isTest(SEEALLDATA = FALSE)
public class TerritoryMappingsTest1 {
public static testMethod void testTerritoryMappings(){
        Test.startTest();
        Id targetRecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Target').getRecordTypeId();
        Id sourceRecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Country Based').getRecordTypeId();
        Id sourceRecordTypeId1 = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Source').getRecordTypeId();
     
               
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
     
        ISO2_Country__c usaSource1 = new ISO2_Country__c(); 
        usaSource1.recordtypeid = sourceRecordTypeId1;
        usaSource1.TargetID__c = usaTarget.id;
        usaSource1.Country__c = 'United States';
        Insert usaSource1;
      
        String Country= TerritoryMappings.COUNTRY_TO_ISO2_MAPPING.get(TerritoryMappings.COUNTRY_MAPPING.get(usaSource.Country__c));
        
        String State = TerritoryMappings.STATE_TO_ISO2_MAPPING.get(TerritoryMappings.STATE_MAPPING.get(usaSource.State_Province__c));
        
        System.assertEquals('US', Country);
             System.assertEquals('CA', State);
        Test.stopTest();
    }
}