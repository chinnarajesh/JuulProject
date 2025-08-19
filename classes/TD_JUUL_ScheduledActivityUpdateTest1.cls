@isTest
public class TD_JUUL_ScheduledActivityUpdateTest1 {
    static testMethod void testScheduledActivityUpdate() {
        
        // Create test data
        Contact testContact = new Contact(LastName='Test', 
                                          Phone='1234567890', 
                                          HomePhone='1234567890', 
                                          OtherPhone='1234567890', 
                                          MobilePhone='1234567890');
        insert testContact;
       talkdesk__Talkdesk_Activity__c testActivity = new talkdesk__Talkdesk_Activity__c(talkdesk__Contact_Phone__c='1234567890',
                                                                                        talkdesk__Contact__c=null, 
                                                                                        talkdesk__Talkdesk_Id__c='123');

        insert testActivity;

        // Execute the Schedulable class
        Test.startTest();
        TD_JUUL_ScheduledActivityUpdate sched = new TD_JUUL_ScheduledActivityUpdate();
        String sch = '0 0 0 1 1 ?';
        System.schedule('Test Scheduled Job', sch, sched);
        Test.stopTest();

        // Verify the results
        testActivity = [SELECT talkdesk__Contact__c FROM talkdesk__Talkdesk_Activity__c WHERE Id=:testActivity.Id];
        System.assertEquals(testContact.Id, testActivity.talkdesk__Contact__c);
    }
}