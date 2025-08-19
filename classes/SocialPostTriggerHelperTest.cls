@isTest
private without sharing class SocialPostTriggerHelperTest {
    private static testMethod void test01(){
        Account acc1 = new Account();
        acc1.lastName = 'test';
        acc1.PersonEmail = 'test@existing.com';
        insert acc1;
        Case caseObj = new Case(Subject = 'TestClassCase');
        insert caseObj;
        
        Account acc = new Account();
        acc.lastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        System.debug('acc'+acc);
        SocialPersona sper = new SocialPersona();
        sper.Name = 'test';
        sper.ParentId = acc.Id;
        sper.Provider = 'Twitter';
        insert sper;
        
        SocialPost sp = new SocialPost();
        sp.Name = 'testpost';
        sp.Handle = 'test';
        sp.Provider = 'Twitter';
        sp.content = 'new test tweet cashier';
        sp.ParentId = caseObj.Id;
        sp.WhoId = acc.Id;
        sp.PersonaId = sper.Id;
        sp.PostTags = 'test@existing.com';
        insert sp;
        
    }
}