/* VERSION     AUTHOR                  DATE                                                         */
/*     1.0     Pushkar Gangwar         06-18-2020                                                   */
/* Class Name: KAMEmailWeeklyReportSchedule                                                           */
/* Description: Scheduler class for KAMEmailWeeklyAlertReportBatch to process execute method sending email to account team
/****************************************************************************************************/
global class KAMEmailWeeklyReportSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
       KAMEmailWeeklyAlertReportBatch aula=new KAMEmailWeeklyAlertReportBatch();
       ID batchprocessid = Database.executeBatch(aula);
   }
}