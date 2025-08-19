/*******************************************************************************************
* @Name         SuggestedOrderHelper
* @Author       Sushma Manickam
* @Date         07/24/2020
* @Description  Update Distributor Retailer Link Id in Suggested Order
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Sushma          07/24/2020         Initial Creation
*******************************************************************************************/
public class SuggestedOrderHelper {
    /**************************************************************************************
    * @Description This method used to update Distributor Retailer Link field in Suggested Order
    * @Param   List of Suggested Order
    * @Return  Void
    **************************************************************************************/ 
    public static void UpdateDRL(List<Suggested_Order__c> SOList, Map<Id,Suggested_Order__c> oldMap, Boolean isUpdate)
    {
        Set<String> ExternalIdSet = new Set<String>();
        Map<String,Id> DRLMap = new Map<String,Id>();
        
        for(Suggested_Order__c so: SOList) {
            if(so.Customer__c != null && so.Distributor__c !=null) {  
                if((oldMap !=null && (oldMap.get(so.Id).Distributor__c != so.Distributor__c || oldMap.get(so.Id).Customer__c != so.Customer__c)) || isUpdate == false) {                    
                    ExternalIdSet.add(so.Distributor__c+'_'+so.Customer__c);
                }
            }
        }               
        if(ExternalIdSet.size() > 0) {
            List<Distributor_Retailer_Link__c>  DRlist = [SELECT id,External_ID__c FROM Distributor_Retailer_Link__c WHERE External_ID__c IN :ExternalIdSet];
            for(Distributor_Retailer_Link__c DR:DRlist) {
                if(DR.External_ID__c != null) {
                    DRLMap.put(DR.External_ID__c,DR.id);                      
                }
                
            }
            if(DRLMap.size() > 0) {
                for(Suggested_Order__c s: SOList) {       
                    if((oldMap !=null && (oldMap.get(s.Id).Distributor__c != s.Distributor__c || oldMap.get(s.Id).Customer__c != s.Customer__c)) || isUpdate == false) {
                        if(DRLMap.containsKey(s.Distributor__c+'_'+s.Customer__c)) {
                            s.Distributor_Retailer_Link__c =  DRLMap.get(s.Distributor__c+'_'+s.Customer__c);
                        }   
                    }  
                }    
            }                       
        }
    }
}