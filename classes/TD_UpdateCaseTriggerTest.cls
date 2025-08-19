/**
* File Name: TD_UpdateCaseTriggerTest
* Description: Test Class for TD_UpdateCaseTrigger
* Copyright : Talkdesk, Inc. Copyright (c) 2017
* Author : Phillip Zeelig
* Date: 10262017
**/ 
@isTest
private class TD_UpdateCaseTriggerTest { 
    
    
    static testMethod void TalkdeskUpdateCaseTriggerTestMethod(){         
         List<Case> caseIds=new List<Case>();
         List<Case> csList=new List<Case>();
         List<Account> aList=new List<Account>();
         List<Contact> cList=new List<Contact>();
        
        //insert test data - account
        Account a = new account();
        a.name = 'Talkdesk';
        a.Phone = '15555555555';
        aList.add(a);
    
        //insert test data - account
        Account a2 = new account();
        a2.Name ='Talkdesk2';
        a2.Phone = '15555551234';
        aList.add(a2);    
        //insert aList;
    
        //insert test data - contact
        Contact c = new contact();
        c.FirstName ='Andrei';
        c.LastName ='Kropotoff';
        c.Phone ='15555555555';
        c.Email = 'phillip.zeelig@talkdesk.com';
        c.HomePhone ='15555555555';
        c.MobilePhone ='15555555555';
        c.OtherPhone = '15555555555';
        c.accountID = a.id;
        cList.add(c);
    
        //insert test data - contact
        Contact c2 = new contact();
        c2.FirstName ='Phillip';
        c2.LastName ='Zeelig';
        c2.Phone ='15555551233';
        c2.HomePhone ='15555551233';
        c2.MobilePhone ='15555551233';
        c2.OtherPhone = '15555551233';
        c2.accountID = a2.id;
        cList.add(c2);
        //insert cList;
    
        //insert test data - case
        Case cs = new case();
        cs.ContactId = c.Id;
        cs.Subject ='Test_Case';
        cs.Type ='Feature Request';
        cs.Origin = 'web';
        cs.Status = 'new';
        cs.TD_last_agent__c=NULL;
        cs.TD_LAST_CALL_SID__c=NULL;
        csList.add(cs);
           
        //insert test data - case2
        Case cs2 = new case();
        cs2.ContactId =c2.Id;
        cs2.Subject ='Test_Case2';
        cs2.Type ='Feature Request';
        cs2.Origin = 'web';
        cs2.Status = 'Open';
        cs2.TD_last_agent__c=NULL;
        cs2.TD_LAST_CALL_SID__c=NULL;
        csList.add(cs2);
           
        //insert test data - case3
        Case cs3 = new case();
        cs3.ContactId = c.Id;
        cs3.Subject ='Test_Case3';
        cs3.Type ='Feature Request';
        cs3.Origin = 'web';
        cs3.Status = 'Closed';
        cs3.TD_last_agent__c=NULL;
        cs3.TD_LAST_CALL_SID__c=NULL;
        csList.add(cs3);
       // insert csList;
        
        // Getting the case to verify that the td fields are not null
        caseIds = [
            SELECT Id, TD_LAST_CALL_SID__c, TD_last_agent__c, ContactId, status, ContactPhone
            FROM Case
        ];
        
        system.debug(caseIds);
        
        Test.startTest();
        
        for(contact contact: cList){
            Id [] fixedSearchResults = new Id[]{c.Id};
            Test.setFixedSearchResults(fixedSearchResults);
        }     
        //insert test data - task
        Task t = new Task();
        t.subject ='Talkdesk Grab Case: 001' ;
        t.Description = '15555555555';
        t.Priority='Normal';
        t.status='Not Started';
        t.WhoId=c.id;
        t.CallDisposition='phillip.zeelig@talkdesk.com';
        
        insert(t); 
        
        Task t1 = new Task();
        t1.subject ='Talkdesk Grab Case: ' +  cs.Id ;
        t1.Description = '005555555555';
        t1.Priority='Normal';
        t1.status='Not Started';
        t1.WhoId=c.id;
        t1.CallDisposition='phillip.zeelig@talkdesk.com';
        insert(t1); 

        Task t2 = new Task();
        t2.subject ='Talkdesk Grab Case: + ' +  cs.Id ;
        t2.Description = '+15555555555';
        t2.Priority='Normal';
        t2.status='Not Started';
        t2.WhoId=c.id;
        t2.CallDisposition='phillip.zeelig@talkdesk.com';
        insert(t2); 

        //check fields on case
        for(Case caseId: caseIds){
                System.assertEquals(NULL,caseId.TD_last_agent__c);
                System.assertEquals(NULL,caseId.TD_LAST_CALL_SID__c);
        }
        Test.stopTest();
        
    }
}