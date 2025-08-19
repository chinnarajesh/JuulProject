global class Sheduler_TemplateOrgUnitExtensionBatch implements Schedulable
{
     global void execute(SchedulableContext sc)
     {
         Batch_updateAccountTemplate b = new Batch_updateAccountTemplate(); 
         database.executeBatch(b,10);
     }
}