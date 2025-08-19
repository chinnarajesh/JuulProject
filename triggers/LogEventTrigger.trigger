/*******************************************************************************************
* @Name         LogEventTrigger
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         04/01/2019
* @Group        Customer Service
* @Description  A trigger which runs when Log Event platform events are created
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/01/2019       Initial Creation
*******************************************************************************************/
trigger LogEventTrigger on Log_Event__e (after insert) {
    LogEventTriggerHandler.insertLog(Trigger.new);
}