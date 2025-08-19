/********************************************************
Purpose:
-------
Code Coverage for KAMMissionBatch
======================================================
History
-------
VERSION  AUTHOR        DATE            Description
1.0      Shreya    25th Feb,2021    Created  
********************************************************/

@isTest
public class ScheduleKAMMissionBatchTest {
    
    public static testMethod void testBatchschedule() {
        
        Test.StartTest();
        String cronexp = '0 0 23 * * ?'; 
        ScheduleKAMMissionBatch a = new ScheduleKAMMissionBatch();                  
        system.schedule( 'KAMMissionBatch01',cronexp, a); 
        Test.stopTest(); 
    }
    
}