/****************************************************************************************************************/
/* VERSION                  AUTHOR                          DATE                                                */
/*  1.0                     Pushkar Gangwar                 05-20-2020                                          */
/* Class Name: AccountRetailStoreGroupTriggerHandler                                                            */
/* Description: Class to handle all beofre or after trigger actions for AccountRetailStoreGroup Object          */
/****************************************************************************************************************/
public class AccountRetailStoreGroupTriggerHandler {
    public static void afterInsert(Map<Id, AccountRetailStoreGroup__c> newMap, Map<Id, AccountRetailStoreGroup__c> oldMap, System.TriggerOperation triggerEvent){
        createAlertRecords(newMap , oldMap, triggerEvent); 
        
        if(AccountTriggerHandler.isExecuting = false){
        OpportunityRSGDoorAccountUpdate o = new OpportunityRSGDoorAccountUpdate(newMap.values());//Added by JC for SFDC - 0000005474
        Database.executeBatch(o);//Added by JC for SFDC - 0000005474
        }
    }
    public static void afterUpdate(Map<Id, AccountRetailStoreGroup__c> newMap, Map<Id, AccountRetailStoreGroup__c> oldMap, System.TriggerOperation triggerEvent){
        createAlertRecords(newMap , oldMap, triggerEvent);
        OpportunityRSGDoorAccountUpdate o = new OpportunityRSGDoorAccountUpdate(newMap.values());//Added by JC for SFDC - 0000005474
        Database.executeBatch(o);//Added by JC for SFDC - 0000005474
    }
    public static void afterDelete(Map<Id, AccountRetailStoreGroup__c> newMap, Map<Id, AccountRetailStoreGroup__c> oldMap, System.TriggerOperation triggerEvent){
        createAlertRecords(newMap , oldMap, triggerEvent);
    }
    /*****************************************************************************************************/
    /* Method Name  : createSubtractionOrAddtionAlert
     * Author       : Pushkar
    /* Description  : Creating Alert and Account Group Alert Records
    /****************************************************************************************************/
    public static void createAlertRecords(Map<Id, AccountRetailStoreGroup__c> newMap, Map<Id, AccountRetailStoreGroup__c> oldMap, System.TriggerOperation triggerEvent){
        Map<Id, List<Account>> hirarchyAdditionMap = new Map<Id, List<Account>>();
        Map<Id, List<Account>> hirarchySubtractionMap = new Map<Id, List<Account>>();
        Map<Id,Account> idAccountMap = new Map<Id,Account>();
        String triggerEventStr = String.valueOf(triggerEvent);
        List<Id> AccountIDs = new List<Id>();
        if(newMap != null){
            for(AccountRetailStoreGroup__c arsg : newMap.values()){
                AccountIDs.add(arsg.AccountId__c);
            }
        }
         if(oldMap != null){
            for(AccountRetailStoreGroup__c arsg : oldMap.values()){
                AccountIDs.add(arsg.AccountId__c);
            }
         }
        /*List<account> acList = new List<Account>();
        if(AcountIDs.size() > 0){
            acList = [SELECT ID, Name FROM Account WHERE Id=:AcountIDs];    
        }
        if(acList.size() > 0){
            for(Account ac : acList){
                if(idAccountMap.get(ac.Id) == null){
                    idAccountMap.put(ac.Id, ac);
                }
            }
        } */

        idAccountMap = new Map<ID,Account>([Select Id, Name from Account where Id in : AccountIDs]);

        if(triggerEventStr != 'AFTER_DELETE'){
            for(AccountRetailStoreGroup__c arsg : newMap.values()){
                if( triggerEventStr == 'AFTER_INSERT' || (triggerEventStr == 'AFTER_UPDATE' && arsg.AccountId__c != oldMap.get(arsg.Id).AccountId__c)){
                    if(arsg.RetailStoreGroupId__c != null && arsg.AccountId__c != null ){
                        if(hirarchyAdditionMap.get(arsg.RetailStoreGroupId__c) == null){
                            hirarchyAdditionMap.put(arsg.RetailStoreGroupId__c, new List<Account>());
                        }
                        hirarchyAdditionMap.get(arsg.RetailStoreGroupId__c).add(idAccountMap.get(arsg.AccountId__c));
                    }
                }
                if((triggerEventStr == 'AFTER_UPDATE' && oldMap.get(arsg.Id).AccountId__c != null && arsg.AccountId__c != oldMap.get(arsg.Id).AccountId__c)){
                    if(hirarchySubtractionMap.get(arsg.RetailStoreGroupId__c) == null){
                        hirarchySubtractionMap.put(arsg.RetailStoreGroupId__c, new List<Account>());
                    }
                    hirarchySubtractionMap.get(arsg.RetailStoreGroupId__c).add(idAccountMap.get(oldMap.get(arsg.Id).AccountId__c));                  
                }
            }   
        }else if(triggerEventStr == 'AFTER_DELETE'){
            for(AccountRetailStoreGroup__c Oldarsg : oldMap.values()){
                if(Oldarsg.RetailStoreGroupId__c != null && Oldarsg.AccountId__c != null ){
                    if(hirarchySubtractionMap.get(Oldarsg.RetailStoreGroupId__c) == null){
                        hirarchySubtractionMap.put(Oldarsg.RetailStoreGroupId__c, new List<Account>());
                    }
                    hirarchySubtractionMap.get(Oldarsg.RetailStoreGroupId__c).add(idAccountMap.get(oldMap.get(Oldarsg.Id).AccountId__c));                  
                }
            }
        }
         if(triggerEventStr == 'AFTER_INSERT'){
            createHirarchyAlert(hirarchyAdditionMap, 'Addition');
         }else if(triggerEventStr == 'AFTER_UPDATE'){
            createHirarchyAlert(hirarchyAdditionMap, 'Addition');
            createHirarchyAlert(hirarchySubtractionMap, 'Subtraction');
        }else if(triggerEventStr == 'AFTER_DELETE'){
            createHirarchyAlert(hirarchySubtractionMap, 'Subtraction');
        }
    }
     /*****************************************************************************************************/
    /* Mehod Name : createHirarchyAlert
    /* Description : Creating "Hirarchy Addition" and "Hirarchy Subtraction" Alert and Account Group Alert Records
    /****************************************************************************************************/
    public static void createHirarchyAlert(Map<Id, List<Account>> ParentChildAccountMap , String alertType){
        Map<AccountOrGroupAlert__c, Alert__c > alertAndGroupALertMap = new Map<AccountOrGroupAlert__c, Alert__c>();
        List<Alert__c> newAlertList = new List<Alert__c>();
        for(Id parentAccountID : ParentChildAccountMap.keySet()){
            ////// Creating Alert //////
            Alert__c alertItem = new Alert__c();
            String alertBody = '';
            if(alertType == 'Addition' ){
                alertItem.Subject__c = 'Account(s) Added to Retail Store Group.';
                alertBody = ParentChildAccountMap.get(parentAccountID).size()+' Account(s) added to Retail Store Group. \n';
            }else if(alertType == 'Subtraction'){
                alertItem.Subject__c = 'Account(s) Removed from Retail Store Group.';
                alertBody = ParentChildAccountMap.get(parentAccountID).size()+' Account(s) Removed from Retail Store Group. \n';
            }
            for(Account addedAccount : ParentChildAccountMap.get(parentAccountID)){
                alertBody += '\n '+addedAccount.Name;
            }
            alertItem.Body__c = alertBody;
            if(alertType == 'Addition'){
                alertItem.AlertType__c = 'Retail Store Group Addition';
            }else  if(alertType == 'Subtraction'){
                 alertItem.AlertType__c = 'Retail Store Group Subtraction';
            }
            ////// Creating Account Or Group Alert //////
            AccountOrGroupAlert__c AG = new AccountOrGroupAlert__c();
            AG.RetailStoreGroupId__c = parentAccountID;
            alertAndGroupALertMap.put(AG, alertItem);
        }
        //database.insert(alertAndGroupALertMap.values());
        if (alertAndGroupALertMap.values() != null && alertAndGroupALertMap.values().size() > 0) {
                List < Database.SaveResult > insertActionPlanResults = Database.Insert(alertAndGroupALertMap.values(), false);
                List < Database.Error > listError = new List <Database.Error> ();
                for (Integer index = 0, size = insertActionPlanResults.size(); index < size; index++) {
                    if (!insertActionPlanResults[index].isSuccess()) {
                        listError.addAll(insertActionPlanResults[index].getErrors());
                    }
                }
                if (listError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(listError, 'AccountRetailStoreGroupTriggerHandler', 'createHirarchyAlert', 'Alert__c', 'Database.Insert_Failed');
                }
        } 
       //Updating AlertId in GroupAlerts
        List<AccountOrGroupAlert__c> groupList = new List<AccountOrGroupAlert__c>();
        for(AccountOrGroupAlert__c groupAlert : alertAndGroupALertMap.Keyset()){
            groupAlert.AlertId__c = alertAndGroupALertMap.get(groupAlert).Id;
            groupList.add(groupAlert);
        }
        //Database.insert(groupList, false) ;
        if (groupList != null && groupList.size() > 0) {
                List < Database.SaveResult > insertActionPlanResults = Database.Insert(groupList, false);
                List < Database.Error > listError = new List <Database.Error> ();
                for (Integer index = 0, size = insertActionPlanResults.size(); index < size; index++) {
                    if (!insertActionPlanResults[index].isSuccess()) {
                        listError.addAll(insertActionPlanResults[index].getErrors());
                    }
                }
                if (listError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(listError, 'AccountRetailStoreGroupTriggerHandler', 'createHirarchyAlert', 'AccountOrGroupAlert__c', 'Database.Insert_Failed');
                }
        }
        System.debug('--Group Alert--'+groupList);
    }
}