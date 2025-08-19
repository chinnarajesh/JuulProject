/*******************************************************************************************
* @Name         ZendeskTicketTriggerHandler
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         10/26/2018
* @Group        Customer Service
* @Description  Trigger Handler which is called from the Zendesk Suoport Ticket Trigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         10/26/2018          Initial Creation
*******************************************************************************************/
public class ZendeskTicketTriggerHandler {
    /**************************************************************************************
     * @Description This method is the entry point of all records from the trigger
     * @Param   trigger.new, trigger context
     * @Return  --none--
     **************************************************************************************/
    public static void handleTrigger(List<Zendesk__Zendesk_Ticket__c> workingRecords, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when AFTER_INSERT {
                try {
                    ZendeskToCaseService.insertCase(workingRecords);
                } catch (Exception e) {
                    System.debug('Exception--> ' + e.getMessage());
                    EventLogger.log(e);
                    if (!Test.isRunningTest()) throw e;
                }
            }
        }
    }
} //end of class