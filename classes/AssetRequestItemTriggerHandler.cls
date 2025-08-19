public class AssetRequestItemTriggerHandler{
    public static void updateStatusOnAsset(List<Asset_Request_Iteam__c> listAssetReqItem, Map<Id,Asset_Request_Iteam__c> oldMapTrigger){
        Set<Id> assetIds = new Set<Id>();
        List<Asset> listAssetToUpdate = new List<Asset>();
        Map<Id,Asset> assetToUpdateMap = new Map<Id, Asset>();
        for(Asset_Request_Iteam__c assetReqRec : listAssetReqItem){
           if(assetReqRec.Retailer_Asset_Id__c <> NULL && oldMapTrigger.get(assetReqRec.id).Status__c <> assetReqRec.Status__c && 
               (assetReqRec.Status__c == 'Shipped' || assetReqRec.Status__c == 'Delivered' || assetReqRec.Status__c == 'Installed')){
                   assetIds.add(assetReqRec.Retailer_Asset_Id__c);
                   //Field_B2B_Goods_Request__c
           }
        }
       System.debug('assetIdsassetIds ***************** '+assetIds);
        if(assetIds != null && assetIds.size()>0){
            assetToUpdateMap = new Map<Id, Asset>([Select Id, Status from Asset where Id IN : assetIds]);
        }
        System.debug('assetToUpdateMap ***************** '+assetToUpdateMap);
        if(assetToUpdateMap != null && assetToUpdateMap.size()>0){
            for(Asset_Request_Iteam__c assetReqRec : listAssetReqItem){
                if(assetToUpdateMap.containsKey(assetReqRec.Retailer_Asset_Id__c)){
                    if(assetReqRec.Field_B2B_Goods_Request_BDF__c == true){
                       assetToUpdateMap.get(assetReqRec.Retailer_Asset_Id__c).Status = assetReqRec.Status__c;
                       listAssetToUpdate.add(assetToUpdateMap.get(assetReqRec.Retailer_Asset_Id__c));
                    }
                }
            }
        }
        System.debug('listAssetToUpdate ***************** '+listAssetToUpdate);
        if(listAssetToUpdate != null && listAssetToUpdate.size()>0){
            List<Database.SaveResult> updateAssetResults = Database.Update(listAssetToUpdate, false);
            List<Database.Error> listError = new List<Database.Error>();
             for(Integer index = 0, size = updateAssetResults.size(); index < size; index++) {
               if(!updateAssetResults[index].isSuccess()){
                   listError.addAll(updateAssetResults[index].getErrors());
               }
           } 
            LogEventTriggerHandler.insertBatchLog(listError, 'AssetRequestItemTriggerHandler', 'updateStatusOnAsset', 'Asset', 'Database.Update_Failed');
                
        }
    }
}