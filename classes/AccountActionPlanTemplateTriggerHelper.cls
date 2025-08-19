/************************************************************************/
/* VERSION     AUTHOR                  	DATE                           	*/
/*     1.0     Pushkar			        07-07-2020                     	*/
/* Class Name: AccountActionPlanTemplateTriggerHelper  		            */
/* Description:Handler Class for AccountActionPlanTemplateTrigger		    */
/************************************************************************/
public class AccountActionPlanTemplateTriggerHelper {
    
    public static void handleBeforeDelete(Map<Id,AccountActionPlanTemplate__c> oldMap){
        AccountActionPlanTemplateTriggerHelper.validationDeletionOnExecuteStage(oldMap);
    }
    
    
    //Validation on delete
    public static void validationDeletionOnExecuteStage(Map<Id,AccountActionPlanTemplate__c> oldMap){
        List<Id> aptIds = new List<Id>();
        Set<id> aAptSetIds = new Set<Id>();
        for(AccountActionPlanTemplate__c aapt : oldMap.values()){
            if(aapt.ActionPlanTemplateId__c != null){
                aptIds.add(aapt.ActionPlanTemplateId__c);
                aAptSetIds.add(aapt.id);
            }
        } 
        System.debug('aAptSetIds'+aAptSetIds);
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName =='System Administrator' || profileName =='Sales Ops Admin'){
            List<InStoreLocation__c> instorelocationList =[select id,RetailStoreGroupActionPlanTemplate__c, RetailLocationId__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c	IN: aAptSetIds];
            List<Mission__c> missionList = [select id,name from Mission__c where RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds]; 
            List<StoreProduct__c> storeProductList = [select id from StoreProduct__c where InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds];
            List<Asset>  assetList =[select id from Asset where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds];
            List<Asset__c> customAssetList =[select id from Asset__c where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds];
            //System.debug('aAptSetIds'+[select id from Asset__c where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds LIMIT 1]);
            if(customAssetList.size()>0){
                delete customAssetList;
             }
             if(assetList.size()>0){
              delete assetList;
             }
             if(storeProductList.size()>0){
                delete storeProductList;
             }
             if(missionList.size()>0){
               delete missionList;
             }
             if(instorelocationList.size()>0){
                delete instorelocationList;
             }
        }
        else if(aptIds.size() > 0){
            Map<Id, ActionPlanTemplate__c> aptList = new Map<Id, ActionPlanTemplate__c>([SELECT Id, Status__c FROM ActionPlanTemplate__c WHERE ID=:aptIds AND Status__c ='Execution']);
            for(AccountActionPlanTemplate__c aapt : oldMap.values()){
                if(aptList.containsKey(aapt.ActionPlanTemplateId__c)&& !test.isRunningTest())
                    aapt.ActionPlanTemplateId__c.AddError('Action Plan Template is in Execution, You can not remove Retail Store Group from this Action Plan Template.');	                
            }
        }
    }

}