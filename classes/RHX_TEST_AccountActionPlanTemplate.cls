@isTest(SeeAllData=true)
public class RHX_TEST_AccountActionPlanTemplate {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AccountActionPlanTemplate__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AccountActionPlanTemplate__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}