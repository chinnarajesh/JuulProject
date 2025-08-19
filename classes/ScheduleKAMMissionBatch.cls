/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Shreya Raut        02-20-2021                     */
/* Class Name: ScheduleKAMMissionBatch                       */
/* Description: */
/**********************************************************************/
global class ScheduleKAMMissionBatch implements schedulable{
    
    global void execute(SchedulableContext sc) {
        
         
        
        Database.executeBatch(new KAMMissionBatch(),2);

        
   }

}