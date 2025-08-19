global class Batch_CustomerExtensionCreation implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name FROM Account where isPersonAccount != true and ShippingCountry = \'US\'';
       
 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        set<id> accountid = new set<id>();
        map<id,cgcloud__Account_Extension__c> alreadyExptensionRecord = new map<id,cgcloud__Account_Extension__c>();
        
        List<account> listToUpdateAccount = New List<account>();
        List<cgcloud__Account_Extension__c> listToCreate = New List<cgcloud__Account_Extension__c>();
        
        for(Account accid : scope)
        {
            accountid.add(accid.id);
        }
        
        for(cgcloud__Account_Extension__c cst : [select id,cgcloud__Account__c from cgcloud__Account_Extension__c where cgcloud__Account__c IN :accountid])
        {
            alreadyExptensionRecord.put(cst.cgcloud__Account__c,cst);
        }
        for(Account acc : scope)
        {
            if(alreadyExptensionRecord.size() <= 0 && !alreadyExptensionRecord.containsKey(acc.id))
            {
                cgcloud__Account_Extension__c cext = new cgcloud__Account_Extension__c();
                cext.cgcloud__Account__c = acc.id;
                cext.cgcloud__State__c   = '010';
                cext.cgcloud__Promotion_Valid_From__c=System.today();
                cext.cgcloud__Promotion_Valid_Thru__c= Date.newInstance(2099, 12, 31);
                cext.cgcloud__Store_Role_Valid_From__c=System.today();
                cext.cgcloud__Store_Role_Valid_Thru__c= Date.newInstance(2099, 12, 31);
                listToCreate.add(cext);
            }
        }
        if(!listToCreate.IsEmpty())
        {
            database.insert(listToCreate,false);
        }
    }
    global void finish(Database.BatchableContext BC) {

        //database.executebatch(new Batch_CreateOrgUnit(),100);

    }
}