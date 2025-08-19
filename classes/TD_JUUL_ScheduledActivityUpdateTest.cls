/** 
* File Name: TD_JUUL_ScheduledActivityUpdateTest.cls
* Description: Test Class for TD_JUUL_ScheduledActivityUpdate
* Copyright : Talkdesk, Inc. Copyright (c) 2017
* Author : Phillip Zeelig
* Date: 10182017
**/ 

@isTest
  private class TD_JUUL_ScheduledActivityUpdateTest{
    static testmethod void  JUULtestschedule(){
            Test.StartTest();
            
            //insert test data - account
            Account a = new account();
            a.Name ='Talkdesk';
            a.Phone = 'talkdesk555-555-5556';
            insert a;
            
            //insert test data - contact
            Contact c = new contact();
            c.FirstName ='Andrei';
            c.LastName ='Kropotoff';
            c.Phone ='555-555-5555';
            c.HomePhone ='555-555-5554';
            c.MobilePhone ='555-555-5553';
            c.OtherPhone = '555-555-5552';
            c.accountID = a.id;
            insert c;
            
            //insert test data - talkdesk activity
      List<talkdesk__talkdesk_activity__c> activity = new List<talkdesk__talkdesk_activity__c>();
      for (Integer i = 0; i< 10; i++) {
          activity.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-5555', name = 'Test ' + i, talkdesk__Talkdesk_Id__c ='Test ' + i, talkdesk__Contact__c=NULL, talkdesk__account__c=NULL));
            }
            for (Integer j = 0; j< 10; j++) {
          activity.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-5554', name = 'Test J ' + j, talkdesk__Talkdesk_Id__c ='Test J ' + j, talkdesk__Contact__c=c.id, talkdesk__account__c=NULL));
            }
            insert activity;
            //Schedule Job
            TD_JUUL_ScheduledActivityUpdate sh1 = new TD_JUUL_ScheduledActivityUpdate();      
            String sch = '0  00 1 3 * ?';
            system.schedule('Test', sch, sh1);
            List<talkdesk__talkdesk_activity__c> objectList = new List<talkdesk__talkdesk_activity__c>(); 
            Test.stopTest();
    }
}