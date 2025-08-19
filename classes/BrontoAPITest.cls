@isTest
private class BrontoAPITest {
    @testSetup
    private static void createTestData(){
    
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        contact conToBeDeleted = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                         MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert conToBeDeleted;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test@example.com',recordTypeId=recordTypeId);
        insert acc;
        
        Case caseWithSubject = new Case(Status='New', Product__c = 'PAX', Issue__c = 'PAX', Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',AccountId=acc.Id); 
        caseWithSubject.Topic__c = 'Battery';
        caseWithSubject.Issue__c = 'Degradation';
        insert caseWithSubject;
    }

    @isTest
    private static void testQueue() {
        Case caseWithSubject = [SELECT ID FROM Case limit 1];
        caseWithSubject.Status = 'Pending';
        update caseWithSubject;
    }

    @isTest
    private static void testAPICodeCoverage() {
        apiBrontoComV4.readOnlyContactData x = new apiBrontoComV4.readOnlyContactData();
        apiBrontoComV4.dateValue dv = new apiBrontoComV4.dateValue();
        apiBrontoComV4.addOrUpdateContacts ac = new apiBrontoComV4.addOrUpdateContacts();
        apiBrontoComV4.resultItem ri = new apiBrontoComV4.resultItem();
        apiBrontoComV4.writeResult wi = new apiBrontoComV4.writeResult();
    }


    @isTest
    private static void testBatch() {
        String query = 'SELECT ID, Type, Status, CreatedDate, ClosedDate, Account.PersonEmail '
                    + ' , Product__c, Topic__c, Issue__c FROM Case';
        Database.executeBatch(new BrontoAPIService(query));
    }
}