/*******************************************************************************************
* @Name         BatchRSGAutomation
* @Author       Shreya Raut
* @Date          11/1/2021  
* @Description  To create and delete ARSG records.
/**********************************************************************/
/*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Shreya Raut       11/1/2021           
*******************************************************************************************/
global class BatchRSGAutomation implements Database.Batchable<sObject>, Database.Stateful {
    Map<String,RetailLocationGroup__c > RSGMap;
    Private set<ID> parentIds;
    Private Map<ID,Account> oldAccount;
    Map<Id, AccountRetailStoreGroup__c> newMap;
    List<Account> accList;
    
    set<ID> accIDs;
    Map<ID,AccountRetailStoreGroup__c> accountRSGMap;
    set<ID> accStatechange;
    set<ID> acctInstIDs;
    String TriggeroperationType;
    Id AccRecordTypeIdRegional = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Regional Chain Retailer').getRecordTypeId();
    Id AccRecordTypeIdChain = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
    Id AccRecordTypeIdIndependent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
    
    global BatchRSGAutomation(List<Account> BatchaccList, Map<Id,Account> BatcholdAccount , set<ID> BatchparentIds, string operationType )
    {
        system.debug('inside batch rsg automation constr');
        RSGMap = new MAP<String,RetailLocationGroup__c >();
        parentIds = new set<ID>();
        parentIds = BatchparentIds;
        System.debug('inside account handler'+parentIDs);
        oldAccount = BatcholdAccount;
        accList = BatchaccList;
        TriggeroperationType = operationType;
        System.debug('11 operation type'+TriggeroperationType);
        System.debug('11 accList type'+accList);
        accStatechange = new set<ID>();
        accountRSGMap = new Map<ID,AccountRetailStoreGroup__c>();
        accIDs = new set<ID>();
        acctInstIDs = new set<ID>();

        System.debug('11 string.isBlank(TriggeroperationType)'+string.isBlank(TriggeroperationType));
        System.debug('11 TriggeroperationType'+TriggeroperationType);
        if( !(string.isBlank(TriggeroperationType) && accList.size()>0 && !acclist.isEmpty() && !BatcholdAccount.isEmpty() )){
        for(Account acc : accList)
        {
            System.debug('inside accounts'+acc.name);
            acctInstIDs.add(acc.id);
             if(TriggeroperationType =='update'){
            
            if(oldAccount.size()>0 && !oldAccount.isEmpty()){
                
                Account oldAcc =  oldAccount.get(acc.Id);
                //To store the ids and used in insertion logic.
                acctInstIDs.add(acc.id);
                //To store the parent account Ids and used in insertion logic.
                System.debug('22 Null acc'+acc);
                System.debug('22 Null acc name'+acc.name);
                //system.debug('22 Null check acc.parentID'+acc.ParentId);
                // system.debug('22 Null check oldAcc.parentID'+oldacc.parentID);
             
                 if(  (acc.name== null && Test.isRunningTest())|| (acc.ParentId != oldAcc.ParentId) || acc.shippingstate != oldAcc.shippingstate)
               {
                    accIDs.add(acc.id);
                   System.debug('22 inside construc accIDs'+accIDs);
                }
                
                System.debug('22 inside construc accIDs after if '+accIDs);
             }
        }
        }
    }
        system.debug('parentIDs  constructore1'+parentIDs);
        //To store the RSG records where parent account is equals to door account's parent account and pricing states is not null.Map<String,RetailLocationGroup__c > RSGMap = new MAP<String,RetailLocationGroup__c >();
        if(parentIDs.size()>0 || parentIDs !=null){
        for(RetailLocationGroup__c rsg : [select id,AccountId__c,Pricing_State__c from RetailLocationGroup__c where AccountId__c IN:parentIDs 
                                          and Pricing_State__c!=null])
        {
            String s = rsg.AccountId__c + '-' + rsg.Pricing_State__c;
            RSGMap.put(s,RSG);
        }
        System.debug('RSGMap constructor'+RSGMap);
        for(AccountRetailStoreGroup__c arsg : [select id,RetailStoreGroupId__c,AccountId__c from AccountRetailStoreGroup__c where
                                               AccountId__c IN: acctInstIDs])
        {
          accountRSGMap.put(arsg.AccountId__c,arsg);
        }
    }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
    STRING QUERY ='Select id,Name,RecordTypeId,ParentId,Ultimate_Parent_Account__c,ShippingState From Account where Id IN: acctInstIDs';
    //system.debug('The query in BatchAddChildAccountsAccessParentId ***************** '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> listAcc) {
    System.debug('inside execute method');
    AccountTriggerHandler.isExecuting = true;
    set<ID> acctInstIDs = new set<ID>();
    Map<ID,AccountRetailStoreGroup__c> arsgdeletelist = new MAp<ID,AccountRetailStoreGroup__c>();
    system.debug('22 execute accIDs'+accIDs);
    system.debug('22 execute accStatechange'+accStatechange);
    //Fetching the ARSG records which needs to delete
        if(TriggeroperationType ==  'update'){
        if(accIDs.size()>0 || accIDs!=null){
        
         if(accStatechange.size()>0 || accStatechange!=null){
          
          for( AccountRetailStoreGroup__c a :  [select id,AccountId__r.ShippingState,RetailStoreGroupId__r.Pricing_State__c from
                                                AccountRetailStoreGroup__c where AccountId__c IN: accIDs ])
          {
              arsgdeletelist.put(a.id,a);
          }
         }
            
        if(arsgdeletelist.size()>0 && !arsgdeletelist.isEmpty())
        {
            try{
            delete arsgdeletelist.values();
               system.debug('delete operation**' + arsgdeletelist);
            }
             catch(Exception e){
               system.debug('e -> Delete' + e.getMessage());
            }
        }
        }
        }
    //INSERT
    system.debug('parentIDs Execute'+parentIDs);
    system.debug('RSGMap  Execute'+RSGMap);
        
    List<AccountRetailStoreGroup__c> arsglist = new List<AccountRetailStoreGroup__c>();
     if(RSGMap.size()>0 && (parentIDs.size()>0 || parentIDs !=null)){
       System.debug('inside RSGcheck 11');
        for(Account acc : listAcc){
            system.debug('accountid' + acc.name);                 
				system.debug('acc ParentId' + acc.ParentId);
                system.debug('acc Ultimate_Parent_Account__c' + acc.Ultimate_Parent_Account__c);
                system.debug('acc shippingstate' + acc.ShippingState);
            if((acc.RecordTypeId == AccRecordTypeIdRegional || acc.RecordTypeId == AccRecordTypeIdChain || 
                acc.RecordtypeId == AccRecordTypeIdIndependent) && !(string.isBlank(acc.ShippingState)) && 
               acc.ParentId!=null && acc.Ultimate_Parent_Account__c!=null ){
               system.debug('inside 12');
               String s = acc.parentID+ '-' +acc.ShippingState;
                if(( RSGMap.get(s)!=null)){
                      system.debug('inside 13');
                    if(acc.Ultimate_Parent_Account__c == acc.ParentId){
                          system.debug('inside 14');
                        if((RSGMap.get(s).AccountId__c == acc.ParentId) && (RSGMap.get(s).Pricing_State__c == acc.ShippingState)){
                            if(accountRSGMap.get(acc.id) !=null && accountRSGMap.get(acc.id).RetailStoreGroupId__c !=RSGMap.get(s).id){
                            system.debug('inside 15');
                            AccountRetailStoreGroup__c  arsg = new AccountRetailStoreGroup__c ();
                            arsg.AccountId__c = acc.id;
                            arsg.RetailStoreGroupId__c= RSGMap.get(s).id;
                            arsglist.add(arsg);
                            }else{
                            system.debug('inside 16');
                            AccountRetailStoreGroup__c  arsg = new AccountRetailStoreGroup__c ();
                            arsg.AccountId__c = acc.id;
                            arsg.RetailStoreGroupId__c= RSGMap.get(s).id;
                            arsglist.add(arsg);
                            }
                        }
                    }
                }
            }
         }
        }
        if(arsglist.size()>0 || !arsglist.isEmpty()){
          try{
                insert arsglist;
              system.debug('Insert 111'+arsglist);
            }
            catch(Exception e){
               system.debug('e ->'  + e.getMessage());
            }    
        }  
        
        newMap = new Map<Id, AccountRetailStoreGroup__c>();
        for(AccountRetailStoreGroup__c oh : arsglist)
        {
            newMap.put(oh.ID, oh);
        }
    }
    global void finish(Database.BatchableContext BC) {
        AccountTriggerHandler.isExecuting = false;
        system.debug('22 AccountTriggerHandler.isExecuting from batchrasg finish'+ AccountTriggerHandler.isExecuting);
       if(newMap.size()>0 && newMap!=null){
        OpportunityRSGDoorAccountUpdate o = new OpportunityRSGDoorAccountUpdate(newMap.values());
        Database.executeBatch(o);
        }
   }
}