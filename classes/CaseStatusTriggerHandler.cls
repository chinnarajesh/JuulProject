public class CaseStatusTriggerHandler {
    public static void process(List<Case> TriggerOld,List<Case> TriggerNew){
        List<Case> caseList = new List<Case>();
        if(Trigger.isDelete){
            caseList = TriggerOld;
        }
        else if(Trigger.isUpdate || Trigger.isInsert){
             caseList = TriggerNew;
        }
        if(Trigger.isUpdate){
            Map<Id,case> caseMap = new map<Id,case>();
            for(Case c : triggerNew){
                caseMap.put(c.Id,c);
            }
            for(Case c : TriggerOld){
                if(c.status == caseMap.get(c.Id).status){
                     caseMap.remove(c.Id);
                }
            }
            caseList = caseMap.values();
        }

        List<Account> accts = calculateCaseForAccount(caseList);
        if(!accts.isEmpty()){

            /*List<Case> casesToUpd = new List<Case>();
            for(Account a : accts){
                for(Case c : a.Cases){
                    c.Accounts_Open_Pending_Case_Count__c =a.Open_Pending_Case_Count__c;
                    casesToUpd.add(c);
                }
            }
            update casesToUpd;*/

            update accts;

        }
    }
    @TestVisible
    private static List<Account> calculateCaseForAccount(List<Case> caseLists){
        List<Account> accounts = queryAccount(caseLists) ;
        for(Account acc : accounts){
            integer size = acc.cases.size() != 0 ? acc.cases.size() : 0;
            acc.Open_Pending_Case_Count__c = string.ValueOf(size);
        }
        return accounts;
    }
    @TestVisible
    private static List<Account> queryAccount(List<Case> caseLists){
        Set<Id> accIds = new Set<Id>();
        for(Case c: caseLists){
            if(c.AccountId !=NULL){
                accIds.add(c.AccountId);
            }
        }
        return [
            SELECT Id,Open_Pending_Case_Count__c,
                (SELECT id,Accounts_Open_Pending_Case_Count__c,Status FROM Cases WHERE isClosed = false)
            FROM Account
            WHERE id IN:accIds
        ];
    }
}