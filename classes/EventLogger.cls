/*******************************************************************************************
* @Name         EventLogger
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         04/01/2019
* @Group        Customer Service
* @Description  This class has methods to insert Log Event platform event
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/01/2019         Initial Creation
*******************************************************************************************/
global class EventLogger {
    /**************************************************************************************
     * @Description This method inserts a platform event when called from an exception
     * @Param   exception
     * @Return  N/A
     **************************************************************************************/
    global static void log(Exception e) {
        Log_Event__e evt = new Log_Event__e();
        evt.Stack_Trace__c = e.getStackTraceString();
        evt.Exception_Type__c = e.getTypeName();
        evt.Line_Number__c = e.getLineNumber();
        evt.Message__c = e.getMessage();
        System.debug('stack trace--> '+evt);
        EventBus.publish(evt);
    }
}