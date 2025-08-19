/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Pushkar Gangwar         05-21-2020                     */
/* Class Name: KAMCreateAssesmentTaskForVisitBatch                    */
/* Description: Test class to check the coverage of 
 * batch "KAMCreateAssesmentTaskForVisitBatch" and 
 * helper class "KAMCreateAssesmentTaskHelper"                        */
/**********************************************************************/
@isTest
private class KAMCreateMissionTaskForMissionBatch_Test {
    @testVisible static testMethod void validateBatchExecution(){
        
		List<Data_Mapping__mdt> metaDataSettings = [SELECT Id , Source_Field__c, Source_Object__c, Target_Field__c, 
                                                    Target_Object__c FROM Data_Mapping__mdt];        
        ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name = 'Action Plan Template 1';
        insert apt1;
        
        ActionPlanTemplateItem__c apti1 = new ActionPlanTemplateItem__c();
        apti1.Subject__c = 'test action plan template item';
        apti1.Priority__c = 'Low';
        apti1.Comments__c = 'Test APTI 1';
        apti1.ActionPlanTemplateId__c = apt1.Id;
        insert apti1;
        ActionPlanTemplateItem__c apti2 = new ActionPlanTemplateItem__c();
        apti2.ActionPlanTemplateId__c = apt1.Id;
        apti2.Subject__c = 'test item';
        apti2.Priority__c = 'High';
        apti2.Comments__c = 'Test APTI 2';
        insert apti2; 
         
        Mission__c visitObj = new Mission__c();
        visitObj.Status__c = 'Planned';
        insert visitObj;
        
        ActionPlan__c aPlanObj1 = new ActionPlan__c();
        //aPlanObj1.Name = 'Test action Plan1';
        aPlanObj1.ActionPlanTemplateId__c = apt1.Id;
        aPlanObj1.Mission__c = visitObj.Id;
        ActionPlan__c aPlanObj2 = new ActionPlan__c();
        //aPlanObj2.Name = 'Test action Plan1';
        aPlanObj2.ActionPlanTemplateId__c = apt1.Id;
        aPlanObj2.Mission__c= visitObj.Id;
        insert aPlanObj2;
        insert aPlanObj1;
        
        test.startTest();
        Database.executeBatch( new KAMCreateMissionTasksForMissionBatch());
        test.stopTest();
        
    }
    
    static testMethod void validateBatchExecution1(){
        ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name = 'Action Plan Template 1';
        insert apt1;
        
        List<ActionPlanTemplateItem__c> aptList = new List<ActionPlanTemplateItem__c>();
        ActionPlanTemplateItem__c apti1 = new ActionPlanTemplateItem__c();
        apti1.Subject__c = 'test action plan template item';
        apti1.Priority__c = 'Low';
        apti1.Comments__c = 'Test APTI 1';
        apti1.ActionPlanTemplateId__c = apt1.Id;
        aptList.add(apti1);
        ActionPlanTemplateItem__c apti2 = new ActionPlanTemplateItem__c();
        apti2.ActionPlanTemplateId__c = apt1.Id;
        apti2.Subject__c = 'test item';
        apti2.Priority__c = 'High';
        apti2.Comments__c = 'Test APTI 2';
        aptList.add(apti2);
        insert aptList;
         
        Mission__c visitObj = new Mission__c();
        visitObj.Status__c = 'Planned';
        insert visitObj;
        
        List<ActionPlan__c> apList = new List<ActionPlan__c>();
        ActionPlan__c aPlanObj1 = new ActionPlan__c();
        //aPlanObj1.Name = 'Test action Plan1';
        aPlanObj1.ActionPlanTemplateId__c = apt1.Id;
        aPlanObj1.Mission__c = visitObj.Id;
        ActionPlan__c aPlanObj2 = new ActionPlan__c();
        //aPlanObj2.Name = 'Test action Plan1';
        aPlanObj2.ActionPlanTemplateId__c = apt1.Id;
        aPlanObj2.Mission__c= visitObj.Id;
        apList.add(aPlanObj2);
        apList.add(aPlanObj1);
        insert apList;
        
        test.startTest();
        Database.executeBatch( new KAMCreateMissionTasksForMissionBatch());
        KAMCreateMissionTaskHelper.createRecords(null,null);
        test.stopTest();
        
    }
}