/*******************************************************************************************
* @Name         CustomTalkdeskActivityTriggerHandlerTest
* @Author       Peter Yao <peter.yao@juul.com>
* @Date         04/04/2019
* @Group        Customer Service
* @Description  Test class for CustomTalkdeskActivityTrigger and Handler
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0             Petery         04/04/2019          Initial Creation
*******************************************************************************************/
@isTest
public class CustomTalkdeskActivityTriggerHandlerTest {
	/* Creates cases and Talkdesk activities with casenumbers filled in notes */
    static testMethod void createTestCasesAndTDActivities() {
        List<Case> caseList = new List<Case>();
        List<talkdesk__Talkdesk_Activity__c> tdaList = new List<talkdesk__Talkdesk_Activity__c> ();
        
        for (Integer i = 0; i < 10; i++) {
            Case c = new Case (
            );
            caseList.add(c);
        }
        
        insert caselist;
        
        List<Case> caseNumbers = [SELECT CaseNumber FROM Case WHERE ID IN:caseList];
        for (Integer ii = 0; ii < 10; ii++) {
            talkdesk__Talkdesk_Activity__c tda = new talkdesk__Talkdesk_Activity__c (
            talkdesk__Talkdesk_Id__c = string.ValueOf(80085 + ii),
            talkdesk__Notes__c = '%' + string.Valueof(caseNumbers[ii].caseNumber) + '%'
            );
            tdaList.add(tda);
        }
        insert tdaList;
    }
}