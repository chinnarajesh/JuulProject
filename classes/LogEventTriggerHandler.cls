/*******************************************************************************************
* @Name         LogEventTriggerHandler
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         04/01/2019
* @Group        Customer Service
* @Description  This class inserts stack trace from exception to the log object
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/01/2019         Initial Creation
*   2.0              Anil          05/16/2019         Added the method "insertBatchLog".
*******************************************************************************************/
public with sharing class LogEventTriggerHandler {
    /**************************************************************************************
     * @Description This method inserts stack from platform event to the log object
     * @Param   Log event platform events
     * @Return  N/A
     **************************************************************************************/
    public static void insertLog(List<Log_Event__e> logEvents) {
        List<Log__c> logList = new List<Log__c>();
        for (Log_Event__e e : logEvents) {
            Log__c log = new Log__c();
            log.Stack_Trace__c = e.Stack_Trace__c;
            log.Exception_Type__c = e.Exception_Type__c;
            log.Line_Number__c = e.Line_Number__c;
            log.Message__c = e.Message__c;
            log.User__c = UserInfo.getUserId();
            logList.add(log);
        }
        List<Database.SaveResult> insertResult = Database.insert(logList);
        System.debug('Log Insert Result--> '+insertResult);
    }
    /**************************************************************************************
     * @Description This method inserts record in the log object when eception occurred.
     * @Param   List<Database.Error> - Holds the list of errors from the Database.SaveResult[]
                clsName - Holds the class name from which exception caused.
                methodName - Holds the method name from which exception caused.
                objName - Holds the obect name from which exception caused.
                exceptionType - Holds the values Database.Insert_Failed,Database.Update_Failed.
                dataFailed - Holds the data which is failed because of the exception. 
     * @Return  N/A
     **************************************************************************************/
    public static void insertBatchLog(List<Database.Error> batchErrorsList, String clsName, String methodName, String objName, String exceptionType) {
    List<Log__c> logList = new List<Log__c>();
      for(Database.Error err : batchErrorsList){
          Log__c log = new Log__c();
          log.Message__c = err.getMessage();
          log.User__c = UserInfo.getUserId();
          log.Object_Name__c = objName; 
          log.Source_Class_Name__c = clsName;
          log.Source_Method_Name__c = methodName;
          log.Exception_Type__c=exceptionType;
     //   log.Stack_Trace__c = dataFailed;
          logList.add(log);
      }
     List<Database.SaveResult> insertResult = Database.insert(logList);
        System.debug('Log Insert Result--> '+insertResult); 
    }
}