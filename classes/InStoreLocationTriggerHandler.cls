/*********************************************************************************/
/* VERSION     AUTHOR                  DATE                                      */
/*     1.0     Surabhi Rastogi        04-08-2020                                 */
/* Class Name: InStoreLocationTriggerHandler                                     */
/* Description: To append the POG value on Retail Store of an In-Store Location  */
/*********************************************************************************/

public class InStoreLocationTriggerHandler{
    
public static string addRetailStoreGrouponInsert (List<InStoreLocation__c> isList) {

    String response='';
    String objectAPIName = 'Account';
    List<Account> accList = new List<Account>();
    Account a = new Account();
    try{
    for (InStoreLocation__c isl:isList){
    //Ensure that the POG on Retail Store appends if the In-Store Location is active and belongs to the Reset Category.
        if(isl.Active__c==true && isl.Category__c == 'Reset'){
            if(isl.PlanogramId__c!=null){ 
                a = new Account();
                a.Id = isl.RetailLocationId__c;
                a.Retail_Store_Group__c = isl.PlanogramId__c;
                accList.add(a);
                system.debug('@@accList : '+accList);
            }
        }
        
    }
    
    if(accList.size()>0){
    
     List<Database.SaveResult> savedResultPlanograms = Database.update(accList, false);
     List<Database.Error> listError = new  List<Database.Error>();
     for(Database.SaveResult currentPOG: savedResultPlanograms){
                if(!currentPOG.isSuccess()){
                    for (Database.Error err: currentPOG.getErrors()) {
                        listError.add(err);
                        response = err.getMessage();
                    }
                }
     }
     
      //Insert exceptions in Log__c object, If any
            if(listError.size()>0)
            { 
                LogEventTriggerHandler.insertBatchLog(listError, 'InStoreLocationTriggerHandler', 'addRetailStoreGroup', objectAPIName, 'Database.Update_Failed');
            }else
            {
                response ='Planogram attached on Retail Store';
                system.debug('@@Response for success: '+response);
            }
     
         }
     
     }
     
         catch(Exception ex){
            system.debug('Print Exception' + ex);
            response = ex.getMessage();
         }
    return response;
    

}

public static string addRetailStoreGrouponUpdate (List<InStoreLocation__c> isList,Map<Id,InStoreLocation__c> islMap) {

    String response='';
    String objectAPIName = 'Account';
    List<Account> accList = new List<Account>();
    Account a = new Account();
    InStoreLocation__c isLOldValues = new InStoreLocation__c();
    try{
    for (InStoreLocation__c isl:isList){
    //Ensure that the POG on Retail Store appends if the In-Store Location is active and belongs to the Reset Category.
        isLOldValues = islMap.get(isl.Id);
        if(isl.Active__c==true && isl.Category__c == 'Reset'){
            if(isl.PlanogramId__c!=null && (isLOldValues.PlanogramId__c!=isl.PlanogramId__c || isLOldValues.Active__c!=isl.Active__c)){ 
                a = new Account();
                a.Id = isl.RetailLocationId__c;
                a.Retail_Store_Group__c = isl.PlanogramId__c;
                accList.add(a);
                system.debug('@@accList : '+accList);
            }
        }
        
    }
    
    if(accList.size()>0){
    
     List<Database.SaveResult> savedResultPlanograms = Database.update(accList, false);
     List<Database.Error> listError = new  List<Database.Error>();
     for(Database.SaveResult currentPOG: savedResultPlanograms){
                if(!currentPOG.isSuccess()){
                    for (Database.Error err: currentPOG.getErrors()) {
                        listError.add(err);
                        response = err.getMessage();
                    }
                }
     }
     
      //Insert exceptions in Log__c object, If any
            if(listError.size()>0)
            { 
                LogEventTriggerHandler.insertBatchLog(listError, 'InStoreLocationTriggerHandler', 'addRetailStoreGroup', objectAPIName, 'Database.Update_Failed');
            }else
            {
                response ='Planogram attached on Retail Store';
                system.debug('@@Response for success: '+response);
            }
     
         }
     
     }
     
         catch(Exception ex){
            system.debug('Print Exception' + ex);
            response = ex.getMessage();
         }
    return response;
    

}

}