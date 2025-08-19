public class ACMShipmentTriggerHandler {
    public static Boolean INSERT_TRIGGER_BYPASS = false;
    public static Boolean UPDATE_TRIGGER_BYPASS = false;

    public static void handleBeforeInsert( List<ACM_Shipment__c> triggerObjects ) {
        if(INSERT_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'State__c', new Map<String,Object>(), triggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'Country__c', new Map<String,Object>(), triggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'Zip__c', new Map<String,Object>{'countryFieldName'=>'Country__c'}, triggerObjects );
        }
    }

    public static void handleBeforeUpdate( List<ACM_Shipment__c> oldTriggerObjects, List<ACM_Shipment__c> newTriggerObjects ) {
        if(UPDATE_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'State__c', new Map<String,Object>(), newTriggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'Country__c', new Map<String,Object>(), newTriggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'Zip__c', new Map<String,Object>{'countryFieldName'=>'Country__c'}, newTriggerObjects );
        }
    }
}