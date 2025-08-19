global class ScheduleAPTsMissionsBatchClass implements schedulable{
    
     global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new APTsMissionsBatchClass(),100);

        
   }

}