/*************************************************************************************************
Trigger Name        : StoreAssortmentTriggerHandler
Version             : 1.0
Date Created        : 26-June-2020
Function            : Handle Actions from triggers on Store Assortment
Author              : Pushkar
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* Pushkar        		26-June-2020            Handle Actions after or before triggers on StoreAssortment__c.
**************************************************************************************************/
public class StoreAssortmentTriggerHandler {
    
    //Method called on before insert event
    public static void handleBeforeInsert(List<StoreAssortment__c> newStoreAssortmentList){
    	checkActiveStoreAssortmentonAccount(newStoreAssortmentList, null);
    }
    
    //Method called on before update event
    public static void handleBeforeUpdate(List<StoreAssortment__c> newStoreAssortmentList, Map<Id,StoreAssortment__c> mapOldStoreAssortment){
    	checkActiveStoreAssortmentonAccount(newStoreAssortmentList, mapOldStoreAssortment);
    }
    
    //Do not allow another active Store Assortment on a Store if one active already exist
    public static void checkActiveStoreAssortmentonAccount(List<StoreAssortment__c> newStoreAssortmentList, Map<Id,StoreAssortment__c> mapOldStoreAssortment){
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountList = new List<Account>(); 
        for(StoreAssortment__c storeAssortment: newStoreAssortmentList){
            if((mapOldStoreAssortment == null && storeAssortment.Active__c) || 
               (mapOldStoreAssortment != null && storeAssortment.Active__c && storeAssortment.Active__c != mapOldStoreAssortment.get(storeAssortment.Id).Active__c))
            	accountIds.add(storeAssortment.AccountId__c);
        }
        
        //Set of Accounts which already have one active store assortment
        Set<Id> setAccountHaveActiveAsstment = new Set<Id>();
        for(StoreAssortment__c sa : [SELECT Id, Active__c, AccountId__c FROM StoreAssortment__c WHERE AccountId__c=:accountIds and Active__c=true]){
            setAccountHaveActiveAsstment.add(sa.AccountId__c);
        }
        
        //Show valdation message if second active assortment is being added
        for(StoreAssortment__c storeAssortment: newStoreAssortmentList){
            if(setAccountHaveActiveAsstment.contains(storeAssortment.AccountId__c))
                storeAssortment.Active__c.addError('An active Store Assortment is already linked with this account.');                    
        } 
        
    }

}