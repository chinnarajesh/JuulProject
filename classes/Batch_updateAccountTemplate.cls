global class Batch_updateAccountTemplate implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name,cgcloud__Account_Template__c, ParentID,TYPE FROM Account where isPersonAccount = false and cgcloud__Account_Template__c = null and ShippingCountry = \'US\' ORDER BY ParentID,TYPE ASC NULLS FIRST';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        Set<id> parentAccountID = NEW Set<id>();
        Map<ID,ID> parentAccountAndtemplate = NEW Map<ID,ID>();
        List<account> listToUpdateAccount = New List<account>();
        Map<ID,ID> accountWithparentID = NEW Map<ID,ID>();
        //get the cloud template name
        list<cgcloud__Account_Template__c> cgcloudAccountTemplate = [select id,Name from cgcloud__Account_Template__c where Name = 'JUUL HQ or Door'];

        for(Account acc : scope)
        {
   
            if(acc.ParentID != null && !accountWithparentID.ContainsKey(acc.ID))
            {   
                accountWithparentID.put(acc.id,acc.ParentID);
            }
        }
      
        //Update parent Account
        for(Account acc : [SELECT Id,Name,cgcloud__Account_Template__c, ParentID,TYPE FROM Account where ID IN : accountWithparentID.Values() and cgcloud__Account_Template__c = null ORDER BY ParentID,TYPE ASC NULLS FIRST])
        {
            System.debug('boolean'+!cgcloudAccountTemplate.isEmpty());
            if(!cgcloudAccountTemplate.isEmpty() )
            {
                acc.cgcloud__Account_Template__c = cgcloudAccountTemplate[0].id;
                listToUpdateAccount.add(acc);
                parentAccountAndtemplate.put(acc.ID,acc.cgcloud__Account_Template__c);
   
            }
           
        }
        
        //Update child Account
        for(Account acc :[SELECT Id,Name,cgcloud__Account_Template__c, ParentID,TYPE FROM Account where  ParentID IN :accountWithparentID.Values() and cgcloud__Account_Template__c = null ORDER BY ParentID,TYPE ASC NULLS FIRST])
        {
    
            if(!cgcloudAccountTemplate.isEmpty() && !parentAccountAndtemplate.ContainsKey(acc.ID))
            {
                acc.cgcloud__Account_Template__c = cgcloudAccountTemplate[0].id;
                listToUpdateAccount.add(acc);
                parentAccountAndtemplate.put(acc.ID,acc.cgcloud__Account_Template__c);
              
            }
            accountWithparentID.put(acc.id,acc.ParentID);
  
        }
        for(Account accid : scope)
        {

            if(!cgcloudAccountTemplate.isEmpty() && !parentAccountAndtemplate.containsKey(accid.ID) )
            {
                accid.cgcloud__Account_Template__c = cgcloudAccountTemplate[0].id;
     
                listToUpdateAccount.add(accid);
        
            }
        }
        //update the cloud template
        if(!listToUpdateAccount.IsEmpty())
        {
        
            database.update(listToUpdateAccount,false);
        }
    }
    global void finish(Database.BatchableContext BC) {
       //database.executebatch(new Batch_CreateOrgUnit(),100);
        database.executebatch(new Batch_CustomerExtensionCreation(),100);
        
    }
}