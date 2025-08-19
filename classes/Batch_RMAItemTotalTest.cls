/*******************************************************************************************
* @Name         Batch_RMAItemTotalTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         09/20/2019
* @Group        Sales Ops
* @Description  Test class for Batch_RMAItemTotal class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil         09/20/2019         Initial Creation
*******************************************************************************************/
@isTest(SEEALLDATA = false)
public class Batch_RMAItemTotalTest {
    @TestSetup static void makeData(){
        List<B2B_RMA_Item__c> listB2BRMAItemToInsert = new List<B2B_RMA_Item__c>();
        Case caseRec = new Case();
            caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B RMA').getRecordTypeId();
            caseRec.Status = 'RMA Open';
            caseRec.Type = 'Missing Product';
            caseRec.Subject = 'Test Subject';
         insert caseRec;
        Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Family ='Marketing Assets';
            p.isActive = true;
            p.D2R_Price__c  = 10;
        insert p;
        for(Integer i=0; i<5;i++){
            B2B_RMA_Item__c B2BRMAItem = new B2B_RMA_Item__c();
                B2BRMAItem.Product__c = p.id;
                B2BRMAItem.Case__c = caseRec.id;
                listB2BRMAItemToInsert.add(B2BRMAItem);
        }

        insert listB2BRMAItemToInsert; 
    }
     private static testMethod void RMAItemTotalTest_Test1(){
         List<B2B_RMA_Item__c> listB2BRMAItem = [Select Id, Case__c, Case__r.RMA_Total__c, RMA_Item_Total__c from B2B_RMA_Item__c Where RMA_Item_Total__c != null];
          Batch_RMAItemTotal RMATotalBatch = new  Batch_RMAItemTotal();
         Database.BatchableContext bc;
            Test.StartTest();
                RMATotalBatch.start(bc);
                RMATotalBatch.execute(bc,listB2BRMAItem);
                RMATotalBatch.finish(bc);
           Test.StopTest(); 
     }
}