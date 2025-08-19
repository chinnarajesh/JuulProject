@isTest(SeeAllData = false)
public class AccountActionPlanTemTrigHelptest {
static testMethod void testBeforeDelete() {
               
         List<ActionPlanTemplate__c> Acpt = new List<ActionPlanTemplate__c> ();
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name = 'Test Action Plan Template';
        apt.Status__c = 'Execution';
        Acpt.add(apt); 

 List<AccountActionPlanTemplate__c> Accapt = new List<AccountActionPlanTemplate__c> ();
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = apt.Id;
        Accapt.add(aapt);

        // Call the handleBeforeDelete method
        Test.startTest();
            Map<Id,AccountActionPlanTemplate__c> oldMap = new Map<Id,AccountActionPlanTemplate__c>();
            oldMap.put(aapt.Id, aapt);
            AccountActionPlanTemplateTriggerHelper.handleBeforeDelete(oldMap);
        Test.stopTest();
}
      
}