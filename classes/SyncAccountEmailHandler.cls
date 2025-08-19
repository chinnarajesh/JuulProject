public class SyncAccountEmailHandler{

    public static void process(List<Case> triggerNew,List<Case> triggerOld){
        Set<String> emails = new Set<String>();
        for(Case c : triggerNew){
            if(c.AccountId == null){
                emails.add(c.SuppliedEmail);
            }
        }

        Map<String,String> accMap = fetchAccountMap(emails);
        for(Integer i = 0 ; i < triggerNew.size() ; i++){
            if((
                (Trigger.IsInsert == true && triggerNew[i].SuppliedEmail != NULL) 
                || (Trigger.isUpdate == true && triggerNew[i].SuppliedEmail != NULL && triggerNew[i].SuppliedEmail != triggerOld[i].SuppliedEmail)
               ) && accMap.containsKey(triggerNew[i].SuppliedEmail)
             ){
                triggerNew[i].AccountId = accMap.get(triggerNew[i].SuppliedEmail);
            }
        }
    }
    @testVisible
    private static Map<String,String> fetchAccountMap(Set<String> emails){
        Map<String,String> accMap = new Map<String,String>();
        for(Account acc : [
            SELECT Id,PersonEmail
            FROM Account
            WHERE isPersonAccount = true
                AND PersonEmail != NULL
                AND PersonEmail IN :emails
        ]){
            accMap.put(acc.PersonEmail,acc.Id);
        }
        return accMap;
    }
}