/**
 * Test class for Case Score caculation
 * Component covered - Trigger - CaseIssueTrigger
 *			Class - CaseTriggerHelper, SchBatchCaseScoreCalculation
 */
@isTest
private class CaseScoreCalculationTest {
	
	@testSetup
	static void setupTestData(){
		List<Case_Issue__c> issueSettings = new List<Case_Issue__c>();
		issueSettings.add (new Case_Issue__c(Point_Value__c = 4, Name = '(SMB)'));
		issueSettings.add (new Case_Issue__c(Point_Value__c = 4, Name = '(MPC)'));
		issueSettings.add (new Case_Issue__c(Point_Value__c = 4, Name = '(OOR)'));
		insert issueSettings;
	}

    static testmethod void testRun1(){
    	contact conToBeDeleted = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                         MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert conToBeDeleted;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test@example.com',recordTypeId=recordTypeId);
        insert acc;
        
        Case caseWithSubject = new Case(Status='Open', Issue__c = '(SMB)', Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',contactId=conToBeDeleted.Id,AccountId=acc.Id); 
        insert caseWithSubject;
        Test.setCreatedDate(caseWithSubject.Id, DateTime.now().addDays(-2));
    	Test.startTest();
        
        
        
        SchBatchCaseScoreCalculation schBatch = new SchBatchCaseScoreCalculation();
        schBatch.execute(null);
        schBatch.finish(null);
        
        Test.stopTest();
        
    }
    static testmethod void testRun2(){
    	contact conToBeDeleted = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                         MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert conToBeDeleted;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test1@example.com',recordTypeId=recordTypeId);
        insert acc;
        
        Case caseWithSubject = new Case(Status='Open',Issue__c = '(MPC)',Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',contactId=conToBeDeleted.Id); 
        insert caseWithSubject;
        
    	Test.setCreatedDate(caseWithSubject.Id, DateTime.now().addDays(-2));
    	Test.startTest();
        
        
        SchBatchCaseScoreCalculation schBatch = new SchBatchCaseScoreCalculation();
        schBatch.execute(null);
        schBatch.finish(null);
        
        Test.stopTest();
        
    }
}