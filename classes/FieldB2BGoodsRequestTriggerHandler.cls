/*******************************************************************************************
* @Name         FieldB2BGoodsRequestTriggerHandler 
* @Author       Keerthana Guddeti <keerthana.guddeti@juul.com>
* @Date         9/10/2019
* @Group        IT
* @Description  Handler class for validating product SKUs before submitting for approval
*******************************************************************************************/
/*   1.0              Keerthana         9/10/2019          Initial Creation
*******************************************************************************************/
public class FieldB2BGoodsRequestTriggerHandler {
    public static void submitApprovalValidation(List<Field_B2B_Goods_Request__c> listFieldB2B , Map<Id,Field_B2B_Goods_Request__c> oldMapTrigger){
        Id FreeGoodsRecTypeId= Schema.SObjectType.Field_B2B_Goods_Request__c.getRecordTypeInfosByDeveloperName().get('Free_Goods').getRecordTypeId();
        for(Field_B2B_Goods_Request__c obj:listFieldB2B ){
            if(obj.quantity__c < 1 && obj.status__c =='Pending' && obj.RecordTypeId == FreeGoodsRecTypeId){
                obj.addError('Please add Product SKUs before submitting for approval');
            }
        }   
    }
}