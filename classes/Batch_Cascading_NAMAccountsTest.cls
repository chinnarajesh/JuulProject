@isTest(SeeAllData = false)
public class Batch_Cascading_NAMAccountsTest{
     /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void prepData(){
    
       /**** Creation of Account records *****/ 
        ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
       List<Account> testAccDataToInsert = new List<Account>();
        Account CHQaccRec = new Account();
            CHQaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            CHQaccRec.Name = 'Test CHQ Account';
            CHQaccRec.Type = 'HQ';
            CHQaccRec.National_Account_Manager__c = null;
            insert CHQaccRec;
            
        
        for(Integer i=0; i<10; i++){
            Account HQaccRec = new Account();
            HQaccRec.Name ='TestAccount '+i;
            HQaccRec.Type = 'HQ';
            HQaccRec.parentId = CHQaccRec.id;
            HQaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(HQaccRec);
        }
        insert testAccDataToInsert;
       /**** End of creation of Account records *****/   
    }
     /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    public static testMethod void NAMAccounts_Test1(){
        List<Account> listAccToUpdate = new List<Account>();
        Map<Id,Id> newAccToNAM = new Map<Id,Id>();
        List<Account> listAcc = [Select Id, ParentId, Parent.ParentId, Parent.Parent.ParentId,Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId, 
                                    National_Account_Manager__c from Account LIMIT 25];
           for(Account acc : listAcc){
               acc.National_Account_Manager__c = UserInfo.getUserId();
               listAccToUpdate.add(acc); 
            }
            update listAccToUpdate;
            for(Account accRec : listAccToUpdate ){
                newAccToNAM.put(accRec.Id, accRec.National_Account_Manager__c);
            } 
           Batch_Cascading_NAMAccounts NAMBatch = new  Batch_Cascading_NAMAccounts(newAccToNAM);
         Database.BatchableContext bc;
            Test.StartTest();
                NAMBatch.start(bc);
                NAMBatch.execute(bc,listAccToUpdate);
                NAMBatch.finish(bc);
           Test.StopTest(); 
           
        }
    
}