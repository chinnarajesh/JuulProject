public with sharing class AccountVMTriggerHandler {
    public static void process(List<Account> triggerNew,Map<Id,Account> triggerOldMap){
        List<Case> caseVoiceMails = queryCaseVoiceMails();
        for(Account acc : triggerNew){
            if((Trigger.isInsert || (Trigger.isUpdate && hasChange(acc,triggerOldMap.get(acc.Id)))) && String.isNotBlank(acc.Phone_Unformatted__c)){
                for(Case cs : caseVoiceMails){
                    string phoneNumber = cs.Subject.replaceAll('[^0-9]+', '');
                    if(phoneNumber.length() > 10){
                        phoneNumber = phoneNumber.right(10);
                    }
                    if(acc.Phone_Unformatted__c.equalsIgnoreCase(phoneNumber)){
                        cs.contactId = acc.PersonContactId;
                        cs.AccountId = acc.Id ;
                    }
                }   
            }
        }
        if(!caseVoiceMails.isEmpty()){
            update caseVoiceMails;
        }
        
    }
    
    @TestVisible
    private static Boolean hasChange(Account accNew,Account accOld){
        return (accNew.Phone_Unformatted__c != accOld.Phone_Unformatted__c) ;   
    }
    
    @TestVisible
    private static List<Case> queryCaseVoiceMails(){
        return [SELECT Id,AccountId,ContactId,Subject
                FROM Case
                WHERE Subject LIKE 'voicemail from%'
                OR 
                Subject LIKE 'INBOUND CALL%'] ;
    }
}