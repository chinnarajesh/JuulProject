/*******************************************************************************************
* @Name         CaseTrigger
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         12/28/2018
* @Group        Customer Service
* @Description  A trigger which runs when there's a DML operation on Case records
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/28/2018          Initial Creation
*******************************************************************************************/
trigger CaseTrigger on Case (before insert, after insert, before update, after update,
        before delete, after delete, after undelete) {
    CaseHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}