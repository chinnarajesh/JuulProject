@isTest(SeeAllData=true)
public class RHX_TEST_Asset {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Asset LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Asset()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}