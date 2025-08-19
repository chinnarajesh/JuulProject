global class APTsInStoreLocationsBatchClass implements Database.Batchable<sObject>, Database.Stateful,Schedulable{



  public Map<Id,Set<Id>> aptAccountIdMap = new Map<Id,Set<Id>>();
  public Map<string,id> aaptMapValues= new Map<string,id>();
  Map<id,Map<String, Id>> stateAPTAaptIds = new  Map<id,Map<String, Id>>();
  Set<Id> allAptIdSet = new Set<Id>();

  Map<String,CommercialActivityProduct__c> caWithCaps = new Map<String,CommercialActivityProduct__c>();
  Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice = new Map<string,Commercial_Activity_Product_Pricing__c>();

  global void execute(SchedulableContext sc) {
      database.executebatch(this,2);
  }
    
  global Database.Querylocator start (Database.BatchableContext BC) {
      string aPtApproved ='APT Approved & Locked';
      String query = 'SELECT Id, Name, ActionPlanType__c, AccountId__c,In_Store_Locations_Created__c,CommercialActivityId__c FROM ActionPlanTemplate__c WHERE  Status__c = \'' + aPtApproved + '\' AND In_Store_Locations_Created__c != true AND AccountId__c !=null';  //AND Id IN : aptId
      return Database.getQueryLocator(query);
  }


  global void execute (Database.BatchableContext BC,List<ActionPlanTemplate__c> aptRecords) {
    Set<id> actionPlanTemplateId = new Set<id>();
    Integer maxDeepLevel = 1;

    Set<Id> aptCommActivityIds = new Set<Id>();


    for(ActionPlanTemplate__c apt : aptRecords){
      // if(aptAccountIdMap.containsKey(apt.AccountId__c)){
      //     set<id> aptIdSet =aptAccountIdMap.get(apt.AccountId__c);
      //     aptIdSet.add(apt.id);
      //     aptAccountIdMap.put(apt.AccountId__c,aptIdSet);
      // }
      // else{
      //   Set<id> aptIdSetNew = new Set<id>();
      //   aptIdSetNew.add(apt.id);
      //   aptAccountIdMap.put(apt.AccountId__c,aptIdSetNew);

      // }
      //  allAptIdSet.add(apt.id);
        actionPlanTemplateId.add(apt.id);
        aptCommActivityIds.add(apt.CommercialActivityId__c);
    }
      //Map<String, Id> stateAaptIds = new  Map<String, Id>();

    Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c,Product_Bundle__c,Product_bundle_Description__c,ProductType__c,CommercialActivityId__c, (select id,name,Commercial_Activity_Product__r.ProductId__c,Price__c,State_ISO2__c,Commercial_Activity_Product__r.CommercialActivityId__c from Commercial_Activity_Product_Pricings__r) from CommercialActivityProduct__c where CommercialActivityId__c IN : aptCommActivityIds ]);

    for(CommercialActivityProduct__c capList : commercialActivityProductMap.values()){
      caWithCaps.put(capList.CommercialActivityId__c+'-'+capList.ProductId__c,capList);

      if(capList.ProductType__c == 'JUUL Product'){
        for(Commercial_Activity_Product_Pricing__c cappData : capList.Commercial_Activity_Product_Pricings__r){
          if(cappData.Commercial_Activity_Product__r.ProductId__c !=null && cappData.State_ISO2__c != null){
            string  s = cappData.Commercial_Activity_Product__r.CommercialActivityId__c+'-'+cappData.Commercial_Activity_Product__r.ProductId__c+'-'+cappData.State_ISO2__c;
            commercialAcitvityProductPrice.put(s,cappData);
          }
        }
      }
    }

    List<AccountActionPlanTemplate__c> actionPlantemplateList =  [select id,name,Account__c,Grouped_State__c ,ActionPlanTemplateId__c,ActionPlanTemplateId__r.AccountId__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c IN : actionPlanTemplateId AND Grouped_State__c !=null AND Active__c=true ];//AND Account__c !=null

    for(AccountActionPlanTemplate__c aap : actionPlantemplateList){
      //stateAaptIds.put(aap.Grouped_State__c, aap.id);
      //stateAPTAaptIds.put(aap.ActionPlanTemplateId__c,stateAaptIds);
      if(stateAPTAaptIds.containsKey(aap.ActionPlanTemplateId__c)){
          Map<String, Id> stateAaptIds= stateAPTAaptIds.get(aap.ActionPlanTemplateId__c);
          stateAaptIds.put(aap.Grouped_State__c, aap.id);
          stateAPTAaptIds.put(aap.ActionPlanTemplateId__c,stateAaptIds);

      }else{
        Map<String, Id> stateAaptIdsNew = new  Map<String, Id>();
        stateAaptIdsNew.put(aap.Grouped_State__c, aap.id);
        stateAPTAaptIds.put(aap.ActionPlanTemplateId__c,stateAaptIdsNew);
      }
        
      if(aptAccountIdMap.containsKey(aap.ActionPlanTemplateId__r.AccountId__c)){
        set<id> aptIdSet =aptAccountIdMap.get(aap.ActionPlanTemplateId__r.AccountId__c);
        aptIdSet.add(aap.ActionPlanTemplateId__c);
        aptAccountIdMap.put(aap.ActionPlanTemplateId__r.AccountId__c,aptIdSet);
      }else{
        Set<id> aptIdSetNew = new Set<id>();
        aptIdSetNew.add(aap.ActionPlanTemplateId__c);
        aptAccountIdMap.put(aap.ActionPlanTemplateId__r.AccountId__c,aptIdSetNew);
      }
      allAptIdSet.add(aap.ActionPlanTemplateId__c);
    }
  }

  global void finish(Database.BatchableContext BC){

      SubBatchOfAPTsInStoreLocationsBatch wrapp = new SubBatchOfAPTsInStoreLocationsBatch(aptAccountIdMap,stateAPTAaptIds,caWithCaps,commercialAcitvityProductPrice,allAptIdSet);
      Database.executeBatch(wrapp, 1);

  }
}