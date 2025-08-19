/*******************************************************************************************
* @Name         FetchProductRecordController
* @Author       Pooja Gite <pooja.gite@juul.com>
* @Date         11/10/2021
* @Description  A method to get ID's of selected Document detail and related Product on flow screen.
*******************************************************************************************/
public class FetchProductRecordController {
    
    @AuraEnabled(Cacheable = true)
    public static List<Document_Details__c> getDocDetails(ID recordid) {
        System.debug('*******DC******'+[select id,Product__c, Product_Name__c, unitPrice__c,Quantity__c, Update_Quantity__c,Product_Description__c,Total_Price__c,DDSKU__c,CreatedDate FROM Document_Details__c  WHERE id =: recordid]);
        return [select id,Product__c, Product_Name__c, unitPrice__c
                FROM Document_Details__c 
                WHERE id =: recordid];
    }
   
    @InvocableMethod
    Public Static List<DataWrap> fetchRecords(List<Requests> requestList){
        System.debug('requestList-->'+requestList);
        List<SObject> inputCollection = requestList[0].inputCollection;
        System.debug('inputCollection-->'+inputCollection);
        Set<Id> ddIds= new Set<Id>();
        for(Document_Details__c ddObj:(List<Document_Details__c>)inputCollection){
            ddIds.add(ddObj.Id);
        }
        System.debug('ddIds-->'+ddIds);
        List<DataWrap> lstWrap= new List<DataWrap>();
        DataWrap wrap= new DataWrap();
       List<Document_Details__c> DocDetailLst = [Select Id,Product__c, Product_Name__c,unitPrice__c,Quantity__c,Update_Quantity__c,Product_Description__c,Total_Price__c,DDSKU__c,CreatedDate 
                                                 From Document_Details__c WHERE Id IN :ddIds];//WHERE Id IN :ddIds
        System.debug('DocDetailLst-->'+DocDetailLst);
        
        Set<Id> prodId= new Set<Id>();
        List<String> strlst= new List<String>();
        for(Document_Details__c dd:DocDetailLst){
            prodId.add(dd.Product__c);
        }
        System.debug('prodId-->'+prodId);
        List<Product2> prodLst=[SELECT Id, Name FROM Product2 WHERE Id IN:prodId];
        for(Product2 p:prodLst){
            String objType = String.valueOf(p);
            strlst.add(objType);
        }
       // wrap.idsLst=strlst;
        wrap.productLst=prodLst;
        wrap.documentDetailLst=DocDetailLst;
        lstWrap.add(wrap);
        System.debug('List wrap-->'+lstWrap);
        return lstWrap;
        
    }
    
    public class DataWrap{
        @InvocableVariable
        public list<SObject> productLst;
         @InvocableVariable
        public list<SObject> documentDetailLst;
    }
    
    public class Requests {
        @InvocableVariable(label='Records for Input' description='yourDescription')// required=true)
        public List<SObject> inputCollection;
    } 
}