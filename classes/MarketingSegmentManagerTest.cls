@isTest
private class MarketingSegmentManagerTest{
    static testMethod void test_getChanges(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(JUUL_Segment__pc = '1'));
        accounts.add(new Account(PAX_Segment__pc = '1'));
        MarketingSegmentManager.getChanges(accounts,'JUUL_Segment__pc',new Map<Id,Account>());
        MarketingSegmentManager.getChanges(accounts,'PAX_Segment__pc',new Map<Id,Account>());
        MarketingSegmentManager.getActivities(System.today(),System.today(),new Set<String>());
        MarketingSegmentManager.getAccounts(accounts,'JUUL_Segment__pc ');
        MarketingSegmentManager.removeFormat('');
    }
    
    static testMethod void testInsert(){
        List<Account> accounts = new List<Account>();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        string recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        accounts.add(new Account(FirstName = 'Test',LastName='Test',recordTypeId=recordTypeId));
        insert accounts;
    }
}