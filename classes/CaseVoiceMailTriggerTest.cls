/*************************************************************************************************
Apex Class Name     : CaseVoiceMailTriggerTest
Version             : 1.0
Date Created        : 25-March2015
Function            : Test class for Case Voice mail trigger 
Author              : Andrew
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* ---------------       -----------             ----------------------------------------------
**************************************************************************************************/
@isTest
private class CaseVoiceMailTriggerTest {

    static testMethod void myUnitTest() {
        Case c = new Case();
        c.subject = 'voicemail from +91 (212) 555-5555';
        c.status = 'New';
        c.description = 'test';
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        string recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test',LastName='Test',Phone = '+91 (212) 555-5555',recordTypeId=recordTypeId);
        insert acc;
        
        insert c;
    }
}