/*******************************************************************************************
* @Name         JuulChainRetail_FreeGoodsBatch
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         05/10/2019
* @Group        Sales Ops
* @Description  A batch job will create Free Goods and Asset Line Items for Marketing Assets from the Assets.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          05/10/2019            Initial Creation
*******************************************************************************************/
global class JuulChainRetail_FreeGoodsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
   /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
    List<Asset> listAssetsToUpdate = new List<Asset>();
    Map<String, String> mapInputs =  new Map<String, String>();
     /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
    global JuulChainRetail_FreeGoodsBatch(Map<String, String> mapInputs){
        this.mapInputs = mapInputs;
    }
    global JuulChainRetail_FreeGoodsBatch(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
      String overrideQuery = '';
      String query = 'SELECT Id, Asset_Request_Item_Id__c, Product2Id, AccountId, Account.Name, Account.Phone, Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,Account.ShippingCountry,Account.ShippingPostalCode,Quantity FROM Asset ';
             query += 'WHERE ';
             query += 'AccountId != NULL';
             query += ' AND ';
             query += 'Product2.Family =\'Marketing Assets\'';
             query += ' AND ';
             query += 'Asset_Request_Item_Id__c = null';
             query += ' AND ';
             query += 'BDF_Flow__c = true';
             query += ' AND ';
             query += 'Quantity > 0';
             query += ' AND ';
             query += '(';
             query += 'Account.RecordType.Name=\'Regional Chain Retailer\' OR Account.RecordType.Name=\'Chain Retail\' OR Account.RecordType.Name=\'Independent Retailer\'';
             query += ')';
             query += ' AND Status = \'Approved\'';
      if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND '+mapInputs.get('overrideQuery');
       }
       query += overrideQuery; 
       System.debug('query ***************** '+query);
       return Database.getQueryLocator(query);
    }
   
   /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Asset>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext bc, List<Asset> listAssets) {
        System.debug('List of Assets Processing **************' +listAssets);
        Set<Id> AccIds = new Set<Id>();
        Set<Id> insertedFreeGoodIds = new Set<Id>();
        Set<Id> insertedAssetItemIds = new Set<Id>();
        List<Field_B2B_Goods_Request__c> listFreeGoodToInsert = new List<Field_B2B_Goods_Request__c>();
        Map<Id, List<Asset>> mapAccountToAsset = new Map<Id, List<Asset>>();
        List<Asset_Request_Iteam__c> listAssetItemsToInsert = new List<Asset_Request_Iteam__c>();
        Map<Id,List<String>> mapAccToShippingAddress = new Map<Id, List<String>>();
        for(Asset assetRec : listAssets){
            AccIds.add(assetRec.AccountId);
            mapAccToShippingAddress.put(assetRec.AccountId, new List<String>{assetRec.Account.ShippingStreet, assetRec.Account.ShippingCity,
                                                                             assetRec.Account.ShippingState,assetRec.Account.ShippingCountry,
                                                                             assetRec.Account.ShippingPostalCode,assetRec.Account.Phone,
                                                                             assetRec.Account.Name});
            if(mapAccountToAsset !=null && mapAccountToAsset.containsKey(assetRec.AccountId)){
                List<Asset> assetList = mapAccountToAsset.get(assetRec.AccountId);
                assetList.add(assetRec);
                mapAccountToAsset.put(assetRec.AccountId, assetList);
            }else{
                mapAccountToAsset.put(assetRec.AccountId, new List<Asset>{assetRec});
            }
         }
         for(Id accountId : AccIds){
             Field_B2B_Goods_Request__c freeGoodRec = new Field_B2B_Goods_Request__c();
             freeGoodRec.RecordTypeId = Schema.SObjectType.Field_B2B_Goods_Request__c.getRecordTypeInfosByName().get('Marketing Assets').getRecordTypeId();
             freeGoodRec.Account__c = accountId;
             freeGoodRec.Status__c = 'Approved';
             freeGoodRec.BDF__c = true;
             freeGoodRec.Shipping_Street_1__c = mapAccToShippingAddress.get(accountId)[0];
             freeGoodRec.Shipping_City__c = mapAccToShippingAddress.get(accountId)[1];
             freeGoodRec.Shipping_State__c = mapAccToShippingAddress.get(accountId)[2];
             freeGoodRec.Shipping_Country__c = mapAccToShippingAddress.get(accountId)[3];
             freeGoodRec.Shipping_Postal_Code__c = mapAccToShippingAddress.get(accountId)[4];
             freeGoodRec.Phone__c = mapAccToShippingAddress.get(accountId)[5];
             freeGoodRec.Attn_to__c = mapAccToShippingAddress.get(accountId)[6];
             listFreeGoodToInsert.add(freeGoodRec);
         }
         System.debug('listFreeGoodToInsert size is **********' +listFreeGoodToInsert.size());
        if(listFreeGoodToInsert != null && listFreeGoodToInsert.size()>0){
            Database.SaveResult[] srList = Database.insert(listFreeGoodToInsert, false);
            List<Database.Error> listError = new List<Database.Error>();
             for(Integer index = 0, size = srList.size(); index < size; index++) {
               if(srList[index].isSuccess()) {
                     insertedFreeGoodIds.add(srList[index].getId());   
                }
                else{
                    listError.addAll(srList[index].getErrors());
                }
            }
           LogEventTriggerHandler.insertBatchLog(listError, 'JuulChainRetail_FreeGoodsBatch', 'execute', 'Asset_Request_Iteam__c', 'Database.Insert_Failed');   
        }
        System.debug('insertedFreeGoodIds *************** '+insertedFreeGoodIds);
        for(Field_B2B_Goods_Request__c fieldB2BRec : listFreeGoodToInsert){
            if(insertedFreeGoodIds <> NULL && insertedFreeGoodIds.contains(fieldB2BRec.id)){
             if(mapAccountToAsset <> NULL && mapAccountToAsset.containsKey(fieldB2BRec.Account__c)){
                 for(Asset aRec : mapAccountToAsset.get(fieldB2BRec.Account__c)){
                     Asset_Request_Iteam__c assetReqItem = new Asset_Request_Iteam__c();
                     assetReqItem.Status__c = 'Requested';
                     assetReqItem.Asset__c = aRec.Product2Id;
                     assetReqItem.Quantity__c = aRec.Quantity;
                     assetReqItem.Field_B2B_Goods_Request__c = fieldB2BRec.id;
                     assetReqItem.Retailer_Asset_Id__c = aRec.id;
                     listAssetItemsToInsert.add(assetReqItem);
                  }
               }
           }        
        }
        System.debug('listAssetItemsToInsert size is ****************** '+listAssetItemsToInsert.size());
        if(listAssetItemsToInsert != null && listAssetItemsToInsert.size()>0){
             Database.SaveResult[] srList1 = Database.insert(listAssetItemsToInsert, false);
             List<Database.Error> listError = new List<Database.Error>();
              for(Integer index = 0, size = srList1.size(); index < size; index++) {
               if(srList1[index].isSuccess()){
                   Asset assetToUpdate = new Asset();
                   assetToUpdate.Id = listAssetItemsToInsert[index].Retailer_Asset_Id__c;
                   assetToUpdate.Asset_Request_Item_Id__c = srList1[index].getId();
                   listAssetsToUpdate.add(assetToUpdate);
               }else{
                     listError.addAll(srList1[index].getErrors());
               }
           }
          System.debug('listAssetsToUpdate size is_Execute Method ****************** '+listAssetsToUpdate); 
          LogEventTriggerHandler.insertBatchLog(listError, 'JuulChainRetail_FreeGoodsBatch', 'execute', 'Asset_Request_Iteam__c', 'Database.Insert_Failed');
        } 
     }   
   /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext bc){
    // execute any post-processing operations
     System.debug('listAssetsToUpdate size is_Finish Method ****************** '+listAssetsToUpdate);
         if(listAssetsToUpdate != null && listAssetsToUpdate.size()>0){
             List<Database.SaveResult> updateAssetResults = Database.Update(listAssetsToUpdate, false);
             List<Database.Error> listError = new List<Database.Error>();
             for(Integer index = 0, size = updateAssetResults.size(); index < size; index++) {
               if(!updateAssetResults[index].isSuccess()){
                 //  LogEventTriggerHandler.insertBatchLog(updateAssetResults[index].getErrors(), 'JuulChainRetail_FreeGoodsBatch', 'execute', 'Asset', 'Database.Update_Failed'));
                 listError.addAll(updateAssetResults[index].getErrors());
               }
           }
         LogEventTriggerHandler.insertBatchLog(listError, 'JuulChainRetail_FreeGoodsBatch', 'execute', 'Asset_Request_Iteam__c', 'Database.Insert_Failed');  
       }  
    }
}