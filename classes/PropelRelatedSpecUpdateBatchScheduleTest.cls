@isTest (seealldata=true)
public with sharing class PropelRelatedSpecUpdateBatchScheduleTest {
  @isTest  public static void testBatch(){    
        Test.StartTest();
      SchedulableContext sc = null;
        String cronexp = '0 0 23 * * ?'; 
       Database.BatchableContext bc;
        PropelRelatedSpecUpdateBatchSchedule a = new PropelRelatedSpecUpdateBatchSchedule();    

            system.schedule('Test Apex Batch1', cronexp, a); 
      Test.stopTest();

    }    
}