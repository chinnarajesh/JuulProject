public  class SubBatchOfAPTsInStoreLocationsBatch implements Database.Batchable<sObject>, Database.Stateful{
  
    public Set<id> accidSet = new Set<id>();
    public Map<String, Id> stateAaptIds = new  Map<String, Id>();
    public Map<Id,Set<Id>> aptAccountIdMap = new Map<Id,Set<Id>>();
    Map<id,Map<String, Id>> stateAPTAaptIds = new Map<id,Map<String, Id>>();
    public Set<Id> aptIdSet = new Set<Id>();
    public Set<Id> allAptIdsSet = new Set<Id>();
    public List<string> errorMessegeList = new List<string>();

    Map<String,CommercialActivityProduct__c> commActivityWithProductsLocal = new Map<String,CommercialActivityProduct__c>();
    Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPriceLocal = new Map<String,Commercial_Activity_Product_Pricing__c>();

    public SubBatchOfAPTsInStoreLocationsBatch(Map<Id,Set<Id>> accountIdMap ,  Map<id,Map<String, Id>> aaptMapValues,Map<String,CommercialActivityProduct__c> commActivityWithProducts,Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice,Set<Id> allActionPlanTemplateIds){
      allAptIdsSet=allActionPlanTemplateIds;
      aptAccountIdMap=accountIdMap;
      stateAPTAaptIds=aaptMapValues;
      commActivityWithProductsLocal = commActivityWithProducts;
      commercialAcitvityProductPriceLocal = commercialAcitvityProductPrice;

    }

    public Database.Querylocator start (Database.BatchableContext BC) {

         //String query = 'SELECT ID,ShippingState, Name, ParentID,Type,ComplianceMechanism__c  FROM Account WHERE ParentID IN : aptAccountIdMap.values';

         return Database.getQueryLocator([SELECT ID,ShippingState, Name, ParentID,Type,ComplianceMechanism__c  FROM Account WHERE ParentID IN : aptAccountIdMap.keySet()]);
    }
    
    public void execute (Database.BatchableContext BC,List<Account> ChildAccounts) {

        Integer maxDeepLevel = 1;

        Map<id,String> rsgAccountStateMap = new Map<id,String>();

       // Map<Id,Map<id,String>> rsgAccountStateMap = new Map<Id,Map<id,String>>();

        Map<id,String> accComplianceMap = new Map<id,String>();

        Map<Id,List<Id>> rsgAccount = new Map<Id,List<Id>>();
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
                        System.debug('stateAaptIdsNew+'+stateAaptIdsNew);
                        for( id aptids : stateAaptIdsNew.keySet()){
                            if(stateAaptIdsNew.get(aptids).containsKey(ChildAccounts[i].ShippingState)){
                                System.debug('aptidsInMap++'+stateAaptIdsNew.get(aptids).get(ChildAccounts[i].ShippingState));
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
                        }
                    }
                    queryIDs.add(ChildAccounts[i].id);
                    firstLevelParentIdWithChilds.put(ChildAccounts[i].id,ChildAccounts[i].parentID);
                }
                System.debug('1 level Deep Ids-'+queryIDs);
                System.debug('1 level Deep Ids count-'+queryIDs.size());
                //allActsCnt = allActsCnt + queryIDs.size();
                while (queryIDs.size() > 0) {
                    // Map<Id,Set<Id>> secongLevelParentWithChildsIdSet = new Map<Id,Set<Id>>();
                    List <Account> childAccount = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState,Type,ComplianceMechanism__c,ParentID From ChildAccounts) FROM Account WHERE ID IN :queryIDs ];        
                    queryIDs.clear();
                    if(maxDeepLevel < 7){
                        System.debug('maxDeepLevel '+maxDeepLevel);
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

                                            
                                         }
                                    }
                                    queryIDs.add(oneAcc.ChildAccounts[i].id);
                                }  
                            }    
                        }   
                        maxDeepLevel = maxDeepLevel+1; 
                        if(queryIDs.size() > 0){
                            // System.debug(maxDeepLevel+' level Deep Ids-'+queryIDs);
                            // System.debug(maxDeepLevel+' level Deep Ids count-'+queryIDs.size());
                        }
                    }    
                }
            }
        Set<Id> accSet = new Set<Id>();
        for(Id a: rsgAccountStateMap.keySet()){
            accSet.add(a);
        }
        System.debug('accSet '+accSet.size());
        System.debug('methos check');
        Map<Id,Id> rsgPlanogramsToUpdate = new Map<Id,Id>();

        System.debug('rsgAccount***'+rsgAccount);
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

        system.debug('aaptIds List'+rsgAccount.keySet());

        rsgAccount.remove(null);

        system.debug('aaptIds List22'+rsgAccount.keySet());


        //Getting Account Action Plan Template Store Products and Assets
        Map<Id,InStoreLocation__c> allStoreLocationsWithjunctionId = new Map<Id,InStoreLocation__c>();
        Set<Id> commercialActivityIds  = new Set<Id>();
        //Map<String,InStoreLocation__c> IslDuplicateCheckMap = new Map<String,InStoreLocation__c>();

        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c,PlanogramId__c,PlanogramId__r.Name,InStoreLocationType__c,RetailLocationId__r.Type,RetailLocationId__c,Category__c,(Select id, Product_Bundle__c,Product_Bundle_Description__c,STD_JUUL_Funding__c ,Retailer_Funding__c,Final_PTC__c,JUUL_Tax_Funding__c,Differentiator__c,DefaultOrderQuantity__c,SuggestedMSRP__c,Source_Product_Id__c,Commercial_Activity__c,ProductId__c,InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id from Store_Products__r where Active__c = true ),(Select Id,Name,Quantity,Differentiator__c,Source_Product_Id__c,Unit_Price__c,CostForCollateral__c,Product2Id,InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id From Assets__r where Active__c = true ),(Select Id,Name,Quantity__c,Differentiator__c,Source_Product_Id__c,Unit_Price__c,CostForCollateral__c,Product__c,InStoreLocation__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id  From Assets1__r where Active__c = true) from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :rsgAccount.keySet() AND Active__c = True and RetailLocationId__r.Type = 'HQ']){ 
            //Need to Remove RetailLocationId__r.Type = 'HQ' from Query and uncomment IslDuplicateCheckMap section when we want to avoid duplicates 
            system.debug('in instorelocation for loop');
            system.debug('action plan template '+s.RetailStoreGroupActionPlanTemplate__c);
            if(s.RetailLocationId__r.Type =='HQ'){
                allStoreLocationsWithjunctionId.put(s.RetailStoreGroupActionPlanTemplate__c,s);
            }
        //   if(s.RetailLocationId__r.Type !='HQ'){
        //       IslDuplicateCheckMap.put(s.RetailStoreGroupActionPlanTemplate__c+'-'+s.RetailLocationId__c,s);
        //   }
        }


        List<AccountActionPlanTemplate__c> accountActionPlanTemplateList =[select id,name,Account__c,Grouped_State__c,ActionPlanTemplateId__c,ActionPlanTemplateId__r.recordType.DeveloperName ,ActionPlanTemplateId__r.RequestedStartDate__c,ActionPlanTemplateId__r.RequestedEndDate__c from AccountActionPlanTemplate__c where id IN: rsgAccount.keySet()];
        System.debug('accountActionPlanTemplateList '+accountActionPlanTemplateList);

        Set<Id> prodcutIdSet = new Set<Id>();
        for(AccountActionPlanTemplate__c aapt : accountActionPlanTemplateList){
            if(allStoreLocationsWithjunctionId.size()>0){
                if(allStoreLocationsWithjunctionId.containsKey(aapt.id)){
                    system.debug('mytest'+allStoreLocationsWithjunctionId.get(aapt.id).Store_Products__r);
                    system.debug('mytest'+(allStoreLocationsWithjunctionId.get(aapt.id).Store_Products__r).size());
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
                system.debug('sub test ');
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
                    System.debug('Inside Instorelocation 1');
                    for(Id a: accSet){
                        System.debug('Inside Instorelocation 2');
                        if(rsgAccount.get(wd.id).contains(a)){
                            String storeLocationKey = wd.id+'-'+a;
                          // checking the Isls are Duplicats are not
                          //if(!IslDuplicateCheckMap.containsKey(storeLocationKey)){
                            String currentAccountState='';
                            System.debug('Inside Instorelocation 3');
                            if(rsgAccountStateMap.containsKey(a))
                                currentAccountState = '-' + rsgAccountStateMap.get(a);
                            InStoreLocation__c sl;
                            System.debug('Inside Instorelocation 4');
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
                            System.debug('check-1 '+commActivityWithProductsLocal);
                        
                            if(!accComplianceMechanism.contains('Category Ban')){

                                Map<Id,List<StoreProduct__c>> relatedStoreProducts = new Map<Id,List<StoreProduct__c>>();
                                Map<Id,List<Asset>> relatedAsset = new Map<Id,List<Asset>>();

                                //System.debug('size of InstoreLocation '+allStoreLocationsWithjunctionId.size());
                                //System.debug('size of storepoducts++'+allStoreLocationsWithjunctionId.get(wd.id).Store_Products__r.size());

                                if(allStoreLocationsWithjunctionId.containsKey(wd.id)){

                                    if(allStoreLocationsWithjunctionId.get(wd.id).Store_Products__r.size()>0){


                                        for(StoreProduct__c spInfo : allStoreLocationsWithjunctionId.get(wd.id).Store_Products__r){

                                            System.debug('check-2 '+spInfo.InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id+'-'+spInfo.ProductId__c);

                                            CommercialActivityProduct__c capRecord = commActivityWithProductsLocal.get(spInfo.InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.CommercialActivityId__r.Id+'-'+spInfo.ProductId__c);

                                            //List<Product2> banProduct = [select id,Flavor_Family__c,Pod_Strength__c From Product2 where id =: spInfo.ProductId__c];

                                            System.debug('Inside Instorelocation '+capRecord);
                                            if(!(accComplianceMechanism.contains('Menthol Ban') && banProductMap.get(spInfo.ProductId__c).Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProductMap.get(spInfo.ProductId__c).Pod_Strength__c == '5%')){

                                                if(capRecord.ProductType__c == 'JUUL Product'){
                                                    System.debug('Inside Instorelocation 7');
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
                                    System.debug('Size of Assests'+allStoreLocationsWithjunctionId.get(wd.id).Assets1__r.size());

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
                                                    //Added for JTP 167 
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
                                                    //Added for JTP 167 
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
                        //}
                    }
                        
                 }
                }
                wd.cascadeToDoor__c = true;
                update wd;
            }

            if(storeLocationsListToUpsert.values() != null){
                System.debug('Inside Instorelocation 8'+storeLocationsListToUpsert);
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

                    //Added by Jyoti SFDC - 0000004342
                    //start
                    if(StoreLocationCustomAssetMap.get(sl)!= null){
                        //Update Store Location in Asset
                        for(Asset__c a: StoreLocationCustomAssetMap.get(sl)){
                            a.InStoreLocation__c = storeLocationsListToUpsert.get(sl).id;
                            customAssetToInsert.add(a);
                        }
                    }
                    //end
                    //start---Added for ticket SFDC - 0000003394    //commented for reversed approach
                    /*if(StoreLocationMissionMap.get(sl)!= null){ 
                        //Update Store Location in Mission  
                        for(Mission__c m: StoreLocationMissionMap.get(sl)){ 
                        m.InStoreLocationId__c = storeLocationsListToUpsert.get(sl).id;  
                            missionToInsert.add(m); 
                        }   
                    }  */ 
                    //end---Added for ticket SFDC - 0000003394
                }
            }

            //Insert SP and assets
            if (spToInsert != null && spToInsert.size() > 0) {
                System.debug('Inside SPInsert');
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

    public void finish(Database.BatchableContext BC){
         



        AsyncApexJob j = [Select Id, Status,CompletedDate,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
        List<String> toAddresses = new List<String>();
        toAddresses.addAll((Label.BatchUserIDs).split(','));

        System.debug('Finish batch'+j.Status);
        List<ActionPlanTemplate__c> actionPlanTemplate = new List<ActionPlanTemplate__c>();
        List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
        List<string> succussORfailledApts = new List<string>();

        Set<Id> failledAptIdSet = new Set<id>();

        for(Id aptId : allAptIdsSet){
            if(!aptIdSet.contains(aptId)){
                failledAptIdSet.add(aptId);
            }

        }
        succussORfailledApts.add('=== succuss apts ===');

        if(j.NumberOfErrors > 0) {
            for(ActionPlanTemplate__c aptlist : [SELECT Id, Name, ActionPlanType__c,RecordType.DeveloperName, AccountId__c,In_Store_Locations_Created__c,Batch_Details__c,    Batch_Status__c,Cascade_Changes__c,Status__c FROM ActionPlanTemplate__c WHERE Id IN : failledAptIdSet]){
                aptlist.Batch_Details__c='Committed to Forecast Failed '+j.CompletedDate;
                actionPlanTemplate.add(aptlist);
            }
        }
           //System.debug('J Status is'+aptlist.Batch_Status__c);

        if(j.Status == 'Completed') {
            for(ActionPlanTemplate__c aptlist : [SELECT Id, Name, ActionPlanType__c,RecordType.DeveloperName, AccountId__c,In_Store_Locations_Created__c,Batch_Details__c,    Batch_Status__c,Cascade_Changes__c,Status__c FROM ActionPlanTemplate__c WHERE Id IN : aptIdSet]){
                succussORfailledApts.add(aptlist.id);
                //Added for 'Cascade changes' button visibility on LWC
                aptlist.Batch_Details__c='Committed to Forecast Completed '+j.CompletedDate;
                System.debug('Inside completed batch details');
                aptlist.Cascade_Changes__c=True;
                if(aptlist.RecordType.DeveloperName == 'ResetActivityProcess'){
                //aptlist.Status__c = 'Cascade Mission to Doors';
                }
                aptlist.In_Store_Locations_Created__c=true;
                actionPlanTemplate.add(aptlist);
            }
            
        }
        if(j.Status == 'Failed' && j.NumberOfErrors > 0){
           for(AccountActionPlanTemplate__c a :[select id,cascadeToDoor__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c IN : aptIdSet]){
                a.cascadeToDoor__c = false;
                cascadeToDoorList.add(a);
            }
        }
        if(j.Status == 'Completed' && failledAptIdSet.size()>0){
            for(AccountActionPlanTemplate__c a :[select id,cascadeToDoor__c,ActionPlanTemplateId__r.Batch_Details__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c IN : failledAptIdSet]){
                a.cascadeToDoor__c = false;
                a.ActionPlanTemplateId__r.Batch_Details__c='Committed to Forecast Failed '+j.CompletedDate;
                cascadeToDoorList.add(a);
            }
        }
        if(cascadeToDoorList.size()>0){
            update cascadeToDoorList;
        }
        if(actionPlanTemplate.size()>0){
            update actionPlanTemplate;

            //To Create Missions for APT after In-Store Locations are created successfully
            //KAMMissionBatch missionsBatch = new KAMMissionBatch();
            //Database.executeBatch(missionsBatch, 2);
        }

        String userId = UserInfo.getUserId();
        user us =[select id,Email from user where id =: userId];
        succussORfailledApts.add('=== failled apts ===');

        if(failledAptIdSet.size()>0){
            for(id apt : failledAptIdSet){
                succussORfailledApts.add(apt);
            }
        }
        if(failledAptIdSet.size()>0 || succussORfailledApts.size()>0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.add(j.CreatedBy.Email);
            mail.setToAddresses(toAddresses);
            mail.setSubject(' In-Store Locations Creation Batch Status');
            //mail.setPlainTextBody(String.join(succussORfailledApts, '\n')+String.join(errorMessegeList, '\n'));
            mail.setPlainTextBody
            ('Below is status of In-Store Locations Creation job:'  + '\n\n' +
                'Job Status : ' + j.Status + '\n'+
                'Job Id : ' + j.ID + '\n'+
                '' +(String.join(succussORfailledApts, '\n'))  +'\n' +
                'Failed APTs: '+ String.join(errorMessegeList, '\n')
            );
            //mail.setPlainTextBody(String.join(errorMessegeList, '\n'));
        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        
    }
}