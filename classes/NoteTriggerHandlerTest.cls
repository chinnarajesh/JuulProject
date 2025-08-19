@isTest
private class NoteTriggerHandlerTest{
    static testMethod void testProcess(){
    
        Account acc = new Account(Name = 'ACC');
        insert acc;
        
        Case c = new Case(Status = 'New',Priority = 'High',AccountId = acc.Id);
        insert c;
        
        Case cFROMdb = [SELECT CaseNumber FROM Case WHERE Id = :c.Id]; 
        
        String num = cFROMdb.CaseNumber;
        system.debug('======='+num);
        String num1 = num.remove('00');
        
        Note n = new Note(
            Title = 'TestNote',
            Body = 'Disposition: Successful Call' + 'Description %' + num1 + '%' +'Contact Phone: +19165204740' + 'Recording URL: https://recordings.talkdeskapp.com/calls/RENTVmNzM5NmVjYTgyMjcwMDAzMDAwMzc1' + 'Call Duration: 6',
            ParentId = acc.Id
        );
        insert n;

        List<CaseComment> cc = [SELECT Id,CommentBody,ParentId FROM CaseComment WHERE ParentId =:c.Id];
        system.assertEquals(0,cc.size());
        
    }
}