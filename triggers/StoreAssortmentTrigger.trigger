/*************************************************************************************************
Trigger Name        : StoreAssortmentTrigger
Version             : 1.0
Date Created        : 26-June-2020
Function            : Handle Actions after or before triggers on Store Assortment
Author              : Pushkar
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* Pushkar        		26-June-2020            Handle Actions after or before triggers on StoreAssortment__c.
**************************************************************************************************/
trigger StoreAssortmentTrigger on StoreAssortment__c (before insert, before update) {
    Trigger_Controller__c storeAssortmentTriggerControl = Trigger_Controller__c.getInstance('StoreAssortmentTrigger'); //Get Trigger Controller Setting
    
    if( storeAssortmentTriggerControl != null && storeAssortmentTriggerControl.Enabled__c ){
        if(Trigger.isBefore){
            if(Trigger.isBefore && Trigger.isInsert){
                StoreAssortmentTriggerHandler.handleBeforeInsert(Trigger.New);
            }
            if(Trigger.isBefore && Trigger.isUpdate){
                StoreAssortmentTriggerHandler.handleBeforeUpdate(Trigger.New, Trigger.OldMap);
            }
        }
    }
}