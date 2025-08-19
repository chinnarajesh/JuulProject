/*******************************************************************************************
* @Name         SalesOrderTriggerHandler
  @Author       
* @Date         
* @Group        
* @Description  
*******************************************************************************************/
/* MODIFICATION LOG
* Version              Developer                  Date               Description
*-------------------------------------------------------------------------------------------
*   1.1              Preetha Barnabas          3/27/2020            Gets the SalesOrder records from SalesOrder trigger and updates related Customer's First Sales Order, Billing and Shipping Address.
*******************************************************************************************/
public class SalesOrderTriggerHandler {
  public static Boolean INSERT_TRIGGER_BYPASS = false;
  public static Boolean UPDATE_TRIGGER_BYPASS = false;
    
  public static void handleAfterInsertUpdateCustomer(List<SalesOrder__c> triggerObjects){
    Map<Id, Account> AccountMap = new Map<Id, Account>();
    Account act;  
    for(salesOrder__c sOrder : triggerObjects){     
       if(sOrder.orderType__c == 'BO' && sOrder.Customer__c != null && sOrder.Customer_Billing_Street__c == null){        
           if (!AccountMap.ContainsKey(sOrder.Customer__c)){
               act = new Account(); 
               act.Id                = sOrder.Customer__c;
               act.BillingCity       = sOrder.SOBilling_City__c;
               act.BillingCountry    = sOrder.SOBilling_Country__c;
               act.BillingPostalCode = sOrder.SOBilling_Zip__c;
               act.BillingState      = sOrder.SOBilling_State__c;  
               act.BillingStreet     = sOrder.SOBilling_Address_1__c + sOrder.SOBilling_Address_2__c;             
               
               if(sOrder.Customer_ShippingAddress__c == null || String.valueOf(sOrder.Customer_ShippingAddress__c).startsWith(' ,') ){
                  act.ShippingCity = sOrder.SOShipping_City__c;
                  act.ShippingCountry = sOrder.SOShipping_Country__c;
                  act.ShippingPostalCode = sOrder.SOShipping_Zip__c;
                  act.ShippingState = sOrder.SOShipping_State__c;  
                  act.ShippingStreet = sOrder.SOShipping_Address_1__c + sOrder.SOShipping_Address_2__c;
               } 
               AccountMap.put(sOrder.Customer__c,act); 
           }
       }
    }
 
   if(AccountMap != null && AccountMap.size()>0){
          List<Database.SaveResult> updateAccountResults = Database.Update(AccountMap.Values(), false);
            List<Database.Error> listError = new List<Database.Error>();
            for(Integer index = 0, size = updateAccountResults.size(); index < size; index++) {
              if(!updateAccountResults[index].isSuccess()){
                listError.addAll(updateAccountResults[index].getErrors());
              }
          }
        LogEventTriggerHandler.insertBatchLog(listError, 'SalesOrderTriggerHandler', 'UpdateCustomerDetails', 'Account', 'Database.Update_Failed');  
        }
 }

    /*public static void handleBeforeInsert( List<SalesOrder__c> triggerObjects ) {
        if(INSERT_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'SOBilling_State__c', new Map<String,Object>(),  triggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'SOBilling_Country__c', new Map<String,Object>(),  triggerObjects );
            TerritoryUtility.standardizeField( 'State', 'SOShipping_State__c', new Map<String,Object>(),  triggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'SOShipping_Country__c', new Map<String,Object>(),  triggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'SOBilling_Zip__c', new Map<String,Object>{'countryFieldName'=>'SOBilling_Country__c'},  triggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'SOShipping_Zip__c', new Map<String,Object>{'countryFieldName'=>'SOShipping_Country__c'},  triggerObjects );
        
        }
    } */
    
   /* public static void handleBeforeInsertUpdateCSM(List<SalesOrder__c> triggerObjects){
        Map<Id,Id> mapAccIdToCSMId = new Map<Id,Id>();
        List<Account> listAcc = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        for(SalesOrder__c a : triggerObjects){
            if(a.Customer__c != Null){
                accIds.add(a.Customer__c);
               }
        }
        System.debug('accIds ************** '+accIds);
        listAcc = [Select Id, Customer_Success_Manager__c from Account where Id In :accIds];
        for(Account objAcc: listAcc){
            if(!mapAccIdToCSMId.containsKey(objAcc.Id)  && objAcc.Customer_Success_Manager__c != null){
                mapAccIdToCSMId.put(objAcc.Id,objAcc.Customer_Success_Manager__c);
              }
        }
        System.debug('mapAccIdToCSMId ************** '+mapAccIdToCSMId);
        
        for (SalesOrder__c a : triggerObjects){
            if(mapAccIdToCSMId.containsKey(a.Customer__c)){
                System.debug('mapAccIdToCSMId.get(a.Customer__c) ************** '+mapAccIdToCSMId.get(a.Customer__c));
                a.Customer_Success_Manager__c = mapAccIdToCSMId.get(a.Customer__c);
              }  
          }
        }*/
    
    
   /* 
    public static void handleBeforeUpdate( List<SalesOrder__c> oldTriggerObjects, List<SalesOrder__c> newTriggerObjects ) {
        if(UPDATE_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'SOBilling_State__c', new Map<String,Object>(),  newTriggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'SOBilling_Country__c', new Map<String,Object>(),  newTriggerObjects );
            TerritoryUtility.standardizeField( 'State', 'SOShipping_State__c', new Map<String,Object>(),  newTriggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'SOShipping_Country__c', new Map<String,Object>(),  newTriggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'SOBilling_Zip__c', new Map<String,Object>{'countryFieldName'=>'SOBilling_Country__c'},  newTriggerObjects );
            TerritoryUtility.standardizeField( 'Zip Code', 'SOShipping_Zip__c', new Map<String,Object>{'countryFieldName'=>'SOShipping_Country__c'},  newTriggerObjects );
        }
    }
*/
}