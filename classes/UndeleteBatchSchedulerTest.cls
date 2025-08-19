/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       05-17-2021                    */
/* Class Name: UndeleteBatchSchedulerTest                       */
/* Description: Test class for UndeleteBatchScheduler  */
 /*Ticket Number:     */
/**********************************************************************/
@isTest
public class UndeleteBatchSchedulerTest {
    
    public static testMethod void testBatchschedule() {
        
        Test.StartTest();
        String cronexp = '0 0 09 * * ?'; 
        UndeleteBatchScheduler a = new UndeleteBatchScheduler();                  
        String jobId = system.schedule( 'UndeleteContactBatch',cronexp, a); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronexp, ct.CronExpression);
        Test.stopTest(); 
    }
}