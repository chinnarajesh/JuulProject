/*******************************************************************************************
* @Name         ScheduleBatch_RMAItemTotal
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         09/20/2019
* @Group        Sales Ops
* @Description  Schedule class for the batch class "Batch_RMAItemTotal"
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          09/20/2019           Initial Creation
*******************************************************************************************/
global class ScheduleBatch_RMAItemTotal implements schedulable{
    global void execute(SchedulableContext sc){
        Batch_RMAItemTotal b = new Batch_RMAItemTotal(); 
        database.executebatch(b);
    }
}