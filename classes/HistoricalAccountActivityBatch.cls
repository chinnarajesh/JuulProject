global class HistoricalAccountActivityBatch implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id,
            (SELECT Id FROM Tasks WHERE isClosed=true),
            (SELECT Id FROM Events)          
            FROM Account 
            WHERE Id!=NULL 
            AND ((Task_Count__c =NULL OR Task_Count__c = 0)
            OR (Event_Count__c =NULL OR Event_Count__c =0))
        ]);
    } 
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for(Account acc : scope){
            acc.Task_Count__c = acc.Tasks !=NULL ? acc.Tasks.size() : 0 ; 
            acc.Event_Count__c = acc.Events !=NULL ? acc.Events.size() : 0 ;    
        }
        Database.update(scope,false);
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}