@isTest
public class SyncAccountEmailHandlerTest {
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
        SyncAccountEmailHandler.process(new List<Case>{c},new List<Case>{c});
        SyncAccountEmailHandler.fetchAccountMap(new Set<String>{'Test@test.com'});
        insert c;
        Test.stopTest();
    }
}