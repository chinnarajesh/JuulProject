/******************************************************
  Purpose:
   -------
   To purge KAM related records Instorelocation, Store product and Asset 
   ======================================================
   Test Class : KAMBatchPurgeDataISAsnip
   ======================================================
   History
   -------
   VERSION  AUTHOR    DATE             Description
   1.0      Shreya    20th Dec,2021    Created 
 *******************************************************/
public class KAMBatchPurgeDataISA implements Database.Batchable<sobject>{
    Public ID AptID;
       ActionPlanTemplate__c selectedAPTQueried = new ActionPlanTemplate__c();
    Public KAMBatchPurgeDataISA(ID Apt){
        AptID = Apt;
            selectedAPTQueried =[Select Id,Batch_Details__c,Last_Recall_Executed__c From ActionPlanTemplate__c Where id =:AptID];
    }
    
    Public List<sObject> start (Database.BatchableContext BC) {
        List<sObject> scope = new List<sObject>();
        scope.addAll([select id from StoreProduct__c where InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c =: AptID and RetailStoreId__r.type!='HQ']);
        scope.addAll([select id from Asset Where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c=: AptID and Account.type !='HQ'  ]);
        scope.addAll([select id from Instorelocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c =: AptID and RetailLocationId__r.type !='HQ' ]);
        scope.addAll([select id from Asset__c Where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c=: AptID and Account__r.type !='HQ'  ]);
       
        return scope;
    }
    public void execute(Database.BatchableContext c, List<sObject> scope)
    {
        List<StoreProduct__c> spList = new List<StoreProduct__c>();
        List<Asset> Ast = new List<Asset>();
         List<Asset__c> CustAst = new List<Asset__c>();
        List<Instorelocation__c> Inst = new List<Instorelocation__c>();
        
       for(sObject obj : scope)
        {
            switch on obj
            {
                when StoreProduct__c sp
                {
                    spList.add(sp);
                }
                when Asset Ass
                {
                    Ast.add(Ass);
                }
                when Instorelocation__c Instrecords
                {
                   Inst.add(Instrecords);
                }
                when Asset__c Asst
                {
                    CustAst.add(Asst);
                }
             }
         }
         System.debug('Inst '+Inst.size());
        if(Inst.size()>0){
            try{
        Delete Inst;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
        }
         if(Ast.size()>0){
            try{
         Delete Ast;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
         }
         if(spList.size()>0){

             try{
              Delete spList;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
             
         }
        if(CustAst.size()>0){

             try{
              Delete CustAst;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
             
         }
        
    }
    Public void finish(Database.BatchableContext BC){
         AsyncApexJob j = [Select Id,Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
        //Added by shreya for ticket SFDC - 0000004466 
        if(j.NumberOfErrors > 0)
         {
          selectedAPTQueried.Batch_Details__c ='ISL Recall Batch Failed '+j.CompletedDate; 
             System.debug('Inside failed batch details');
         }
        if(j.Status == 'Completed' && j.NumberOfErrors == 0)
        {
           selectedAPTQueried.Batch_Details__c ='ISL Recall Batch completed '+j.CompletedDate; 
           selectedAPTQueried.Last_Recall_Executed__c=DateTime.now();
        }
        update selectedAPTQueried;
        
        KAMBatchPurgeDataMissionAP k = new KAMBatchPurgeDataMissionAP(aptId);
        Database.executeBatch(k,10);
    }
       
}