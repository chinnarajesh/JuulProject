@isTest(seeAllData=false)
public class UpgradeStepTest {
    @isTest 
    static void getTest()
    {
        VlocityDiagnosticWizardTestDataFactory.createUpgradePlanAndSteps(10, 'Auto');
        List<Map<String,Object> > steps = VlocityDiagnosticWizardController.getDiagnosticSteps('Diagnostic');
        System.assert (steps != null);
    }
    
    @isTest static 
        void updateTest()
    {
        VlocityDiagnosticWizardDescriber dc = new VlocityDiagnosticWizardDescriber();
        dc.nsPrefix = 'vlocity_ins__';

        List<UpgradeStep__c> steps = VlocityDiagnosticWizardTestDataFactory.createUpgradePlanAndSteps(5, 'Auto');

        //Success
        Map<String,Object> payloadSuccess = new Map<String,Object>{'step' => dc.sObjectToMap(steps[0])};
        Map<String,Object> outputSuccess = VlocityDiagnosticWizardController.updateDiagnosticStep(JSON.serialize(payloadSuccess));
        System.assertEquals(outputSuccess.get('hasErrors'),false);

        //Error
        Boolean hasErrors = false;
        steps[1].Name = null;
        try
        {
            Map<String,Object> payloadError = new Map<String,Object>{'step' => dc.sObjectToMap(steps[1])};
            Map<String,Object> outputError = VlocityDiagnosticWizardController.updateDiagnosticStep(JSON.serialize(payloadError));
        }
        catch (System.DMLException e)
        {
            hasErrors = true;
        }
        System.assertEquals(hasErrors, true);
    }

    @isTest
    static void UpgradeStepTriggerTest()
    {
        //No Name
        try
        {
            UpgradeStep__c step1 = new UpgradeStep__c();
            insert step1;
        }
        catch (System.DMLException e) {}

        //No External Id
        try
        {
            String rand = VlocityDiagnosticWizardTestDataFactory.randomString(10);
            UpgradeStep__c step = new UpgradeStep__c(Name='Test' + rand);
            insert step;
        }
        catch (System.DMLException e) {}

        //No Unique Id
        try
        {
            String rand = VlocityDiagnosticWizardTestDataFactory.randomString(10);
            UpgradeStep__c step = new UpgradeStep__c(
                Name='Test' + rand,
                ExternalId__c='Test' + rand
                );
            insert step;
        }
        catch (System.DMLException e) {}

        //No Upgrade Plan Id
        try
        {
            String rand = VlocityDiagnosticWizardTestDataFactory.randomString(10);
            UpgradeStep__c step = new UpgradeStep__c(
                Name='Name' + rand,
                ExternalId__c='ExternalId' + rand,
                UniqueId__c='Test' + rand
                );
            insert step;
        }
        catch (System.DMLException e) {}

        //replace PreCursorStepUniqueId__c
        try
        {
            List<UpgradeStep__c> steps1 = VlocityDiagnosticWizardTestDataFactory.createUpgradePlanAndSteps(5, 'Auto');
            steps1[1].PreCursorStepUniqueId__c = steps1[0].UniqueId__c;

            upsert steps1;
        }
        catch (System.DMLException e) {}
    }
}