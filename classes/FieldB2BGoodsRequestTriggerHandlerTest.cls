/*******************************************************************************************
* @Name         FieldB2BGoodsRequestTriggerHandlerTest
* @Author       Keerthana Guddeti <keerthana.guddeti@juul.com>
* @Date         9/10/2019
* @Group        IT
* @Description  Handler class for validating product SKUs before submitting for approval
*******************************************************************************************/
@isTest(SEEALLDATA = FALSE)
public class FieldB2BGoodsRequestTriggerHandlerTest{
    @TestSetup static void makeData(){
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='FieldB2BGoodsRequestTrigger',Enabled__c=true);
        insert(triggerController); 
        Id idRecordId = Schema.SObjectType.Field_B2B_Goods_Request__c.getRecordTypeInfosByDeveloperName().get('Free_Goods').getRecordTypeId();
        Field_B2B_Goods_Request__c fgrObj = new Field_B2B_Goods_Request__c();
        fgrObj.RecordTypeId = idRecordId;
        fgrObj.Status__c = 'New';
        fgrObj.Shipping_Country__c = 'US';
        fgrObj.Shipping_State__c = 'CA';
        fgrObj.Additional__c = 'Test data for Field B2B Goods Request';
        insert fgrObj;    
    }
public static testMethod void submitApprovalValidationTest(){
    Field_B2B_Goods_Request__c fgrRec = [Select Id, Status__c from Field_B2B_Goods_Request__c LIMIT 1];
    System.debug('fgrRec ******************** '+fgrRec);
    try{
        fgrRec.Status__c = 'Pending';
        update fgrRec;
    }catch(Exception e){
        System.Assert(e.getMessage().contains('Please add Product SKUs before submitting for approval'));
    }
}
}