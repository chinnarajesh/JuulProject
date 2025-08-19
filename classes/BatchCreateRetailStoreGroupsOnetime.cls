/*******************************************************************************************
* @Name         BatchCreateRetailStoreGroupsOnetime
* @Author       Srikanth <Srikanth.Bumhyavaram@juul.com>
* @Date         06/27/2020
* @Group        Sales Ops
* @Description  Onetime batch job - Reatil Store Groups created based on direct child Accounts 
*               of Ultimate Parent Account,  
*               Source Accounts to filter using map input variable 'overrideQuery'
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Srikanth          06/27/2020         Initial Creation
*******************************************************************************************/
global class BatchCreateRetailStoreGroupsOnetime implements Database.Batchable<sObject>, Database.Stateful {
    global String InputStringUltParentIds;
    global List<String> UltParentIdsList;
    String AdminEmailIds; 
    Integer TotalRSGInsert=0, TotalARSGInsert=0, TotalRSGErrors=0, TotalARSGErrors=0, TotalARSGParentNotFound=0,TotalRSGRecords=0,TotalARSGRecords=0; 
    global BatchCreateRetailStoreGroupsOnetime(String InputStringUltParentIds){
       this.InputStringUltParentIds = InputStringUltParentIds;
       UltParentIdsList = String.valueOf(InputStringUltParentIds).split(',');
       MSASalesDataProcessBatch__c MSACustomSetting = MSASalesDataProcessBatch__c.getinstance('MSASalesDataProcessBatch');
       AdminEmailIds   = MSACustomSetting.AdminEmailIds__c; 
    }
/**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = ''; 
        if (UltParentIdsList.size() >0) {
              query = 'Select Id, Name, Type, Ultimate_Parent_Account__c from account ';
              query += 'where shippingcountry = \'US\' and Type =\'HQ\' and recordtype.name in (\'Regional Chain Retailer\',\'Independent Retailer\',\'Chain Retail\') '; 
              query += 'and ParentId IN :UltParentIdsList ';
        } else { 
              query = 'select Id from Account Limit 0';
        }
        system.debug('Query##'+query); 
        return Database.getQueryLocator(query);
     }
   /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Account>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Account> listAcc) {
      List<Database.Error> insertlistRSGError  = new List<Database.Error>();
      List<Database.Error> insertlistARSGError = new List<Database.Error>();
      Map<Id, Id> mapAccountId2RSGId = new Map<Id, Id>();
        
      list<RetailLocationGroup__c> ListRSG = new list<RetailLocationGroup__c>();
      RetailLocationGroup__c NewRSG;
      for(Account acc : listAcc){
          NewRSG = new RetailLocationGroup__c();
          NewRSG.Name                 = acc.Name + ' RSG';
          NewRSG.AccountId__c         = acc.Id;
          NewRSG.UltimateParentId__c  = acc.Ultimate_Parent_Account__c;
          NewRSG.Description__c       = 'RSG created by batch job on' + system.today().format();
          ListRSG.add(NewRSG);
          TotalRSGRecords++;
      }
      System.debug('********* Insert RSG with New Zone Accounts *********');
      if(ListRSG != null && ListRSG.size()> 0) {
               List<Database.SaveResult> RSGSaveResults = Database.insert(ListRSG, false);
               for(Integer i=0; i<RSGSaveResults.size(); i++){
                   Database.SaveResult saveResult = RSGSaveResults[i];
                   if (saveResult.isSuccess()){
                       ListRSG[i].Id = saveResult.getId(); 
                       mapAccountId2RSGId.put(ListRSG[i].AccountId__c,saveResult.getId());
                       TotalRSGInsert++;
                   }
                   else{
                       insertlistRSGError.addAll(saveResult.getErrors());
                       TotalRSGErrors++;
                   }
               }
               if(insertlistRSGError != null && insertlistRSGError.size()> 0){
                  LogEventTriggerHandler.insertBatchLog(insertlistRSGError, 'BatchCreateRetailStoreGroupsOnetime', 'execute', 'RetailLocationGroup__c', 'Database.Insert_Failed');
               }
           }
        if (mapAccountId2RSGId != null && mapAccountId2RSGId.size()> 0){
        Id RSGId = null; 
        list< AccountRetailStoreGroup__c> listARSG = new list< AccountRetailStoreGroup__c>();
        AccountRetailStoreGroup__c ARSG = new AccountRetailStoreGroup__c();    
        for(account Door : [select Id, Name, Type, Ultimate_Parent_Account__c,
                            ParentId, Parent.ParentId, Parent.Parent.ParentId,Parent.Parent.Parent.ParentId 
                            from account where shippingcountry = 'US' and
                            recordtype.name in ('Regional Chain Retailer','Independent Retailer','Chain Retail') and 
                            Type in ('Regional Chain Retailer','Independent Retailer','National Chain Retailer','Chain') and 
                            (ParentId IN :mapAccountId2RSGId.KeySet() OR
                             Parent.ParentId IN :mapAccountId2RSGId.KeySet() OR 
                             Parent.Parent.ParentId IN :mapAccountId2RSGId.KeySet() OR
                             Parent.Parent.Parent.ParentId IN :mapAccountId2RSGId.KeySet() OR
                             Parent.Parent.Parent.Parent.ParentId IN :mapAccountId2RSGId.KeySet())]) { 
              RSGId = null;
              TotalARSGRecords++;
              if(Door.ParentId != null && mapAccountId2RSGId.containsKey(Door.ParentId)){
                  RSGId = mapAccountId2RSGId.get(Door.ParentId);
              } else if(Door.Parent.ParentId != null && mapAccountId2RSGId.containsKey(Door.Parent.ParentId)){
                  RSGId = mapAccountId2RSGId.get(Door.Parent.ParentId);
              } else if(Door.Parent.Parent.ParentId != null && mapAccountId2RSGId.containsKey(Door.Parent.Parent.ParentId)){
                  RSGId = mapAccountId2RSGId.get(Door.Parent.Parent.ParentId);
              } else if(Door.Parent.Parent.Parent.ParentId != null && mapAccountId2RSGId.containsKey(Door.Parent.Parent.Parent.ParentId)){
                  RSGId = mapAccountId2RSGId.get(Door.Parent.Parent.Parent.ParentId);
              } else { TotalARSGParentNotFound++;}
                                 
              
              if (RSGId != null) {
                    ARSG = new AccountRetailStoreGroup__c();
                    ARSG.RetailStoreGroupId__c = RSGId;
                    ARSG.AccountId__c          = Door.Id; 
                  listARSG.add(ARSG);
              }
           }
           
           System.debug('********* Insert ARSG with Door Accounts *********');
            if(listARSG != null && listARSG.size() > 0){
                Database.saveResult[] ChildList = Database.insert(listARSG, false);
                for(Database.saveResult ir : ChildList){
                    if(!ir.isSuccess()){
                        insertlistARSGError.addAll(ir.getErrors());
                        TotalARSGErrors++;
                    }
                    else { TotalARSGInsert++;}
                }
                if(insertlistARSGError != null && insertlistARSGError.size()> 0){
                    LogEventTriggerHandler.insertBatchLog(insertlistARSGError, 'BatchCreateRetailStoreGroupsOnetime', 'execute', 'AccountRetailStoreGroup__c', 'Database.Insert_Failed');
                }    
            }
           
        }
    }
   /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
 
        if(!String.isEmpty(AdminEmailIds)){
            try{                
                String[] toAddresses= AdminEmailIds.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,CreatedDate, 
                                  CompletedDate, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String ElapsedTime='';
                datetime start = a.CreatedDate;
                datetime later = a.CompletedDate;
                decimal millisecs = decimal.valueOf(later.getTime() - start.getTime());
                decimal dDays = millisecs/1000/60/60/24;
                system.debug('dDays: ' +dDays);
                integer iDays = integer.valueOF(math.floor(dDays));
                decimal remainderDays = dDays- iDays;
                decimal dHours = remainderDays * 24;
                integer iHours = integer.valueOf(math.floor(dHours));
                decimal remainderHours = dHours - iHours;
                decimal dMinutes = remainderHours * 60;
                integer iMinutes = integer.valueOf(math.floor(dMinutes));
                decimal remainderMinutes = dMinutes - iMinutes;
                decimal dSeconds = remainderMinutes * 60;
                integer iSeconds = integer.valueOf(math.floor(dSeconds));
                decimal remainderSeconds = dSeconds - iSeconds;
                if(iDays >0) { ElapsedTime += iDays + ' Days ';  }
                if(iDays >0 || iHours >0) {ElapsedTime += iHours + ' Hrs '; }
                if(iHours >0 || iMinutes >0) {ElapsedTime += iMinutes + ' Min '; }  
                ElapsedTime += iSeconds + ' Sec';
                system.debug('Days: ' + iDays+' - '+'Hours: ' + iHours+' - '+'Minutes: ' + iMinutes+' - '+'Seconds: ' + iSeconds);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job BatchCreateRetailStoreGroupsOnetime ' + a.Status);
                mail.setPlainTextBody(
                   '  The batch Apex job BatchCreateRetailStoreGroupsOnetime processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + 
                    '\n The batch job started ' + a.CreatedDate + ' and completed '+ a.CompletedDate + ' with total elapsed time ' + ElapsedTime + '.' +
                    '\n **************** Input parameters provided **************** ' +
                    '\n InputStringUltParentIds(Required): ' + InputStringUltParentIds   + 
                    '\n ********** Processed record & Error counts **************** ' +
                    '\n Total RSG Records for Insert: ' + TotalRSGRecords             +
                    ',  Total RSG Successful Inserts: ' + TotalRSGInsert               +
                    ',  Total RSG Error in Insert: ' + TotalRSGErrors                 +  
                    '\n Total ARSG Records for Insert: ' + TotalARSGRecords           +
                    ',  Total ARSG Successful Inserts: ' + TotalARSGInsert             +
                    ',  Total ARSG Error in Insert: ' + TotalARSGErrors               +
                    ',  Total ARSG Error ParentNotFound: ' + TotalARSGParentNotFound  +
                    '\n *********************************************************** ' + '\n');

               system.debug('Email :'+ mail); 
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        }         
    }
}