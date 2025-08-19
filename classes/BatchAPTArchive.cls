global class BatchAPTArchive implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public Set<Id> allAptIdSet = new Set<Id>();

    global void execute(SchedulableContext sc) {
        database.executebatch(this,100);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Id, Name, Status__c FROM ActionPlanTemplate__c WHERE RequestedEndDate__c <= YESTERDAY AND Status__c != \'Archived\'';   
        //AND Id = \'a6455000000J3DvAAK\'
        //System.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<ActionPlanTemplate__c> aptRecords)
    {
        for(ActionPlanTemplate__c apt : aptRecords){
            apt.Status__c = 'Archived';
            allAptIdSet.add(apt.Id);
        }
        System.debug('aptRecords'+aptRecords);
        if(!aptRecords.IsEmpty())
        {
            Database.update(aptRecords,false);
            
        }  
    }
    global void finish(Database.BatchableContext BC) {

        System.debug('allAptIdSetSize'+allAptIdSet.size());
        
    }
}