/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Shreya Raut             04-09-2021                     */
/* Class Name: EACOpportunityBatch                                    */
/* Description: Batch class for EACOpportunityBatch SFDC - 0000004243 */ 
/**********************************************************************/
public class EACOpportunityBatch implements Database.Batchable<sobject> {
    
    Public ID RSGIDs;
    Public Opportunity oppMap = new Opportunity();
    public Id OppEACRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAC').getRecordTypeId();
    public EACOpportunityBatch(ID RSGID, Opportunity oppList)
    {
        RSGIDs = RSGID;
        oppMap = oppList;
        System.debug('RSGIDS'+RSGIDs);
        System.debug('Inside Constructor'+oppMAp);
        
    }
     public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Inside start');
        String query = 'select id,AccountId__c,RetailStoreGroupId__c from AccountRetailStoreGroup__c where RetailStoreGroupId__c =:RSGIDs';
        System.debug('Qury'+query);
        return Database.getQueryLocator(query);
    } 
    public void execute(Database.BatchableContext BC,List<AccountRetailStoreGroup__c> AccRSG){
        
        System.debug('Limits.getQueryRows - Opp'+ Limits.getQueryRows());
        set<Id> accID = new set<Id>();
        Map<Id,Account> accUpdate = new Map<Id,Account>();       
        List<Account> accList = new List<Account>(); 
        List<Account> HQaccList = new List<Account>();
        
        
        List<String> AcctCurrentPOSProviderPickList = new List<String>();  
        Schema.SObjectType s = Schema.getGlobalDescribe().get('Account') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('CurrentPOSProvider__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            AcctCurrentPOSProviderPickList.add(pickListVal.getValue());
        }    
        System.debug('pickList'+AcctCurrentPOSProviderPickList);

        
        for(AccountRetailStoreGroup__c aRSG: AccRSG) {                            
            accID.add(aRSG.AccountId__c);                      
        } 
        
        if(accID !=null) {
            Map<ID,Account> accRecs = new Map<ID,Account>([select RACS_Status__c,CurrentPOSProvider__c,Manager_Override__c,Date_RACS_Committed__c,Racs_Certified_Date__c,X2D_Bar_Scanner__c,AV_Capable__c, QPL_Capable__c from Account Where Id IN: accID]);
            System.debug('First Account'+accRecs.size());
            System.debug('Limits.getQueryRows - with accReords'+ Limits.getQueryRows());
            for(AccountRetailStoreGroup__c st: AccRSG) {
                Account a = new Account();
                if(accRecs.containskey(st.AccountId__c)) {
                    a = accRecs.get(st.AccountId__c); 
                    System.debug('accountID'+a);
                }                   
                // if(RSGMap.containskey(st.RetailStoreGroupId__c)) {
                if((oppMap.StageName != 'Closed/Won' || oppMap.StageName != 'Closed Won'||oppMap.StageName != 'Closed Lost' )) {     
                    a.Ready_Date_Confirmed__c = oppMap.Ready_Start_date__c; 
                    a.Ready_Date_Estimated__c = oppMap.EST_Implementation_Date__c; 
                }
                if(oppMap.StageName != 'Closed/Won' || oppMap.StageName != 'Closed Won'||oppMap.StageName != 'Closed Lost') {     
                    a.RACS_Status__c = oppMap.StageName;                    
                }
                if(oppMap.StageName == 'Committed') {  
                    if(AcctCurrentPOSProviderPickList.contains(oppMap.Current_POS__c))
                    a.CurrentPOSProvider__c = oppMap.Current_POS__c;
                    a.Manager_Override__c = oppMap.Manager_Override__c;
                    a.Date_RACS_Committed__c = oppMap.Comitted_Date__c;
                }
                if(oppMap.StageName == 'Ready') {     
                    a.QPL_Capable__c = true;
                    a.AV_Capable__c = true;
                    a.X2D_Bar_Scanner__c = true;
                }
                system.debug('StageNAme=='+oppMap.StageName);
                if(oppMap.StageName == 'Closed/Won') {
                    
                    // a.Racs_Certified_Date__c = RSGMap.get(st.RetailStoreGroupId__c).Date_Certified__c;
                    a.Racs_Certified_Date__c = system.today();
                    a.RACS_Status__c = 'Certified';
                    system.debug('a.Racs_Certified_Date__c =='+a.Racs_Certified_Date__c);
                }
                accList.add(a); 
            }
            
            
            if(!accList.isEmpty()) {
                accUpdate.putall(accList);
            } 
            if (accUpdate != null && accUpdate.size() > 0) {
                List<Database.SaveResult> insertNotificationResults =  Database.Update(accUpdate.values(), false);
                system.debug('insertNotificationResults=='+insertNotificationResults);
                List<Database.Error> listError = new List<Database.Error> ();
                for (Integer index = 0, size = insertNotificationResults.size(); index < size; index++) {
                    if (!insertNotificationResults[index].isSuccess()) {
                        listError.addAll(insertNotificationResults[index].getErrors());
                    }
                }
                if (listError.size() > 0) {
                    system.debug('listError-- '+ listError);
                    LogEventTriggerHandler.insertBatchLog(listError, 'EACOpportunityBatch', 'Execute', 'Opportunity', 'Database.Insert_Failed');
                }
            }
    
        }        
    }
        public void finish(Database.BatchableContext BC){
            
            
        }
        
    }