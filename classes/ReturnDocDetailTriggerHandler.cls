public class ReturnDocDetailTriggerHandler{
    public static void updateSODocumentDetail(Return_Document_Detail__c returnDocDetailRec, Map<Id,Return_Document_Detail__c> oldMapTrigger){
        List<Document_Details__c> listDocDetails = new List<Document_Details__c>();
        Map<Id,Id> mapDocDetailToProduct = new Map<Id,Id>();
        
            Return_Order__c RORec = [SELECT Id,Original_SO_Number__c, Case__r.AccountId from Return_Order__c Where Id =: returnDocDetailRec.Return_Order__c];
            System.debug('RoRec **************** '+RORec);
            System.debug('Case__r.AccountId  *********** '+RORec.Case__r.AccountId);
            if(RORec.Original_SO_Number__c != null){
                listDocDetails = [SELECT Id,Product__c from Document_Details__c Where salesOrderNumber__c =: RORec.Original_SO_Number__c]; 
            }else{
                if(RORec.Case__r.AccountId <> NULL){
                    listDocDetails = [SELECT Id,Product__c,salesOrderNumber__c from Document_Details__c Where salesOrderNumber__r.Distributor__c =: RORec.Case__r.AccountId
                                        AND Product__c =: returnDocDetailRec.Return_Product__c ORDER BY CreatedDate DESC LIMIT 1];       
                }
            }
            System.debug('listDocDetails **************** '+listDocDetails);
            for(Document_Details__c ddRec : listDocDetails){
                mapDocDetailToProduct.put(ddRec.Product__c, ddRec.Id);
            }
            if(mapDocDetailToProduct != null && mapDocDetailToProduct.containsKey(returnDocDetailRec.Return_Product__c)){
                returnDocDetailRec.SO_Document_Detail__c = mapDocDetailToProduct.get(returnDocDetailRec.Return_Product__c);
            }
        
    }
}