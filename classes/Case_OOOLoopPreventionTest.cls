/**
 * Test class for 
 */
@isTest(SeeAllData=False)
private class Case_OOOLoopPreventionTest {
static testmethod void LoopTest(){
        EmailLoopProtectionKeywordSetting__c setting = new EmailLoopProtectionKeywordSetting__c();
        setting.Name = 'Test';
       // setting.Keyword__c = 'test';
        insert setting;
        Test.startTest();
        Case newcase1 = new Case(
                            SuppliedEmail = 'danielc@schoolcenter.com'
                            , subject = 'Test test'
                            , origin = 'support@pax.com');
        try{            
       insert newCase1;
       }catch(Exception ex){
       	   //System.assertEquals('This is duplicate case, created by auto-reply', ex.getMessage());
       }
       Test.stopTest();
}
}