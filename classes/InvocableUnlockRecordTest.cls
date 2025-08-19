@isTest
public class InvocableUnlockRecordTest {
	static testMethod void createCaseAndLock() {
    	Case c = new Case (
            );
        insert c;
    	Approval.Lock(c.Id);
        
        String recordId = String.valueOf(c.Id);
        InvocableUnlockRecord.variables variables;
        variables = new InvocableUnlockRecord.variables();
        variables.recordId = recordId;
        
        InvocableUnlockRecord.unlockCase(
            new List<InvocableUnlockRecord.variables>{variables});
	}
}