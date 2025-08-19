@isTest
private class CaseTriggerTests{
    static testmethod void testRun1(){
        contact conToBeDeleted = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                         MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert conToBeDeleted;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test@example.com',recordTypeId=recordTypeId);
        insert acc;
        
        Case caseWithSubject = new Case(Status='Open',Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',contactId=conToBeDeleted.Id,AccountId=acc.Id); 
        insert caseWithSubject;
        
    }
    static testmethod void testRun2(){
        contact conToBeDeleted = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                         MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert conToBeDeleted;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test1@example.com',recordTypeId=recordTypeId);
        insert acc;
        
        Case caseWithSubject = new Case(Status='Open',Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',contactId=conToBeDeleted.Id); 
        insert caseWithSubject;
        
    }
}