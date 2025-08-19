/*******************************************************************************************
* @Name         ScheduleBatch_RMAItemTotalTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         09/20/2019
* @Group        Sales Ops
* @Description  Test class for the schedule class "ScheduleBatch_RMAItemTotal"
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          09/20/2019           Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class ScheduleBatch_RMAItemTotalTest {
  static testmethod void myMethod1(){
        Test.StartTest();
            ScheduleBatch_RMAItemTotal  batchRMA= new ScheduleBatch_RMAItemTotal();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Apex Batch1', sch, batchRMA); 
        Test.stopTest(); 
    }
}