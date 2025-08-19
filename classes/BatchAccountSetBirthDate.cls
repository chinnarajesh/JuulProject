/*********************************************************************
*
*   File Name: BatchAccountSetBirthDate.cls
*
*   File Description: Batch class to set PersonBirthDate from BirthDateText__c
*
**********************************************************************
*
*   Date        Author              Change
*   10/01/15                         Initial Creation                             
*           
**********************************************************************
* Execution -   Database.executeBatch(new BatchAccountSetBirthDate(), 200);
*********************************************************************/
global class BatchAccountSetBirthDate implements Database.Batchable<sObject>{

   global BatchAccountSetBirthDate(){
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('SELECT ID, BirthdateText__c, PersonBirthDate FROM ACCOUNT WHERE IsPersonAccount = true AND BirthdateText__c <> null AND PersonBirthDate = null');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(Account acc : (List<Account>)scope){
            if(! String.isBlank(acc.BirthdateText__c)){
	            	String dateValue = acc.BirthdateText__c.substring(0,10);
	               if(acc.BirthdateText__c.contains('/')){
	               		acc.PersonBirthDate = Date.newInstance(
		               								Integer.valueOf(
		               									dateValue.split('/')[2]
		               								)
		               								,Integer.valueOf(
		               									dateValue.split('/')[0]
		               								),Integer.valueOf(
		               									dateValue.split('/')[1]
		               								));
	               }else{
	               		acc.PersonBirthDate = Date.newInstance(
		               								Integer.valueOf(
		               									dateValue.split('-')[0]
		               								)
		               								,Integer.valueOf(
		               									dateValue.split('-')[1]
		               								),Integer.valueOf(
		               									dateValue.split('-')[2]
		               								));
	               }
	            }
        }
        Database.update(scope, false);
      
   }

   global void finish(Database.BatchableContext BC){
   }
}