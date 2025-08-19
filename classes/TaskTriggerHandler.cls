public class TaskTriggerHandler {
    public static void process(List<Task>TriggerNew){
        Set<Id> userIds = new Set<Id> ();
        List<Task> tasksList = new List<Task>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        Map<Task,Case> taskCaseMap = filter(TriggerNew);
        for(Task tsk : taskCaseMap.keySet()){
            taskIds.add(tsk.Id);
            if(tsk.OwnerId!=NULL ){
                userIds.add(tsk.OwnerId);

            }
            if(taskCaseMap.get(tsk)!=NULL){
                caseIds.add(taskCaseMap.get(tsk).Id);
            }
        }
        if(!caseIds.isEmpty() && !taskIds.isEmpty()){
            createCaseComment(taskIds,caseIds);
            List<Case> cases = new List<Case>();
            for(Id caseId : caseIds){
                Case c = new Case(Id = caseId);
                c.Taskdesk_Trigger_Called__c = true;
                cases.add(c);
            }
            update cases;
        }

        List<Task> tasks = new List<Task>();
        for(Task t : taskCaseMap.keySet()){
            tasks.add(
                new Task(
                    Id = t.Id,
                    WhatId = taskCaseMap.get(t) != NULL ? taskCaseMap.get(t).Id : NULL
                )
            );
        }
        if(!tasks.isEmpty()) update tasks;
    }



    //Task Description having validate cases
    private static Map<Task,Case> filter(List<Task> TriggerNew){
        Map<String,String> caseNumberMap = new Map<String,String>();
        Map<String,Case> caseMap = new Map<String,Case>();
        List<Task> filteredTasks = new List<Task>();
        for(Task tsk : TriggerNew){
            if(String.isNotBlank(tsk.Description) && tsk.CallDurationInSeconds!=NULL){
                Integer posOne = tsk.Description.indexOf('%');
                Integer posTwo = tsk.Description.lastIndexOf('%');
                system.debug('% pos'+posOne +posTwo);
                if(posTwo > posOne && (posTwo-PosOne) > 1 && (posTwo-PosOne) <=9 ){
                   caseNumberMap.put(tsk.Id, reformat(tsk.Description.substring(posOne+1, posTwo)));
                }
            }
        }
        if(!caseNumberMap.values().isEmpty()){
           caseMap = queryCases(caseNumberMap.values());
        }

        Map<Task,Case> taskCaseMap = new Map<Task,Case>();
        for(Task tsk : TriggerNew){
            if(caseNumberMap.containsKey(tsk.Id) && caseMap.containsKey(caseNumberMap.get(tsk.Id)) && tsk.CallDurationInSeconds!=NULL){
                taskCaseMap.put(tsk, caseMap.get(caseNumberMap.get(tsk.Id)));
            }
            else if(tsk.CallDurationInSeconds!=NULL){
                taskCaseMap.put(tsk,NULL);
            }
        }
        return taskCaseMap;
    }
    private static string reformat(String str){
        for(Integer  i =str.length() ; i < 8 ; i++){
            str ='0'+str ;
        }
        return str.toLowerCase();
    }

    private static Map<String,Case> queryCases(List<String> caseNumbers){
        Map<String,Case> caseMap = new  Map<String,Case>();
        for(Case cs :[SELECT Id,CaseNumber FROM Case WHERE CaseNumber IN : caseNumbers]){
            caseMap.put(cs.CaseNumber,cs);
        }
        return caseMap;
    }
 /*
    private static String genKey(Case c,Task t){
        return (c != NULL ? (c.Id+'').subString(0,15) : '') + '-' + ((t.OwnerId+'').subString(0,15));
    }
*/
   @future
    private static void createCaseComment(Set<Id> taskIds,Set<Id> caseIds){
        List<CaseComment> caseComments = new List<CaseComment>();
        Map<String,Case> caseMap = new Map<String,Case>();
        for(Case cs : [SELECT Id, CaseNumber FROM Case WHERE Id IN : caseIds]){
            caseMap.put(cs.CaseNumber,cs);
        }
        for(Task t : [SELECT Id,Description FROM Task WHERE Id IN :taskIds]){
            if(String.isNotBlank(t.Description)){
                Integer posOne = t.Description.indexOf('%');
                Integer posTwo = t.Description.lastIndexOf('%');
                system.debug('% pos'+posOne +posTwo);
                if(posTwo > posOne && (posTwo-PosOne) > 1 && (posTwo-PosOne) <=9 ){
                   Case c = caseMap.get(reformat(t.Description.substring(posOne+1, posTwo)));
                   CaseComment comment = new CaseComment(CommentBody =t.Description,ParentId=c.Id);
                   caseComments.add(comment);
                }

            }
        }
        if(!caseComments.isEmpty()){
            insert caseComments;
        }
   }
   /*******
    JIRA Ticket# SO-1797.
    Description: When we update the task status from open to completed for an Account.
                 Then it will update the Latest Activity Comment field on the associated Account with the Description.
   ********/
   public static void updateAccNotesWithTaskComments(List<Task> newTriggerList, Map<Id,Task> oldMapTrigger){
       Set<Id> accountIds = new Set<Id>();
       Map<Id,Account> mapTaskToAccount;
       String prefix='';
       List<Account> listAccountToUpdate = new List<Account>();
       for(Task taskRec : newTriggerList){
             if(taskRec.WhatId <> NULL){
                 prefix = ((String)taskRec.WhatId).substring(0,3);
             }
             if(taskRec.Status == 'Completed' && taskRec.Status <> oldMapTrigger.get(taskRec.id).Status && taskRec.WhatId <> NULL 
                && prefix == '001' && taskRec.Subject.toLowerCase().startsWith('check in') && taskRec.Description <> NULL){
                   accountIds.add(taskRec.WhatId);
               }
             }  
             if(accountIds != null && accountIds.size() > 0){
                 mapTaskToAccount = new Map<Id,Account>([Select Id, Latest_Activity_Comment__c from Account where Id IN : accountIds]);
             }  
          
           for(Task taskRec : newTriggerList){
               if(mapTaskToAccount != null && mapTaskToAccount.containsKey(taskRec.WhatId)){
                   mapTaskToAccount.get(taskRec.WhatId).Latest_Activity_Comment__c = taskRec.Description;
                   listAccountToUpdate.add(mapTaskToAccount.get(taskRec.WhatId));
               }
           }
          if(listAccountToUpdate != null && listAccountToUpdate.size() > 0){
             Database.SaveResult[] srList = Database.Update(listAccountToUpdate, false);
          } 
     } 

}