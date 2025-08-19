@isTest
private class HistoricalLeadActivityTests {
    @testSetup static void dataSetup(){                
        Lead ld = new Lead(Firstname='Test',LastName='L');
        insert ld;
    }
    
    public static testmethod void HistoricalLeadCount(){
        List<Task> taskList = new List<Task>();
        Lead ld =[SELECT Id,Task_count__c,Event_count__c FROM Lead WHERE FirstName='Test'] ;
        Task t = new Task(
            WhoId = ld.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        ); 
        taskList.add(t);
        Task t1 = new Task(
            WhoId = ld.Id,
            Subject = 'Subject Description',
            Type = 'Call',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        );
        taskList.add(t1);
        Test.startTest();
        insert taskList;
        Lead leadUpd = [SELECT Id,Task_count__c,Event_count__c FROM Lead WHERE FirstName='Test'] ;
        leadUpd.Task_count__c = 0;
        leadUpd.Event_count__c = 0;
        update leadUpd;
        HistoricalLeadActivityBatch b = new HistoricalLeadActivityBatch();
        DataBase.executeBatch(b);
        Test.stopTest();
        Lead leadUpdNew = [SELECT Id,Task_count__c,Event_count__c FROM Lead WHERE FirstName='Test'] ;
        system.assertEquals(1, leadUpdNew.Task_Count__c);
    }
    
    public static testmethod void LeadConversionCount(){
        List<Task> taskList = new List<Task>();
         List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [
          select MasterLabel
          from LeadStatus
          where IsConverted = true
          limit 1
     	];
        Lead ld =[SELECT Id,Task_count__c,Event_count__c FROM Lead WHERE FirstName='Test'] ;
        Task t = new Task(
            WhoId = ld.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        ); 
        taskList.add(t);
        Task t1 = new Task(
            WhoId = ld.Id,
            Subject = 'Subject Description',
            Type = 'Call',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        );
        taskList.add(t1);
        List<Event> events = new List<Event>();
        Event e = new Event(
            WhoId = ld.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            DurationInMinutes = 30,
            ActivityDate = Date.newInstance(2015,10,10),
            ActivityDateTime = Date.newInstance(2015,10,10)
        ); 
        events.add(e);
        Event e1 = new Event(
            WhoId = ld.Id,
            Subject = 'Subject Description1',
            Type = 'Call',
            DurationInMinutes = 30,
            ActivityDate = Date.newInstance(2015,10,10),
            ActivityDateTime = Date.newInstance(2015,10,10)
        );
        events.add(e1);
        insert taskList;
        insert events;
        Lead leadUpd = [SELECT Id,Task_count__c,Event_count__c FROM Lead WHERE FirstName='Test'] ;
        leadUpd.Task_count__c = 0;
        leadUpd.Event_count__c = 0;
        update leadUpd;
         Database.LeadConvert lc = new Database.LeadConvert();
        String oppName = leadUpd.Name;              
        lc.setLeadId(leadUpd.Id);
        lc.setOpportunityName(oppName);
        lc.setConvertedStatus(convertStatus.MasterLabel);               
        leadConverts.add(lc);
        if(!leadConverts.isEmpty()){
            Database.convertLead(leadConverts);
        }
        Test.startTest();
        HistoricalLeadActivityBatch b = new HistoricalLeadActivityBatch();
        DataBase.executeBatch(b);
        Test.stopTest();
        Account accNew = [SELECT Id,Pre_Conversion_Task_Count__c,Pre_Conversion_Event_Count__c FROM Account WHERE FirstName='Test'] ;
        system.assertEquals(2, accNew.Pre_Conversion_Task_Count__c);
    }
    
    
}