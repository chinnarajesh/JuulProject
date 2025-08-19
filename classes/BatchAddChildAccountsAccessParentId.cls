/*******************************************************************************************
* @Name         BatchAddChildAccountsAccessParentId
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         12/17/2019
* @Group        Sales Ops
* @Description  Based on an Account ParentId Id changes, this batch job will enable  
*               the apex sharing to all the child Accounts.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Anil/Srikanth      12/17/2019         Initial Creation
*******************************************************************************************/
global class BatchAddChildAccountsAccessParentId implements Database.Batchable<sObject>, Database.Stateful {
     global Set<Id> SourceAccountIds;
    global Map<Id,Id> resultNewMap, resultOldMap;
    global String StrRowCause = Schema.AccountShare.RowCause.Manual;  
    global ChildAccountShare__c settingsConst;
    global List<String> shippingCountryList;
    global Map<ID,Account> oldAccount;
    global List<Account> listAccToUpdate;
    Private set<ID> parentIds;
    global String TriggeroperationType;
    global BatchAddChildAccountsAccessParentId(Map<Id,Id> resultNewMap, Map<Id,Id> resultOldMap, Map<Id,Account> oldAccounts, Set<ID> BatchparentIds,String operationType ){
       this.SourceAccountIds  = resultNewMap.keySet();
       this.resultNewMap = resultNewMap;
       this.resultOldMap = resultOldMap; 
       this.oldAccount = oldAccounts;
       parentIds = BatchparentIds;
       TriggeroperationType = operationType;
       settingsConst = ChildAccountShare__c.getinstance('ChidlAccountShare');
       shippingCountryList = String.valueOf(settingsConst.Shipping_Country_List__c).split(',');
    }
   /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id, Type, Name,OwnerId, Parent.OwnerId, Parent.Parent.OwnerId, Parent.Parent.Parent.OwnerId, Parent.Parent.Parent.Parent.OwnerId, ';
               query += 'ParentId,Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId FROM Account ';
               query += 'WHERE (Id IN :SourceAccountIds OR ParentId IN :SourceAccountIds OR Parent.ParentId IN :SourceAccountIds OR Parent.Parent.ParentId IN :SourceAccountIds OR Parent.Parent.Parent.ParentId IN :SourceAccountIds) ';
               query += 'AND ShippingCountry IN :shippingCountryList ';
        System.debug('The query in BatchAddChildAccountsAccessParentId ***************** '+query);
        return Database.getQueryLocator(query);
     }
   /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Account>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Account> listAcc) {
      System.debug('listAcclistAcc ******************** '+listAcc);
      System.debug('resultNewMap ******************* '+resultNewMap);
      System.debug('resultOldMap ******************* '+resultOldMap);
      AccountShare accShare;
      List<AccountShare> listAccShareToUpsert = new List<AccountShare>();
      listAccToUpdate = new List<Account>();
      Account AccToUpdate;
      Set<Id> oldOwnerSet, newOwnerSet, DeleteOwnerSet;
      Set<Id> DeleteAllOwnerSet = new Set<Id>();
      Set<Id> oldOwnerIds       = new Set<Id>();
      Set<Id> newOwnerIds       = new Set<Id>(); 
      Set<Id> oldParentIdSet    = new Set<Id>();
      Set<Id> AllOldParentIdSet = new Set<Id>();
      List<Database.Error> deletelistError     = new List<Database.Error>();
      List<Database.Error> upsertlistError     = new List<Database.Error>();
      List<Database.Error> updatelistError     = new List<Database.Error>();
      
      Map<Id,Set<Id>> DeleteAccountSetOwnerMap = new Map<Id,Set<Id>>();
      Map<Id,Set<Id>> AccountSetOldParentsMap  = new Map<Id,Set<Id>>();
      Map<Id,Set<Id>> oldParentSetOwnerMap     = new Map<Id,Set<Id>>();
      Map<Id,Set<Id>> newParentSetOwnerMap     = new Map<Id,Set<Id>>();
      Id ultiParentId, ultiParentOwnerId;
      
      // STEP1: i)  Map Old Parent Ids to every Child Account
      //        ii) Get New Parent Owner Ids for every Child Account
 
      for(Account acc : listAcc){
          System.debug('********* Map Old Parent Ids to every Child Account *********');
          oldParentIdSet = new Set<Id>();
          if(resultOldMap != null && resultOldMap.size()> 0) {
              if(resultOldMap.containsKey(acc.Id)) {
                  if (resultOldMap.get(acc.Id) != null){
                      oldParentIdSet.add(resultOldMap.get(acc.Id));
                      AllOldParentIdSet.add(resultOldMap.get(acc.Id));
                  }
              } 
              if(acc.ParentId != null && resultOldMap.containsKey(acc.ParentId)) {
                  if (resultOldMap.get(acc.ParentId) != null){
                      oldParentIdSet.add(resultOldMap.get(acc.ParentId));
                      AllOldParentIdSet.add(resultOldMap.get(acc.ParentId));
                  }
              } 
              if(acc.Parent.ParentId != null && resultOldMap.containsKey(acc.Parent.ParentId)) {
                  if (resultOldMap.get(acc.Parent.ParentId) != null){
                      oldParentIdSet.add(resultOldMap.get(acc.Parent.ParentId));
                      AllOldParentIdSet.add(resultOldMap.get(acc.Parent.ParentId));
                  }
              } 
              if(acc.Parent.Parent.ParentId != null && resultOldMap.containsKey(acc.Parent.Parent.ParentId)) {
                  if (resultOldMap.get(acc.Parent.Parent.ParentId) != null){
                      oldParentIdSet.add(resultOldMap.get(acc.Parent.Parent.ParentId));
                      AllOldParentIdSet.add(resultOldMap.get(acc.Parent.Parent.ParentId));
                  }
              } 
              if(acc.Parent.Parent.Parent.ParentId != null && resultOldMap.containsKey(acc.Parent.Parent.Parent.ParentId)) {
                  if (resultOldMap.get(acc.Parent.Parent.Parent.ParentId) != null){
                      oldParentIdSet.add(resultOldMap.get(acc.Parent.Parent.Parent.ParentId));
                      AllOldParentIdSet.add(resultOldMap.get(acc.Parent.Parent.Parent.ParentId));
                  }
              }
              if(oldParentIdSet != null && oldParentIdSet.size()> 0) {
                  AccountSetOldParentsMap.put(acc.Id,oldParentIdSet);
              }
          }

          System.debug('********* Get New Parent Owner Ids for every Child Account *********'); 
          newOwnerIds = new Set<Id>();  
          if (acc.ParentId != null) {  
              If (acc.Parent.OwnerId != null && acc.Parent.OwnerId <> acc.OwnerId) 
                 { newOwnerIds.add(acc.Parent.OwnerId); }
              If (acc.Parent.Parent.OwnerId != null && acc.Parent.Parent.OwnerId <> acc.OwnerId) 
                 { newOwnerIds.add(acc.Parent.Parent.OwnerId); }
              If (acc.Parent.Parent.Parent.OwnerId != null && acc.Parent.Parent.Parent.OwnerId <> acc.OwnerId) 
                 { newOwnerIds.add(acc.Parent.Parent.Parent.OwnerId); }
              If (acc.Parent.Parent.Parent.Parent.OwnerId != null && acc.Parent.Parent.Parent.Parent.OwnerId <> acc.OwnerId) 
                 { newOwnerIds.add(acc.Parent.Parent.Parent.Parent.OwnerId); }
              newParentSetOwnerMap.put(acc.ParentId,newOwnerIds);
          }
      }
      
      // STEP2: Get Old Parent Owner Ids for every Child Account
      
      System.debug('********* Get Old Parent Owner Ids for every Child Account *********'); 
      if(AccountSetOldParentsMap != null && AccountSetOldParentsMap.size()> 0) {
        list<Account> oldParentAccountList = [select Id, ownerId, Parent.OwnerId, Parent.Parent.OwnerId, Parent.Parent.Parent.OwnerId, Parent.Parent.Parent.Parent.OwnerId
                                               from Account where Id IN :AllOldParentIdSet];
        oldOwnerIds = new Set<Id>();
        for (Account PA: oldParentAccountList){
            oldOwnerIds.add(PA.OwnerId);
            If (PA.Parent.OwnerId != null) { oldOwnerIds.add(PA.Parent.OwnerId); }
            If (PA.Parent.Parent.OwnerId != null) { oldOwnerIds.add(PA.Parent.Parent.OwnerId); }
            If (PA.Parent.Parent.Parent.OwnerId != null) { oldOwnerIds.add(PA.Parent.Parent.Parent.OwnerId); }
            If (PA.Parent.Parent.Parent.Parent.OwnerId != null) { oldOwnerIds.add(PA.Parent.Parent.Parent.Parent.OwnerId); }
            oldParentSetOwnerMap.put(PA.Id,oldOwnerIds);
        }
      }
      
      // STEP3: i)  Exclude Old Parent Owner if exists in New Parent hierarchy
      //        ii) Prepare AccountShare data to add New Parent Owner Ids
 
      for(Account acc : listAcc){ 
          System.debug('********* Exclude Old Parent Owner if exists in New Parent hierarchy *********'); 
          oldOwnerSet    = new Set<Id>();
          newOwnerSet    = new Set<Id>();
          DeleteOwnerSet = new Set<Id>();
          if(AccountSetOldParentsMap.containsKey(acc.id)) {
              for (Id oldParentId:AccountSetOldParentsMap.get(acc.id)) {
                  if(oldParentSetOwnerMap.containsKey(oldParentId)) {
                      oldOwnerSet = oldParentSetOwnerMap.get(oldParentId);
                      if(oldOwnerSet != null && oldOwnerSet.size()> 0){
                          for (Id oldOwnerId :oldOwnerSet ) {
                             if(acc.OwnerId <> oldOwnerId  &&
                                (acc.Parent.OwnerId == null                      || acc.Parent.OwnerId <> oldOwnerId)               && 
                                (acc.Parent.Parent.OwnerId == null               || acc.Parent.Parent.OwnerId <> oldOwnerId)        && 
                                (acc.Parent.Parent.Parent.OwnerId == null        || acc.Parent.Parent.Parent.OwnerId <> oldOwnerId) && 
                                (acc.Parent.Parent.Parent.Parent.OwnerId == null || acc.Parent.Parent.Parent.Parent.OwnerId <> oldOwnerId)) {
                                DeleteOwnerSet.add(oldOwnerId); 
                                DeleteAllOwnerSet.add(oldOwnerId); 
                             } 
                          }
                          if(DeleteOwnerSet != null && DeleteOwnerSet.size()> 0){
                             DeleteAccountSetOwnerMap.put(acc.id,DeleteOwnerSet);
                          }
                      }  
                  } 
              }
          }
          
     /* Assign the ultiParentId and ultiParentOwnerId  variables with the ultimate Parent Id and
        Ultimate Parent Owner Id of an account.
      */ 
       if(acc.Parent.Parent.Parent.ParentId != null){
              ultiParentId      = acc.Parent.Parent.Parent.ParentId;
              ultiParentOwnerId = acc.Parent.Parent.Parent.Parent.OwnerId;
          }else if(acc.Parent.Parent.ParentId != null){
              ultiParentId      = acc.Parent.Parent.ParentId;
              ultiParentOwnerId = acc.Parent.Parent.Parent.OwnerId;
          }else if(acc.Parent.ParentId != null){
              ultiParentId      = acc.Parent.ParentId;
              ultiParentOwnerId = acc.Parent.Parent.OwnerId;
          }else if(acc.ParentId != null){
              ultiParentId      = acc.ParentId;
              ultiParentOwnerId = acc.Parent.OwnerId;
          }else {
              ultiParentId      = null;
              ultiParentOwnerId = null;
          }
         
          AccToUpdate = new Account();
          AccToUpdate.Id  = acc.Id;
          AccToUpdate.Ultimate_Parent_Account__c = ultiParentId;
          AccToUpdate.Ultimate_Parent_Account_Owner__c = ultiParentOwnerId;
          listAccToUpdate.add(AccToUpdate);
 
          System.debug('********* Prepare AccountShare data to add New Parent Owner Ids *********'); 
          System.debug('********* newParentSetOwnerMap: ' + newParentSetOwnerMap);
          if(acc.ParentId != null){
              newOwnerSet = newParentSetOwnerMap.get(acc.ParentId);
              if(newOwnerSet != null && newOwnerSet.size()> 0){
                  for (Id newOwnerId :newOwnerSet ) {    
                      accShare = new AccountShare(AccountId = acc.id, 
                                                  AccountAccessLevel = 'Read', 
                                                  OpportunityAccessLevel = 'Read',   
                                                  CaseAccessLevel = 'Read', 
                                                  UserOrGroupId = newOwnerId,
                                                  RowCause =  StrRowCause);
                      listAccShareToUpsert.add(accShare);
                  }
              }
          }     
      }
        
      //STEP4: i)   Prepare AccountShare data to delete Old Parent Owner Ids
      //       ii)  Delete AccountShare with Old Owner Ids
      //       ii)  Upsert AccountShare with New Parent Owner Ids
      
      System.debug('DeleteAccountIds ************** '+DeleteAccountSetOwnerMap.keySet());
      System.debug('DeleteAccountSetOwnerMap.Values() ***************** '+DeleteAccountSetOwnerMap.Values());
      System.debug('listAccShareToUpsert ************** '+listAccShareToUpsert);
        
      System.debug('********* Prepare AccountShare data to delete Old Parent Owner Ids *********'); 
      if(DeleteAccountSetOwnerMap != null && DeleteAccountSetOwnerMap.size()> 0){
          List<AccountShare> mapAccShare = new List<AccountShare>([Select Id, AccountId, UserOrGroupID,UserOrGroup.Name From AccountShare Where RowCause = :StrRowCause AND AccountId IN : DeleteAccountSetOwnerMap.keySet() AND UserOrGroupID IN: DeleteAllOwnerSet]);
          System.debug('mapAccShare **************** '+mapAccShare);
          List<AccountShare> DeleteListAccountShare  = new List<AccountShare>();
          if(mapAccShare != null && mapAccShare.size()> 0){
              for (AccountShare AccShareRec:mapAccShare){
                  if (DeleteAccountSetOwnerMap.containsKey(AccShareRec.AccountId)) {
                      if(DeleteAccountSetOwnerMap.get(AccShareRec.AccountId).contains(AccShareRec.UserOrGroupID)) {
                              DeleteListAccountShare.add(AccShareRec);
                      }
                  }
              }
          }

          System.debug('********* Delete AccountShare with Old Owner Ids *********');
          System.debug('********* DeleteListAccountShare: ' + DeleteListAccountShare);
          if(DeleteListAccountShare != null && DeleteListAccountShare.size()> 0){
              Database.DeleteResult[] drList = Database.delete(DeleteListAccountShare, false);
              for(Database.DeleteResult dr : drList) {
                  if (!dr.isSuccess()) {deletelistError.addAll(dr.getErrors()); } 
             }
             if(deletelistError != null && deletelistError.size()> 0){
               LogEventTriggerHandler.insertBatchLog(deletelistError, 'BatchAddChildAccountsAccessParentId', 'execute', 'AccountShare', 'Database.Delete_Failed');
             }
          }
      }
        
      System.debug('********* Upsert AccountShare with New Parent Owner Ids *********');
      if(listAccShareToUpsert != null && listAccShareToUpsert.size()> 0){
          Database.UpsertResult[] urList = Database.upsert(listAccShareToUpsert, false);
          for(Database.UpsertResult ur : urList) {
               if (!ur.isSuccess()) {   upsertlistError.addAll(ur.getErrors()); }
          }
          if(upsertlistError != null && upsertlistError.size()> 0){
              LogEventTriggerHandler.insertBatchLog(upsertlistError, 'BatchAddChildAccountsAccessParentId', 'execute', 'AccountShare', 'Database.Upsert_Failed');
          }
      } 
      System.debug('********* Update AccountShare with New Ultimate Parent Account and Ultimate Parent Account Owner Ids *********');
      if(listAccToUpdate != null && listAccToUpdate.size() > 0){
         Database.saveResult[] srList = Database.update(listAccToUpdate, false);
          for(Database.saveResult ur : srList){
               if(!ur.isSuccess()){
                   updatelistError.addAll(ur.getErrors());
                }
          }
          if(updatelistError != null && updatelistError.size()> 0){
              LogEventTriggerHandler.insertBatchLog(updatelistError, 'BatchAddChildAccountsAccessParentId', 'execute', 'Account', 'Database.Update_Failed');
          }    
      }
    }
    
   /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
       
         System.debug('from batchparentID parentIDs'+parentIds);
         Database.executeBatch(new BatchRSGAutomation(listAccToUpdate,oldAccount,parentIds,TriggeroperationType));
        
    }
}