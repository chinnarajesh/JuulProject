public with sharing class OmniScriptFromApexLWC {
  @AuraEnabled
  public static List<StoreProduct__c> getMissionChildData(String missionId) {
    List<StoreProduct__c> storeProducts = new List<StoreProduct__c>();
    try {
            if (String.isBlank(missionId)) {
                throw new IllegalArgumentException('Mission Id is required');
            }

            storeProducts = [
                SELECT Id, Name, ActualMSRP__c,Active__c
                FROM StoreProduct__c
                WHERE InStoreLocationId__c IN (
                    SELECT InStoreLocationId__c FROM Mission__c WHERE Id = :missionId
                )
            ];
        } catch (Exception e) {
            System.debug('Error in getStoreProductsByMissionId: ' + e.getMessage());
            throw new AuraHandledException('Failed to fetch store products: ' + e.getMessage());
        }
        
        return storeProducts;
    }
}