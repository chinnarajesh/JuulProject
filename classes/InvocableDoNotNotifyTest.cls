@isTest
public class InvocableDoNotNotifyTest {
	static testMethod void createCase() {
    	Case c = new Case (
            );
        insert c;
        
        String recordId = String.valueOf(c.Id);
        InvocableDoNotNotify.variables variables;
        variables = new InvocableDoNotNotify.variables();
        variables.recordId = recordId;
        
        InvocableDoNotNotify.doNotNotify(
            new List<InvocableDoNotNotify.variables>{variables});
	}
}