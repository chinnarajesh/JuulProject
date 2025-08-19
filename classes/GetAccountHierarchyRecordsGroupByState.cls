public class GetAccountHierarchyRecordsGroupByState {

    public  Map<String, List<Id>> actGrpByStateGlobal;
    public static Map<String, List<Id>> actGrpByState;
    public static ID BatchID;

    @AuraEnabled
    public static  List<stateAccounts> getStateBasedAccounts (ID ActionPlanTemplateId) {

        Id accID; 
  
        List<ActionPlanTemplate__c> APT = new List<ActionPlanTemplate__c>([SELECT Id, Name, ActionPlanType__c, AccountId__c from ActionPlanTemplate__c where Id =:ActionPlanTemplateId and AccountId__c != null]);

        if(APT.size() > 0){
            accID = APT[0].AccountId__c;
        }
        AccountHierarchyStateBatchClass batch = new AccountHierarchyStateBatchClass(accID,ActionPlanTemplateId);
        BatchID = Database.executeBatch(batch, 100);
    
        ID initialID = accid;   
        Set <ID> childIDs = new Set <ID>();

        actGrpByState = new Map<String, List<Id>>();

        Map<String, Integer> actGrpCntByState = new Map<String, Integer>();
        Integer allActsCnt = 0;

        Set <ID> queryIDs = new Set <ID>();    
        Boolean parentIDReroll = false;  
        Account ultimateAcc;
        Map <ID, List <Account>> childMap = new Map <ID, List <Account>>();

        //Account accIDList = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState From ChildAccounts ORDER BY ShippingState ASC) FROM Account WHERE ID =:accID ];
    
        // if (accIDList.ChildAccounts.size() > 0) {
                    
        //     for (Integer i = 0; i < accIDList.ChildAccounts.size(); i++) {
                
        //         childMap.put(accid, accIDList.ChildAccounts);
        //         childIDs.add(accIDList.ChildAccounts[i].id);
          
        //         if(actGrpByState.containsKey(accIDList.ChildAccounts[i].ShippingState)){
        //             List<Id> actIds444 = actGrpByState.get(accIDList.ChildAccounts[i].ShippingState);
        //             actIds444.add(accIDList.ChildAccounts[i].id);
        //             actGrpByState.put(accIDList.ChildAccounts[i].ShippingState,actIds444);
        //             actGrpCntByState.put(accIDList.ChildAccounts[i].ShippingState,actIds444.size());
        //         }else{
        //             List<Id> actIds333 = new List<Id>();
        //             actIds333.add(accIDList.ChildAccounts[i].id);
        //             actGrpByState.put(accIDList.ChildAccounts[i].ShippingState,actIds333);
        //             actGrpCntByState.put(accIDList.ChildAccounts[i].ShippingState,actIds333.size());
        //         }
                

                
        //         queryIDs.add(accIDList.ChildAccounts[i].id);
                
        //     }

        //     System.debug('1 level Deep Ids-'+queryIDs);
        //     System.debug('1 level Deep Ids count-'+queryIDs.size());

        //     allActsCnt = allActsCnt + queryIDs.size();


        //     Integer maxDeepLevel = 1;

        //     while (queryIDs.size() > 0) {

        //         List <Account> childAccount = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState From ChildAccounts) FROM Account WHERE ID IN :queryIDs];        
        //         queryIDs.clear();
        //         if(maxDeepLevel < 7){
        //             for (Account oneAcc: childAccount) {
                    
        //                 if (oneAcc.ChildAccounts.size() > 0) {
                            
        //                     childMap.put(oneAcc.id, oneAcc.ChildAccounts);
                            
        //                     for (Integer i = 0; i < oneAcc.ChildAccounts.size(); i++) {
                            
        //                         childIDs.add(oneAcc.ChildAccounts[i].id);   

        //                         if(actGrpByState.containsKey(oneAcc.ChildAccounts[i].ShippingState)){
        //                             List<Id> actIds222 = actGrpByState.get(oneAcc.ChildAccounts[i].ShippingState);
        //                             actIds222.add(oneAcc.ChildAccounts[i].id);
        //                             actGrpByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222);
        //                             actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222.size());
        //                         }else{
        //                             List<Id> actIds111 = new List<Id>();
        //                             actIds111.add(oneAcc.ChildAccounts[i].id);
        //                             actGrpByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111);
        //                             actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111.size());
        //                         }

        //                         queryIDs.add(oneAcc.ChildAccounts[i].id);
                                
        //                     }  
        //                 }    
        //             }   
        //             maxDeepLevel = maxDeepLevel+1; 
        //             if(queryIDs.size() > 0){
        //                 System.debug(maxDeepLevel+' level Deep Ids-'+queryIDs);
        //                 System.debug(maxDeepLevel+' level Deep Ids count-'+queryIDs.size());
        //                 allActsCnt = allActsCnt + queryIDs.size();

        //             }
                    
                    
        //         }    
        //     }
        // }
        // System.debug('State Wise Grouped Accounts-'+actGrpByState);
        // System.debug('State Wise Grouped Account Counts-'+actGrpCntByState);
        // System.debug('All Child Accounts Count-'+allActsCnt);
      
        // Set<string> aaptStateSet = new Set<string>();
        // for(AccountActionPlanTemplate__c a: [select id,Grouped_State__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c = :ActionPlanTemplateId] ){
        //     if(a.Grouped_State__c != null){
        //         aaptStateSet.add(a.Grouped_State__c);    
        //     }        
        // }
        // List<stateAccounts> stateList = new List<stateAccounts>();
        
        // for(string st : actGrpCntByState.keySet()){
        //     stateAccounts wrapp = new stateAccounts();
        //     wrapp.groupedAccountIds=actGrpByState.get(st);
        //     wrapp.groupedState=st;
        //     wrapp.groupedAccountsCount=actGrpCntByState.get(st);
        //     wrapp.groupedStateAccountsCount=actGrpCntByState;
        //     if(aaptStateSet.contains(st)){
        //         wrapp.disabled=true;
        //         wrapp.selected=true;
        //         wrapp.className = 'slds-hint-parent slds-is-selected';
        //     }else{
        //         wrapp.disabled=false;
        //         wrapp.className='slds-hint-parent';
        //         wrapp.selected=false;    
        //     }
        //     wrapp.groupedStateWithAccountIds = actGrpByState;
        //     stateList.add(wrapp);
        // }
        //System.debug('stateList '+JSON.serializePretty(stateList));


        //return JSON.serializePretty(stateList);
        return null; //stateList;
    }
    @AuraEnabled
    public static  List<stateAccounts> fetchBatchAssociateStateData (ID ActionPlanTemplateId) {
        System.debug('method check ');
          List<ActionPlanTemplate__c> aptList = [select id,name,Associate_States_Group__c from ActionPlanTemplate__c where id =: ActionPlanTemplateId];
        
        String jsonString = aptList[0].Associate_States_Group__c;
        System.debug('jsonString '+jsonString);

        Map<String, Integer> stateMapvalues = (Map<String, Integer>)JSON.deserialize(jsonString, Map<String, Integer>.class);
        System.debug('stateMapvalues '+stateMapvalues);

        Set<string> aaptStateSet = new Set<string>();
        String statusValue ;
        for(AccountActionPlanTemplate__c a: [select id,Grouped_State__c,ActionPlanTemplateId__r.Status__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c = :ActionPlanTemplateId] ){
            if(a.Grouped_State__c != null){
                aaptStateSet.add(a.Grouped_State__c); 
                statusValue=a.ActionPlanTemplateId__r.Status__c;   
            }        
        }
        List<String> sortedStateCodes = new List<String>(stateMapValues.keySet());
        sortedStateCodes.sort();

        List<stateAccounts> stateList = new List<stateAccounts>();
        for(string st : sortedStateCodes){
            stateAccounts wrapp = new stateAccounts();
            //wrapp.groupedAccountIds=actGrpByState.get(st);
            wrapp.groupedState=st;
            wrapp.groupedAccountsCount=stateMapvalues.get(st);
            wrapp.groupedStateAccountsCount=stateMapvalues;
            if(statusValue !='Planning'){
                wrapp.disabled=true;
            }
            if(aaptStateSet.contains(st)){
                //wrapp.disabled=true;
                wrapp.selected=true;
                wrapp.className = 'slds-hint-parent slds-is-selected';
            }else{
                wrapp.disabled=false;
                wrapp.className='slds-hint-parent';
                wrapp.selected=false;    
            }
            //wrapp.groupedStateWithAccountIds = actGrpByState;
            stateList.add(wrapp);
        }
        System.debug('stateList '+JSON.serializePretty(stateList));


        //return JSON.serializePretty(stateList);
        return stateList;
    }
  
    @AuraEnabled
    public static string associateStateGroupsOnApt(Id ActionPlanTemplateId, Map<String,String> selectedStatesCount, Map<String,String> unSelectedStates ) { 

        List<ActionPlanTemplate__c> APT = new List<ActionPlanTemplate__c>([SELECT Id, Name, ActionPlanType__c, AccountId__c from ActionPlanTemplate__c where Id =:ActionPlanTemplateId and AccountId__c != null]);

        string accountId =APT[0].AccountId__c;
        system.debug('templateId'+ActionPlanTemplateId);
        //system.debug('selectedRSGList--->'+selectedStateList);
        String returnResponse;  
        Set<Id> successRSGRecords = new Set<Id>();
        String method_Name='associateRetailStoreGroupsOnApt';
        String operationType = 'Database.Insert_Failed';
        Boolean associateStoreGroupsFailure = false;
        Map<string,AccountActionPlanTemplate__c> aAptstateMap = new Map<string,AccountActionPlanTemplate__c>();

        for(AccountActionPlanTemplate__c aapt: [select id,Grouped_State__c,ActionPlanTemplateId__r.Status__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c = :ActionPlanTemplateId] ){
            if(aapt.Grouped_State__c != null){
                aAptstateMap.put(aapt.Grouped_State__c,aapt); 
            }        
        }
        List<AccountActionPlanTemplate__c> AAPTList = new List<AccountActionPlanTemplate__c>();
        if(selectedStatesCount.size()>0 && ActionPlanTemplateId != null){
            try{
                for(string selectedState : selectedStatesCount.keySet()){
                    AccountActionPlanTemplate__c AAPT = new AccountActionPlanTemplate__c();

                    if(aAptstateMap.containsKey(selectedState)){
                        AAPT = new AccountActionPlanTemplate__c();
                        AAPT.id=aAptstateMap.get(selectedState).id;
                        AAPTList.add(AAPT);
                    }else{
                        AAPT = new AccountActionPlanTemplate__c();
                        AAPT.ActionPlanTemplateId__c = ActionPlanTemplateId;
                        AAPT.Grouped_Store_Locations__c = Integer.valueOf(selectedStatesCount.get(selectedState));
                        AAPT.Grouped_State__c=selectedState;
                        AAPT.Account__c=accountId;
                        AAPT.Active__c = true;
                        AAPTList.add(AAPT);
                    }
                  
                }
                system.debug('AAPTList'+AAPTList);
                if (ActionPlanTemplateId != null && AAPTList.size() > 0) {
                    List<Database.UpsertResult> insertedRSGroups = Database.upsert(AAPTList, true);
                    List<Database.Error> errorRsGroup = new  List<Database.Error>();
                    for (Integer index = 0, size = insertedRSGroups.size(); index < size; index++) {
                        if (!insertedRSGroups[index].isSuccess()) {
                            associateStoreGroupsFailure = true;
                            errorRsGroup.addAll(insertedRSGroups[index].getErrors());
                            returnResponse= errorRsGroup[0].getMessage();
                        }else{
                            successRSGRecords.add(insertedRSGroups[index].id);
                        }
                    }
                    //Insert exceptions in Log__c object, If any
                    // if(errorRsGroup.size()>0)
                    // {
                    //     LogEventTriggerHandler.insertBatchLog(errorRsGroup,class_Name,method_Name,'Account Action Plan Template',operationType);
                    // }
                }
               
                returnResponse ='States Groups associated successfully';
            }catch(Exception ex){
                throw new AuraHandledException('Error: '
                + 'This Action Plan Template Is In Execution. You Cannot Add Retail Store Groups On This Action Plan Template');
                
            }
        } 
        if(unSelectedStates.size()>0 && ActionPlanTemplateId !=null){
            set<string> stateSet = new set<string>();
            for(string unselectedStatesGroup : unSelectedStates.keySet()){
                stateSet.add(unselectedStatesGroup);
            }
            Set<id> aAptSetIds = new Set<Id>();
            List<AccountActionPlanTemplate__c> aaptUnselectedList = [select id,Grouped_State__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c = :ActionPlanTemplateId and Grouped_State__c IN : stateSet];
            for(AccountActionPlanTemplate__c aapt : aaptUnselectedList){
                aAptSetIds.add(aapt.id);
            }
            List<InStoreLocation__c> instorelocationList =[select id,RetailStoreGroupActionPlanTemplate__c, RetailLocationId__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c	IN: aAptSetIds];
            List<Mission__c> missionList = [select id,name from Mission__c where RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds]; 
            List<StoreProduct__c> storeProductList = [select id from StoreProduct__c where InStoreLocationId__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds];
            List<Asset>  assetList =[select id from Asset where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds];
            List<Asset__c> customAssetList =[select id from Asset__c where InStoreLocation__r.RetailStoreGroupActionPlanTemplate__c IN: aAptSetIds];
            if(customAssetList.size()>0){
               delete customAssetList;
            }
            if(assetList.size()>0){
             delete assetList;
            }
            if(storeProductList.size()>0){
               delete storeProductList;
            }
            if(missionList.size()>0){
              delete missionList;
            }
            if(instorelocationList.size()>0){
               delete instorelocationList;
            }
            if(aaptUnselectedList.size()>0){
                delete aaptUnselectedList;
            }

            returnResponse ='Unselected States Groups deleted successfully';

        }
        // else{
        //     returnResponse = 'Please select retail store groups.';
        // }
        return returnResponse;
    }

    //Unsused Method just keeping for reference
    // public static Set <ID> MyTest_Bak (ID accID) {
    
    //     ID initialID = accid;    
    //     Set <ID> childIDs = new Set <ID>();

    //     //Map<Id,String> actGrpByState = new Map<Id,String>();

    //     Map<String, List<Id>> actGrpByState = new Map<String, List<Id>>();

    //     Map<String, Integer> actGrpCntByState = new Map<String, Integer>();


    //     Set <ID> queryIDs = new Set <ID>();    
    //     Boolean parentIDReroll = false;  
    //     Account ultimateAcc;
    //     Map <ID, List <Account>> childMap = new Map <ID, List <Account>>();
            
    //     while (!parentIDReroll) {   
    //         Account accIDList = [SELECT ID, ShippingState,Name, ParentID ,(SELECT ID,ShippingState From ChildAccounts) FROM Account WHERE ID =:accID];
        
    //         If (accIDList.parentID != null) {
                
    //             accID = accIDList.ParentID;
                
    //         } else { 
    //             parentIDReroll = true; 
    //             ultimateAcc = accIDList;
    //         }

    //     }  
    
    //     if (ultimateAcc.ChildAccounts.size() > 0) {
                    
    //         for (Integer i = 0; i < ultimateAcc.ChildAccounts.size(); i++) {
                
    //             childMap.put(accid, ultimateAcc.ChildAccounts);
    //             childIDs.add(ultimateAcc.ChildAccounts[i].id);
    //             //if(ultimateAcc.ChildAccounts[i].ShippingState != '' && ultimateAcc.ChildAccounts[i].ShippingState != NULL){
    //                 //actGrpByState.put(ultimateAcc.ChildAccounts[i].id,ultimateAcc.ChildAccounts[i].ShippingState);
    //             //}
    //             if(actGrpByState.containsKey(ultimateAcc.ChildAccounts[i].ShippingState)){
    //                 List<Id> actIds444 = actGrpByState.get(ultimateAcc.ChildAccounts[i].ShippingState);
    //                 actIds444.add(ultimateAcc.ChildAccounts[i].id);
    //                 actGrpByState.put(ultimateAcc.ChildAccounts[i].ShippingState,actIds444);
    //                 actGrpCntByState.put(ultimateAcc.ChildAccounts[i].ShippingState,actIds444.size());
    //             }else{
    //                 List<Id> actIds333 = new List<Id>();
    //                 actIds333.add(ultimateAcc.ChildAccounts[i].id);
    //                 actGrpByState.put(ultimateAcc.ChildAccounts[i].ShippingState,actIds333);
    //                 actGrpCntByState.put(ultimateAcc.ChildAccounts[i].ShippingState,actIds333.size());
    //             }
                

                
    //             queryIDs.add(ultimateAcc.ChildAccounts[i].id);
                
    //         }
                
                    
    //         while (queryIDs.size() > 0) {
                        
    //             List <Account> childAccount = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState From ChildAccounts) FROM Account WHERE ID IN :queryIDs];        
    //             queryIDs.clear();
                    
    //             for (Account oneAcc: childAccount) {
                
    //                 if (oneAcc.ChildAccounts.size() > 0) {
                        
    //                     childMap.put(oneAcc.id, oneAcc.ChildAccounts);
                        
    //                     for (Integer i = 0; i < oneAcc.ChildAccounts.size(); i++) {
                        
    //                     childIDs.add(oneAcc.ChildAccounts[i].id);    
    //                     //if(oneAcc.ChildAccounts[i].ShippingState != '' && oneAcc.ChildAccounts[i].ShippingState != NULL){
    //                         //actGrpByState.put(oneAcc.ChildAccounts[i].id,oneAcc.ChildAccounts[i].ShippingState);
    //                     //}

    //                     if(actGrpByState.containsKey(oneAcc.ChildAccounts[i].ShippingState)){
    //                         List<Id> actIds222 = actGrpByState.get(oneAcc.ChildAccounts[i].ShippingState);
    //                         actIds222.add(oneAcc.ChildAccounts[i].id);
    //                         actGrpByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222);
    //                         actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222.size());
    //                     }else{
    //                         List<Id> actIds111 = new List<Id>();
    //                         actIds111.add(oneAcc.ChildAccounts[i].id);
    //                         actGrpByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111);
    //                         actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111.size());
    //                     }

    //                     queryIDs.add(oneAcc.ChildAccounts[i].id);
                            
    //                     }  
    //                 }    
    //             }        
    //         }
    //     }
    //     System.debug(childIDs.size());
    //     System.debug(actGrpByState);
    //     System.debug(actGrpCntByState);
    //     //System.debug(childIDs);
    //     //System.debug(actGrpByState);
    //     return childIDs;
        
    // }
    public class stateAccounts {
        @AuraEnabled
        public Id id {set;get;}
        @AuraEnabled
        public string groupedState {get;set;}
        @AuraEnabled
        public Integer groupedAccountsCount {get;set;} 
        @AuraEnabled
        public Boolean disabled {get;set;}
        @AuraEnabled
        public string className {get;set;}
        @AuraEnabled
        public boolean selected {get;set;} 
        @AuraEnabled  
        public List<id> groupedAccountIds {get;set;}
        @AuraEnabled  
        public Map<String,List<id>> groupedStateWithAccountIds {get;set;}
        @AuraEnabled  
        public Map<String,Integer> groupedStateAccountsCount {get;set;}

    }

  
}