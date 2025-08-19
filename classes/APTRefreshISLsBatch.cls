global class APTRefreshISLsBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,Set<Id>> aptAccountIdMap = new Map<Id,Set<Id>>();
    public Map<string,id> aaptMapValues= new Map<string,id>();
    Map<id,Map<String, Id>> stateAPTAaptIds = new  Map<id,Map<String, Id>>();
    //public Integer totalAmtOfRecords = 0;
    Set<Id> allAptIdSet = new Set<Id>();
    Map<string, InStoreLocation__c> ISLMap;
    Set<id> actionPlanTemplateId = new Set<id>();
    public List<string> errorMessegeList = new List<string>();
    public Set<Id> deleteaccountIdSet = new Set<Id>();
    public Set<Id> instoreLocationIdSet = new Set<Id>();
    Map<Id,List<Id>> rsgAccount = new Map<Id,List<Id>>();
   
    public Set<Id> aptIdSet = new Set<Id>();
    Set<Id> aptCommActivityIds = new Set<Id>();
    
    public Set<Actionplantemplate__c> apt; 
    public List<Id> accountIds;
    Map<String, Id> stateAaptIds = new  Map<String, Id>();
    public String d;
  
    Map<String,CommercialActivityProduct__c> commActivityWithProductsLocal = new Map<String,CommercialActivityProduct__c>();    
    Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPriceLocal = new Map<string,Commercial_Activity_Product_Pricing__c>();
    List<AccountActionPlanTemplate__c> actionPlantemplateList = new List<AccountActionPlanTemplate__c> ();
    public APTRefreshISLsBatch(){
        apt = new Set<Actionplantemplate__c>();
        ISLMap = new Map<string, InStoreLocation__c >();
        d = Label.Days;
        Date oldDate = system.today().addDays(Integer.valueof(d));
        string aPtApproved ='APT Approved & Locked';
        for(Actionplantemplate__c apt1 :[SELECT Id,recordtype.name,Status__c,Mass_Cascade_Active_Flag_Date__c,RequestedStartDate__c,Mass_Cascade_Flag__c,CommercialActivityId__c FROM actionplantemplate__c WHERE ((RequestedStartDate__c  <=: oldDate and RequestedStartDate__c >: system.today()) OR Mass_Cascade_Flag__c = true) and Status__c =: aPtApproved and In_Store_Locations_Created__c = true and Missions_Created__c != true and In_Store_Locations_Refreshed__c != true] ){  
            apt.add(apt1);
            actionPlanTemplateId.add(apt1.id);
            aptCommActivityIds.add(apt1.CommercialActivityId__c);
            break;
        }
      
        accountIds = new List<Id>();
      
        Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c,Product_Bundle__c,Product_bundle_Description__c,ProductType__c,CommercialActivityId__c, (select id,name,Commercial_Activity_Product__r.ProductId__c,Price__c,State_ISO2__c,Commercial_Activity_Product__r.CommercialActivityId__c from Commercial_Activity_Product_Pricings__r) from CommercialActivityProduct__c where CommercialActivityId__c IN : aptCommActivityIds ]);
        for(CommercialActivityProduct__c capList : commercialActivityProductMap.values()){
            commActivityWithProductsLocal.put(capList.CommercialActivityId__c+'-'+capList.ProductId__c,capList);
    
          if(capList.ProductType__c == 'JUUL Product'){
            for(Commercial_Activity_Product_Pricing__c cappData : capList.Commercial_Activity_Product_Pricings__r){
              if(cappData.Commercial_Activity_Product__r.ProductId__c !=null && cappData.State_ISO2__c != null){
                string  s = cappData.Commercial_Activity_Product__r.CommercialActivityId__c+'-'+cappData.Commercial_Activity_Product__r.ProductId__c+'-'+cappData.State_ISO2__c;
                commercialAcitvityProductPriceLocal.put(s,cappData);
              }
            }
          }
        }
         actionPlantemplateList =  [select id,name,Account__c,Grouped_State__c ,Grouped_Store_Locations__c,ActionPlanTemplateId__c,ActionPlanTemplateId__r.AccountId__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c IN : actionPlanTemplateId AND Grouped_State__c !=null AND Active__c=true ];//AND Account__c !=null
        for(AccountActionPlanTemplate__c aap : actionPlantemplateList){
            accountIds.add(aap.Account__c);
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
     global Database.Querylocator start (Database.BatchableContext BC) {
        return Database.getQueryLocator('Select id,ShippingState, Name, ParentID,Type,ComplianceMechanism__c From Account WHERE ParentID IN: accountIds');
    }
    global void execute (Database.BatchableContext BC,List<Account> ChildAccounts) {
        Integer maxDeepLevel = 1;
        Map<id,String> rsgAccountStateMap = new Map<id,String>();
       // Map<Id,Map<id,String>> rsgAccountStateMap = new Map<Id,Map<id,String>>();
        Map<id,String> accComplianceMap = new Map<id,String>();
        System.debug('ChildAccounts++ '+ChildAccounts);
        Set <ID> queryIDs = new Set <ID>();
        Map<id,Map<string,id>> aptAccountMap = new Map<id,Map<string,id>>();
        Map<Id,Map<String, Id>> stateAaptIdsNew = new  Map<Id,Map<String, Id>>();
        Map<Id,Id> firstLevelParentIdWithChilds = new Map<id,id>();
        //Set <ID> chunkChildAccIds = new Set <ID>();
        if (ChildAccounts.size() > 0) {
                for (Integer i = 0; i < ChildAccounts.size(); i++) {
                    if(ChildAccounts[i].Type != 'HQ'){
                        //chunkChildAccIds.add(ChildAccounts[i].id);
                        rsgAccountStateMap.put(ChildAccounts[i].id, ChildAccounts[i].ShippingState);
                        if(ChildAccounts[i].ComplianceMechanism__c != null){
                            accComplianceMap.put(ChildAccounts[i].id, ChildAccounts[i].ComplianceMechanism__c);
                        }else {
                            accComplianceMap.put(ChildAccounts[i].id, '');
                        }
                        if(aptAccountIdMap.containsKey(ChildAccounts[i].ParentID)){
                            Set<id> actionPlanTemplateId  = aptAccountIdMap.get(ChildAccounts[i].ParentID);
                            for(id aptId : actionPlanTemplateId){
                                if(stateAPTAaptIds.containsKey(aptId)){
                                    stateAaptIdsNew.put(aptId,stateAPTAaptIds.get(aptId));
                                }
                            }
                        }
                        //System.debug('stateAaptIdsNew+'+stateAaptIdsNew);
                        for( id aptids : stateAaptIdsNew.keySet()){
                            if(stateAaptIdsNew.get(aptids).containsKey(ChildAccounts[i].ShippingState)){
                                //System.debug('aptidsInMap++'+stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState));
                                if(rsgAccount.containsKey(stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState))){
                                    List<Id> actIdsExist = rsgAccount.get(stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState));
                                    if(ChildAccounts[i].Type != 'HQ'){
                                        actIdsExist.add(ChildAccounts[i].id);
                                        rsgAccount.put(stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState),actIdsExist);
                                    }
                                }else{
                                    List<Id> actIdsNew = new List<Id>();
                                    if(ChildAccounts[i].Type != 'HQ'){
                                        actIdsNew.add(ChildAccounts[i].id);
                                        rsgAccount.put(stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState),actIdsNew);
                                    }
                                }
                            }
                            system.debug('stateAaptIdsNew++ '+stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState));
                            System.debug('rsgAccountList++ '+rsgAccount.values());
                        }
                    }
                    queryIDs.add(ChildAccounts[i].id);
                    firstLevelParentIdWithChilds.put(ChildAccounts[i].id,ChildAccounts[i].parentID);
                }
            System.debug('1 level RSGAccount-'+rsgAccount);
            System.debug('1 level queryIDs-'+queryIDs);
                //System.debug('1 level Deep Ids count-'+queryIDs.size());
                //allActsCnt = allActsCnt + queryIDs.size();
                while (queryIDs.size() > 0) {
                    // Map<Id,Set<Id>> secongLevelParentWithChildsIdSet = new Map<Id,Set<Id>>();
                    List <Account> childAccount = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState,Type,ComplianceMechanism__c,ParentID From ChildAccounts) FROM Account WHERE ID IN :queryIDs ];        
                    queryIDs.clear();
                    if(maxDeepLevel < 7){
                        //System.debug('maxDeepLevel '+maxDeepLevel);
                        //System.debug('childAccount'+childAccount);
                        for (Account oneAcc: childAccount) {
                            //System.debug('oneAcc cnt'+oneAcc.ChildAccounts.size());
                            if (oneAcc.ChildAccounts.size() > 0) {
                                //childMap.put(oneAcc.id, oneAcc.ChildAccounts);
                                for (Integer i = 0; i < oneAcc.ChildAccounts.size(); i++) {
                                     Id topMostParentId ;
                                    if(firstLevelParentIdWithChilds.containsKey(oneAcc.ChildAccounts[i].ParentID)){
                                       topMostParentId = firstLevelParentIdWithChilds.get(oneAcc.ChildAccounts[i].ParentID);
                                       firstLevelParentIdWithChilds.put(oneAcc.ChildAccounts[i].id,topMostParentId);
                                        // Remove the old entry
                                       firstLevelParentIdWithChilds.remove(oneAcc.ChildAccounts[i].ParentID);
                                    }
                                    if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                        //chunkChildAccIds.add(oneAcc.ChildAccounts[i].id);
                                        rsgAccountStateMap.put(oneAcc.ChildAccounts[i].id, oneAcc.ChildAccounts[i].ShippingState);
                                        if(oneAcc.ChildAccounts[i].ComplianceMechanism__c != null){
                                            accComplianceMap.put(oneAcc.ChildAccounts[i].id, oneAcc.ChildAccounts[i].ComplianceMechanism__c);
                                        }else {
                                            accComplianceMap.put(oneAcc.ChildAccounts[i].id, '');
                                        }
                                        ////////
                                        if(aptAccountIdMap.containsKey(topMostParentId)){
                                              Set<id> actionPlanTemplateId  = aptAccountIdMap.get(topMostParentId);
                                            for(id aptId : actionPlanTemplateId){
                                                if(stateAPTAaptIds.containsKey(aptId)){
                                                    stateAaptIdsNew.put(aptId,stateAPTAaptIds.get(aptId));
                                                }
                                            }
                                        }
                                        for(id aptids : stateAaptIdsNew.keySet()){
                                             if(stateAaptIdsNew.get(aptids).containsKey(oneAcc.ChildAccounts[i].ShippingState)){
                                                if(rsgAccount.containsKey(stateAaptIdsNew.get(aptids).get(oneAcc.ChildAccounts[i].ShippingState))){
                                                    List<Id> actIds222 = rsgAccount.get(stateAaptIdsNew.get(aptids).get(oneAcc.ChildAccounts[i].ShippingState));
                                                 if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                                     actIds222.add(oneAcc.ChildAccounts[i].id);
                                                     rsgAccount.put(stateAaptIdsNew.get(aptids).get(oneAcc.ChildAccounts[i].ShippingState),actIds222);
                                                 }
                                                 }else{
                                                   List<Id> actIds111 = new List<Id>();
                                                 if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                                     actIds111.add(oneAcc.ChildAccounts[i].id);
                                                     rsgAccount.put(stateAaptIdsNew.get(aptids).get(oneAcc.ChildAccounts[i].ShippingState),actIds111);
                                                  }
                                                } 
                                              }
                                            system.debug('stateAaptIdsNew++ '+stateAaptIdsNew.get(aptids).get(oneAcc.ChildAccounts[i].ShippingState));
                                            System.debug('rsgAccountList++ '+rsgAccount.values());
                                            
                                         }
                                    }
                                    queryIDs.add(oneAcc.ChildAccounts[i].id);
                                }  
                            }    
                        }   
                        maxDeepLevel = maxDeepLevel+1; 
                    }    
                }
            }
            Set<Id> accSet = new Set<Id>();
        for(Id a: rsgAccountStateMap.keySet()){
            accSet.add(a);
        }
       
        String storeCategory ='';
        String APTRecordType;
        Id APRecordType;
        Id missionRecordType;
        Map<String, InStoreLocation__c> storeLocationsListToUpsert = new Map<String,InStoreLocation__c>();
        Map<String,List<StoreProduct__c>> StoreLocationStoreProductMap = new Map<String,List<StoreProduct__c>>();
        Map<String,List<Asset>> StoreLocationAssetMap = new Map<String,List<Asset>>();
        Map<String,List<Asset__c>> StoreLocationCustomAssetMap = new Map<String,List<Asset__c>>();
        List<StoreProduct__c> spToInsert = new List<StoreProduct__c>();
        List<Asset> assetToInsert = new List<Asset>();
        List<Asset__c> customAssetToInsert = new List<Asset__c>();
        String class_Name ='SubBatchClassOfInStoreLocations';
        String method_Name='Execute';
        String operationType = 'Database.Insert_Failed';
        //system.debug('aaptIds List'+rsgAccount.keySet());
        rsgAccount.remove(null);
        system.debug('aaptIds List22'+rsgAccount.keySet());
        system.debug('aaptIds List22'+rsgAccount.values());
        //////
      
        //////
        //Getting Account Action Plan Template Store Products and Assets
        Map<Id,InStoreLocation__c> allStoreLocationsWithjunctionId = new Map<Id,InStoreLocation__c>();
        Set<Id> commercialActivityIds  = new Set<Id>();
       

        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c,RetailLocationId__c, RetailLocationId__r.Type,PlanogramId__c,PlanogramId__r.Name,InStoreLocationType__c,Category__c,(Select id, Product_Bundle__c,Product_Bundle_Description__c,STD_JUUL_Funding__c ,Retailer_Funding__c,Final_PTC__c,JUUL_Tax_Funding__c,Differentiator__c,DefaultOrderQuantity__c,SuggestedMSRP__c,Source_Product_Id__c,Commercial_Activity__c,ProductId__c,InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id from Store_Products__r where Active__c = true ),(Select Id,Name,Quantity,Differentiator__c,Source_Product_Id__c,Unit_Price__c,CostForCollateral__c,Product2Id,InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id From Assets__r where Active__c = true ),(Select Id,Name,Quantity__c,Differentiator__c,Source_Product_Id__c,Unit_Price__c,CostForCollateral__c,Product__c,InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id  From Assets1__r where Active__c = true) from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :rsgAccount.keySet() AND Active__c = True and RetailLocationId__r.Type = 'HQ']){
            allStoreLocationsWithjunctionId.put(s.RetailStoreGroupActionPlanTemplate__c,s);

        }

        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c,RetailLocationId__c, RetailLocationId__r.Type,PlanogramId__c,PlanogramId__r.Name,InStoreLocationType__c,Category__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :rsgAccount.keySet() AND Active__c = True and RetailLocationId__r.Type != 'HQ']){
            if(s.RetailLocationId__r.Type !='HQ'){
                ISLMap.put(s.RetailStoreGroupActionPlanTemplate__c+'-'+s.RetailLocationId__c,s);
            }
        }
        List<AccountActionPlanTemplate__c> accountActionPlanTemplateList =[select id,name,Account__c,Grouped_State__c,ActionPlanTemplateId__c,ActionPlanTemplateId__r.recordType.DeveloperName ,ActionPlanTemplateId__r.RequestedStartDate__c,ActionPlanTemplateId__r.RequestedEndDate__c,ActionPlanTemplateId__r.CommercialActivityId__c from AccountActionPlanTemplate__c where id IN: rsgAccount.keySet()];
        //System.debug('accountActionPlanTemplateList '+accountActionPlanTemplateList);
        Set<Id> prodcutIdSet = new Set<Id>();
        for(AccountActionPlanTemplate__c aapt : accountActionPlanTemplateList){
            if(allStoreLocationsWithjunctionId.size()>0){
                if(allStoreLocationsWithjunctionId.containsKey(aapt.id)){
                    if(allStoreLocationsWithjunctionId.get(aapt.id).Store_Products__r.size()>0){
                        for(StoreProduct__c spInfo : allStoreLocationsWithjunctionId.get(aapt.id).Store_Products__r){
                            prodcutIdSet.add(spInfo.ProductId__c);
                        }
                    }
                    if(allStoreLocationsWithjunctionId.get(aapt.id).Assets1__r.size()>0){
                        for(Asset__c assetInfo : allStoreLocationsWithjunctionId.get(aapt.id).Assets1__r){
                            prodcutIdSet.add(assetInfo.Product__c);
                        }
                    }
                }
            }
        }
        
        Map<id,Product2> banProductMap = new Map<Id,Product2> ([select id,Flavor_Family__c,Pod_Strength__c From Product2 where id IN: prodcutIdSet]);
        try{
            for(AccountActionPlanTemplate__c wd: accountActionPlanTemplateList){
                aptIdSet.add(wd.ActionPlanTemplateId__c);
                //system.debug('sub test ');
                APTRecordType = wd.ActionPlanTemplateId__r.recordType.DeveloperName;
                APRecordType =  Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get(APTRecordType).getRecordTypeId();
                missionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get(APTRecordType).getRecordTypeId();
                if(APTRecordType == 'AccountPlan')
                    storeCategory = 'Account Plan';
                if(APTRecordType == 'PromotionalActivityProcess')
                    storeCategory='Promotion';
                if(APTRecordType == 'ResetActivityProcess')
                    storeCategory ='Reset';
                if(rsgAccount.get(wd.id) != null){
                    //System.debug('Inside Instorelocation 1');
                    for(Id a: accSet){
                        //System.debug('Inside Instorelocation 2');
                        if(rsgAccount.get(wd.id).contains(a)){
                            String storeLocationKey = wd.id+'-'+a;
                            if(!ISLMap.containsKey(storeLocationKey)){
                            String currentAccountState='';
                            //System.debug('Inside Instorelocation 3');
                            if(rsgAccountStateMap.containsKey(a))
                                currentAccountState = '-' + rsgAccountStateMap.get(a);
                            InStoreLocation__c sl;
                            //System.debug('Inside Instorelocation 4');
                            sl = new InStoreLocation__c();
                            sl.RetailStoreGroupActionPlanTemplate__c = wd.id;
                            sl.RetailLocationId__c = a;
                            sl.Active__c = True;
                            sl.Category__c = storeCategory;
                            sl.StartDate__c = wd.ActionPlanTemplateId__r.RequestedStartDate__c;
                            sl.EndDate__c =wd.ActionPlanTemplateId__r.RequestedEndDate__c;
                            sl.Status__c ='Executed';
                        
                            String accComplianceMechanism ='';
                            if(!accComplianceMap.isEmpty() && accComplianceMap.containsKey(a))
                                accComplianceMechanism= accComplianceMap.get(a);
                            String slKey = sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c;
                            storeLocationsListToUpsert.put(slKey,sl);
                            //Store Products and Asserts Insertion
                            //System.debug('check-1 '+commActivityWithProductsLocal);
                        
                            if(!accComplianceMechanism.contains('Category Ban')){
                                Map<Id,List<StoreProduct__c>> relatedStoreProducts = new Map<Id,List<StoreProduct__c>>();
                                Map<Id,List<Asset>> relatedAsset = new Map<Id,List<Asset>>();
                                //System.debug('size of InstoreLocation '+allStoreLocationsWithjunctionId.size());
                                //System.debug('size of storepoducts++'+allStoreLocationsWithjunctionId.get(wd.id).Store_Products__r.size());
                                if(allStoreLocationsWithjunctionId.containsKey(wd.id)){
                                    if(allStoreLocationsWithjunctionId.get(wd.id).Store_Products__r.size()>0){
                                        for(StoreProduct__c spInfo : allStoreLocationsWithjunctionId.get(wd.id).Store_Products__r){
                                            //System.debug('check-2 '+spInfo.InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id+'-'+spInfo.ProductId__c);
                                            CommercialActivityProduct__c capRecord = commActivityWithProductsLocal.get(spInfo.InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id+'-'+spInfo.ProductId__c);
                                            //List<Product2> banProduct = [select id,Flavor_Family__c,Pod_Strength__c From Product2 where id =: spInfo.ProductId__c];
                                            //System.debug('Inside Instorelocation '+capRecord);
                                            if(!(accComplianceMechanism.contains('Menthol Ban') && banProductMap.get(spInfo.ProductId__c).Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '5%')){
                                                if(capRecord.ProductType__c == 'JUUL Product'){
                                                    //System.debug('Inside Instorelocation 7');
                                                    StoreProduct__c sp = new StoreProduct__c();
                                                    //Added by Shreya for SFDC - 0000004228 
                                                    if(capRecord.Product_Bundle__c!=null &&(capRecord.Product_Bundle__c == 'Combo' || capRecord.Product_Bundle__c =='GetxSavex'))
                                                        sp.Product_Bundle__c = capRecord.Product_Bundle__c;
                                                    if(capRecord.Product_bundle_Description__c!=null)
                                                        sp.Product_Bundle_Description__c = capRecord.Product_bundle_Description__c;
                                                        sp.RetailStoreId__c= a;
                                                        sp.ProductId__c = spInfo.ProductId__c;
                                                    if(capRecord.Id != null)
                                                        sp.Source_Product_Id__c = capRecord.Id;
                                                    // commented by juturi
                                                    // if(pricingMatricData.containsKey(c.Id + currentAccountState))
                                                    // sp.PricingMatrixId__c = pricingMatricData.get(c.Id + currentAccountState).id;
                                                    string commercialActivityId =spInfo.InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id;
                                                    if(commercialAcitvityProductPriceLocal.containsKey(commercialActivityId+'-'+spInfo.ProductId__c + currentAccountState))  // added by juturi
                                                    sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPriceLocal.get(commercialActivityId+'-'+spInfo.ProductId__c + currentAccountState).Id; // added by juturi
                                                    //added by Shreys for ticket SFDC - 0000003131
                                                    sp.STD_JUUL_Funding__c = spInfo.STD_JUUL_Funding__c;  //sr01
                                                    sp.JUUL_Tax_Funding__c = spInfo.JUUL_Tax_Funding__c;  //sr02
                                                    sp.Retailer_Funding__c = spInfo.Retailer_Funding__c;  //sr03
                                                    //Added for JTP 167 
                                                    sp.Active__c = True;
                                                    //sp.Differentiator__c = c.differentiator;
                                                    sp.DefaultOrderQuantity__c = spInfo.DefaultOrderQuantity__c;
                                                
                                                    if(!StoreLocationStoreProductMap.containsKey(slKey))
                                                        StoreLocationStoreProductMap.put(slKey,new List<StoreProduct__c>());
                                                    StoreLocationStoreProductMap.get(slKey).add(sp);
                                                
                                                } 
                                            }
                                        }
                                    }
                                    //System.debug('Size of Assests'+allStoreLocationsWithjunctionId.get(wd.id).Assets1__r.size());
                                    if(allStoreLocationsWithjunctionId.get(wd.id).Assets1__r.size()>0){
                                        for(Asset__c assetInfo : allStoreLocationsWithjunctionId.get(wd.id).Assets1__r){
                                            CommercialActivityProduct__c capRecord = commActivityWithProductsLocal.get(assetInfo.InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id+'-'+assetInfo.Product__c);
                                            //List<Product2> banProduct = [select id,Flavor_Family__c,Pod_Strength__c From Product2 where id =: assetInfo.Product__c];
                                            if(!(accComplianceMechanism.contains('Menthol Ban') && banProductMap.get(assetInfo.Product__c).Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProductMap.get(assetInfo.Product__c).Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProductMap.get(assetInfo.Product__c).Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProductMap.get(assetInfo.Product__c).Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProductMap.get(assetInfo.Product__c).Pod_Strength__c == '5%')){
                                                if(capRecord.ProductType__c == 'Trade Collateral'){
                                                    Asset ass = new Asset();
                                                    ass.AccountId =  a;
                                                    ass.Product2Id =assetInfo.Product__c;
                                                    ass.Unit_Price__c = assetInfo.Unit_Price__c;
                                                    ass.name= assetInfo.name;
                                                    ass.Source_Product_Id__c = capRecord.Id;
                                                    ass.Quantity =assetInfo.Quantity__c;
                                                    ass.Active__c = True;
                                                    if(!StoreLocationAssetMap.containsKey(slKey))
                                                        StoreLocationAssetMap.put(slKey,new List<Asset>());
                                                    StoreLocationAssetMap.get(slKey).add(ass);
                                                    //start
                                                    Asset__c ass1 = new Asset__c();
                                                    ass1.Account__c =  a;
                                                    ass1.Product__c = assetInfo.Product__c;
                                                    ass1.Unit_Price__c = assetInfo.Unit_Price__c;
                                                    ass1.name= assetInfo.name;
                                                    ass1.Source_Product_Id__c = capRecord.Id;
                                                    ass1.Quantity__c =assetInfo.Quantity__c;
                                                    ass1.Active__c = True;
                                                    if(!StoreLocationCustomAssetMap.containsKey(slKey))
                                                        StoreLocationCustomAssetMap.put(slKey,new List<Asset__c>());
                                                    StoreLocationCustomAssetMap.get(slKey).add(ass1);
                                                    //end
                                                }
                                            }
                                
                                        }
                                    }
                                }
                            }
                        }
                    }
                        
                    }
                }
                wd.cascadeToDoor__c = true;
                update wd;
            }
            if(storeLocationsListToUpsert.values() != null){
                //System.debug('Inside Instorelocation 8'+storeLocationsListToUpsert);
                upsert storeLocationsListToUpsert.values();
                for(String sl :storeLocationsListToUpsert.Keyset()){
                    //Update Store Location in Store Product
                    if(StoreLocationStoreProductMap.get(sl) != null){
                        for(StoreProduct__c sp: StoreLocationStoreProductMap.get(sl)){
                            sp.InStoreLocationId__c = storeLocationsListToUpsert.get(sl).id;
                            spToInsert.add(sp);
                        }
                    }
                    if(StoreLocationAssetMap.get(sl)!= null){
                        //Update Store Location in Asset
                        for(Asset a: StoreLocationAssetMap.get(sl)){
                            a.InStoreLocation__c = storeLocationsListToUpsert.get(sl).id;
                            assetToInsert.add(a);
                        }
                    }
                    if(StoreLocationCustomAssetMap.get(sl)!= null){
                        //Update Store Location in Asset
                        for(Asset__c a: StoreLocationCustomAssetMap.get(sl)){
                            a.InStoreLocation__c = storeLocationsListToUpsert.get(sl).id;
                            customAssetToInsert.add(a);
                        }
                    }
                }
            }
            //Insert SP and assets
            if (spToInsert != null && spToInsert.size() > 0) {
                //System.debug('Inside SPInsert');
                List<Database.SaveResult> spToInsertResults = Database.Insert(spToInsert, true);
                List<Database.Error> spToInsertError = new List <Database.Error> ();
                for (Integer index = 0, size = spToInsertResults.size(); index < size; index++) {
                    if (!spToInsertResults[index].isSuccess()) {
                        spToInsertError.addAll(spToInsertResults[index].getErrors());
                        
                    }
                }
                if (spToInsertError.size() > 0) {
                    System.debug('Inside Error SPInsert');
                    LogEventTriggerHandler.insertBatchLog(spToInsertError, class_Name,method_Name, 'Store Product', 'Database.Insert_Failed');
                }
            }
            
            //Insert Assets for commercial activity items
            if (assetToInsert != null && assetToInsert.size() > 0) {
                List < Database.SaveResult > assetToInsertResults = Database.Insert(assetToInsert, true);
                List < Database.Error > assetToInsertError = new List <Database.Error> ();
                for (Integer index = 0, size = assetToInsertResults.size(); index < size; index++) {
                    if (!assetToInsertResults[index].isSuccess()) {
                        assetToInsertError.addAll(assetToInsertResults[index].getErrors());
                        
                    }
                }
                if (assetToInsertError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(assetToInsertError, class_Name,method_Name, 'Asset', 'Database.Insert_Failed');
                }
            }
            //Insert Assets for commercial activity items
            if (customAssetToInsert != null && customAssetToInsert.size() > 0) {
                List < Database.SaveResult > customAssetToInsertResults = Database.Insert(customAssetToInsert, true);
                List < Database.Error > customAssetToInsertError = new List <Database.Error> ();
                for (Integer index = 0, size = customAssetToInsertResults.size(); index < size; index++) {
                    if (!customAssetToInsertResults[index].isSuccess()) {
                        customAssetToInsertError.addAll(customAssetToInsertResults[index].getErrors());
                        
                    }
                }
                if (customAssetToInsertError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(customAssetToInsertError, class_Name,method_Name, 'Asset__c', 'Database.Insert_Failed');
                }
            }
            
            
          
        }catch(Exception e){
            errorMessegeList.add(e.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC){
        //execute this peice
        //Delete when Door removed/unlink from parent Account
        AsyncApexJob batchJob = [Select Id, CompletedDate,Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, CreatedById
                          from AsyncApexJob where Id =:BC.getJobId()];
        List<String> toAddresses = new List<String>();
        toAddresses.addAll((Label.BatchUserIDs).split(','));
        
        if(batchJob.Status == 'Completed' && batchJob.NumberOfErrors ==0) {
            if(ISLMap.size() > 0){
                for(InStoreLocation__c isl : ISLMap.values()){
                    if(!rsgAccount.get(isl.RetailStoreGroupActionPlanTemplate__c).contains(isl.RetailLocationId__c)){
                        system.debug('RetailStoreGroupActionPlanTemplate__c++ '+isl.RetailStoreGroupActionPlanTemplate__c);
                        System.debug('isl.RetailLocationId__c++ '+isl.RetailLocationId__c);
                        system.debug('APPTaccIds++ '+rsgAccount.get(isl.RetailStoreGroupActionPlanTemplate__c));
                        deleteaccountIdSet.add(isl.RetailLocationId__c);
                        instoreLocationIdSet.add(isl.id); 
                    }
                }
            
                List<StoreProduct__c> storeProductList = [select id from StoreProduct__c where InStoreLocationId__c IN: instoreLocationIdSet];
                List<Asset>  assetList =[select id from Asset where InStoreLocation__c IN: instoreLocationIdSet];
                List<Asset__c> customAssetList =[select id from Asset__c where InStoreLocation__c IN: instoreLocationIdSet];
                List<InStoreLocation__c> instorelocationList =[select id,RetailStoreGroupActionPlanTemplate__c, RetailLocationId__c from InStoreLocation__c where id IN: instoreLocationIdSet];
        
                if(customAssetList.size()>0){
                    delete customAssetList;
                }
                if(assetList.size()>0){
                    delete assetList;
                }
                if(storeProductList.size()>0){
                    delete storeProductList;
                }
                if(instorelocationList.size()>0){
                    delete instorelocationList;
                }
                System.debug('deleteaccountIdSet'+deleteaccountIdSet);
                System.debug('deleteaccountIdSet'+deleteaccountIdSet.size());
            }
            
            List<ActionPlanTemplate__c> actionPlanTemplate = new List<ActionPlanTemplate__c>();
            for(ActionPlanTemplate__c aptlist : [SELECT Id, In_Store_Locations_Refreshed__c FROM ActionPlanTemplate__c WHERE Id IN : actionPlanTemplateId]){
                aptlist.In_Store_Locations_Refreshed__c = true;
                actionPlanTemplate.add(aptlist);
            }
            if(actionPlanTemplate.size()>0){
                update actionPlanTemplate;
            }
            List<id> accountList = new List<Id>();
            List<AccountActionPlanTemplate__c> ApptLocationUpdateList = new List<AccountActionPlanTemplate__c>();
            for(AccountActionPlanTemplate__c aapt : actionPlantemplateList){
                accountList = rsgAccount.get(aapt.Id);
                aapt.Grouped_Store_Locations__c=accountList.size();
                ApptLocationUpdateList.add(aapt);
            }
            if(ApptLocationUpdateList.size()>0){
                update ApptLocationUpdateList;
            }
        }
        d = Label.Days;
        Date oldDate1  = system.today().addDays(Integer.valueof(d));
        List<Actionplantemplate__c> aptListToProcess = new List<Actionplantemplate__c>();
        string aPtApproved ='APT Approved & Locked';
        for(Actionplantemplate__c apt1 :[SELECT Id,recordtype.name,Status__c,Mass_Cascade_Active_Flag_Date__c,RequestedStartDate__c,Mass_Cascade_Flag__c,CommercialActivityId__c FROM actionplantemplate__c WHERE ((RequestedStartDate__c  <=: oldDate1 and RequestedStartDate__c >: system.today()) OR Mass_Cascade_Flag__c = true) and Status__c =: aPtApproved and In_Store_Locations_Created__c = true and Missions_Created__c != true and In_Store_Locations_Refreshed__c != true] )
        {  
            aptListToProcess.add(apt1);
        }
        if(aptListToProcess.size()>0)
        {
            Database.executeBatch(new APTRefreshISLsBatch(),2);
        }else{
            List<string> succussORfailledApts = new List<string>();
            succussORfailledApts.add('=== succuss apts ===');
            for(ActionPlanTemplate__c ActionPlanTemp : [select id from ActionPlanTemplate__c where LastModifiedDate = TODAY and Status__c='APT Approved & Locked' and In_Store_Locations_Created__c = true and In_Store_Locations_Refreshed__c = true and Missions_Created__c != true and LastModifiedById =: batchJob.CreatedById]){
                succussORfailledApts.add(ActionPlanTemp.id);
            }
            // if(ActionPlanTemp.size()>=0)
            //     totalAmtOfRecords = ActionPlanTemp.size();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.add(batchJob.CreatedBy.Email);
            mail.setToAddresses(toAddresses);
            mail.setSubject('ISL Refresh Batch Status');
            mail.setPlainTextBody
                ('Below is status of ISL Refresh batch job:'  + '\n\n' +
                 'Job Status : ' + batchJob.Status + '\n'+
                 'Job Id : ' + batchJob.ID + '\n'+
                 '' +(String.join(succussORfailledApts, '\n'))  +'\n' 
                );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
   
}