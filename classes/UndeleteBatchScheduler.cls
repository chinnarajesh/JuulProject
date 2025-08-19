/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       05-17-2021                    */
/* Class Name: UndeleteBatchScheduler                       */
/* Description: Scheduling batch job for UndeleteBatchScheduler  */
 /*Ticket Number:     */
/**********************************************************************/
public class UndeleteBatchScheduler implements schedulable{
  
    public void execute(SchedulableContext sc){
        UndeleteContactBatch conBatch = new UndeleteContactBatch();
        Database.executeBatch(conBatch);
        
       } 
}