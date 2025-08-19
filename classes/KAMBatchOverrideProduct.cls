/*****************************************************************************************/
/* VERSION       AUTHOR                        DATE                                      */
/* 1.0           Shreya Raut                   12-06-2021                                */
/* Class Name:   KAMBatchOverrideProduct                                                 */
/* Description: To create asset and Store product records on Action Plan Template object */
/*****************************************************************************************/
Public class KAMBatchOverrideProduct implements Database.Batchable<sobject>{
    Public set<Id> accountIds;
    Public set<Id> accIDs =  new Set<ID>();
    Private Id aptId;
    public String class_Name ='KAMBatchOverrideProduct';
    String method_Name='Execute';
    String operationType = 'Database.Insert_Failed';
    Set<id> selectedRsgList = new Set<Id>();
    Map<Id,List<Id>> rsgAccount = new Map<Id,List<Id>>();
    Map<Id,List<KAMAccountPlanning.Items>> rsgAptItems = new  Map<Id,List<KAMAccountPlanning.Items>>();
    Map<String,String> APTIMtaskFieldsMap = new Map<String,String>();
    //Set<Id> allAPTIList = new Set<Id>();
    List<ActionPlanTemplateItem__c> selectedAPTIListQueried = new List<ActionPlanTemplateItem__c>();
    //Map<Id,ActionPlanTemplateItem__c> aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>();
    List<Data_Mapping__mdt> APTMissionMapping = new List<Data_Mapping__mdt>();
    //List<Data_Mapping__mdt> aptiMtaskMapping = new List<Data_Mapping__mdt>();
    List<KAMAccountPlanning.WrapperData> partialData = new List<KAMAccountPlanning.WrapperData>();
    //Map<id,String> accComplianceMap = new Map<id,String>();
    Set<Id> allSelectedProducts = new Set<Id>(); 
    Map<id,Product2> banProductList;
    Set<Id> junctionIds = new Set<Id>();
    Map<String,List<StoreProduct__c>> StoreLocationStoreProductMap = new Map<String,List<StoreProduct__c>>();
    Map<String,List<Asset>> StoreLocationAssetMap = new Map<String,List<Asset>>();
    Public Map<String, InStoreLocation__c> storeLocationsListToUpsert = new Map<String,InStoreLocation__c>();
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
    //Map<id,String> rsgAccountStateMap = new Map<id,String>();

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
    Public set<Id> MissionaccountIds;
    Map<id,id> rgMap = new Map<Id,id>();

    public Integer maxDeepLevel = 1;
    Map<String, Id> stateAaptIds = new  Map<String, Id>();
    Set<string> stateGroupSet = new Set<string>();
    set<Id> accountIdSet = new Set<Id>();
    String hQAccountState;
    String hQAccountCompMechanism;
    Id hQAccountId;

    Boolean hQAccountStatus = false;
    //Constructor
    public KAMBatchOverrideProduct(Id aptId1, List<KAMAccountPlanning.WrapperData> selectedData1){
        System.debug('Inside KAMBATCHPRODUCT constructor');
        aptId = aptId1;
        selectedData = selectedData1;
        accountIds = new Set<Id>();
        //Get Action plan fields mappings from custom metadata types.
        APTMissionMapping=[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplate__c' AND Target_Object__c ='Mission__c'];
        for(Data_Mapping__mdt data: APTMissionMapping){
            sourceAPT += data.Source_Field__c+',';
        }
        if(sourceAPT.endsWith(',')){
            sourceAPT = sourceAPT.substring(0, sourceAPT.length() - 1);
        }
        
        String queryAPT = 'Select Id,Batch_Details__c,RecordType.DeveloperName, Status__c,CommercialActivityId__c,Batch_Status__c,Cascade_Changes__c,'  +sourceAPT+' From ActionPlanTemplate__c Where id =:aptId';
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
        
        
        //Modified by Ramya -ticket SFDC-0000004199, SFDC-0000004200
        DateTime dt = selectedAPTQueried.RequestedStartDate__c;  //rm02
        DateTime dtEnd = selectedAPTQueried.RequestedEndDate__c; //sr01
        Date newD = Date.valueOf(dt);         //rm04
        Date EndD = Date.valueOf(dtEnd);      //sr02
        Date Today = Date.valueOf(System.today()); //sr03
        // commented by juturi JTP-1393
        // for(PricingMatrix__c prm: [Select id,Start_Date__c,End_Date__c,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c,ProductId__r.Name from PricingMatrix__c WHERE Start_Date__c < Today and End_Date__c > Today]){ //Active__c = True //rm06
        //     if(prm.ProductId__c !=null && prm.StateTerritoryISO2__c != null){
        //         String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
        //         pricingMatricData.put(s,prm);
        //     }
        // }
        // added by juturi
        Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c from CommercialActivityProduct__c where CommercialActivityId__c =:selectedAPTQueried.CommercialActivityId__c]);

        for(Commercial_Activity_Product_Pricing__c capp : [select id,name,State__c,Commercial_Activity_Product__r.ProductId__c,State_ISO2__c,Price__c  from Commercial_Activity_Product_Pricing__c where Commercial_Activity_Product__c IN: commercialActivityProductMap.keyset()]){
                if(capp.Commercial_Activity_Product__r.ProductId__c !=null && capp.State_ISO2__c != null){
                    string  s = capp.Commercial_Activity_Product__r.ProductId__c+'-'+capp.State_ISO2__c;
                    commercialAcitvityProductPrice.put(s,capp);
                  }
             }
        // ended by juturi
        if(selectedAPTQueried.CommercialActivityId__c != null){
            caItems = [Select id,ProductId__c ,ProductId__r.Name,ProductType__c,CommercialActivityId__c,CollateralUnitCost__c  from CommercialActivityProduct__c  where CommercialActivityId__c= :selectedAPTQueried.CommercialActivityId__c AND HideItemWhilePlanning__c = true];
        }
        for(KAMAccountPlanning.WrapperData wd: selectedData){
            if(wd.selected && !wd.readOnly){ 
         
                partialData.add(wd);
                selectedRsgList.add(wd.Id);
           
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
            }         
        } 
        banProductList =new Map<Id,Product2>([Select id,Flavor_Family__c,Pod_Strength__c From Product2 where id In: allSelectedProducts]);
        List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
        for(AccountActionPlanTemplate__c a :[select id,cascadeToDoor__c from AccountActionPlanTemplate__c 
                                             where id IN :selectedRsgList and ActionPlanTemplateId__c =: aptId]){
                                                 a.cascadeToDoor__c = true;
                                                 cascadeToDoorList.add(a);
                                             }
        if(cascadeToDoorList.size()>0){
            update cascadeToDoorList;
        }
      
        // Make a map to store account ids respective to retail store group
        if(selectedRSGList != null && selectedRSGList.size() > 0){ 
          
            // for(AccountRetailStoreGroup__c arsg: [Select id,AccountId__c,RetailStoreGroupId__c,AccountId__r.ComplianceMechanism__c,AccountId__r.ShippingState,
            //                                       RetailStoreGroupId__r.AccountId__c from AccountRetailStoreGroup__c where RetailStoreGroupId__c IN :selectedRSGList and AccountId__c!=null and AccountId__r.Type != 'HQ']){    
            //     if(!rsgAccount.containsKey(arsg.RetailStoreGroupId__c)){
            //         rsgAccount.put(arsg.RetailStoreGroupId__c,new List<Id>());
            //     }
            //     rsgAccount.get(arsg.RetailStoreGroupId__c).add(arsg.AccountId__c);
            //     if(arsg.AccountId__r.ComplianceMechanism__c != null)
            //         accComplianceMap.put(arsg.AccountId__c,arsg.AccountId__r.ComplianceMechanism__c);
            //     else
            //         accComplianceMap.put(arsg.AccountId__c,'');
                
            //     if(arsg.AccountId__r.ShippingState != null)
            //         rsgAccountStateMap.put(arsg.AccountId__c,arsg.AccountId__r.ShippingState);
            //     else
            //         rsgAccountStateMap.put(arsg.AccountId__c,'');
            //       accountIds.add(arsg.AccountId__c);
                
            // }
            // for(RetailLocationGroup__c rs: [Select id,AccountId__r.ShippingState, AccountId__c,AccountId__r.ComplianceMechanism__c,Pricing_State__c from RetailLocationGroup__c where id IN: selectedRsgList]){
            //     if(rs.AccountId__c != null && rs.Pricing_State__c != null){
            //         rsgParentaccountStateMap.put(rs.Id,rs.Pricing_State__c);
            //        //accountIds.add(rs.AccountId__c);
            //      }
            //  if(rs.AccountId__c != null){
            //     //rgMap.put(rs.id,rs.AccountId__c);
            //       if(rs.AccountId__r.ShippingState != null)
            //         rsgAccountStateMap.put(rs.AccountId__c,rs.AccountId__r.ShippingState);
            //     else
            //         rsgAccountStateMap.put(rs.AccountId__c,'');
            //     if(rs.AccountId__r.ComplianceMechanism__c != null)
            //         accComplianceMap.put(rs.AccountId__c,rs.AccountId__r.ComplianceMechanism__c);
            //     else
            //         accComplianceMap.put(rs.AccountId__c,'');
            //  }
            // }

            for(AccountActionPlanTemplate__c aap :  [select id,name,Account__c,Grouped_State__c,Account__r.ShippingState,Account__r.ComplianceMechanism__c from AccountActionPlanTemplate__c where id =: selectedRSGList]){
                accountIdSet.add(aap.Account__c);
                stateAaptIds.put(aap.Grouped_State__c, aap.id);

                rsgParentaccountStateMap.put(aap.Id,aap.Grouped_State__c);
                if(aap.Account__r.ShippingState != null){
                    hQAccountState = aap.Account__r.ShippingState;
                }else{
                    hQAccountState='';
                }
                if(aap.Account__r.ComplianceMechanism__c !=null){
                    hQAccountCompMechanism = aap.Account__r.ComplianceMechanism__c;
                }
                else{
                    hQAccountCompMechanism = '';
                }
                hQAccountId = aap.Account__c;


                // List<id> stateAccountIds = new List<id>();
                // for(Account  arsg: [Select id,ComplianceMechanism__c,ShippingState,ParentId from account where ParentId =: aap.Account__c and ParentId !=null and Type != 'HQ' and ShippingState =: aap.Grouped_State__c ]){ 
                   
                //     stateAccountIds.add(arsg.id);
                // }
                // rsgAccount.put(aap.id,stateAccountIds);
            }
        }

        for(KAMAccountPlanning.WrapperData w: partialData){
          String accountState='';
            if(rsgParentaccountStateMap.containsKey(w.Id))
                accountState = '-' + rsgParentaccountStateMap.get(w.id);
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
        system.debug('inside start');
        
        System.debug('** test storeLocationsListToUpsert'+storeLocationsListToUpsert);
        //return Database.getQueryLocator('Select id From Account where Id IN: accountIds');
        return Database.getQueryLocator('SELECT ID,ShippingState, Name, ParentID,Type,ComplianceMechanism__c  FROM Account WHERE ParentID IN :accountIdSet ');
       
        //return accountIds;
    }
    
    //Execute method
    Public void execute (Database.BatchableContext BC, List<Account> ChildAccounts) {


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
            //System.debug('All Child Accounts -'+accountIds);
            Set<Id> accSet = new Set<Id>();

            if(hQAccountStatus == false){
                rsgAccountStateMap.put(hQAccountId, hQAccountState);
                accComplianceMap.put(hQAccountId, hQAccountCompMechanism);
                accSet.add(hQAccountId);
                hQAccountStatus = true;
            }
            

       system.debug('inside execute');
        for(Id a: rsgAccountStateMap.keySet()){
            accSet.add(a);
        }
        		
        for(InStoreLocation__c is : [select id,RetailStoreGroupActionPlanTemplate__c, RetailLocationId__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c	=: aptId
                                    and RetailLocationId__c =:accSet]){
                            String slKey = is.RetailStoreGroupActionPlanTemplate__c+'='+is.RetailLocationId__c;
                            storeLocationsListToUpsert.put(slKey,is);
                            
                        }
        system.debug('accSet'+accSet);
        Map<String,Mission__c> mapKeyMission = new Map<String,Mission__c>();
        Map<Id,Id> rsgPlanogramsToUpdate = new Map<Id,Id>();
        for(KAMAccountPlanning.WrapperData wd: partialData){
            if(rsgAccount.get(wd.Id) != null){
                for(Id a: accSet){
                    System.debug('a'+a);
                   // if(rsgAccount.get(wd.Id).contains(a)){
                        System.debug('wd.junction'+wd.junctionId);
                        String currentAccountState='';
                        if(rsgAccountStateMap.containsKey(a))
                            currentAccountState = '-' + rsgAccountStateMap.get(a);
                    
                          if(APTRecordType == 'ResetActivityProcess'){
                            if(wd.plannedPlanogramId != null){
                                 rsgPlanogramsToUpdate.put(wd.Id,wd.plannedPlanogramId);
                            }
                        }
                        
                        System.debug('test** storeLocationsListToUpsert'+storeLocationsListToUpsert);
                        System.debug('test** storeLocationsListToUpsert keyset'+storeLocationsListToUpsert.keySet());
                        String accComplianceMechanism ='';
                        if(!accComplianceMap.isEmpty() && accComplianceMap.containsKey(a))
                            accComplianceMechanism= accComplianceMap.get(a);
                        //String slKey = sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c;
                        //storeLocationsListToUpsert.put(slKey,sl);
                        if(!accComplianceMechanism.contains('Category Ban')){
                            //Create store products if Planogram was selected
                            if(wd.standardPog && wd.planogramProducts != null && wd.planogramProducts.size()>0){
                                for(KAMAccountPlanning.Products p : wd.planogramProducts){
                                    Product2 banProduct = new Product2();
                                    if(banProductList.containsKey(p.Id))
                                        banProduct =  banProductList.get(p.Id);
                                         System.debug('**4');
                                    if(!(accComplianceMechanism.contains('Menthol Ban') && banProduct.Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProduct.Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProduct.Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProduct.Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProduct.Pod_Strength__c == '5%')){
                                        StoreProduct__c sp = new StoreProduct__c();
                                        system.debug('inside a3'+a);
                                        sp.RetailStoreId__c= a;
                                        sp.ProductId__c = p.id;
                                        // if(pricingMatricData.containsKey(p.Id + currentAccountState)) //commented by juturi
                                        // sp.PricingMatrixId__c = pricingMatricData.get(p.Id + currentAccountState).Id; // commented by juturi
                                        if(commercialAcitvityProductPrice.containsKey(p.Id + currentAccountState)) // added by juturi
                                        sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPrice.get(p.Id + currentAccountState).Id; //added by juturi
                                        // sp.Differentiator__c = p.differentiator;
                                        //Added by Shreya for ticket SFDC - 0000003131
                                        sp.STD_JUUL_Funding__c = p.STDFunding; //sr01
                                        sp.JUUL_Tax_Funding__c = p.TaxFunding; //sr02
                                        sp.Retailer_Funding__c = p.RetailerFunding;  //sr03
                                        sp.DefaultOrderQuantity__c = p.quantity;
                                        sp.Source_Product_Id__c = p.parentId;
                                        //Added for JTP 167 
                                        sp.Active__c = True;
                                        String slKey1 = wd.junctionId+'='+sp.RetailStoreId__c;
                                        System.debug('test** slkey'+slkey1);
                                        if(storeLocationsListToUpsert.get(slkey1)!=null){
                                        sp.InStoreLocationId__c = storeLocationsListToUpsert.get(slkey1).id;
                                        spToInsert.add(sp);
                                        }
                                       
                                    }
                                }
                            }
                            //Create store products if additional products were selected
                            if(wd.products != null && wd.products.size()>0){ 
                                 System.debug('**6');
                                for(KAMAccountPlanning.Products p: wd.products){
                                    if(p.selected){
                                        Product2 banProduct = new Product2();
                                        if(banProductList.containsKey(p.Id))
                                            banProduct =  banProductList.get(p.Id);
                                        if(!(accComplianceMechanism.contains('Menthol Ban') && banProduct.Flavor_Family__c =='Classic Menthol') && !(accComplianceMechanism.contains('Potency Ban - 0.77%') && banProduct.Pod_Strength__c == '0.77%') && !(accComplianceMechanism.contains('Potency Ban - 1.5%') && banProduct.Pod_Strength__c == '1.5%') && !(accComplianceMechanism.contains('Potency Ban - 3.0%') && banProduct.Pod_Strength__c == '3%') && !(accComplianceMechanism.contains('Potency Ban - 5.0%') && banProduct.Pod_Strength__c == '5%')){
                                            StoreProduct__c sp = new StoreProduct__c();
                                             system.debug('inside a7'+a);
                                            sp.RetailStoreId__c= a;
                                            sp.ProductId__c = p.Id;
                                            // if(pricingMatricData.containsKey(p.Id + currentAccountState)) // commented by juturi
                                            // sp.PricingMatrixId__c = pricingMatricData.get(p.Id + currentAccountState).Id; commented by juturi
                                            if(commercialAcitvityProductPrice.containsKey(p.Id + currentAccountState)) // added by juturi
                                            sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPrice.get(p.Id + currentAccountState).Id; //added by juturi
                                            //sp.Differentiator__c = p.differentiator;
                                            //Added by Shreya for Ticket SFDC - 0000003131
                                            sp.STD_JUUL_Funding__c = p.STDFunding;  //sr01
                                            sp.JUUL_Tax_Funding__c = p.TaxFunding;  //sr02
                                            sp.Retailer_Funding__c = p.RetailerFunding; //sr03
                                            sp.DefaultOrderQuantity__c = p.quantity;
                                            sp.Source_Product_Id__c = p.parentId;
                                            //Added for JTP 167 
                                            sp.Active__c = True;
                                            String slKey1 = wd.junctionId+'='+sp.RetailStoreId__c;
                                            if(storeLocationsListToUpsert.get(slkey1)!=null){
                                            sp.InStoreLocationId__c = storeLocationsListToUpsert.get(slkey1).id;
                                               spToInsert.add(sp);
                                            }
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
                                                StoreProduct__c sp = new StoreProduct__c();
                                                 system.debug('inside a11'+a);
                                                //Added by Shreya for SFDC - 0000004228 
                                                if(c.productBundle!=null &&(c.productBundle == 'Combo' || c.productBundle =='GetxSavex'))
                                                sp.Product_Bundle__c = c.productBundle;
                                                if(c.ProductDescription!=null)
                                                sp.Product_Bundle_Description__c = c.ProductDescription;
                                                sp.RetailStoreId__c= a;
                                                sp.ProductId__c = c.Id;
                                                if(c.parentId!='null')
                                                sp.Source_Product_Id__c = c.parentId;
                                                // if(pricingMatricData.containsKey(c.Id + currentAccountState)) //commented by juturi
                                                // sp.PricingMatrixId__c = pricingMatricData.get(c.Id + currentAccountState).id; // commented by juturi
                                                if(commercialAcitvityProductPrice.containsKey(c.Id + currentAccountState)) // added by juturi
                                                sp.CommercialActivityProductPricingId__c = commercialAcitvityProductPrice.get(c.Id + currentAccountState).Id; //added by juturi
                                                //added by Shreys for ticket SFDC - 0000003131
                                                sp.STD_JUUL_Funding__c = c.STDFunding;  //sr01
                                                sp.JUUL_Tax_Funding__c = c.TaxFunding;  //sr02
                                                sp.Retailer_Funding__c = c.RetailerFunding;  //sr03
                                                //Added for JTP 167 
                                                sp.Active__c = True;
                                                //sp.Differentiator__c = c.differentiator;
                                                sp.DefaultOrderQuantity__c = c.quantity;
                                                String slKey1 = wd.junctionId+'='+sp.RetailStoreId__c;
                                                System.debug('slkey1'+slkey1);
                                                if(storeLocationsListToUpsert.get(slKey1)!=null){
                                                sp.InStoreLocationId__c = storeLocationsListToUpsert.get(slKey1).id;
                                                   spToInsert.add(sp);
                                                }
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
                                                String slKey1 = wd.junctionId+'='+ass.AccountId;
                                                if(storeLocationsListToUpsert.get(slKey1)!=null){
                                                ass.InStoreLocation__c = storeLocationsListToUpsert.get(slKey1).id;
                                                assetToInsert.add(ass);
                                                }
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
                                                String slKey2 = wd.junctionId+'='+ass1.Account__c;
                                                if(storeLocationsListToUpsert.get(slKey2)!=null){
                                                ass1.InStoreLocation__c = storeLocationsListToUpsert.get(slKey2).id;
                                                //end
                                               customAssetToInsert.add(ass1);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                       
                  //  }
                    
                }
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
            List<Database.SaveResult> spToInsertResults = Database.Insert(spToInsert, true);
            List<Database.Error> spToInsertError = new List <Database.Error> ();
            for (Integer index = 0, size = spToInsertResults.size(); index < size; index++) {
                if (!spToInsertResults[index].isSuccess()) {
                    spToInsertError.addAll(spToInsertResults[index].getErrors());
                    
                }
            }
            if (spToInsertError.size() > 0) {
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
       
    }
    
    //Finish Method
    Public void finish(Database.BatchableContext BC){
        
          AsyncApexJob j = [Select Id, Status, NumberOfErrors,CompletedDate
        from AsyncApexJob where Id = :BC.getJobId()]; 
        //Added by shreya for ticket SFDC - 0000004466 
         if(j.NumberOfErrors > 0)
         {
          selectedAPTQueried.Batch_Details__c ='Override Products Batch Failed '+j.CompletedDate; 
             System.debug('Inside failed batch details');
         }
        else  if(j.Status == 'Completed' && j.NumberOfErrors == 0)
        {
           selectedAPTQueried.Batch_Details__c ='Override Products Batch Completed '+j.CompletedDate;   
        }
        update selectedAPTQueried;
        
    }
    
}