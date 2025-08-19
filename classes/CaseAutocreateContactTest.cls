public class CaseAutocreateContactTest {
    
    public static testMethod void testBulkContactsGetCreated() {
        List<Case> newCases = new List<Case>();
        for (Integer i = 0; i<50; i++) {
            Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com' + i,
                                SuppliedName='John Doe' + i,
                                Subject='Feedback - Something' + i);
            newCases.add(c);
        }
        for (Integer i = 0; i<40; i++) {
            Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com' + i,
                                SuppliedName='JohnDoe' + i,
                                Subject='Feedback - Something' + i);
            newCases.add(c);
        }
        for (Integer i = 0; i<10; i++) {
            Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com' + i,
                                Web_First_Name__c='John' + i,
                                Web_Last_Name__c='Doe' + i,
                                Subject='Feedback - Something' + i);
            newCases.add(c);
        }
        
         for (Integer i = 0; i<10; i++) {
            Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com' + i,
                               Subject='Feedback - Something' + i);
            newCases.add(c);
        }
        insert newCases;
        
        System.debug('here');
        List<Id> newCaseIds = new List<Id>();
        for (Case caseObj:newCases) {
            newCaseIds.add(caseObj.Id);    
        }
        
        List<Case> updatedCases = [Select ContactId From Case Where Id in :newCaseIds];
        
        
    }

    public static testMethod void testContactGetsCreated() {
        Case c = new Case(SuppliedEmail='jdoe_test_test@doe.com',
                            SuppliedName='John Doe',
                            Subject='Feedback - Something');
        insert c;

        List<Account> johnDoes = [select Id from Account where PersonEmail ='jdoe_test_test@doe.com'];

        
   }

    public static testMethod void testNoDupesAreCreated() {
        Contact cnt1 = new Contact(FirstName = 'John',
                                LastName = 'Doe',
                                Email='jdoe_test_test@doe.com');

        insert cnt1;

        Case case1 = new Case(SuppliedEmail='jdoe_test_test@doe.com',
                            SuppliedName='John Doe',
                            Subject='Feedback - Something');

        insert case1;

        List<Account> johnDoes = [select Id from Account where PersonEmail ='jdoe_test_test@doe.com'];

    }

    public static testMethod void testEmailNameDoesntGetCreated() {
        Case c = new Case(SuppliedEmail='testEmailNameDoesntGetCreated@doe.com',
                            SuppliedName='testEmailNameDoesntGetCreated@doe.com',
                            Subject='Feedback - Something');
        insert c;

        List<Account> johnDoes = [select Id from Account where PersonEmail ='testEmailNameDoesntGetCreated@doe.com'];

   }
}