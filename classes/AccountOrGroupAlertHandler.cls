public class AccountOrGroupAlertHandler {

    public static void handleAfterInsert( Map<Id,AccountOrGroupAlert__c> newMapAGA, Map<Id,AccountOrGroupAlert__c> oldMapAGA){
            KAMApexSharing.shareAlertRecords(newMapAGA,oldMapAGA);
    }
     public static void handleAfterUpdate( Map<Id,AccountOrGroupAlert__c> newMapAGA, Map<Id,AccountOrGroupAlert__c> oldMapAGA){
            KAMApexSharing.shareAlertRecords(newMapAGA,oldMapAGA);
    }
    

}