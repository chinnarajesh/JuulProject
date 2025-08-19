@isTest(SeeAllData=False)
public class SchBatchCaseScoreCalculationTest {
    @isTest
    static void testScheduleBatch() {
        // Create test cases
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            Case c = new Case(Issue__c = 'Test Issue', CreatedDate = Date.today().addDays(-1));
            testCases.add(c);
        }
        insert testCases;
        
        // Schedule batch job
        Test.startTest();
        SchBatchCaseScoreCalculation s = new SchBatchCaseScoreCalculation();
        String sch = '0 0 * * * ?';
        System.schedule('Case Score Calculation Job (Hourly)', sch, s);
        Test.stopTest();
        
        // Verify that the batch job was executed and the cases were updated
        List<Case> updatedCases = [SELECT Id, Case_Score__c FROM Case WHERE Id IN :testCases];
        for (Case c : updatedCases) {
            System.assertNotEquals(0, c.Case_Score__c);
        }
    }
}