@isTest
public class SyncAccountEmailHanderTest {
    @isTest
    public static void checkEmail(){
        String rtId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
        Account acc = new Account(
            PersonEmail = 'test@test.com',
            RecordTypeId = rtId,
            LastName = 'test'
        );
        insert acc;
        Case c = new Case(
            Status = 'New',
            Priority = 'Normal',
            SuppliedEmail = 'test@test.com'
        );
        
        
        Test.startTest();
        insert c;
        System.assert([SELECT Count() FROM Case WHERE AccountId != NULL] == 1);
        system.assertEquals(1,[SELECT Id FROM Case WHERE AccountId != NULL].size());
        Test.stopTest();
    }
}