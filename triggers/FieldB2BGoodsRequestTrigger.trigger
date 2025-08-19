/*******************************************************************************************
* @Name         FieldB2BGoodsRequestTrigger
* @Author       Keerthana Guddeti <keerthana.guddeti@juul.com>
* @Date         9/10/2019
* @Group        IT
* @Description  Trigger for validating product SKUs before submitting for approval
*******************************************************************************************/
/*   1.0              Keerthana         9/10/2019          Initial Creation
*******************************************************************************************/
trigger FieldB2BGoodsRequestTrigger on Field_B2B_Goods_Request__c (before insert,before update) {
    Trigger_Controller__c FieldB2BGoodsRequestTriggerControl = Trigger_Controller__c.getInstance('FieldB2BGoodsRequestTrigger'); 
    if( FieldB2BGoodsRequestTriggerControl != null && FieldB2BGoodsRequestTriggerControl.Enabled__c ){
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            FieldB2BGoodsRequestTriggerHandler.submitApprovalValidation(Trigger.New, Trigger.oldMap);
        }
      }
   }
}