/*************************************************************************************************
Trigger Name        : AccountRetailStoreGroupTrigger
Version             : 1.0
Date Created        : 04-June-2020
Function            : Handle Actions after or before triggers on Account Retail Store Group(AccountRetailStoreGroup__c)
Author              : Pushkar
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* Pushkar        		04-June-2020            Handle Actions after or before triggers on  Account Retail Store Group(AccountRetailStoreGroup__c).
**************************************************************************************************/
trigger AccountRetailStoreGroupTrigger on AccountRetailStoreGroup__c (before insert,after insert, before update,after update, after delete) {
    Trigger_Controller__c AccountTriggerControl = Trigger_Controller__c.getInstance('AccountRetailStoreGroupTrigger'); 
    if( AccountTriggerControl != null && AccountTriggerControl.Enabled__c ){   
    	if(Trigger.isAfter){   
        	if(Trigger.isInsert){ 
            	AccountRetailStoreGroupTriggerHandler.afterInsert(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
        	}
        	if(Trigger.isUpdate){
            	AccountRetailStoreGroupTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap,  Trigger.operationType);
        	}
         	if(Trigger.isDelete){
         	    AccountRetailStoreGroupTriggerHandler.afterDelete(Trigger.newMap, Trigger.oldMap,  Trigger.operationType);
        	}
        }
    }
}