/*******************************************************************************************
* @Name         DocumentDetailTriggerHandler
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         07/17/2019
* @Group        Sales Ops
* @Description  Handler class for DocumentDetailTrigger Apex Trigger. 
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          07/17/2019            Initial Creation
*******************************************************************************************/
public class DocumentDetailTriggerHandler{
    /*
    JIRA Ticket Reference : https://juullabs.atlassian.net/browse/SO-1514
    This method will be used to update Total Quantity which is Pod Pack Size * Quantity
    And for mutipack, it will update Total Flavor Family Quantity which is same as quantity, assuming mutipack contains 1 quantity of each flavor. 
    */            
    public static void updateTotalQuantity(List<Document_Details__c> newTriggerList, Map<Id,Document_Details__c> oldTriggerMap,  System.TriggerOperation triggerEvent){
        switch on triggerEvent {
            when BEFORE_INSERT {
               for(Document_Details__c docDetailRec : newTriggerList){
                 if(docDetailRec.Pod_Pack_Size__c <> NULL && docDetailRec.Quantity__c <> NULL){
                     if(docDetailRec.Flavor_Family__c <> NULL && docDetailRec.Flavor_Family__c == 'Multipack'){
                          docDetailRec.TotalQuantity__c =  Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;
                          docDetailRec.Total_Flavor_Family_Quantity__c = docDetailRec.Quantity__c;  
                     }else{
                         docDetailRec.TotalQuantity__c =  Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;
                         docDetailRec.Total_Flavor_Family_Quantity__c = Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;  
                     }
                  }
               }
            }
            when BEFORE_UPDATE{
                for(Document_Details__c docDetailRec : newTriggerList){
                    if(docDetailRec.Pod_Pack_Size__c <> NULL && docDetailRec.Quantity__c <> oldTriggerMap.get(docDetailRec.id).Quantity__c && docDetailRec.Quantity__c <> NULL){
                       if(docDetailRec.Flavor_Family__c <> NULL && docDetailRec.Flavor_Family__c== 'Multipack'){
                          docDetailRec.TotalQuantity__c =  Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;
                          docDetailRec.Total_Flavor_Family_Quantity__c = docDetailRec.Quantity__c;  
                     }else{
                         docDetailRec.TotalQuantity__c =  Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;
                         docDetailRec.Total_Flavor_Family_Quantity__c = Integer.ValueOf(docDetailRec.Pod_Pack_Size__c) * docDetailRec.Quantity__c;  
                     } 
                   }    
               }
            }
        }
    } 
}