@isTest(SeeAllData = True)
private without sharing class CaseTriggerHelperTest {
    static testMethod void testMethod01() {
        SocialPost sp = new SocialPost();
        sp.Name = 'test';
        sp.Content = 'test';
        insert sp;
        Case cases = new Case();
        cases.SourceId = sp.Id;
        insert cases;
        
    }
}