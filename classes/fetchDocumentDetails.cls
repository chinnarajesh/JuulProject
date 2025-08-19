/*****************************************************************************************************/
    /* Mehod Name : fetchDocumentDetails
    /* Description : fetch all Document details and create records for Case/RetuernOrder/ Returnd Docuement Details.
    /* Ticket : JTP-228
    /* Added By : Pooja Gite
    /*****************************************************************************************************/
public class fetchDocumentDetails {
   
	Public static List<Document_Details__c> dd = new List<Document_Details__c>();
//getDocDetails methods to fetch all Document detail recordsas per filter criteria.
    @AuraEnabled(cacheable=true)
    public static List<Document_Details__c> getDocDetails(String SOIds) {
        dd = [select Id, Product_Name__c,product__c, DDSKU__c,Product_Description__c,unitPrice__c,Total_Price__c,CreatedDate,Quantity__c,Update_Quantity__c FROM Document_Details__c where salesOrderNumber__c =: SOIds];
        return dd;
        
    }
    
    /*@AuraEnabled
    public static void saveDocDetailsLwc(List<Document_Details__c> records){
        if(records.size()>0 && records != null){
            List<Document_Details__c> ddList = new List<Document_Details__c>();
            
            for(integer i = 0; i < records.size(); i++) {
                Document_Details__c dd = new Document_Details__c();
                dd.Id = records[i].Id;
                dd.Update_Quantity__c = records[i].Update_Quantity__c;
                ddList.add(dd);
            }
            upsert ddList;
        }
    }*/
//createCase methods to create records for Case/RetuernOrder/ Returnd Docuement Details.
    @AuraEnabled
    public static void createCase(Id recordId, List<Id> SelectedValues, String PLvalue, String radioVal, String totalBox, String totalweight, String totalpallet, String pickUpHrs){
        system.debug('Picklist'+PLvalue +'Radio'+radioVal);
        System.debug('SelectedValues******************'+SelectedValues);
        system.debug(Limits.getDMLStatements() +', '+ Limits.getLimitDMLStatements());
 		Id recTypeCase;
        
        Map<Id,Document_Details__c> ddMap = new Map<Id,Document_Details__c>([Select Id,Product__c, Product_Name__c, DDSKU__c,Product_Description__c,unitPrice__c,Total_Price__c,CreatedDate,Quantity__c,Update_Quantity__c from Document_Details__c where Id IN: SelectedValues]);
        Map<Id,salesOrder__c> SOMap = new Map<Id,salesOrder__c>([Select Id, Name,Customer__r.ShippingCountry, Customer_PO_Number__c from salesOrder__c where Id =: recordId]);
        User u = [Select Id, ContactId  from user where Id =: UserInfo.getUserId()];      
      
        Map<String,Schema.RecordTypeInfo> rtMapCase = Schema.SObjectType.Case.getRecordTypeInfosByName();
        recTypeCase = rtMapCase.get('B2B RMA').getRecordTypeId();
        system.debug('rtMapCase'+rtMapCase.get('B2B RMA').getRecordTypeId());
        system.debug('recTypeCase'+recTypeCase);


        List<Case> newCases = new List<Case>();
		Case c = new Case();
        Return_Order__c ro = new Return_Order__c();
		//salesOrder__c So= SOMap.get(SOIds[0]);
		salesOrder__c So= SOMap.get(recordId);
        if(radioVal== 'Yes'){
            System.debug('inside if yes');
            c.RecordTypeId = recTypeCase;
            c.Sales_Order__c = recordId;
            c.Description = pickUpHrs;
            c.Return_Reason__c = PLvalue;
            c.Type = PLvalue;
            c.AccountId = So.Customer__c;
			c.Total_Shipment_Weight__c = integer.valueof(totalweight);
            c.ContactId = u.ContactId;
            c.Market__c = So.Customer__r.ShippingCountry;
            newCases.add(c);
        }
        else if(radioVal == 'No'){
            c.RecordTypeId = recTypeCase;
            c.Sales_Order__c = recordId;
            c.Return_Reason__c = PLvalue;
            c.Type = PLvalue;
            c.AccountId = So.Customer__c;
            c.ContactId = u.ContactId;
            c.Market__c = So.Customer__r.ShippingCountry;
            newCases.add(c);
        }
		insert newCases;
        
        List<Return_Order__c> newROList = new List<Return_Order__c>();
        if(radioVal== 'Yes'){
            //Return_Order__c ro = new Return_Order__c();
            ro.Case__c = c.Id;
            ro.PO__c = So.Customer_PO_Number__c;
            ro.Quantity_of_Boxes__c = integer.valueof(totalBox);
            ro.Quantity_of_Pallets__c = integer.valueof(totalpallet);
            newROList.add(ro);
         }
        else if(radioVal== 'No'){
            ro.Case__c = c.Id;
            ro.PO__c = So.Customer_PO_Number__c;
            newROList.add(ro);
        }
        insert newROList;
        
        List<Return_Document_Detail__c> newRDDList = new List<Return_Document_Detail__c>();
         
		system.debug('** SelectedValues'+SelectedValues);
        for(Id sv: SelectedValues){
               Return_Document_Detail__c rdd = new Return_Document_Detail__c();
            system.debug('** SV'+sv);
            Document_Details__c dd1= ddMap.get(sv);
             system.debug('** dd1'+dd1);
             system.debug('** ddMap.get(sv)'+ddMap.get(sv));
            rdd.Return_Order__c = ro.Id;
            rdd.Return_Product__c = dd1.product__c;
            rdd.Reported_Quantity__c = dd1.Update_Quantity__c;
            rdd.Reported_Unit_Price__c = dd1.unitPrice__c;
            rdd.SO_Document_Detail__c = null;// added for JTP-219
            newRDDList.add(rdd);
        }
        system.debug('newRDDList '+newRDDList);
        if(newRDDList!=null){
        insert newRDDList; 
         }
    } 
}