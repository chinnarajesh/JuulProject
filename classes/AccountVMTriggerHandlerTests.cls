@isTest
private class AccountVMTriggerHandlerTests {
    @TestSetUp static void prepData(){
        Case caseVM = new Case(Status='Open',Priority='New',subject='INBOUND CALL – Missed Call, No VM – from: 1234567890',Description='Chat started on A'); 
        insert caseVM;
         contact con = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                              MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert con;
        
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test@example.com',recordTypeId=recordTypeId,Phone='1234567890');
        insert acc;        
    }
    
    static testMethod void run(){
        Case cs = [SELECT contactId,AccountId FROM Case LIMIT 1] ;
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE FirstName='Test'] ;
       // system.assertEquals(cs.ContactId, acc.personContactId) ;
       // system.assertEquals(cs.AccountId, acc.Id) ;
    }
}