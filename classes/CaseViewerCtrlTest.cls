@isTest
private class CaseViewerCtrlTest{

    static testMethod void testAll(){
        Case c = new Case(
            SuppliedEmail='jdoe_test_test@doe.com',
            Subject='Feedback - Something'
        );
        insert c;

        CaseViewerCtrl.updateCase(c.Id);
        System.assertEquals(1,[SELECT Id FROM Case_Collision__c].size());
        CaseViewerCtrl.getFirebase();
        CaseViewerCtrl.getIsAccessible();
        CaseViewerCtrl.getFirebaseTimeOut();
        System.assertEquals(UserInfo.getUserId(), CaseViewerCtrl.getLoginUser().Id);
    }
}