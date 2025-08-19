global class HistoricalLeadActivityBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id,
            (SELECT Id FROM Tasks WHERE isClosed=true),
            (SELECT Id FROM Events),
            isConverted,Task_Count__c,Event_Count__c,ConvertedContactId,ConvertedAccountId           
            FROM Lead 
            WHERE Id!=NULL 
            AND ((Task_Count__c =NULL OR Task_Count__c = 0)
            OR (Event_Count__c =NULL OR Event_Count__c =0))
        ]);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        Map<Id,Lead> mapOfConvertedContactIdandLead = new Map<Id,Lead> ();
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead l : scope){
            if(l.isConverted && String.isNotBlank(l.ConvertedContactId) && String.isNotBlank(l.ConvertedAccountId)){
                system.debug('$$$$ converted Lead id'+l.Id);
                mapOfConvertedContactIdandLead.put(l.ConvertedContactId,l);
            }else{
                l.Task_Count__c = l.Tasks !=NULL ? l.Tasks.size() : 0 ; 
                l.Event_Count__c = l.Events !=NULL ? l.Events.size() : 0 ; 
                leadsToUpdate.add(l) ;   
            } 
        }
        if(!leadsToUpdate.isEmpty()){
            Database.update(leadsToUpdate,false);
        }
        List<Account> accsToUpdate = processConvertedLeads(mapOfConvertedContactIdandLead) ;
        if(!accsToUpdate.isEmpty()){
            Database.update(accsToUpdate, false);
        }
    }
    
    private static List<Account> processConvertedLeads(Map<Id,Lead> mapOfConvertedContactIdandLead){
        Map<Id,Account> accsMap = new Map<Id,Account>() ;
        accsMap = processTasks(mapOfConvertedContactIdandLead);
        accsMap = processEvents(accsMap ,mapOfConvertedContactIdandLead);
        
        return accsMap.values();
    }
    
    private static Map<Id,Account> processTasks(Map<Id,Lead> mapOfConvertedContactIdandLead){
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Task t : [SELECT Id,whoId FROM Task WHERE whoId IN : mapOfConvertedContactIdandLead.keySet()]){
            String tempAccId = mapOfConvertedContactIdandLead.get(t.WhoId).convertedAccountId ;
            if(String.isNotBlank(tempAccId) && accMap.get(tempAccId)!=NULL){

                Account acc = accMap.get(tempAccId);
                acc.Pre_Conversion_Task_Count__c = acc.Pre_Conversion_Task_Count__c +1 ;
                accMap.put(tempAccId,acc);
            }else if(String.isNotBlank(tempAccId)){
                Account acc = new Account();
                acc.Id = tempAccId ;
                acc.Pre_Conversion_Task_Count__c = 1;
                accMap.put(tempAccId, acc);
            }       
        }
        return accMap;
    }
    
    private static Map<Id,Account> processEvents(Map<Id,Account> accsMap ,Map<Id,Lead> mapOfConvertedContactIdandLead){
        for(Event e : [SELECT Id,whoId FROM Event WHERE whoId IN : mapOfConvertedContactIdandLead.keySet()]){
            String tempAccId = mapOfConvertedContactIdandLead.get(e.WhoId).convertedAccountId ;
            if(String.isNotBlank(tempAccId) && accsMap.get(tempAccId)!=NULL){
                Account acc = accsMap.get(tempAccId);
                acc.Pre_Conversion_Event_Count__c = (acc.Pre_Conversion_Event_Count__c ==NULL || acc.Pre_Conversion_Event_Count__c == 0 ) ? 1 : (acc.Pre_Conversion_Event_Count__c +1);
                accsMap.put(tempAccId,acc);
            }else if(String.isNotBlank(tempAccId)){
                Account acc = new Account();
                acc.Id = tempAccId ;
                acc.Pre_Conversion_Event_Count__c = 1;
                accsMap.put(tempAccId, acc);
            }       
        }
        return accsMap;     
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}