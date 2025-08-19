/*******************************************************************************************
* @Name         CustomTalkdeskActivityTrigger
* @Author       Peter Yao <peter.yao@juul.com>
* @Date         04/03/2019
* @Group        Customer Service
* @Description  A trigger which runs when Talkdesk Activity records are created or
*               manipulated
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0             Petery         04/03/2019          Initial Creation
*******************************************************************************************/

trigger CustomTalkdeskActivityTrigger on talkdesk__Talkdesk_Activity__c (before insert, after insert, before update, after update,
        before delete, after delete, after undelete) {
	CustomTalkdeskActivityTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType);
}