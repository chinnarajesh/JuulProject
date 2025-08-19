@isTest
public class InvocableEinsteinTranslateTest {
	static testMethod void translateTest() {     
        InvocableEinsteinTranslate.inputVariables variables;
        variables = new InvocableEinsteinTranslate.inputVariables();
        variables.sourceLang = 'en';
        variables.targetLang = 'es';
        variables.textToTranslate = 'Translate me please';
        
        InvocableEinsteinTranslate.loopVariables(
            new List<InvocableEinsteinTranslate.inputVariables>{variables});
	}
}