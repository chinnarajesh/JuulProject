/*******************************************************************************************
* @Name         CustomTalkdeskActivityTriggerHandler
* @Author       Peter Yao <peter.yao@juul.com>
* @Date         04/03/2019
* @Group        Customer Service
* @Description  Trigger Handler which is called from the CustomTalkdeskActivityTrigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Petery         04/03/2019          Initial Creation
*******************************************************************************************/
public class CustomTalkdeskActivityTriggerHandler {
    /**************************************************************************************
     * @Description This method is the entry point of all records from the trigger
     * @Param   trigger.new, trigger context
     * @Return  --none--
     **************************************************************************************/
    public static void handleTrigger(List<talkdesk__Talkdesk_Activity__c> workingRecords, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT, BEFORE_UPDATE {
                try {
                    Integer posOne;
                    Integer posTwo;
                    List<String> caseNumberList = new List <String>();
                    List<talkdesk__Talkdesk_Activity__c> validActivities = new List<talkdesk__Talkdesk_Activity__c>();
                    Map<String, String> caseNumberMap = new Map<String, String>();
                    /* Loop through Talkdesk activities and look for %casenumber% in notes */
                    for (talkdesk__Talkdesk_Activity__c tda : workingRecords) {
                        if (String.isNotBlank(tda.talkdesk__Notes__c)) {
                            posOne = tda.talkdesk__Notes__c.indexOf('%');
                            posTwo = tda.talkdesk__Notes__c.lastIndexOf('%');
                            /* Add to list if Talkdesk activity has valid case number format */
                            if (posTwo > posOne && (posTwo - PosOne) > 1 && (posTwo - PosOne) <= 9) {
                                validActivities.add(tda);
                                caseNumberList.add(tda.talkdesk__Notes__c.substring(posOne + 1, posTwo));
                                System.debug(caseNumberList);
                            }
                        }
                    }
                    /* Map case numbers to case IDs and loop through valid Talkdesk Activities to add in ID to case field */
                    if (!caseNumberList.isEmpty()) {
                        for (Case cl : [SELECT Id,CaseNumber FROM Case WHERE CaseNumber IN:caseNumberList]) {
                            caseNumberMap.put(cl.CaseNumber, cl.Id);
                        }
                        for (talkdesk__Talkdesk_Activity__c tda : validActivities) {
                            if (String.isNotBlank(tda.talkdesk__Notes__c)) {
                                posOne = tda.talkdesk__Notes__c.indexOf('%');
                                posTwo = tda.talkdesk__Notes__c.lastIndexOf('%');
                                String caseNumber = tda.talkdesk__Notes__c.substring(posOne + 1, posTwo);
                                if (caseNumberMap.containsKey(caseNumber)) {
                                    tda.talkdesk__Case__c = (Id) caseNumberMap.get(caseNumber);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.debug('Exception--> ' + e.getMessage());
                    EventLogger.log(e);
                    if (!Test.isRunningTest()) throw e;
                }
            }
        }
    }
}