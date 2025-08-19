@isTest
private class DeleteEmailBatchTest {

    static testMethod void testEmailMeassage(){
 
           
        List<Account> accounts = new List<Account>();
        List<Case> cas = new List<Case>();
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
             Account acc = new Account();
            acc.Name  = 'Test Account';
            acc.Email__c = 'abc'+'@test.com';
            acc.Phone = '1238901234';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert acc;
        
        accounts.add(acc);
        
        for (Account account : [select id from account]) {
            cas.add(new Case(
                accountId=account.id,
                Product__c = 'pax'
            ));
        }
        insert cas;

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        List<LiveChatTranscript> chats = new List<LiveChatTranscript>();

        for(Case c : [SELECT id FROM Case]){
            chats.add(new LiveChatTranscript(
                Body = '23456 ',
                CaseId = c.Id,
                LiveChatVisitorId = visitor.Id
            ));
        }
        insert chats;

        Test.startTest();
        DeleteEmailBatch cseBtch = new DeleteEmailBatch(365,'LiveChatTranscript');
        Database.executeBatch(cseBtch);
        DeleteEmailBatch cseBtch1 = new DeleteEmailBatch(365,'Task');
        Database.executeBatch(cseBtch1);
        cseBtch1 = new DeleteEmailBatch(365,'Task', true);
        Database.executeBatch(cseBtch1);
        Test.stopTest();
    }
}