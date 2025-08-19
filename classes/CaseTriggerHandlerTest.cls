@isTest
private Class CaseTriggerHandlerTest{

    @testSetup
    static void setup(){
        String rtypeId = [SELECT Id FROM Recordtype WHERE SObjecttype = 'Case' AND DeveloperName = 'B2B_Support_Case'].Id;
        String rt = [SELECT Name, SobjectType,IsPersonType FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True].Id;
        Account acc = new Account(Name = 'Test Account',Email__c ='Test@con.com');
        List<Account> accs = new List<Account>{acc} ;
        Account acc1 = new Account(LastName = 'Account Test',RecordTypeId = rt,PersonEmail = 'Test@con.com');
        accs.add(acc1) ;
        insert accs;
        
        Contact con = new Contact(LastName = 'conLast1',Email = 'Test@con.com');
        insert con;
        Case c = new Case(RecordTypeId = rtypeId, SuppliedName = 'Test',suppliedEmail='Test@con.com');
        List<Case> cases = new List<Case>{c} ;
        Case c1 = new Case(SuppliedName = 'Test1',ContactId = con.Id,Description = 'Chat started on Test',suppliedEmail='Test2@con.com');
        cases.add(c1);
        insert cases;
    }
    static testMethod void testProcess(){
        String rtypeId = [SELECT Id FROM Recordtype WHERE SObjecttype = 'Case' AND DeveloperName = 'B2B_Support_Case'].Id;
        List<Case> c1 = [SELECT Id,AccountId,RecordType.Name,ContactId FROM Case WHERE RecordTypeId = :rtypeId];
        Account acc = [Select Id From Account Where Name = 'Test Account' LIMIT 1];
        system.assertEquals(1,c1.Size());
        system.assertEquals(null,c1[0].AccountId);
        system.assertNotEquals(null,c1[0].contactId);
        caseTriggerhandler.initAccount(new contact(FirstName='Test',LastName='Con',Email='abc@email.com'));
    }    
}