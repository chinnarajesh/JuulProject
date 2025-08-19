/*******************************************************************************************
* @Name         Batch_Cascading_NAMAccounts
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         06/05/2019
* @Group        Sales Ops
* @Description  A batch job will update NAM field from Parent to Childs down the hierarchy
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          06/05/2019            Initial Creation
*******************************************************************************************/
global class Batch_Cascading_NAMAccounts implements Database.Batchable<sObject>, Database.Stateful {
    global String idString='';
    global Map<Id,Id> resultMap;
    global Batch_Cascading_NAMAccounts(Map<Id,Id> resultMap){
        idString='(' ; 
        for(String s1 : resultMap.keySet()){
            idString = idString + '\''+s1+'\','; 
        }
       idString=idString.removeEnd(',');
       idString+=')';
       this.resultMap = resultMap;
    }
   /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query = 'SELECT Id, Type,Name, National_Account_Manager__c,ParentId,Parent.ParentId,Parent.Parent.ParentId,Parent.Parent.Parent.ParentId FROM Account ';
               query  = (idString=='()')? query : query+' WHERE (ParentId IN '+IdString+ ' OR Parent.ParentId IN'+IdString+ ' OR Parent.Parent.ParentId IN'+IdString+ ' OR Parent.Parent.Parent.ParentId IN'+IdString+')';
          System.debug('The query is_Batch_Cascasding_NAMAccounts ***************** '+query);
        return Database.getQueryLocator(query);
    }
   /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Asset>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Account> listAcc) {
        List<Account> listAccToUpdate = new List<Account>();
        for(Account accRec : listAcc){
            if(resultMap.containsKey(accRec.ParentId)){
                if(accRec.National_Account_Manager__c <> resultMap.get(accRec.ParentId)){
                    accRec.National_Account_Manager__c = resultMap.get(accRec.ParentId);
                }
            }else if(resultMap.containsKey(accRec.Parent.ParentId)){
                if(accRec.National_Account_Manager__c <> resultMap.get(accRec.Parent.ParentId)){
                    accRec.National_Account_Manager__c = resultMap.get(accRec.Parent.ParentId);
                }
            }else if(resultMap.containsKey(accRec.Parent.Parent.ParentId)){
                if(accRec.National_Account_Manager__c <> resultMap.get(accRec.Parent.Parent.ParentId)){
                    accRec.National_Account_Manager__c = resultMap.get(accRec.Parent.Parent.ParentId);
                 }  
            }else if(resultMap.containsKey(accRec.Parent.Parent.Parent.ParentId)){
                if(accRec.National_Account_Manager__c <> resultMap.get(accRec.Parent.Parent.Parent.ParentId)){
                    accRec.National_Account_Manager__c = resultMap.get(accRec.Parent.Parent.Parent.ParentId);
                 }   
            }
            listAccToUpdate.add(accRec);
        }
       if(listAccToUpdate != null && listAccToUpdate.size()>0){
             Database.SaveResult[] srList = Database.Update(listAccToUpdate, false);
             List<Database.Error> listError = new List<Database.Error>();
             for(Integer index = 0, size = srList.size(); index < size; index++) {
               if(!srList[index].isSuccess()) 
                    listError.addAll(srList[index].getErrors());
                }
            LogEventTriggerHandler.insertBatchLog(listError, 'Batch_Cascasding_NAMAccounts', 'execute', 'Account', 'Database.Update_Failed');   
            }
           
     }
   /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
    
    }
}