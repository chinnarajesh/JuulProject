@isTest(seeAllData=false)
private class HistoricalAccountActivityTests {
  public static testmethod void HistoricalLeadCount(){               
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        accList.add(acc);
        insert accList;
   
        List<Task> taskList = new List<Task>();
        Account acc1 =[SELECT Id FROM Account WHERE Name='Test'] ;
        Task t = new Task(
            whatId = acc.Id,
            Subject = 'Subject Description',
            Description ='Disposition: Successful Call' + 'Description %'+'Contact Phone: +19165204740',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        ); 
        taskList.add(t);
        Task t1 = new Task(
            WhatId = acc.Id,
            Subject = 'Subject Description',
            Type = 'Call',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        );
        taskList.add(t1);
        Test.startTest();
        insert taskList;
        Account accUpd =[SELECT Id FROM Account WHERE Name='Test'] ;
        accUpd.Task_count__c = 0;
        accUpd.Event_count__c = 0;
        update accUpd;
        HistoricalAccountActivityBatch b = new HistoricalAccountActivityBatch();
        DataBase.executeBatch(b);
        Test.stopTest();
        Account accUpdNew =[SELECT Id FROM Account WHERE Name='Test'] ;
        //system.assertEquals(1, accUpdNew.Task_Count__c);
    }
    
   
    
}