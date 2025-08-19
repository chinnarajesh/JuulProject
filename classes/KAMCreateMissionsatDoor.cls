/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        05-20-2020                     */
/* Class Name: KAMCreateMissionsatDoor                       */
/* Description:To create missions on retail store group via quick action "Create Missions at door"  */
/**********************************************************************/
public with sharing class KAMCreateMissionsatDoor {
    public KAMCreateMissionsatDoor() {
        
    }
    public static String class_Name='KAMCreateMissionsatDoor';
    
    //Method to get all the action plan templates with their items on retail store group.
    @AuraEnabled(cacheable=true)
    public static string getAllAPTWithItemsProducts(Id RetailStoreGrpID, String SelectedRecordType){
        //SOQL on juntion object AccountActionPlanTemplate to get  
        List<AccountActionPlanTemplate__c> AAPT = new List<AccountActionPlanTemplate__c>(
            [SELECT Id,ActionPlanTemplateId__c,ActionPlanTemplateId__r.StoreAssortment__c ,ActionPlanTemplateId__r.StoreAssortment__r.AssortmentId__c,ActionPlanTemplateId__r.CommercialActivityId__c from AccountActionPlanTemplate__c where RetailLocationId__c =:RetailStoreGrpID and ActionPlanTemplateId__r.recordtype.developerName=:SelectedRecordType]
        );
        Map<Id,List<Id>> mapAssortmentTemplate = new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapCommActTemplate = new Map<Id,List<Id>>();
        Set<Id> actionPlanTemplateId = new  Set<Id>();
        for(AccountActionPlanTemplate__c a: AAPT ){
            if(a.ActionPlanTemplateId__r.CommercialActivityId__c != null){
                if(!mapCommActTemplate.containsKey(a.ActionPlanTemplateId__r.CommercialActivityId__c)){
                    mapCommActTemplate.put(a.ActionPlanTemplateId__r.CommercialActivityId__c,new List<Id>());
                }
                mapCommActTemplate.get(a.ActionPlanTemplateId__r.CommercialActivityId__c).add(a.ActionPlanTemplateId__c);                
            }
            
            if(a.ActionPlanTemplateId__r.StoreAssortment__c != null){
                if(!mapAssortmentTemplate.containsKey(a.ActionPlanTemplateId__r.StoreAssortment__r.AssortmentId__c)){
                    mapAssortmentTemplate.put(a.ActionPlanTemplateId__r.StoreAssortment__r.AssortmentId__c,new List<Id>());
                }
                mapAssortmentTemplate.get(a.ActionPlanTemplateId__r.StoreAssortment__r.AssortmentId__c).add(a.ActionPlanTemplateId__c);                
            }
                        
            actionPlanTemplateId.add(a.ActionPlanTemplateId__c);            
        }
        System.debug('actionPlanTemplateId Set :'+actionPlanTemplateId);
        
        //SOQL to get Action Plan Item  for an Action Plan Template      
        Map<Id,List<ActionPlanTemplateItem__c>> mapAPTIList = new Map<Id,List<ActionPlanTemplateItem__c>>();
        for(ActionPlanTemplateItem__c api : [Select id,Name,Priority__c, Subject__c,ActionPlanTemplateId__c,ActionPlanTemplateId__r.Name from ActionPlanTemplateItem__c where ActionPlanTemplateId__c in :actionPlanTemplateId]){
            if(!mapAPTIList.containsKey(api.ActionPlanTemplateId__c)){
                mapAPTIList.put(api.ActionPlanTemplateId__c,new List<ActionPlanTemplateItem__c>());
            }
            mapAPTIList.get(api.ActionPlanTemplateId__c).add(api);                 
        } 
        system.debug('mapAPTIList='+mapAPTIList);
        //SOQL to get Assortment Products  for an Action Plan Template      
        Map<Id,List<AssortmentProduct__c>> mapAPTPList = new Map<Id,List<AssortmentProduct__c>>();
        for(AssortmentProduct__c app : [Select id,ProductId__c ,ProductId__r.Name,AssortmentId__c  from AssortmentProduct__c  where AssortmentId__c  in : mapAssortmentTemplate.keySet()]){
            List<Id> actiontemplateIds = mapAssortmentTemplate.get(app.AssortmentId__c);
            system.debug('actiontemplateIds = '+actiontemplateIds);
            for(Id actiontemplateId :actiontemplateIds){
                if(!mapAPTPList.containsKey(actiontemplateId)){
                    mapAPTPList.put(actiontemplateId,new List<AssortmentProduct__c>());
                }
                mapAPTPList.get(actiontemplateId).add(app);
            }                             
        } 
        system.debug('mapAPTPList='+mapAPTPList);
        //SOQL to get Commercial Activity Items  for an Action Plan Template      
        Map<Id,List<CommercialActivityProduct__c>> mapAPTCIList = new Map<Id,List<CommercialActivityProduct__c>>();
        for(CommercialActivityProduct__c ci : [Select id,ProductId__c ,ProductId__r.Name,ProductType__c,CommercialActivityId__c   from CommercialActivityProduct__c  where CommercialActivityId__c   in : mapCommActTemplate.keySet()]){
            List<Id> actiontemplateIds = mapCommActTemplate.get(ci.CommercialActivityId__c);
            for(Id actiontemplateId :actiontemplateIds){
                if(!mapAPTCIList.containsKey(actiontemplateId)){
                    mapAPTCIList.put(actiontemplateId,new List<CommercialActivityProduct__c>());
                }
                mapAPTCIList.get(actiontemplateId).add(ci);
            }                             
        } 
        
        List<APTWrapper> aptWrapList = new List<APTWrapper>();
        for(Id aptID : mapAPTIList.keySet()){
            APTWrapper aptWraper = new APTWrapper();             
            aptWraper.id = aptID;
            
            //Add Items to warpper
            List<Items> aptiList = new List<Items>();
            for(ActionPlanTemplateItem__c aptItem : mapAPTIList.get(aptID)){
                aptWraper.Name = aptItem.ActionPlanTemplateId__r.Name;
                Items aptiWrapp = new Items();
                aptiWrapp.id = aptItem.id;
                aptiWrapp.name = aptItem.Name ;
                aptiWrapp.priority =aptItem.Priority__c;
                aptiWrapp.subject =aptItem.Subject__c;
                aptiList.add(aptiWrapp);
            }
            aptWraper.items = aptiList;
            
            //Add Products to warpper
            List<Products> prdList = new List<Products>();
            List<AssortmentProduct__c> apl = new List<AssortmentProduct__c>();
            system.debug('aptID='+aptID+' and aptWraper.id='+aptWraper.id);
            system.debug('mapAPTPList='+mapAPTPList);
            if(mapAPTPList.get(aptID) != null)
                apl = mapAPTPList.get(aptID);
            for(AssortmentProduct__c aptprd : apl){                
                Products aptpWrapp = new Products();
                aptpWrapp.id = aptprd.ProductId__c;
                aptpWrapp.name = aptprd.ProductId__r.Name ;                
                prdList.add(aptpWrapp);
            }
            aptWraper.products = prdList;
            
            //Add Commercial activity items to warpper
            List<CommercialActivityItems> commItemList = new List<CommercialActivityItems>();
            List<CommercialActivityProduct__c> cil = new List<CommercialActivityProduct__c>();           
            if(mapAPTCIList.get(aptID) != null)
                cil = mapAPTCIList.get(aptID);
            for(CommercialActivityProduct__c cap : cil){                
                CommercialActivityItems ciWrapp = new CommercialActivityItems();
                ciWrapp.id = cap.ProductId__c;
                ciWrapp.name = cap.ProductId__r.Name ; 
                ciWrapp.productType = cap.ProductType__c;
                commItemList.add(ciWrapp);
            }
            aptWraper.commercialActivityItems = commItemList;
            
            
            aptWrapList.add(aptWraper);
        }  
        system.debug('aptWrapList'+aptWrapList);   

        return JSON.serializePretty(aptWrapList);
    }
        
    //Method to create Missions along with Action plan, action plan item and mission tasks on all related accounts of retail store group.Fires when a user clicks "Create Missions on Door" button in quick action popup
    @AuraEnabled
    public static string createVisitsOnRelatedAccounts(Id retailStoreId,  List<ActionPlanTemplate__c> selectedAPTList, List<ActionPlanTemplateItem__c> selectedAPTIList, List<Id> selectedProducts, List<CommercialActivityItems> selectedCommercialItems) { 
        system.debug('Inside Visits');
        String method_Name='createVisitsOnRealedAccounts';
        String operationType = 'Database.Insert_Failed';
        String returnResponse;  
        List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
        List<Mission__c> vistList = new List<Mission__c>();
        List<ActionPlan__c> actionPlanList = new List<ActionPlan__c>();
        List<ActionPlanItem__c> actionPlanItemList = new List<ActionPlanItem__c>();
        List<MissionTask__c> missionTaskList = new List<MissionTask__c>();
        Map<ActionPlanItem__c, MissionTask__c> missionAPIMap = new Map<ActionPlanItem__c, MissionTask__c>();
        Map<Id, Mission__c> missionAccountMap = new Map<Id, Mission__c>();
        List<ActionPlanItem__c> APIonMissionTask =new List<ActionPlanItem__c>();
        Map<String,String> APTAPFieldsMap;
        Map<String,String> APTIAPIFieldsMap;
        Set<Id> successMTaskRecords = new Set<Id>();
        Boolean MTaskFailure = false;
        Set<Id> successAPIRecords = new Set<Id>();
        Boolean apiFailure = false;
        Set<Id> successAPRecords = new Set<Id>();
        Boolean apFailure = false;
        Set<Id> successRecords = new Set<Id>();
        Boolean someFailure = false;
        arsgList = [Select id,AccountId__c from AccountRetailStoreGroup__c where RetailStoreGroupId__c = :retailStoreId and AccountId__c!=null];
        system.debug('selectedAPTIList'+selectedAPTIList);
        system.debug('selectedAPTList'+selectedAPTList);
        List<StoreProduct__c> spToInsert = new List<StoreProduct__c>();
        List<Asset> assetToInsert = new List<Asset>();
        if(arsgList.size()>0){
            for(AccountRetailStoreGroup__c arsg : arsgList){  
                Mission__c visit = new Mission__c();
                visit.AccountId__c = arsg.AccountId__c;
                missionAccountMap.put(arsg.AccountId__c,visit);
                //Make list of Store Products to be inserted (for Assortment Products)
                for(Id prd: selectedProducts){
                    spToInsert.add(new StoreProduct__c(ProductId__c =prd,RetailStoreId__c = arsg.AccountId__c));
                }
                //Make list of Store Products and Asset to be inserted (for commercial activity items)
                for(CommercialActivityItems cai: selectedCommercialItems){
                    if(cai.productType == 'JUUL Product')
                        spToInsert.add(new StoreProduct__c(ProductId__c =cai.Id,RetailStoreId__c = arsg.AccountId__c));
                    else if(cai.productType == 'Trade Collateral')
                        assetToInsert.add(new Asset(AccountId = arsg.AccountId__c, Product2Id =cai.Id, name= cai.name ));
                }
            }
        }
         
        //Insert Store Product for Selected Assortment Products and commercial activity items
        if (spToInsert != null && spToInsert.size() > 0) {
            List < Database.SaveResult > spToInsertResults = Database.Insert(spToInsert, true);
            List < Database.Error > spToInsertError = new List <Database.Error> ();
            for (Integer index = 0, size = spToInsertResults.size(); index < size; index++) {
                if (!spToInsertResults[index].isSuccess()) {
                    spToInsertError.addAll(spToInsertResults[index].getErrors());
                    returnResponse= spToInsertError[0].getMessage();
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
                    returnResponse= assetToInsertError[0].getMessage();
                }
            }
            if (assetToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(assetToInsertError, class_Name,method_Name, 'Asset', 'Database.Insert_Failed');
            }
        }
        
        
        system.debug('missionAccountMap.values()'+missionAccountMap);
        
      //Process further,if there are any related accounts.
        if(!(missionAccountMap.isEmpty())){
            try{
                
                List<Database.SaveResult> insertedMissions = Database.insert(missionAccountMap.values(), true); 
                system.debug('insertedMissions'+insertedMissions);
                List<Database.Error> listError = new  List<Database.Error>();
                
                for (Integer index = 0, size = insertedMissions.size(); index < size; index++) {
                    if (!insertedMissions[index].isSuccess()) {
                        someFailure = true;
                        listError.addAll(insertedMissions[index].getErrors());
                        returnResponse= listError[0].getMessage();
                    }else{
                        successRecords.add(insertedMissions[index].id);
                    }
                  //Insert exceptions in Log__c object, If any
                    if(listError.size()>0)
                    {
                        LogEventTriggerHandler.insertBatchLog(listError,class_Name,method_Name,'Mission',operationType);
                    }
                }
                //Process Action plans if missions got created successfully
                if (!someFailure && successRecords.size()>0)
                {  
                    //Get Action plan item and Action plan fields mappings from custom metadata types.
                    List<Data_Mapping__mdt> APTAPMapping =[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplate__c' AND Target_Object__c ='ActionPlan__c'];
                    APTAPFieldsMap= new Map<String,String>();
                    String sourceAPT = '';
                    for(Data_Mapping__mdt data: APTAPMapping){
                        APTAPFieldsMap.put(data.Source_Field__c,data.Target_Field__c);  
                        sourceAPT += data.Source_Field__c+',';
                    }
                    if(sourceAPT.endsWith(',')){
                        sourceAPT = sourceAPT.substring(0, sourceAPT.length() - 1);
                    }
                    Set<Id> selectedAPTIdList = new Set<Id>();
                    for(ActionPlanTemplate__c i :selectedAPTList){
                        selectedAPTIdList.add(i.id);
                    }
                    system.debug('selectedAPTIdList'+selectedAPTIdList);
                        
                    String query = 'Select RecordType.DeveloperName,'  +sourceAPT+' From ActionPlanTemplate__c Where id IN :selectedAPTIdList';
                    system.debug('query'+query);
                    system.debug('APTAPFieldsMap'+APTAPFieldsMap);
                    List<ActionPlanTemplate__c> selectedAPTListQueried =Database.query(query);
                    system.debug('selectedAPTListQueried'+selectedAPTListQueried);
                    //Create a list to store new Action plan records  
                    for(Id visitId :successRecords){
                        system.debug('visitId'+visitId);
                        for(ActionPlanTemplate__c curAPT :selectedAPTListQueried){
                            String curAPTRecordType = curAPT.recordType.DeveloperName;
                            Id APRecordType =  Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get(curAPTRecordType).getRecordTypeId();
                            ActionPlan__c ap = new ActionPlan__c();
                            system.debug('APTAPFieldsMap.keyset()'+APTAPFieldsMap.keyset());
                            for(string field: APTAPFieldsMap.keyset()){
                                ap.put(APTAPFieldsMap.get(field),curAPT.get(field));
                            }
                            ap.Mission__c = visitId;
                            ap.isProcessed__c = true;
                            ap.Status__c ='Planned';
                            if(APRecordType != null){
                               ap.RecordTypeId = APRecordType;  
                            }
                           
                            actionPlanList.add(ap);
                        }
                    }
                    //Insert Action plan records
                    if (actionPlanList != null && actionPlanList.size() > 0) {
                        List<Database.SaveResult> insertedAP = Database.insert(actionPlanList, true);
                        List<Database.Error> errorAPList = new  List<Database.Error>();
                        for (Integer index = 0, size = insertedAP.size(); index < size; index++) {
                            if (!insertedAP[index].isSuccess()) {
                                apFailure = true;
                                errorAPList.addAll(insertedAP[index].getErrors());
                                returnResponse= errorAPList[0].getMessage();
                            }else{
                                successAPRecords.add(insertedAP[index].id);
                            }
                        }
                        //Insert exceptions in Log__c object, If any
                        if(errorAPList.size()>0)
                        {
                            LogEventTriggerHandler.insertBatchLog(errorAPList,class_Name,method_Name,'Action Plan',operationType);
                        }
                    }
                    //Process Action plan items, If Action plans got created successfully and if user has selected APT items.
                    if (!apFailure && successAPRecords.size()>0 && selectedAPTIList.size()>0)
                    {   
                        //Get Mapping of Action plan template items and action plan item fields.
                        List<Data_Mapping__mdt> APTIAPIMapping =[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplateItem__c' AND Target_Object__c ='ActionPlanItem__c'];
                        APTIAPIFieldsMap= new Map<String,String>();
                        String sourceAPTI ='';
                        
                        for(Data_Mapping__mdt data :APTIAPIMapping){
                            APTIAPIFieldsMap.put(data.Source_Field__c,data.Target_Field__c); 
                            sourceAPTI += data.Source_Field__c+',';
                        } 
                        if(sourceAPTI.endsWith(',')){
                            sourceAPTI = sourceAPTI.substring(0, sourceAPTI.length() - 1);
                        }

                        Set<Id> selectedAPTIIdList = new Set<Id>();
                        for(ActionPlanTemplateItem__c i :selectedAPTIList){
                            selectedAPTIIdList.add(i.id);
                        }
                        
                        String queryAPIMapping = 'Select ActionPlanTemplateId__c, '  +sourceAPTI+' From ActionPlanTemplateItem__c Where id IN :selectedAPTIIdList';
                        system.debug('queryAPIMapping'+queryAPIMapping);
                        List<ActionPlanTemplateItem__c> selectedAPTIListQueried =Database.query(queryAPIMapping);
                        for(ActionPlan__c ap :[Select id,ActionPlanTemplateId__c from ActionPlan__c where id in:successAPRecords]){
                            for(ActionPlanTemplateItem__c curAPTI :selectedAPTIListQueried){
                                system.debug('curAPTI'+curAPTI);
                                if(ap.ActionPlanTemplateId__c == curAPTI.ActionPlanTemplateId__c){
                                    ActionPlanItem__c api = new ActionPlanItem__c();
                                    api.ActionPlanId__c =ap.Id;
                                    system.debug('APTIAPIFieldsMap'+APTIAPIFieldsMap);
                                    for(string field: APTIAPIFieldsMap.keyset()){
                                        api.put(APTIAPIFieldsMap.get(field),curAPTI.get(field));
                                        system.debug('api'+api);
                                    }
                                    actionPlanItemList.add(api);
                                }
                            }
                        } 
                        //Insert Action plan items 
                        if (actionPlanItemList != null && actionPlanItemList.size() > 0) {
                            List<Database.SaveResult> insertedAPI = Database.insert(actionPlanItemList, true);
                            List<Database.Error> errorAPIList = new  List<Database.Error>();
                            for (Integer index = 0, size = insertedAPI.size(); index < size; index++) {
                                if (!insertedAPI[index].isSuccess()) {
                                    apiFailure = true;
                                    errorAPIList.addAll(insertedAPI[index].getErrors());
                                    returnResponse= errorAPIList[0].getMessage();
                                }else{
                                    successAPIRecords.add(insertedAPI[index].id);
                                }
                            }
                            //Insert exceptions in Log__c object, If any
                            if(errorAPIList.size()>0)
                            {
                                LogEventTriggerHandler.insertBatchLog(errorAPIList,class_Name,method_Name,'Action Plan Item',operationType);
                            }
                        }
                        system.debug('insertedAPI'+successAPIRecords);
                        //Process Mission tasks if Action plan items got created successfully
                        if(!apiFailure && successAPIRecords.size()>0){
                            for(ActionPlanItem__c api: [Select id,ActionPlanId__r.Mission__c from ActionPlanItem__c where id in :successAPIRecords]){
                                MissionTask__c mtask = new MissionTask__c();
                                system.debug('api.ActionPlanId__r.Mission__c;'+api.ActionPlanId__r.Mission__c);
                                mtask.ParentId__c = api.ActionPlanId__r.Mission__c;
                                mtask.Status__c = 'Planned';
                                missionTaskList.add(mtask);
                                missionAPIMap.put(api,mtask);
                            }
                            //Insert Mission tasks
                            if (missionTaskList != null && missionTaskList.size() > 0) {
                                List<Database.SaveResult> insertedMtask = Database.insert(missionTaskList, true);
                                List<Database.Error> errorMissionTaskList = new  List<Database.Error>();
                                for (Integer index = 0, size = insertedMtask.size(); index < size; index++) {
                                    if (!insertedMtask[index].isSuccess()) {
                                        MTaskFailure = true;
                                        errorMissionTaskList.addAll(insertedMtask[index].getErrors());
                                        returnResponse= errorMissionTaskList[0].getMessage();
                                    }else{
                                        successMTaskRecords.add(insertedMtask[index].id);
                                    }
                                }
                                //Insert exceptions in Log__c object, If any
                                if(errorMissionTaskList.size()>0)
                                {
                                    LogEventTriggerHandler.insertBatchLog(errorMissionTaskList,class_Name,method_Name,'Mission Task',operationType);
                                }
                            }
                            //Relate AP items to mission task created above.
                            if(!MTaskFailure && successMTaskRecords.size()>0){
                                for(ActionPlanItem__c a : missionAPIMap.keySet()){
                                    a.MissionTaskId__c = missionAPIMap.get(a).Id;
                                    APIonMissionTask.add(a);
                                }
                                
                                if (APIonMissionTask != null && APIonMissionTask.size() > 0) {
                                    List < Database.SaveResult > APIonMissionTaskResults = Database.Update(APIonMissionTask, true);
                                    List < Database.Error > APIonMissionTaskError = new List <Database.Error> ();
                                    for (Integer index = 0, size = APIonMissionTaskResults.size(); index < size; index++) {
                                        if (!APIonMissionTaskResults[index].isSuccess()) {
                                            APIonMissionTaskError.addAll(APIonMissionTaskResults[index].getErrors());
                                            returnResponse= APIonMissionTaskError[0].getMessage();
                                        }
                                    }
                                    if (APIonMissionTaskError.size() > 0) {
                                        LogEventTriggerHandler.insertBatchLog(APIonMissionTaskError, class_Name,method_Name, 'Mission Task', 'Database.Update_Failed');
                                    }
                                } 
                            } 
                        }                    
                    } 
                    returnResponse ='Missions created successfully';
                } 
            }
            catch(Exception ex){
                returnResponse = ex.getMessage();
            }
        }
        else{
            system.debug('missionAccountMap.values()'+missionAccountMap);
            returnResponse = 'No associated accounts found. Please create accounts in order to create missions first';
        }
        return returnResponse;
    }
    
    public Class APTWrapper{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public boolean expanded {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
        @AuraEnabled
        public List<Products> products {get;set;}
        @AuraEnabled
        public List<CommercialActivityItems> commercialActivityItems {get;set;}
        
    }
    public Class Items{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String priority {get;set;}        
    }
    public Class CommercialActivityItems{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String productType {get;set;}
    }
    public Class Products{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String name {get;set;}               
    }
}