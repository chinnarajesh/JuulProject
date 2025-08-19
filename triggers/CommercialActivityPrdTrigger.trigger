/*************************************************************************************************
Trigger Name        : CommercialActivityPrdTrigger
Version             : 1.0
Date Created        : 17-March-2021
Author              : Shreya Raut
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* ---------------       -----------             ----------------------------------------------
**************************************************************************************************/
trigger CommercialActivityPrdTrigger on CommercialActivityProduct__c (after insert,after update,before insert,before update,after delete, before delete) {
    
     if(Trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate){
          CommercialActivityProdTriggerHandler.productBundleCheck(Trigger.New);
          //CommercialActivityProdTriggerHandler.ProductBundlePicklistCheck(Trigger.New); 
          CommercialActivityProdTriggerHandler.ProductBundleEmptyCheck(Trigger.New);   
        }
        
    }
    if(trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate){
        }
        if(Trigger.isDelete){
            CommercialActivityProdTriggerHandler.productBundleCheckAfterDelete(Trigger.old);
          // CommercialActivityProdTriggerHandler.productBundleCheck(Trigger.old);
        }
    }
    if(Trigger.isBefore)
    {
         if(Trigger.isInsert || Trigger.isUpdate)
        {
            system.debug('inside before insert update'+CommercialActivityProdTriggerHandler.run);
            if( CommercialActivityProdTriggerHandler.run==false)
            CommercialActivityProdTriggerHandler.checkPricingMatrix(Trigger.new);
        }
    }

}