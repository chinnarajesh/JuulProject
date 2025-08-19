public class DeleteEmailBatch implements Database.Batchable<sobject>{

    private Integer n_days = 365;
    private String sObjectName;
    private Boolean delCases = false;

    public DeleteEmailBatch(Integer n_days, String sObjectName){
        this.n_days = n_days;
        this.sObjectName = sObjectName;
    }


    public DeleteEmailBatch(Integer n_days, String sObjectName, Boolean delCases){
        this.n_days = n_days;
        this.sObjectName = sObjectName;
        this.delCases = delCases;
    }

    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id FROM Case WHERE Product__c != NULL AND Product__c IN (\'pax\', \'pax 2\', \'pax 3\', \'era\', \'tbd\')');
    }

    public void execute(Database.BatchableContext bc, List<Case> scope){
        Set<String> caseIds = new Set<String>();
        List<sObject> sobjs = new List<sObject>();
        for(Case c : scope){
            caseIds.add(c.Id);
        }
        if(sObjectName == 'Task'){
            sobjs.addALL(Database.query('SELECT Id FROM Task WHERE WhatId IN :caseIds AND CreatedDate = LAST_N_DAYS:' +n_days));
        }
        else{
            sobjs.addALL(Database.query('SELECT Id FROM LiveChatTranscript WHERE CaseId IN :caseIds AND CreatedDate = LAST_N_DAYS:' +n_days));
        }
        delete sobjs;
        if(delCases){
            delete scope;
        }
    }

    public void finish(Database.BatchableContext bc){

    }

}