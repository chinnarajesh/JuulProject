public class MarketingSegmentManager{
    public static void manageChange(Map<Id,Account> newAccounts,Map<Id,Account> oldAccounts){
        List<Account> paxAccounts = new List<Account>();
        List<Account> pax2Accounts = new List<Account>();
        List<Account> juulAccounts = new List<Account>();
        List<Segment_changes__c> changes = new List<Segment_changes__c>();
        
        for(Account acc : newAccounts.values()){
            if((Trigger.isInsert && String.isNotBlank(acc.JUUL_Segment__pc)) || (Trigger.isUpdate && acc.JUUL_Segment__pc != oldAccounts.get(acc.Id).JUUL_Segment__pc)){
                juulAccounts.add(acc);
            }
            if((Trigger.isInsert && String.isNotBlank(acc.PAX_Segment__pc)) || (Trigger.isUpdate && acc.PAX_Segment__pc != oldAccounts.get(acc.Id).PAX_Segment__pc)){
                paxAccounts.add(acc);
            }
            else if((Trigger.isInsert && String.isNotBlank(acc.PAX_2_Segment__pc)) || (Trigger.isUpdate && acc.PAX_2_Segment__pc != oldAccounts.get(acc.Id).PAX_2_Segment__pc)){
                pax2Accounts.add(acc);
            }
        }
        if(!paxAccounts.isEmpty()){
            paxAccounts = getAccounts(paxAccounts,'PAX_Segment__pc');
            changes.addAll(getChanges(paxAccounts,'PAX_Segment__pc',oldAccounts));    
        }else if(!pax2Accounts.isEmpty()){
            pax2Accounts = getAccounts(pax2Accounts,'PAX_2_Segment__pc');
            changes.addAll(getChanges(pax2Accounts,'PAX_2_Segment__pc',oldAccounts));       
        }else if(!juulAccounts.isEmpty()){
            juulAccounts = getAccounts(juulAccounts,'JUUL_Segment__pc');
            changes.addAll(getChanges(juulAccounts,'JUUL_Segment__pc',oldAccounts));       
        }


        insert changes;
    }
    
    @Testvisible
    private static List<Segment_changes__c> getChanges(List<Account> accounts,String field,Map<Id,Account> oldAccounts){
        List<Segment_changes__c> changes = new List<Segment_changes__c>();
        Map<String,List<Segment_changes__c>> emailSegmentMap = new Map<String,List<Segment_changes__c>>();
        String ptype = (field == 'JUUL_Segment__pc' ? 'JUUL' : field == 'PAX_Segment__pc'? 'PAX' : 'PAX2');
        Date minDate,maxDate;
        for(Account acc : accounts){
            Segment_changes__c sc = new Segment_changes__c();
            if(!acc.Segment_changes__r.isEmpty()){
                sc = acc.Segment_changes__r[0].clone(false,false,false);
                sc.From_Date__c = sc.To_Date__c;
                sc.From_Value__c = sc.To_Value__c;
                if(sc.From_Date__c != NULL)
                    sc.Number_of_days__c = sc.From_Date__c.daysBetween(sc.To_Date__c);
            }
            else if(oldAccounts != NULL && oldAccounts.containsKey(acc.Id)){
                sc.From_Value__c = removeFormat(String.valueOf(oldAccounts.get(acc.Id).get(field)));
            }
            sc.Account__c = acc.Id;
            sc.To_Date__c = System.today();
            sc.To_Value__c = removeFormat(String.valueOf(acc.get(field)));
            sc.Product_Line__c = ptype;
            sc.Emails_Sent__c = 0;
            sc.Conversion__c = String.isBlank(sc.From_Value__c) ? sc.To_Value__c : (sc.From_Value__c + '-' + sc.To_Value__c);
            if(sc.To_Value__c == sc.From_Value__c){
                continue;
            }
            
            if(sc.From_Date__c != NULL && (minDate == null || minDate > sc.From_Date__c )){
                minDate = sc.From_Date__c;
            }
            if(sc.To_Date__c != NULL && (minDate == null || maxDate < sc.To_Date__c )){
                maxDate = sc.To_Date__c;
            }
            if(String.isNotBlank(acc.PersonEmail)){
                if(emailSegmentMap.get(acc.PersonEmail) == null){
                    emailSegmentMap.put(acc.PersonEmail,new List<Segment_changes__c>());
                }
                emailSegmentMap.get(acc.PersonEmail).add(sc);
            }
            
            changes.add(sc);
        }
        
        List< MC4SF__MC_Subscriber_Activity__c > activities = getActivities(minDate,maxDate,emailSegmentMap.keySet());
        for(MC4SF__MC_Subscriber_Activity__c ac : activities){
            for(Segment_changes__c sc : emailSegmentMap.get(ac.MC4SF__MC_Subscriber__r.MC4SF__Email2__c)){
                if((sc.From_Date__c == NULL || sc.From_Date__c <= ac.MC4SF__Timestamp__c) && sc.To_Date__c <= ac.MC4SF__Timestamp__c){
                    sc.Emails_Sent__c ++;
                }
            }
        }
        
        return changes;
    }
    
    @Testvisible
    private static List< MC4SF__MC_Subscriber_Activity__c > getActivities(Date minDate,Date maxDate,Set<String> emails){
        return [
            SELECT Id, MC4SF__MC_Subscriber__r.MC4SF__Email2__c, MC4SF__Timestamp__c
            FROM MC4SF__MC_Subscriber_Activity__c
            WHERE MC4SF__MC_Subscriber__r.MC4SF__Email2__c IN:emails
                AND MC4SF__Timestamp__c >= :minDate AND MC4SF__Timestamp__c <= :maxDate 
        ];
    }
    
    @Testvisible
    private static List<Account> getAccounts(List<Account> accounts,String field){
        String ptype = (field == 'JUUL_Segment__pc' ? 'JUUL' : field == 'PAX_Segment__pc'? 'PAX' : 'PAX2');
        return [
            SELECT Id,PAX_Segment__pc, JUUL_Segment__pc,PersonEmail,PAX_2_Segment__pc,
                (
                    SELECT Id, From_Date__c, From_Value__c, To_Date__c, To_Value__c, Product_Line__c 
                    FROM Segment_changes__r
                    WHERE Product_Line__c =:ptype
                    ORDER BY CreatedDate DESC LIMIT 1
                )
            FROM Account 
            WHERE Id IN:accounts
        ];
    }
    
    @Testvisible
    private static String removeFormat(String ph){
        return String.isNotBlank(ph) ? ph.replaceAll('[^\\d]', '') : ph;
    }
}