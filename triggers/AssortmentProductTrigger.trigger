/*************************************************************************************************
Trigger Name        : AssortmentProductTrigger
Version             : 1.0
Date Created        : 08-Feb-2022
Author              : Shreya Raut
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* ---------------       -----------             ----------------------------------------------
**************************************************************************************************/
trigger AssortmentProductTrigger on AssortmentProduct__c (before insert,before update) {
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate){
           
            AssortmentProductHandler.checkPricingMatrix(Trigger.new);
        }
     }

}