global class ScheduleAPTRefreshISLsBatch implements schedulable{
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new APTRefreshISLsBatch(),1);

        
   }

}