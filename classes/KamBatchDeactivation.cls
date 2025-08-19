public class KamBatchDeactivation implements Database.Batchable<sobject>{
    
    Public ID AptID;
    Public ID AccountID;
    Public Set<Id> selectedRsgList = new Set<ID>();
     set<ID> accountIDs = new set<ID>();
    Private List<KAMAccountPlanning.WrapperData> selectedData;
    ActionPlanTemplate__c selectedAPTQueried = new ActionPlanTemplate__c();
    public KamBatchDeactivation(ID Apt, List<KAMAccountPlanning.WrapperData> selectedData1)
    {
        AptID = Apt;
        selectedData = selectedData1;
        selectedAPTQueried = [Select Id,AccountId__c,Batch_Details__c from ActionPlanTemplate__c where Id =:apt];
        
         for(KAMAccountPlanning.WrapperData wd: selectedData){
           if(wd.selected && !wd.readOnly){ 
               
                selectedRsgList.add(wd.Id);
         }
         }
       
        for(RetailLocationGroup__c rs: [Select id, AccountId__c,AccountId__r.ComplianceMechanism__c,Pricing_State__c from RetailLocationGroup__c where id IN: selectedRsgList]){
          accountIDs.add(rs.AccountId__c);
        }
     }
    
    Public List<sObject>	 start (Database.BatchableContext BC) {
         List<sObject> scope = new List<sObject>();
        scope.addAll([select id,Active__c,RetailStoreId__c from StoreProduct__c where InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c =: AptID]);
        scope.addAll([select id,Active__c,AccountId from Asset Where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c=: AptID  ]);
        scope.addAll([select id,Active__c,Account__c from Asset__c where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c =: AptID ]);
        return scope;
    }
    public void execute(Database.BatchableContext c, List<sObject> scope)
    {
        List<StoreProduct__c> spList = new List<StoreProduct__c>();
        List<Asset> Ast = new List<Asset>();
        List<Asset__c> CusAst = new List<Asset__c>();
        
       for(sObject obj : scope)
        {
            switch on obj
            {
                when StoreProduct__c sp
                {
                    sp.Active__c =false;
                    spList.add(sp);
                }
                when Asset Ass
                {
                    Ass.Active__c = false;
                    Ast.add(Ass);
                    System.debug('inside ass'+ast.size());
                }
                when Asset__c CustAss
                {
                   CustAss.Active__c = false;
                   CusAst.add(CustAss);
                }
             }
         }
        if(CusAst.size()>0){
            try{
        update CusAst;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
        }
         if(Ast.size()>0){
            try{
         update Ast;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
         }
         if(spList.size()>0){

             try{
              update spList;
            }catch(Exception e){
                system.debug('error ->' + e.getMessage());
            }
         }
  
     }
    Public void finish(Database.BatchableContext BC){
        
         AsyncApexJob j = [Select Id, Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
        //Added by shreya for ticket SFDC - 0000004466 
        if(j.NumberOfErrors > 0)
         {
          selectedAPTQueried.Batch_Details__c ='Product Deactivation Batch Failed '+j.CompletedDate; 
             System.debug('Inside failed batch details');
         }
        else  if(j.Status == 'Completed' && j.NumberOfErrors == 0)
        {
           selectedAPTQueried.Batch_Details__c ='Product Deactivation Batch Completed '+j.CompletedDate;   
        }
        update selectedAPTQueried;
        
        set<ID> AccIDs = new set<ID>();
        Boolean CascadeChanges = false;
        KAMBatchOverrideProduct k = new KAMBatchOverrideProduct(aptId,selectedData);
        Database.executeBatch(k,10);
    }
    

}