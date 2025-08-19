/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Shreya Raut       02-01-2021                     */
/* Class Name: KamAccountPlanning                       */
/* Description: To create Instorelocation, asset and Store product records on Action Plan Template object */
/**********************************************************************/
Public class KamBatchAccountPlanningforProducts implements Database.Batchable<sobject>{
    Public set<Id> accountIds;
    Map<String,List<Id>> stateWiseAccounts = new Map<String,List<Id>>();
    Private Id aptId;
    public String class_Name ='KamBatchAccountPlanningforProducts';
    String method_Name='Execute';
    String operationType = 'Database.Insert_Failed';
    List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
    Set<id> selectedRsgList = new Set<Id>();
    //Map<Id,List<Id>> rsgAccount = new Map<Id,List<Id>>();
    Map<Id,List<KAMAccountPlanning.Items>> rsgAptItems = new  Map<Id,List<KAMAccountPlanning.Items>>();
    Map<ActionPlan__c,Mission__c> missionAP = new Map<ActionPlan__c,Mission__c>();
    Map<ActionPlan__c,List<ActionPlanItem__c>> apAPItems = new Map<ActionPlan__c,List<ActionPlanItem__c>>();
    Map<ActionPlanItem__c,MissionTask__c> mTaskAptItemMap = new Map<ActionPlanItem__c,MissionTask__c>();
    Map<Mission__c,List<MissionTask__c>> missionMTaskList = new Map<Mission__c,List<MissionTask__c>>();
    Map<String,String> APTMissionFieldsMap = new Map<String,String>();
    Map<String,String> APTIMtaskFieldsMap = new Map<String,String>();
    Set<Id> allAPTIList = new Set<Id>();
    List<ActionPlanTemplateItem__c> selectedAPTIListQueried = new List<ActionPlanTemplateItem__c>();
    Map<Id,ActionPlanTemplateItem__c> aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>();
    List<Data_Mapping__mdt> APTMissionMapping = new List<Data_Mapping__mdt>();
    List<Data_Mapping__mdt> aptiMtaskMapping = new List<Data_Mapping__mdt>();
    List<KAMAccountPlanning.WrapperData> partialData = new List<KAMAccountPlanning.WrapperData>();
    //Map<id,String> accComplianceMap = new Map<id,String>();
    Set<Id> allSelectedProducts = new Set<Id>(); 
    Map<id,Product2> banProductList;
    Set<Id> junctionIds = new Set<Id>();
    Map<String,List<StoreProduct__c>> StoreLocationStoreProductMap = new Map<String,List<StoreProduct__c>>();
    Map<String,List<Asset>> StoreLocationAssetMap = new Map<String,List<Asset>>();
   // Map<Id,InStoreLocation__c> allStoreLocationsWithjunctionId = new Map<Id,InStoreLocation__c>();
    Map<String, InStoreLocation__c> storeLocationsListToUpsert = new Map<String,InStoreLocation__c>();
   // List<InStoreLocation__c> sltoDeactivateList = new List<InStoreLocation__c>();
    List<StoreProduct__c> spToInsert = new List<StoreProduct__c>();
    List<Asset> assetToInsert = new List<Asset>();
    List<StoreProduct__c> existingRelatedStoreProducts = new List<StoreProduct__c>();
    List<Asset> existingAssets = new List<Asset>();
    //Added for ticket SFDC - 0000003394    
    //List<Mission__c> missionToInsert = new List<Mission__c>();//commented for reversed approach
   // Map<String,KAMAccountPlanning.WrapperData> accontWithWrapperMap = new map<String,KAMAccountPlanning.WrapperData>();
    ActionPlanTemplate__c selectedAPTQueried = new ActionPlanTemplate__c();
    Private List<KAMAccountPlanning.WrapperData> selectedData;
    Map<String,PricingMatrix__c> pricingMatricData = new Map<String,PricingMatrix__c>();
    Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice = new Map<string,Commercial_Activity_Product_Pricing__c>();
    List<CommercialActivityProduct__c> caItems = new List<CommercialActivityProduct__c>();
    Map<id,String> rsgParentaccountStateMap = new Map<id,String>();
    Map<id,String> rsgAccountStateMap = new Map<id,String>();

    //Added by Jyoti SFDC - 0000004342
    //start
    Map<String,List<Asset__c>> StoreLocationCustomAssetMap = new Map<String,List<Asset__c>>();
    List<Asset__c> customAssetToInsert = new List<Asset__c>();
    List<Asset__c> existingCustomAssets = new List<Asset__c>();
    //end
    //Added for ticket SFDC - 0000003394    
    //Map<String,List<Mission__c>> StoreLocationMissionMap = new Map<String,List<Mission__c>>();//commented for reversed approach
    String storeCategory ='';
    String sourceAPT = '';
    String sourceAPTI ='';
    String APTRecordType;
    Id APRecordType;
    Id missionRecordType;
    Boolean Cascadechanges;
    Set<ID> ISLAccountIDSet = new Set<ID>();
    Public set<Id> MissionaccountIds;

    public Integer maxDeepLevel = 1;
    Map<String, Id> stateAaptIds = new  Map<String, Id>();
    Set<string> stateGroupSet = new Set<string>();
    set<Id> accountIdSet = new Set<Id>();
    //Constructor
    public KamBatchAccountPlanningforProducts(Id aptId1, List<KAMAccountPlanning.WrapperData> selectedData1,Set<ID> ISLAccountID,Set<ID> MissionAccountID,Boolean CascadeChanges1){
        System.debug('Inside KAMBATCHPRODUCT constructor');
        aptId = aptId1;
        selectedData = selectedData1;
        Cascadechanges = Cascadechanges1;
        ISLAccountIDSet = ISLAccountID;
        MissionaccountIds = new set<ID>();
        MissionaccountIds = MissionAccountID;
        accountIds = new Set<Id>();
        //Get Action plan fields mappings from custom metadata types.
        APTMissionMapping=[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplate__c' AND Target_Object__c ='Mission__c'];
        for(Data_Mapping__mdt data: APTMissionMapping){
            APTMissionFieldsMap.put(data.Source_Field__c,data.Target_Field__c);  
            sourceAPT += data.Source_Field__c+',';
        }
        if(sourceAPT.endsWith(',')){
            sourceAPT = sourceAPT.substring(0, sourceAPT.length() - 1);
        }
        
        String queryAPT = 'Select Id,Batch_Details__c,CascadeChangesBatch__c,RecordType.DeveloperName, Status__c,CommercialActivityId__c,Batch_Status__c,Cascade_Changes__c,In_Store_Locations_Created__c,'  +sourceAPT+' From ActionPlanTemplate__c Where id =:aptId';
        selectedAPTQueried =Database.query(queryAPT);
        
        APTRecordType = selectedAPTQueried.recordType.DeveloperName;
        APRecordType =  Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get(APTRecordType).getRecordTypeId();
        missionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get(APTRecordType).getRecordTypeId();
        if(APTRecordType == 'AccountPlan')
            storeCategory = 'Account Plan';
        if(APTRecordType == 'PromotionalActivityProcess')
            storeCategory='Promotion';
        if(APTRecordType == 'ResetActivityProcess')
            storeCategory ='Reset';
        
        //Get Mapping of Action plan template items.
        aptiMtaskMapping =[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplateItem__c' AND Target_Object__c ='MissionTask__c'];
        for(Data_Mapping__mdt data :aptiMtaskMapping){
            aptiMtaskFieldsMap.put(data.Source_Field__c,data.Target_Field__c); 
            sourceAPTI += data.Source_Field__c+',';
        } 
        if(sourceAPTI.endsWith(',')){
            sourceAPTI = sourceAPTI.substring(0, sourceAPTI.length() - 1);
        }
        
        String queryAPIMapping = 'Select Id,'  +sourceAPTI+' From ActionPlanTemplateItem__c Where ActionPlanTemplateId__c = \''+selectedAPTQueried.Id+'\'';
       
        selectedAPTIListQueried =Database.query(queryAPIMapping);
        aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>(selectedAPTIListQueried);
       
        //Modified by Ramya -ticket SFDC-0000004199, SFDC-0000004200
        DateTime dt = selectedAPTQueried.RequestedStartDate__c;  //rm02
        DateTime dtEnd = selectedAPTQueried.RequestedEndDate__c; //sr01
        Date newD = Date.valueOf(dt);         //rm04
        Date EndD = Date.valueOf(dtEnd);      //sr02
        Date Today = Date.valueOf(System.today()); //sr03
        //commented by juturi JTP-1393
        // for(PricingMatrix__c prm: [Select id,Start_Date__c,End_Date__c,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c,ProductId__r.Name from PricingMatrix__c WHERE Start_Date__c < Today and End_Date__c > Today]){ //Active__c = True //rm06
        //     if(prm.ProductId__c !=null && prm.StateTerritoryISO2__c != null){
        //         String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
        //         pricingMatricData.put(s,prm);
        //     }
        // }
        //added by juturi
        Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c, (select id,name,Commercial_Activity_Product__r.ProductId__c,Price__c,State_ISO2__c from Commercial_Activity_Product_Pricings__r) from CommercialActivityProduct__c where CommercialActivityId__c =: selectedAPTQueried.CommercialActivityId__c and ProductType__c ='JUUL Product']);

        for(CommercialActivityProduct__c capList : commercialActivityProductMap.values()){
            for(Commercial_Activity_Product_Pricing__c cappData : capList.Commercial_Activity_Product_Pricings__r){
                if(cappData.Commercial_Activity_Product__r.ProductId__c !=null && cappData.State_ISO2__c != null){
                              string  s = cappData.Commercial_Activity_Product__r.ProductId__c+'-'+cappData.State_ISO2__c;
                              commercialAcitvityProductPrice.put(s,cappData);
              }
          }
        }
        // for(Commercial_Activity_Product_Pricing__c capp : [select id,name,State__c,Commercial_Activity_Product__r.ProductId__c,
        // State_ISO2__c,Price__c  from Commercial_Activity_Product_Pricing__c where Commercial_Activity_Product__c IN: commercialActivityProductMap.keyset()]){
        //         if(capp.Commercial_Activity_Product__r.ProductId__c !=null && capp.State_ISO2__c != null){
        //             string  s = capp.Commercial_Activity_Product__r.ProductId__c+'-'+capp.State_ISO2__c;
        //             commercialAcitvityProductPrice.put(s,capp);
        //           }
        //      }
        // ended by juturi
        if(selectedAPTQueried.CommercialActivityId__c != null){
            caItems = [Select id,ProductId__c ,ProductId__r.Name,ProductType__c,CommercialActivityId__c,CollateralUnitCost__c  from CommercialActivityProduct__c  where CommercialActivityId__c= :selectedAPTQueried.CommercialActivityId__c AND HideItemWhilePlanning__c = true];
        }
        for(KAMAccountPlanning.WrapperData wd: selectedData){
          //  if(wd.selected && !wd.readOnly){ 
         
                partialData.add(wd);
                selectedRsgList.add(wd.Id);
           
                if(wd.Items != null && wd.Items.size()>0){
                    for(KAMAccountPlanning.Items i: wd.Items){
                        if(i.selected){
                            allAPTIList.add(i.Id);
                            if(!rsgAptItems.containsKey(wd.Id))
                                rsgAptItems.put(wd.Id,new List<KAMAccountPlanning.Items>());
                            rsgAptItems.get(wd.Id).add(i);
                        }
                    } 
                }
               
                if(wd.planogramProducts != null && wd.planogramProducts.size()>0){
                    for(KAMAccountPlanning.Products p : wd.planogramProducts){
                        allSelectedProducts.add(p.id);
                    }
                }
                if(wd.products != null && wd.products.size()>0){
                    for(KAMAccountPlanning.Products p: wd.products){
                        if(p.selected)
                            allSelectedProducts.add(p.id);
                    }
                }
                if(wd.CommercialActivityItems != null && wd.CommercialActivityItems.size()>0){
                    for(KAMAccountPlanning.CommercialActivityItems c: wd.CommercialActivityItems){
                        if(c.selected)
                            allSelectedProducts.add(c.id);
                    }
                }
                if(caItems.size()>0){
                    for(CommercialActivityProduct__c c:caItems){
                        allSelectedProducts.add(c.ProductId__c);
                    }
                }
           // }         
        } 
        System.debug('allSelectedProducts '+allSelectedProducts.size());
        
        banProductList =new Map<Id,Product2>([Select id,Flavor_Family__c,Pod_Strength__c From Product2 where id In: allSelectedProducts]);
        List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
        for(AccountActionPlanTemplate__c a :[select id,cascadeToDoor__c,Grouped_State__c from AccountActionPlanTemplate__c
                                             where id IN :selectedRsgList and ActionPlanTemplateId__c =: aptId]){
                                                 a.cascadeToDoor__c = true;
                                                 cascadeToDoorList.add(a);
                                                 stateGroupSet.add(a.Grouped_State__c);
                                                 
                                             }
        if(cascadeToDoorList.size()>0){
            update cascadeToDoorList;
        }
      
        // Make a map to store account ids respective to retail store group
        if(selectedRSGList != null && selectedRSGList.size() > 0){ 
           System.debug('selectedRSGList '+selectedRSGList);
            // Commented by juturi
            // for(AccountRetailStoreGroup__c arsg: [Select id,AccountId__c,RetailStoreGroupId__c,AccountId__r.ComplianceMechanism__c,AccountId__r.ShippingState from AccountRetailStoreGroup__c where AccountId__c IN :selectedRSGList and AccountId__c!=null and AccountId__r.Type != 'HQ']){    
                
            //     if(!rsgAccount.containsKey(arsg.AccountId__c)){
            //         rsgAccount.put(arsg.AccountId__c,new List<Id>());
            //     }
            //     rsgAccount.get(arsg.AccountId__c).add(arsg.AccountId__c);
                
            //     if(arsg.AccountId__r.ComplianceMechanism__c != null)
            //         accComplianceMap.put(arsg.AccountId__c,arsg.AccountId__r.ComplianceMechanism__c);
            //     else
            //         accComplianceMap.put(arsg.AccountId__c,'');
                
            //     if(arsg.AccountId__r.ShippingState != null)
            //         rsgAccountStateMap.put(arsg.AccountId__c,arsg.AccountId__r.ShippingState);
            //     else
            //         rsgAccountStateMap.put(arsg.AccountId__c,'');
            //     System.debug('!ISLAccountID.isEmpty() '+!ISLAccountID.isEmpty());
            //          System.debug(' ISLAccountID.size()>0'+ ISLAccountID.size() );
            //     //Added by shreya for ticket SFDC - 0000004466 
            //     if(Cascadechanges==true)
            //     {
            //         selectedAPTQueried.CascadeChangesBatch__c = true;
                    
                   
            //         accountIds = ISLAccountID;
            //     }else{
            //              accountIds.add(arsg.AccountId__c);
            //     }

            //    }




            

            
            
            for(AccountActionPlanTemplate__c aap :  [select id,name,Account__c,Grouped_State__c from AccountActionPlanTemplate__c where id =: selectedRSGList]){
                accountIdSet.add(aap.Account__c);
                stateAaptIds.put(aap.Grouped_State__c, aap.id);


                // List<id> stateAccountIds = new List<id>();
                // for(Account  arsg: [Select id,ComplianceMechanism__c,ShippingState,ParentId from account where ParentId =: aap.Account__c and ParentId !=null and Type != 'HQ' and ShippingState =: aap.Grouped_State__c ]){ 
                   
                //     stateAccountIds.add(arsg.id);
                // }
                // rsgAccount.put(aap.id,stateAccountIds);
            }
            //System.debug('rsgAccount++'+rsgAccount);

            // for(Account  arsg: [Select id,ComplianceMechanism__c,ShippingState,ParentId from account where ParentId IN :accountIdSet and ParentId !=null and Type != 'HQ' and ShippingState =: stateGroupSet]){    
                
            //     // if(!rsgAccount.containsKey(arsg.ParentId)){
            //     //     rsgAccount.put(arsg.ParentId,new List<Id>());
            //     // }
            //     // rsgAccount.get(arsg.ParentId).add(arsg.id);
                
            //     if(arsg.ComplianceMechanism__c != null)
            //         accComplianceMap.put(arsg.id,arsg.ComplianceMechanism__c);
            //     else
            //         accComplianceMap.put(arsg.id,'');
                
            //     if(arsg.ShippingState != null)
            //         rsgAccountStateMap.put(arsg.id,arsg.ShippingState);
            //     else
            //         rsgAccountStateMap.put(arsg.id,'');
            //     System.debug('!ISLAccountID.isEmpty() '+!ISLAccountID.isEmpty());
            //          System.debug(' ISLAccountID.size()>0'+ ISLAccountID.size() );
            //     //Added by shreya for ticket SFDC - 0000004466 
            //     if(Cascadechanges==true)
            //     {
            //         selectedAPTQueried.CascadeChangesBatch__c = true;
                    
                   
            //         accountIds = ISLAccountID;
            //     }else{
            //              accountIds.add(arsg.id);
                         
            //     }

            // }

            // for(RetailLocationGroup__c rs: [Select id, AccountId__c, Pricing_State__c from RetailLocationGroup__c where id IN: selectedRsgList]){
            //     if(rs.AccountId__c != null && rs.Pricing_State__c != null){
            //         rsgParentaccountStateMap.put(rs.Id,rs.Pricing_State__c);
            //     }
            // }
            for(AccountActionPlanTemplate__c rs: [Select id, Account__c, Grouped_State__c from AccountActionPlanTemplate__c where id IN: selectedRsgList]){
                if(rs.Account__c != null && rs.Grouped_State__c != null){
                    rsgParentaccountStateMap.put(rs.Account__c,rs.Grouped_State__c);
                }
            }
        }
        update selectedAPTQueried;
        for(KAMAccountPlanning.WrapperData w: partialData){
          String accountState='';
            if(rsgParentaccountStateMap.containsKey(w.accountId))
                accountState = '-' + rsgParentaccountStateMap.get(w.accountId);
            if(w.CommercialActivityItems != null && w.CommercialActivityItems.size()>0){
                for(CommercialActivityProduct__c cap: caItems){
                    KAMAccountPlanning.CommercialActivityItems ciWrapp = new KAMAccountPlanning.CommercialActivityItems();
                    ciWrapp.id = cap.ProductId__c;
                    ciWrapp.name = cap.ProductId__r.Name ;
                    ciWrapp.parentId = cap.Id;
                    ciWrapp.listPrice = cap.CollateralUnitCost__c;
                    ciWrapp.productType = cap.ProductType__c;
                    ciWrapp.selected = true;
                    // commented by juturi
                    // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(cap.ProductId__c + accountState)){
                    //     ciWrapp.pricingId =pricingMatricData.get(cap.ProductId__c + accountState).Id;
                    //     ciWrapp.minimumMSRP = pricingMatricData.get(cap.ProductId__c + accountState).MinimumMSRP2__c;
                    //     ciWrapp.maximumExpectedMSRP = pricingMatricData.get(cap.ProductId__c + accountState).ExpectedMaximumMSRP__c;
                    //     ciWrapp.listPrice = pricingMatricData.get(cap.ProductId__c + accountState).PriceByState__c;
                        
                    // }
                    // added by juturi
                    if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(cap.ProductId__c + accountState)){
                        ciWrapp.pricingId =commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Id;
                        ciWrapp.listPrice = commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Price__c;

                    }
                      w.CommercialActivityItems.add(ciWrapp);
                }
            }
        
      
        }
    }
    
    //Start Method
    Public Database.Querylocator start (Database.BatchableContext BC) {
        //List<account> accList1 = new List<Account>();
        //accList1 = [Select id From Account where Id IN: accountIds];
        String queryCustom;
        if(Cascadechanges == true){
            queryCustom = 'SELECT ID,ShippingState, Name, ParentID,Type,ComplianceMechanism__c  FROM Account WHERE Id IN :ISLAccountIDSet ';
        }else {
            queryCustom = 'SELECT ID,ShippingState, Name, ParentID,Type,ComplianceMechanism__c  FROM Account WHERE ParentID IN :accountIdSet';
        }
        // AND ShippingState IN :stateGroupSet 
       System.debug('accountIdSet '+accountIdSet);
       System.debug('ShippingState '+stateGroupSet);
       //System.debug('queryCustom '+ [SELECT ID,ShippingState, Name, ParentID,Type,ComplianceMechanism__c  FROM Account]);
       //return Database.getQueryLocator('Select id From Account where Id IN: accountIds');
       return Database.getQueryLocator(queryCustom);
       //return accountIds;
    }
    
    //Execute method
    Public void execute (Database.BatchableContext BC, List<Account> ChildAccounts) {
        //Map<String, List<Id>> rsgAccount = new Map<String, List<Id>>();
        System.debug('method check');
        System.debug('ChildAccounts '+ChildAccounts);
        Map<id,String> rsgAccountStateMap = new Map<id,String>();
        Map<id,String> accComplianceMap = new Map<id,String>();

        Map<Id,List<Id>> rsgAccount = new Map<Id,List<Id>>();
        Set <ID> queryIDs = new Set <ID>();
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

                        if(rsgAccount.containsKey(stateAaptIds.get(ChildAccounts[i].ShippingState))){
                            List<Id> actIdsExist = rsgAccount.get(stateAaptIds.get(ChildAccounts[i].ShippingState));
                            if(ChildAccounts[i].Type != 'HQ'){
                                actIdsExist.add(ChildAccounts[i].id);
                                rsgAccount.put(stateAaptIds.get(ChildAccounts[i].ShippingState),actIdsExist);
                                //actGrpCntByState.put(ChildAccounts[i].ShippingState,actIdsExist.size());
                            }
                        }else{
                            List<Id> actIdsNew = new List<Id>();
                            if(ChildAccounts[i].Type != 'HQ'){
                                actIdsNew.add(ChildAccounts[i].id);
                                rsgAccount.put(stateAaptIds.get(ChildAccounts[i].ShippingState),actIdsNew);
                                //actGrpCntByState.put(ChildAccounts[i].ShippingState,actIdsNew.size());
                            }
                        }
                        
                    }
                    

                    

                    
                    queryIDs.add(ChildAccounts[i].id);
                }
                System.debug('1 level Deep Ids-'+queryIDs);
                System.debug('1 level Deep Ids count-'+queryIDs.size());
                //allActsCnt = allActsCnt + queryIDs.size();
                while (queryIDs.size() > 0) {
                    List <Account> childAccount = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState,Type,ComplianceMechanism__c From ChildAccounts) FROM Account WHERE ID IN :queryIDs ];        
                    queryIDs.clear();
                    if(maxDeepLevel < 7){
                        System.debug('maxDeepLevel '+maxDeepLevel);
                        //System.debug('childAccount'+childAccount);
                        for (Account oneAcc: childAccount) {
                            //System.debug('oneAcc cnt'+oneAcc.ChildAccounts.size());
                            if (oneAcc.ChildAccounts.size() > 0) {
                                //childMap.put(oneAcc.id, oneAcc.ChildAccounts);
                                for (Integer i = 0; i < oneAcc.ChildAccounts.size(); i++) {

                                    if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                        //chunkChildAccIds.add(oneAcc.ChildAccounts[i].id);
                                        rsgAccountStateMap.put(oneAcc.ChildAccounts[i].id, oneAcc.ChildAccounts[i].ShippingState);

                                        if(oneAcc.ChildAccounts[i].ComplianceMechanism__c != null){
                                            accComplianceMap.put(oneAcc.ChildAccounts[i].id, oneAcc.ChildAccounts[i].ComplianceMechanism__c);
                                        }else {
                                            accComplianceMap.put(oneAcc.ChildAccounts[i].id, '');
                                        }

                                        if(rsgAccount.containsKey(stateAaptIds.get(oneAcc.ChildAccounts[i].ShippingState))){
                                            List<Id> actIds222 = rsgAccount.get(stateAaptIds.get(oneAcc.ChildAccounts[i].ShippingState));
                                            if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                                actIds222.add(oneAcc.ChildAccounts[i].id);
                                                rsgAccount.put(stateAaptIds.get(oneAcc.ChildAccounts[i].ShippingState),actIds222);
                                                //actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222.size());
                                            }
                                        }else{
                                            List<Id> actIds111 = new List<Id>();
                                            if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                                actIds111.add(oneAcc.ChildAccounts[i].id);
                                                rsgAccount.put(stateAaptIds.get(oneAcc.ChildAccounts[i].ShippingState),actIds111);
                                                //actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111.size());
                                            }
                                        }
                                        
                                    }

                                    

                                    
                                    queryIDs.add(oneAcc.ChildAccounts[i].id);
                                }  
                            }    
                        }   
                        maxDeepLevel = maxDeepLevel+1; 
                        if(queryIDs.size() > 0){
                            System.debug(maxDeepLevel+' level Deep Ids-'+queryIDs);
                            System.debug(maxDeepLevel+' level Deep Ids count-'+queryIDs.size());
                        }
                    }    
                }
            }
            //System.debug('State Wise Grouped Accounts-'+actGrpByState);
            //System.debug('State Wise Grouped Account Counts-'+actGrpCntByState);
            System.debug('All Child Accounts -'+accountIds);
        

            



       
        Set<Id> accSet = new Set<Id>();
        for(Id a: rsgAccountStateMap.keySet()){
            accSet.add(a);
        }
        System.debug('accSet '+accSet.size());
        System.debug('methos check');
        Map<String,Mission__c> mapKeyMission = new Map<String,Mission__c>();
        Map<Id,Id> rsgPlanogramsToUpdate = new Map<Id,Id>();

        System.debug('rsgAccount***'+rsgAccount);
        for(KAMAccountPlanning.WrapperData wd: partialData){

            if(rsgAccount.get(wd.junctionId) != null){
                System.debug('Inside Instorelocation 1');
                for(Id a: accSet){
                    System.debug('Inside Instorelocation 2');
                    if(rsgAccount.get(wd.junctionId).contains(a)){
                        String currentAccountState='';
                        System.debug('Inside Instorelocation 3');
                        if(rsgAccountStateMap.containsKey(a))
                            currentAccountState = '-' + rsgAccountStateMap.get(a);
                        InStoreLocation__c sl;
                       System.debug('Inside Instorelocation 4');
                            sl = new InStoreLocation__c();
                            sl.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                            sl.RetailLocationId__c = a;
                            sl.Active__c = True;
                            sl.Category__c = storeCategory;
                            sl.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
                            sl.EndDate__c =selectedAPTQueried.RequestedEndDate__c;
                            sl.Status__c ='Executed';
                      
                        if(APTRecordType == 'AccountPlan' || APTRecordType == 'PromotionalActivityProcess'){
                            if(wd.currentplanogramId != null){
                                sl.PlanogramId__c = wd.currentplanogramId;
                            }
                           
                        }
                        else if(APTRecordType == 'ResetActivityProcess'){
                            if(wd.plannedPlanogramId != null){
                                sl.PlanogramId__c = wd.plannedPlanogramId;
                                //Make a map to store planogram with retail store Id to update on retail store groups
                                rsgPlanogramsToUpdate.put(wd.Id,wd.plannedPlanogramId);
                            }
                        }
                        
                        
                        if(wd.standardPog){
                            sl.InStoreLocationType__c = 'Planogram Specific';
                        }else if(!wd.standardPog) {
                            sl.InStoreLocationType__c = 'Custom Assortment';
                        }
                        
                        String accComplianceMechanism ='';
                        if(!accComplianceMap.isEmpty() && accComplianceMap.containsKey(a))
                            accComplianceMechanism= accComplianceMap.get(a);
                        String slKey = sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c;
                        storeLocationsListToUpsert.put(slKey,sl);
                      
                        if(!accComplianceMechanism.contains('Category Ban')){

                            //Create store products if Planogram was selected
                            if(wd.standardPog && wd.planogramProducts != null && wd.planogramProducts.size()>0){
                                for(KAMAccountPlanning.Products p : wd.planogramProducts){
                                    Product2 banProduct = new Product2();
                                    if(banProductList.containsKey(p.Id))
                                        banProduct =  banProductList.get(p.Id);
                                        
                                    if(!(accComplianceMechanism.contains('Menthol Ban') && banProduct.Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProduct.Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProduct.Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProduct.Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProduct.Pod_Strength__c == '5%')){
                                        System.debug('Inside Instorelocation 5');
                                        StoreProduct__c sp = new StoreProduct__c();
                                        sp.RetailStoreId__c= a;
                                        sp.ProductId__c = p.id;
                                        // if(pricingMatricData.containsKey(p.Id + currentAccountState)) //commented by juturi
                                        // sp.PricingMatrixId__c = pricingMatricData.get(p.Id + currentAccountState).Id; //commented by juturi
                                        if(commercialAcitvityProductPrice.containsKey(p.Id + currentAccountState))  // added by juturi
                                        sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPrice.get(p.Id + currentAccountState).Id; // added by juturi
                                        // sp.Differentiator__c = p.differentiator;
                                        //Added by Shreya for ticket SFDC - 0000003131
                                        sp.STD_JUUL_Funding__c = p.STDFunding; //sr01
                                        sp.JUUL_Tax_Funding__c = p.TaxFunding; //sr02
                                        sp.Retailer_Funding__c = p.RetailerFunding;  //sr03
                                        sp.DefaultOrderQuantity__c = p.quantity;
                                        sp.Source_Product_Id__c = p.parentId;
                                        //Added for JTP 167 
                                        sp.Active__c = True;
                                        if(!StoreLocationStoreProductMap.containsKey(slKey))
                                            StoreLocationStoreProductMap.put(slKey,new List<StoreProduct__c>());
                                        StoreLocationStoreProductMap.get(slKey).add(sp);
                                       
                                    }
                                }
                            }
                            //Create store products if additional products were selected
                            if(wd.products != null && wd.products.size()>0){ 
                                for(KAMAccountPlanning.Products p: wd.products){
                                    if(p.selected){
                                        Product2 banProduct = new Product2();
                                        if(banProductList.containsKey(p.Id))
                                            banProduct =  banProductList.get(p.Id);
                                        if(!(accComplianceMechanism.contains('Menthol Ban') && banProduct.Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProduct.Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProduct.Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProduct.Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProduct.Pod_Strength__c == '5%')){
                                            System.debug('Inside Instorelocation 6');
                                            StoreProduct__c sp = new StoreProduct__c();
                                            sp.RetailStoreId__c= a;
                                            sp.ProductId__c = p.Id;
                                            // commented by juturi
                                            // if(pricingMatricData.containsKey(p.Id + currentAccountState))
                                            // sp.PricingMatrixId__c = pricingMatricData.get(p.Id + currentAccountState).Id;
                                            if(commercialAcitvityProductPrice.containsKey(p.Id + currentAccountState))  // added by juturi
                                            sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPrice.get(p.Id + currentAccountState).Id; // added by juturi
                                            //sp.Differentiator__c = p.differentiator;
                                            //Added by Shreya for Ticket SFDC - 0000003131
                                            sp.STD_JUUL_Funding__c = p.STDFunding;  //sr01
                                            sp.JUUL_Tax_Funding__c = p.TaxFunding;  //sr02
                                            sp.Retailer_Funding__c = p.RetailerFunding; //sr03
                                            sp.DefaultOrderQuantity__c = p.quantity;
                                            sp.Source_Product_Id__c = p.parentId;
                                            //Added for JTP 167 
                                            sp.Active__c = True;
                                            if(!StoreLocationStoreProductMap.containsKey(slKey))
                                                StoreLocationStoreProductMap.put(slKey,new List<StoreProduct__c>());
                                            StoreLocationStoreProductMap.get(slKey).add(sp);
                                           
                                        }
                                    }
                                }
                            }
                            //Create store products and Assets if Commercial Activity Items were selected
                            if(wd.CommercialActivityItems != null && wd.CommercialActivityItems.size()>0){
                                for(KAMAccountPlanning.CommercialActivityItems c: wd.CommercialActivityItems){
                                    if(c.selected){
                                        Product2 banProduct = new Product2();
                                        if(banProductList.containsKey(c.Id))
                                            banProduct =  banProductList.get(c.Id);
                                        if(!(accComplianceMechanism.contains('Menthol Ban') && banProduct.Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProduct.Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProduct.Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProduct.Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProduct.Pod_Strength__c == '5%')){
                                            if(c.productType == 'JUUL Product'){
                                                System.debug('Inside Instorelocation 7');
                                                StoreProduct__c sp = new StoreProduct__c();
                                                //Added by Shreya for SFDC - 0000004228 
                                                if(c.productBundle!=null &&(c.productBundle == 'Combo' || c.productBundle =='GetxSavex'))
                                                sp.Product_Bundle__c = c.productBundle;
                                                if(c.ProductDescription!=null)
                                                sp.Product_Bundle_Description__c = c.ProductDescription;
                                                sp.RetailStoreId__c= a;
                                                sp.ProductId__c = c.Id;
                                                if(c.parentId!='null')
                                                sp.Source_Product_Id__c = c.parentId;
                                                // commented by juturi
                                                // if(pricingMatricData.containsKey(c.Id + currentAccountState))
                                                // sp.PricingMatrixId__c = pricingMatricData.get(c.Id + currentAccountState).id;
                                                if(commercialAcitvityProductPrice.containsKey(c.Id + currentAccountState))  // added by juturi
                                                sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPrice.get(c.Id + currentAccountState).Id; // added by juturi
                                                //added by Shreys for ticket SFDC - 0000003131
                                                sp.STD_JUUL_Funding__c = c.STDFunding;  //sr01
                                                sp.JUUL_Tax_Funding__c = c.TaxFunding;  //sr02
                                                sp.Retailer_Funding__c = c.RetailerFunding;  //sr03
                                                //Added for JTP 167 
                                                sp.Active__c = True;
                                                //sp.Differentiator__c = c.differentiator;
                                                sp.DefaultOrderQuantity__c = c.quantity;
                                               
                                                if(!StoreLocationStoreProductMap.containsKey(slKey))
                                                    StoreLocationStoreProductMap.put(slKey,new List<StoreProduct__c>());
                                                StoreLocationStoreProductMap.get(slKey).add(sp);
                                               
                                            } 
                                            else if(c.productType == 'Trade Collateral'){
                                                Asset ass = new Asset();
                                                ass.AccountId =  a;
                                                ass.Product2Id =c.Id;
                                                ass.Unit_Price__c = c.listPrice;
                                                ass.name= c.name;
                                                ass.Source_Product_Id__c = c.parentId;
                                                ass.Quantity =c.quantity;
                                                //Added for JTP 167 
                                                ass.Active__c = True;
                                                if(!StoreLocationAssetMap.containsKey(slKey))
                                                    StoreLocationAssetMap.put(slKey,new List<Asset>());
                                                StoreLocationAssetMap.get(slKey).add(ass);

                                                //Added by Jyoti SFDC - 0000004342
        										//start
                                                Asset__c ass1 = new Asset__c();
                                                ass1.Account__c =  a;
                                                ass1.Product__c =c.Id;
                                                ass1.Unit_Price__c = c.listPrice;
                                                ass1.name= c.name;
                                                ass1.Source_Product_Id__c = c.parentId;
                                                ass1.Quantity__c =c.quantity;
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
                        
                       
                    }
                    
                }
            }
       }
          
        
        
        //Insert Store Locations
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
        
        //Update planogram on RSG
        if(rsgPlanogramsToUpdate.keySet() != null){
            List<RetailLocationGroup__c> rsgPlanogramsToUpdateList =[Select id,PlanogramId__c from RetailLocationGroup__c where ID IN: rsgPlanogramsToUpdate.keySet()];
            for(RetailLocationGroup__c r: rsgPlanogramsToUpdateList){
                r.PlanogramId__c = rsgPlanogramsToUpdate.get(r.id);
            }
            update rsgPlanogramsToUpdateList; 
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

        //Added by Jyoti SFDC - 0000004342
        //start
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
        //end
       
        //start---Added for ticket SFDC - 0000003394
        //Insert Missions
        /*List<Id> successRecords = new List<Id>();
        //start---Added for ticket SFDC - 0000003394    
        //if(mapKeyMission.size()>0 && missionToInsert != null && missionToInsert.size() > 0){    
            //List<Database.SaveResult> missionToInsertResults = Database.Insert(missionToInsert, true);  
        //end---Added for ticket SFDC - 0000003394
        if(mapKeyMission.size()>0){    
            List<Database.SaveResult> missionToInsertResults = Database.Insert(mapKeyMission.values(), true);  
            List<Database.Error> missionToInsertError = new List <Database.Error>();
            for (Integer index = 0, size = missionToInsertResults.size(); index < size; index++) {
                if (!missionToInsertResults[index].isSuccess()) {
                    missionToInsertError.addAll(missionToInsertResults[index].getErrors());
                    //returnResponse= missionToInsertError[0].getMessage();
                }else
                    successRecords.add(missionToInsertResults[index].id);
            }
            if (missionToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(missionToInsertError,class_Name,method_Name, 'Mission', operationType);
            }
            
            //Update mission ids in Action Plans
            Map<Id,ActionPlan__c> actionPlansToInsert = new Map<Id,ActionPlan__c>();
            for(Mission__c m: mapKeyMission.values()){
                ActionPlan__c ap = new ActionPlan__c();
                if(APRecordType != null){
                    ap.RecordTypeId = APRecordType;  
                }
                ap.isProcessed__c = true;
                ap.ActionPlanTemplateId__c = selectedAPTQueried.Id;
                ap.Mission__c = m.Id;
                actionPlansToInsert.put(m.Id,ap);              
            }
            
            // Insert Action Plans
            If(actionPlansToInsert != null && actionPlansToInsert.size()>0){
                List<Database.SaveResult> actionPlansToInsertResults = Database.Insert(actionPlansToInsert.values(), true);
                List<Database.Error> actionPlansToInsertError = new List <Database.Error>();
                for (Integer index = 0, size = actionPlansToInsertResults.size(); index < size; index++) {
                    if (!actionPlansToInsertResults[index].isSuccess()) {
                        actionPlansToInsertError.addAll(actionPlansToInsertResults[index].getErrors());
                        //returnResponse= missionToInsertError[0].getMessage();
                    }
                }
                if (actionPlansToInsertError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(actionPlansToInsertError,class_Name,method_Name, 'Action Plan', operationType);
                }
            }
            
            Map<ActionPlanItem__c,MissionTask__c> mapAPTIMT = new Map<ActionPlanItem__c,MissionTask__c>();
             
                       
            for(KAMAccountPlanning.WrapperData wd: partialData){
                if(rsgAccount.get(wd.Id) != null){
                    for(Id a: accSet){
                        if(rsgAccount.get(wd.Id).contains(a)){
                              // KAMAccountPlanning.WrapperData wd = accontWithWrapperMap.get(a.Id);
                                Mission__c m = mapKeyMission.get(wd.Id+'='+a);
                                if(m!=null)
                                    for(KAMAccountPlanning.Items i: rsgAptItems.get(wd.Id)){                        
                                        if(i.selected){
                                            ActionPlanItem__c api = new ActionPlanItem__c();
                                            api.ActionPlanTemplateItemId__c =i.Id;
                                            api.ActionPlanId__c = actionPlansToInsert.get(m.Id).Id;
                                            MissionTask__c mtask = new MissionTask__c();
                                            //mtask.Status__c = 'New';
                                            mtask.ParentId__c  = m.Id;
                                            mtask.AccountId__c = a;
                                            for(string field: aptiMtaskFieldsMap.keyset()){                               
                                                mtask.put(aptiMtaskFieldsMap.get(field),aptItemsMap.get(i.Id).get(field));                                
                                            }
                                            
                                            //Map to store missiontasks respective to action plan items
                                            mapAPTIMT.put(api,mtask);
                                            
                                        }
                                    }
                        }
                       
                    }
                }
            }
         
            
            //Insert Mission Task
            if(mapAPTIMT.size()>0){                                                
                List<Database.SaveResult> mTaskToInsertResults = Database.Insert(mapAPTIMT.values(), true);
                List<Database.Error> mTaskToInsertError = new List <Database.Error>();
                for (Integer index = 0, size = mTaskToInsertResults.size(); index < size; index++) {
                    if (!mTaskToInsertResults[index].isSuccess()) {
                        mTaskToInsertError.addAll(mTaskToInsertResults[index].getErrors());
                        //returnResponse= missionToInsertError[0].getMessage();
                    }
                }
                if (mTaskToInsertError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(mTaskToInsertError,class_Name,method_Name, 'Mission task', operationType);
                }                
            }
            
            if(mapAPTIMT.size()>0){
                List<ActionPlanItem__c> apiToInsert = new List<ActionPlanItem__c>();
                for(ActionPlanItem__c api:mapAPTIMT.keySet()){                                                            
                    api.MissionTaskId__c = mapAPTIMT.get(api).Id;
                    //ai.ActionPlanTemplateItemId__c =;
                    apiToInsert.add(api);                                       
                }
                
                if(apiToInsert != null && apiToInsert.size()>0){
                    List<Database.SaveResult> apiToInsertResults = Database.Insert(apiToInsert, true);
                    List<Database.Error> apiToInsertError = new List <Database.Error>();
                    for (Integer index = 0, size = apiToInsertResults.size(); index < size; index++) {
                        if (!apiToInsertResults[index].isSuccess()) {
                            apiToInsertError.addAll(apiToInsertResults[index].getErrors());
                            //returnResponse= missionToInsertError[0].getMessage();
                        }
                    }
                    if (apiToInsertError.size() > 0) {
                        LogEventTriggerHandler.insertBatchLog(apiToInsertError,class_Name,method_Name, 'Mission task', operationType);
                    }
                }
            }
        }*/
         //end---Added for ticket SFDC - 0000003394 // commented for reversed approach
       // KAMApexSharing.shareMissionRecords(successRecords);
    }
    
    //Finish Method
    Public void finish(Database.BatchableContext BC){
        AsyncApexJob j = [Select Id, Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
         selectedAPTQueried.CascadeChangesBatch__c = false;
        //Added by shreya for ticket SFDC - 0000004466 
        if(j.Status == 'Failed' && Cascadechanges == true)
         {
          selectedAPTQueried.Batch_Details__c ='ISL Cascade changes to Doors Failed '+j.CompletedDate; 
         }
           else if(j.Status == 'Completed' && Cascadechanges == true) {
                 selectedAPTQueried.Batch_Details__c ='ISL Cascade changes to Doors Completed '+j.CompletedDate;   
             }
             System.debug('Inside failed batch details');
         
        if(CascadeChanges == false){  
        //selectedAPTQueried.Batch_Status__c=j.Status;
         if(j.NumberOfErrors > 0) {
              selectedAPTQueried.Batch_Details__c='Committed to Forecast Failed '+j.CompletedDate;
         }
        System.debug('J Status is'+selectedAPTQueried.Batch_Status__c);
        if(j.Status == 'Completed' && j.NumberOfErrors ==0) {
            //Added for 'Cascade changes' button visibility on LWC
             selectedAPTQueried.Batch_Details__c='Committed to Forecast Completed '+j.CompletedDate;
             System.debug('Inside completed batch details');
            selectedAPTQueried.Cascade_Changes__c=True;
            selectedAPTQueried.Status__c = 'APT Approved & Locked'; 
            if(APTRecordType == 'ResetActivityProcess')
                selectedAPTQueried.Status__c = 'APT Approved & Locked';
            selectedAPTQueried.In_Store_Locations_Created__c=true;
             
           
        }else{
            List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
            for(AccountActionPlanTemplate__c a :[select id,cascadeToDoor__c from AccountActionPlanTemplate__c 
                                                 where id IN :selectedRsgList and ActionPlanTemplateId__c =: aptId]){
                                                     a.cascadeToDoor__c = false;
                                                     cascadeToDoorList.add(a);
                                                     
                                                 }
            if(cascadeToDoorList.size()>0){
                update cascadeToDoorList;
            }
            
        }
        }else{
             if(j.Status == 'Completed' && j.NumberOfErrors ==0 && selectedAPTQueried.Status__c !=Label.CascadeMissiontoDoors ) {
                 KAMBatchAccountPlanning k2 = new KAMBatchAccountPlanning(aptId,selectedData,MissionAccountIDs,CascadeChanges);
                 Database.executeBatch(k2,10);
             }
        }
         update selectedAPTQueried;
    }
}