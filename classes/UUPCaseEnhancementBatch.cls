global class UUPCaseEnhancementBatch implements Database.Batchable<sObject> {
    

    
    //Constructor to get the Caselist
    global UUPCaseEnhancementBatch(List<Case> TriggerNew){
    }
    
    //Start Method to get Accounts
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
    
    System.debug('inside start method');
        String query= 'SELECT Id,Status__c,OwnerId from Account';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        // Empty execute method
    }
    
    global void finish(Database.BatchableContext bc) {
        // Empty finish method
    }
    
    public class BatchDeprecatedException extends Exception {}
}