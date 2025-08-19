/*******************************************************************************************
* @Name         ZendeskTicketTrigger
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         10/26/2018
* @Group        Customer Service
* @Description  A trigger which runs when Zendesk Support Ticket records are created or
*               manipulated
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         10/26/2018          Initial Creation
*******************************************************************************************/
trigger ZendeskTicketTrigger on Zendesk__Zendesk_Ticket__c (before insert, after insert, before update, after update,
        before delete, after delete, after undelete) {
    ZendeskTicketTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType);
}