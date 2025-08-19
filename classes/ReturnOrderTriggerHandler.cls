public class ReturnOrderTriggerHandler {
    public static void updateSODocumentDetail(Return_Order__c  returnOrderRec, Map<Id,Return_Order__c> oldMapTrigger, Boolean isUpdate, Boolean isBefore){
       List<Return_Document_Detail__c> returnDocDetailToUpdate = new List<Return_Document_Detail__c>();
       Map<Id,Id> mapDocDetailTOProduct = new Map<Id,Id>();
        if(returnOrderRec.Return_Document_Details_Num__c > 0 && returnOrderRec.Original_SO_Number__c <> oldMapTrigger.get(returnOrderRec.id).Original_SO_Number__c){
             if(returnOrderRec.Original_SO_Number__c <> NULL){
                 List<Document_Details__c> listDocDetails = [SELECT Id,Product__c from Document_Details__c WHERE salesOrderNumber__c =: returnOrderRec.Original_SO_Number__c];
                 for(Document_Details__c ddRec : listDocDetails){
                     mapDocDetailTOProduct.put(ddRec.Product__c, ddRec.id);
                    }
                }
                List<Return_Document_Detail__c> listReturnDocDetails = [SELECT Id, Name,Return_Product__c,SO_Document_Detail__c from Return_Document_Detail__c
                                                                        WHERE Return_Order__c = : returnOrderRec.id];
                for(Return_Document_Detail__c returnDDRec : listReturnDocDetails){
                    if(mapDocDetailTOProduct <> NULL && mapDocDetailTOProduct.containsKey(returnDDRec.Return_Product__c)){
                        returnDDRec.SO_Document_Detail__c = mapDocDetailTOProduct.get(returnDDRec.Return_Product__c);
                    }else{
                        System.debug('Entering into else loopp ************* ');
                        returnDDRec.SO_Document_Detail__c = null;
                    }
                    returnDocDetailToUpdate.add(returnDDRec);  
                }
                if(returnDocDetailToUpdate != null && returnDocDetailToUpdate.size()>0){
                    update returnDocDetailToUpdate;
                }
            }       
    }
}