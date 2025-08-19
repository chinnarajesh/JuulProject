@isTest
private class TaskTriggerHandlerTest{
    
    static testMethod void TestProcess(){
        List<User> uList = [SELECT Id FROM User WHERE IsActive = true LIMIT 2];
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='TaskTrigger',Enabled__c=true);
        insert(triggerController);
        
        Account acc = new Account(Name = 'TestAcc',ShippingStreet= 'TestStreet',ShippingCountry='TestCountry',ShippingCity='IE',ShippingPostalCode='1111');
        insert acc;
        
        Contact con  = new Contact(AccountId = acc.Id,LastName = 'TestCon');
        insert con;
        
        Case c = new Case(Status = 'New',Priority = 'High',AccountId = acc.Id,Web_Form__c ='Test');
        insert c;
        
        Case cFROMdb = [SELECT CaseNumber FROM Case WHERE Id = :c.Id]; 
        String num = cFROMdb.CaseNumber;
        system.debug('======='+num);
        String num1 = num.remove('00');
        
     
        Task t = new Task(
            OwnerId = uList[0].Id,
            WhatId = acc.Id,
            WhoId = con.Id,
            Subject = 'Check In',
            Description ='Disposition: Successful Call' + 'Description %' + num1 + '%' +'Contact Phone: +19165204740',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            CallDurationInSeconds = 10,
            ActivityDate = Date.newInstance(2015,10,10)
        );
        insert t;
        /*
        Task t1 = new Task(
            OwnerId = uList[1].Id,
            WhatId = acc.Id,
            WhoId = con.Id,
            Subject = 'Subject Description',
            Type = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.newInstance(2015,10,10)
        );
        insert t1;
        */
        System.assertEquals(0,[SELECT Count() FROM CaseComment]); 
    }
    
}