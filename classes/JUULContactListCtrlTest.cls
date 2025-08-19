@isTest
private class JUULContactListCtrlTest {
    public static Contact con;
    @isTest
    static void testFetchJUULContacts() {
        createTestData();
        
        List<Contact> lstContacts = JUULContactListCtrl.fetchJUULContacts('Test Region');
        system.assertEquals(lstContacts.size(), 1);
        
    }
    
    private static void createTestData() {
        //Id juulContactsRTIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('JUUL_Contacts').getRecordTypeId();
		Id juulContactsRTIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JUUL_Contacts').getRecordTypeId();
        con = new Contact();
        con.LastName = 'Test Contact';
        con.Region__c = 'Test Region';
        con.Title = 'Test Title';
        con.Email = 'test@test.com';
        con.RecordTypeId = juulContactsRTIdContact;
        insert con;
    }
}