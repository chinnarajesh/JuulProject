@isTest(SeeAllData=False)
public class CaseRoutingServiceTest {
    private static Case createCase(String recordType, String queueOwner) {
        Case newCase = new Case();
        newCase.RecordTypeId = RecordTypeUtil.recordTypeId('Case', recordType);
        newCase.First_Queue_Owner__c = queueOwner;
        return newCase;
    }

    @isTest
    static void testUpdateCaseOwnerAsync() {
          
        // Create test data
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            Case c = new Case();
            c.First_Queue_Owner__c = 'Test Owner ' + i;
            testCases.add(c);
        }
        insert testCases;

        // Verify that the cases were updated
        for (Case c : testCases) {
            c = [SELECT Id, OwnerId, First_Queue_Owner__c FROM Case WHERE Id = :c.Id];
            System.assertNotEquals(null, c.OwnerId, 'Owner Id should not be null');
        }
    }

    }