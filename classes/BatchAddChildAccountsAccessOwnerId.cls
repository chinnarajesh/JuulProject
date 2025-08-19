/*******************************************************************************************
* @Name         BatchAddChildAccountsAccessOwnerId
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         12/17/2019
* @Group        Sales Ops
* @Description  Based on an Account Owner Id changes, this batch job will enable  
*               the apex sharing to all the child Accounts.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Anil/Srikanth      12/17/2019         Initial Creation
*******************************************************************************************/
global class BatchAddChildAccountsAccessOwnerId implements Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> SourceAccountIds;
    global Map<Id,Id> resultNewMap, resultOldMap;
    global String StrRowCause = Schema.AccountShare.RowCause.Manual;
    global ChildAccountShare__c settingsConst;
    global List<String> shippingCountryList;
    global BatchAddChildAccountsAccessOwnerId(Map<Id,Id> resultNewMap, Map<Id,Id> resultOldMap){
       this.SourceAccountIds  = resultNewMap.keySet();
       this.resultNewMap = resultNewMap;
       this.resultOldMap = resultOldMap;   
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
               System.debug('The query in Batch_EnableChildAccountsAcess ***************** '+query);
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
      List<Account> listAccToUpdate = new List<Account>();
      Account AccToUpdate;
      Set<Id> SourceOldOwnerIdSet = new Set<Id>(); 
      Set<Id> SourceNewOwnerIdSet = new Set<Id>();
      set<Id> DeleteOwnerSet;
      set<Id> DeleteAllOwnerSet = new Set<Id>();
      Map<Id, set<Id>> DeleteAccountSetOwnerMap = new Map<Id, set<Id>>();
      List<Database.Error> deletelistError = new List<Database.Error>();
      List<Database.Error> upsertlistError = new List<Database.Error>();
      List<Database.Error> updatelistError     = new List<Database.Error>();
      Id ultiParentId, ultiParentOwnerId;
      //STEP1: i)   Get Old and New OwnerIds for every Child Account of Source Accounts
      //       ii)  Exclude Old Owner if exists in Parent hierarchy as Parent Owner
      //       iii) Add Old Owner to AccountShare if one of the Parents has same Old Owner
      //       iv)  Add New Owners to Child Accounts
      
      for(Account acc : listAcc){
          System.debug('************* Get Old and New OwnerIds for every Child Account of Source Accounts *************'); 
          SourceOldOwnerIdSet = new Set<Id>();
          SourceNewOwnerIdSet = new Set<Id>();
          if(resultNewMap.containsKey(acc.Id)){
              SourceOldOwnerIdSet.add(resultOldMap.get(acc.Id));
              SourceNewOwnerIdSet.add(resultNewMap.get(acc.Id));
          } 
          if(acc.ParentId != null && resultNewMap.containsKey(acc.ParentId)){
              SourceOldOwnerIdSet.add(resultOldMap.get(acc.ParentId));
              SourceNewOwnerIdSet.add(resultNewMap.get(acc.ParentId));
          } 
          if(acc.Parent.ParentId != null && resultNewMap.containsKey(acc.Parent.ParentId)){
              SourceOldOwnerIdSet.add(resultOldMap.get(acc.Parent.ParentId));
              SourceNewOwnerIdSet.add(resultNewMap.get(acc.Parent.ParentId));
          } 
          if(acc.Parent.Parent.ParentId != null && resultNewMap.containsKey(acc.Parent.Parent.ParentId)){
              SourceOldOwnerIdSet.add(resultOldMap.get(acc.Parent.Parent.ParentId));
              SourceNewOwnerIdSet.add(resultNewMap.get(acc.Parent.Parent.ParentId));
          } 
          if(acc.Parent.Parent.Parent.ParentId != null && resultNewMap.containsKey(acc.Parent.Parent.Parent.ParentId)){
              SourceOldOwnerIdSet.add(resultOldMap.get(acc.Parent.Parent.Parent.ParentId));
              SourceNewOwnerIdSet.add(resultNewMap.get(acc.Parent.Parent.Parent.ParentId));
          }

         // System.debug('child Account Id    ************* ' + acc.Id); 
         // System.debug('SourceOldOwnerIdSet ************* ' + SourceOldOwnerIdSet); 
         // System.debug('SourceNewOwnerIdSet ************* ' + SourceNewOwnerIdSet);

          DeleteOwnerSet = new Set<Id>();
          for(Id oldOwnerId:SourceOldOwnerIdSet) {
             System.debug('************* Exclude Old Owner if exists in Parent hierarchy as Parent Owner *************'); 
             if(acc.OwnerId <> oldOwnerId                        &&  (!resultNewMap.containsKey(acc.Id))            &&
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

          System.debug('************* Add Old Owner to AccountShare if one of the Parents has same Old Owner *************');
          if(resultNewMap.containsKey(acc.Id)) {
              if ((acc.Parent.OwnerId != null                      && acc.Parent.OwnerId == resultOldMap.get(acc.Id))               || 
                  (acc.Parent.Parent.OwnerId != null               && acc.Parent.Parent.OwnerId == resultOldMap.get(acc.Id))        || 
                  (acc.Parent.Parent.Parent.OwnerId != null        && acc.Parent.Parent.Parent.OwnerId == resultOldMap.get(acc.Id)) || 
                  (acc.Parent.Parent.Parent.Parent.OwnerId != null && acc.Parent.Parent.Parent.Parent.OwnerId == resultOldMap.get(acc.Id))) {
                      accShare = new AccountShare(AccountId = acc.id, 
                                                  AccountAccessLevel = 'Read', 
                                                  OpportunityAccessLevel = 'Read',  
                                                  CaseAccessLevel = 'Read', 
                                                  UserOrGroupId = resultOldMap.get(acc.Id),
                                                  RowCause =  StrRowCause);
                      listAccShareToUpsert.add(accShare);
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
          }else{
              ultiParentId      = null;
              ultiParentOwnerId = null;
          }
          AccToUpdate = new Account();
          AccToUpdate.Id  = acc.Id;
          AccToUpdate.Ultimate_Parent_Account__c = ultiParentId;
          AccToUpdate.Ultimate_Parent_Account_Owner__c = ultiParentOwnerId;
          listAccToUpdate.add(AccToUpdate);

         System.debug('************* Add New Owners to Child Accounts *************');  
         for(Id newOwnerId:SourceNewOwnerIdSet) {
             if(acc.OwnerId <> newOwnerId) {
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
      
      //STEP2: i)   Prepare AccountShare data to delete Old Parent Owner Ids
      //       ii)  Delete AccountShare with Old Owner Ids
      //       ii)  Upsert AccountShare with New Parent Owner Ids
      
      System.debug('DeleteAccountIds ************** '+DeleteAccountSetOwnerMap.keySet());
      System.debug('DeleteAccountSetOwnerMap.Values() ***************** '+DeleteAccountSetOwnerMap.Values());
      System.debug('listAccShareToUpsert ************** '+listAccShareToUpsert);
      
      System.debug('********* Prepare AccountShare data to delete Old Parent Owner Ids *********'); 
      if(DeleteAccountSetOwnerMap != null && DeleteAccountSetOwnerMap.size()> 0){
          List<AccountShare> mapAccShare = new List<AccountShare>([Select Id, AccountId, UserOrGroupID,UserOrGroup.Name From AccountShare Where RowCause = :StrRowCause AND AccountId IN :DeleteAccountSetOwnerMap.keySet() AND UserOrGroupID IN :DeleteAllOwnerSet]);
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
          if(DeleteListAccountShare != null && DeleteListAccountShare.size()> 0){
              Database.DeleteResult[] drList = Database.delete(DeleteListAccountShare, false);
              for(Database.DeleteResult dr : drList) {
                if (!dr.isSuccess()) { deletelistError.addAll(dr.getErrors()); }
              } 
              if(deletelistError != null && deletelistError.size()> 0){
                  LogEventTriggerHandler.insertBatchLog(deletelistError, 'BatchAddChildAccountsAccessOwnerId', 'execute', 'AccountShare', 'Database.Delete_Failed');
              }
          }
      }
      
      System.debug('********* Upsert AccountShare with New Parent Owner Ids *********');
      if(listAccShareToUpsert != null && listAccShareToUpsert.size()> 0){
          Database.UpsertResult[] urList = Database.upsert(listAccShareToUpsert, false);
          for(Database.UpsertResult ur : urList) {
              if(!ur.isSuccess()) { upsertlistError.addAll(ur.getErrors()); }
          }
          if(upsertlistError != null && upsertlistError.size()> 0){
              LogEventTriggerHandler.insertBatchLog(upsertlistError, 'BatchAddChildAccountsAccessOwnerId', 'execute', 'AccountShare', 'Database.Upsert_Failed');
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
              LogEventTriggerHandler.insertBatchLog(updatelistError, 'BatchAddChildAccountsAccessOwnerId', 'execute', 'Account', 'Database.Update_Failed');
          }    
      }
    }
   /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
    
    }
}