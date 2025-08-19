public class ContactTriggerHandler {
    public static Boolean INSERT_TRIGGER_BYPASS = false;
    public static Boolean UPDATE_TRIGGER_BYPASS = false;

    public static void handleBeforeInsert( List<Contact> triggerObjects ) {
        if(INSERT_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'MailingState',new Map<String,Object>(), triggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'MailingCountry',new Map<String,Object>(), triggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'MailingPostalCode',new Map<String,Object>{'countryFieldName'=>'MailingCountry'}, triggerObjects );
        }
    }

    public static void handleBeforeUpdate( List<Contact> oldTriggerObjects, List<Contact> newTriggerObjects ) {
        if(UPDATE_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'MailingState',new Map<String,Object>(), newTriggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'MailingCountry',new Map<String,Object>(), newTriggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'MailingPostalCode',new Map<String,Object>{'countryFieldName'=>'MailingCountry'}, newTriggerObjects );
        }
    }
    
    public static void handleAfterUpdate( Map<Id,Contact> newMapContact, Map<Id,Contact> oldMapContact){
        if(UPDATE_TRIGGER_BYPASS!=true){
             ContactTriggerHelper.createAlerts(newMapContact,oldMapContact);
            
        }
    }

}