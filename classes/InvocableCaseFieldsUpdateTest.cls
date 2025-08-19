@isTest
public class InvocableCaseFieldsUpdateTest {
    
    static testMethod void createCase() {
      
      Case c = new Case ();
      insert c;
     
      String recordId = String.valueOf(c.Id);
      InvocableCaseFieldsUpdate.variables variables =  new InvocableCaseFieldsUpdate.variables();
      variables.recordId =  recordId;
      variables.fieldName =  'DO_NOT_NOTIFY__c';
      variables.fieldValue =  'true';
      variables.isTrueOrFalse =  'Yes';        
      InvocableCaseFieldsUpdate.updateFields(new List <InvocableCaseFieldsUpdate.variables> {variables});
            
      variables.fieldName =  'DO_NOT_NOTIFY__c';
      variables.fieldValue =  'false';
      variables.isTrueOrFalse =  'Yes';        
      InvocableCaseFieldsUpdate.updateFields(new List <InvocableCaseFieldsUpdate.variables> {variables});
                        
      variables.fieldName =  'Market_Outbound_Email1__c';
      variables.fieldValue =  'support@juulvapor.com';
      variables.isTrueOrFalse =  'No';
      InvocableCaseFieldsUpdate.updateFields(new List <InvocableCaseFieldsUpdate.variables> {variables});
      
	}
}