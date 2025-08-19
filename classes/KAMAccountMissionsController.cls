public with sharing class KAMAccountMissionsController {
    
    @AuraEnabled(cacheable=true)
    public static List<Mission__c> getMissionRecords(String recordId)
    {
        system.debug('record id'+recordId);
        List<Mission__c> relatedMission = [select id,Name,Commercial_Activity__c,MissionType__c,Status__c,EndDate__c,StartDate__c,InstructionDescription__c
                                          from Mission__c where AccountId__c=:recordId and StartDate__c<=TODAY and EndDate__c>=TODAY order by StartDate__c asc];
        return relatedMission;
    }

}