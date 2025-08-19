global class BatchMassDuplicateAnalysisDelete implements Database.Batchable<sObject>{

   global final String Query;
    
 

   global BatchMassDuplicateAnalysisDelete(String q){
      Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Account> accounts = new List<Account>();
       for(Duplicate_Account_Analysis__c da : (List<Duplicate_Account_Analysis__c>)scope){
           accounts.add(new Account(
           		Id = da.Account__c
           ));
       }
       delete accounts;
       
       delete scope;
    
    }

   global void finish(Database.BatchableContext BC){
   }
}