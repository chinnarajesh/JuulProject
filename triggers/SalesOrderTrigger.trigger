/***************************************************************************************************************************
* @Name         SalesOrderTrigger
* @Author       
* @Date         
* @Group        
* @Description  
*****************************************************************************************************************************/
/* MODIFICATION LOG
* Version              Developer                  Date                Description
*-------------------------------------------------------------------------------------------
*   1.1              Preetha Barnabas          03/27/2020             Executes SalesOrderTriggerHandler logic that updates related Customer's First Sales Order, Billing and Shipping Address.
******************************************************************************************************************************/
trigger SalesOrderTrigger on SalesOrder__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
    Trigger_Controller__c SalesOrderTriggerControl = Trigger_Controller__c.getInstance('SalesOrderTrigger'); //Get Trigger Controller Setting
    
    if( SalesOrderTriggerControl != null && SalesOrderTriggerControl.Enabled__c ){
      /*  if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                //SalesOrderTriggerHandler.handleBeforeInsert( Trigger.New );
              //  SalesOrderTriggerHandler.handleBeforeInsertUpdateCSM( Trigger.New );
            } 
            if (Trigger.isUpdate) {
                //SalesOrderTriggerHandler.handleBeforeUpdate( Trigger.Old, Trigger.New );
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        */
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {
                 SalesOrderTriggerHandler.handleAfterInsertUpdateCustomer(Trigger.New);
            } 
        /*    if (Trigger.isUpdate) {
                //Add Future Logic Here
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
            */
        }
    }
}