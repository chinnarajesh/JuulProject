@isTest
private class ActivityTriggerHandlerTests {
    @testSetup static void dataSetup(){
        
        Account acc = new Account(Name ='Test Acc');
        insert acc;
        
        Lead ld = new Lead(Firstname='Test',LastName='L');
        insert ld;
    }
    
    public static testmethod void countTestAcc(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Acc'];
        List<Task> taskList = new List<Task>();
        Task t = new Task(
            //OwnerId = uList[0].Id,
            WhatId = acc.Id,
            //WhoId = con.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        ); 
        taskList.add(t);
        Task t1 = new Task(
            //OwnerId = uList[1].Id,
            WhatId = acc.Id,
            //WhoId = con.Id,
            Subject = 'Subject Description',
            Type = 'Call',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        );
        taskList.add(t1);
        Test.startTest();
        insert taskList;
        Account accUpd = [SELECT Id,task_count__c FROM Account WHERE Name='Test Acc'];
        system.assertEquals(1, accUpd.task_count__c);
        Test.stopTest();
    }
    
    public static testmethod void countTestLead(){
        Lead lead = [SELECT Id FROM Lead WHERE FirstName='Test'];
        List<Task> taskList = new List<Task>();
        Task t = new Task(
            //OwnerId = uList[0].Id,
            //WhatId = acc.Id,
            WhoId = lead.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        ); 
        taskList.add(t);
        Task t1 = new Task(
            //OwnerId = uList[1].Id,
            //WhatId = acc.Id,
            WhoId = lead.Id,
            Subject = 'Subject Description',
            Type = 'Call',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        );
        taskList.add(t1);
        Test.startTest();
        insert taskList;
        Lead leadUpd = [SELECT Id,task_count__c FROM lead WHERE Firstname='Test'];
        system.assertEquals(1, leadUpd.task_count__c);
        Test.stopTest();
    }
    
    public static testmethod void countTestAccEvents(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Acc'];
        List<Event> events = new List<Event>();
        Event e = new Event(
            WhatId = acc.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            DurationInMinutes = 30,
            ActivityDate = Date.newInstance(2015,10,10),
            ActivityDateTime = Date.newInstance(2015,10,10)
        ); 
        events.add(e);
        Event e1 = new Event(
            WhatId = acc.Id,
            Subject = 'Subject Description1',
            Type = 'Call',
            DurationInMinutes = 30,
            ActivityDate = Date.newInstance(2015,10,10),
            ActivityDateTime = Date.newInstance(2015,10,10)
        );
        events.add(e1);
        Test.startTest();
        insert events;
        Account accUpd = [SELECT Id,Event_count__c FROM Account WHERE Name='Test Acc'];
        system.assertEquals(2, accUpd.Event_count__c);
        Test.stopTest();
    }
    public static testmethod void countTestLeadEvents(){
        Lead lead = [SELECT Id FROM Lead WHERE FirstName='Test'];
       List<Event> events = new List<Event>();
        Event e = new Event(
            WhoId = lead.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            DurationInMinutes = 30,
            ActivityDate = Date.newInstance(2015,10,10),
            ActivityDateTime = Date.newInstance(2015,10,10)
        ); 
        events.add(e);
        Event e1 = new Event(
            WhoId = lead.Id,
            Subject = 'Subject Description1',
            Type = 'Call',
            DurationInMinutes = 30,
            ActivityDate = Date.newInstance(2015,10,10),
            ActivityDateTime = Date.newInstance(2015,10,10)
        );
        events.add(e1);
        Test.startTest();
        insert events;
        Lead leadUpd = [SELECT Id,Event_count__c FROM lead WHERE Firstname='Test'];
        system.assertEquals(2, leadUpd.Event_count__c);
        Test.stopTest();
    }
}