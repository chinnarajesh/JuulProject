/*****************************************************************************/
/* VERSION     AUTHOR                 DATE                                   */
/*     1.0     Shreya Raut            02-20-2021                             */
/* Class Name: KAMMissionBatch                                               */
/* Description: To create Mission,Mission task,action plan and action plan   */
/*              item records of APT record befor 15 Dyas of requested start  */
/*              date field                                                   */
/*****************************************************************************/
Public class KAMMissionBatch implements Database.Batchable<sobject>,Database.Stateful {

    Public Set<Actionplantemplate__c> apt; 
    Public Integer totalAmtOfRecords = 0;
    public String class_Name ='KAMMissionBatch';
    public Map<String,String> APTIMtaskFieldsMap;
    List<Data_Mapping__mdt> aptiMtaskMapping = new List<Data_Mapping__mdt>();
    String method_Name='Execute';
    Map<Id,ActionPlanTemplateItem__c> aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>();
    List<ActionPlanTemplateItem__c> selectedAPTIListQueried = new List<ActionPlanTemplateItem__c>();
    String operationType = 'Database.Insert_Failed';
    public Map<ID,String> ActionplanMAP;
    List<WrapperData> WrapList = new List<WrapperData>();
    Public Map<String,ActionPlanTemplateItem__c> aptItems;
    List<WrapperData> partialData = new List<WrapperData>();
    Set<Id> junctionIds = new Set<Id>();
    List<Data_Mapping__mdt> APTMissionMapping = new List<Data_Mapping__mdt>();
    Map<String,String> APTMissionFieldsMap = new Map<String,String>();
    String sourceAPT = '';
    Map<string, InStoreLocation__c > ISLMap;
    List<ActionPlanTemplate__c> selectedAPTQueried = new List<ActionPlanTemplate__c>();
    String  APTRecordType = '';
    MAP<string,ID> MissionRT =new Map<String,ID>();
    MAP<string,ID> ActionPlanRT =new Map<String,ID>();
    Map<String,List<Items>> rsgAptItems = new  Map<String,List<Items>>();
    ID ACcountMissionRecordType;
    ID PromoMissionRecordType;
    ID ResetMissionRecordType;
    ID ACcountAPRecordType;
    ID PromoAPRecordType;
    ID ResetAPRecordType;
    Map<ID,AccountActionPlanTemplate__c>aapt = new Map<ID,AccountActionPlanTemplate__c>();
    Map<Id,List<Id>> rsgAccount = new Map<Id,List<Id>>();
    Set<id> selectedRsgList = new Set<Id>();
    String sourceAPTI ='';
    Public List<Id> accountIds;
    Public Date oldDate;
    Public String d;
    Public String daysToProcessAPT;//JTP-177
    Public Date ActiveFlagDate;//JTP-177

    Map<String, Id> stateAaptIds = new  Map<String, Id>();
    public Integer maxDeepLevel = 1;

    public KAMMissionBatch()
    { 
        system.debug('inside KAMMissionBatch');
        ActionplanMAP = new Map<ID,String>();
        apt = new Set<Actionplantemplate__c>();
        d = Label.Days;
        Date oldDate = system.today().addDays(Integer.valueof(d));
        daysToProcessAPT = Label.APT_Mass_Cascade;//JTP-177
        string aPtApproved ='APT Approved & Locked';
        for(Actionplantemplate__c apt1 :[SELECT Id,recordtype.name,Status__c,Mass_Cascade_Active_Flag_Date__c,RequestedStartDate__c,Mass_Cascade_Flag__c FROM actionplantemplate__c WHERE (RequestedStartDate__c  =: oldDate OR Mass_Cascade_Flag__c = true) and Status__c =: aPtApproved and In_Store_Locations_Created__c = true and Missions_Created__c != true] )
        {
            if(apt1.Mass_Cascade_Active_Flag_Date__c != null){
            ActiveFlagDate = apt1.Mass_Cascade_Active_Flag_Date__c.addDays(Integer.valueof(daysToProcessAPT));//JTP-177
            System.debug('ActiveFlagDate : '+ActiveFlagDate);
                System.debug('Today : '+System.today());
            }
            if((ActiveFlagDate == System.today() && apt1.Mass_Cascade_Flag__c == true) || apt1.RequestedStartDate__c == oldDate)
            {
            apt.add(apt1);
            ActionplanMAP.put(apt1.id,apt1.recordtype.name);
                break;
            }
        }
        System.debug('apt : '+apt);
        System.debug('ActionplanMAP : '+ActionplanMAP);
        //INS Map used to link ISL records to Mission records.
        ISLMap = new Map<String,InStoreLocation__c  >();
        for(InStoreLocation__c is : [select id,RetailStoreGroupActionPlanTemplate__c,RetailLocationId__r.Name   ,RetailLocationId__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c IN: apt ]){
            ISLMap.put(is.RetailStoreGroupActionPlanTemplate__c+'-'+is.RetailLocationId__c,is);
        }
        
        //Map to store similar fields between APT and (mission and action plan)  
        APTMissionMapping=[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt
                           where Source_Object__c='ActionPlanTemplate__c' AND Target_Object__c ='Mission__c'];
        for(Data_Mapping__mdt data: APTMissionMapping){
            APTMissionFieldsMap.put(data.Source_Field__c,data.Target_Field__c);  
            sourceAPT += data.Source_Field__c+',';
        }
        if(sourceAPT.endsWith(',')){
            sourceAPT = sourceAPT.substring(0, sourceAPT.length() - 1);
        }
        String queryAPT = 'Select Id,Batch_Details__c,RecordType.DeveloperName, Status__c,CommercialActivityId__c,Cascade_Changes__c,Missions_Created__c,' 
            +sourceAPT+' From ActionPlanTemplate__c Where id IN:apt';
        selectedAPTQueried =Database.query(queryAPT);
        AccountAPRecordType = Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get('AccountPlan').getRecordTypeId();
        PromoAPRecordType = Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get('PromotionalActivityProcess').getRecordTypeId();
        ResetAPRecordType = Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        
        AccountmissionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get('AccountPlan').getRecordTypeId();
        PromomissionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get('PromotionalActivityProcess').getRecordTypeId();
        ResetmissionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        
        
        MissionRT.put('AccountPlan',AccountmissionRecordType);
        MissionRT.put('PromotionalActivityProcess',PromomissionRecordType);
        MissionRT.put('ResetActivityProcess',ResetmissionRecordType);
        
        ActionPlanRT.put('AccountPlan',AccountAPRecordType);
        ActionPlanRT.put('PromotionalActivityProcess',PromoAPRecordType);
        ActionPlanRT.put('ResetActivityProcess',ResetAPRecordType);
        
        APTIMtaskFieldsMap = new Map<String,String>();
        aptiMtaskMapping =[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where
                           Source_Object__c='ActionPlanTemplateItem__c' AND Target_Object__c ='MissionTask__c'];
        for(Data_Mapping__mdt data :aptiMtaskMapping){
            aptiMtaskFieldsMap.put(data.Source_Field__c,data.Target_Field__c); 
            sourceAPTI += data.Source_Field__c+',';
        }
        
        if(sourceAPTI.endsWith(',')){
            sourceAPTI = sourceAPTI.substring(0, sourceAPTI.length() - 1);
        }
        
        String queryAPIMapping1 = 'Select Id,'  +sourceAPTI+' From ActionPlanTemplateItem__c Where ActionPlanTemplateId__c IN:selectedAPTQueried';
        selectedAPTIListQueried =Database.query(queryAPIMapping1);
        aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>(selectedAPTIListQueried);

        //Map to store AccountActionPlanTemplate__c records linked to APT
        for(AccountActionPlanTemplate__c aapt1 : [Select Id,ActionPlanTemplateId__c,cascadeToDoor__c,RetailLocationId__c,ActionPlanTemplateId__r.CommercialActivityId__c,ActionPlanTemplateId__r.StoreAssortment__c,
                                                  ActionPlanTemplateId__r.recordtype.DeveloperName,RetailLocationId__r.Name,RetailLocationId__r.Pricing_State__c,ActionPlanTemplateId__r.StoreAssortment__r.AssortmentId__c,
                                                  RetailLocationId__r.PlanogramId__r.Id,RetailLocationId__r.PlanogramId__r.Name from AccountActionPlanTemplate__c where ActionPlanTemplateId__c IN :apt AND Account__c != null])
        {
            aapt.put(aapt1.id,aapt1);
            junctionIds.add(aapt1.id);
        }
        System.debug('aapt++'+aapt);
        //Map used to get the APTI selected on Manage Action Plan Template LWC
        Map<String,List<ActionPlanItem__c >> aptItems = new Map<String,List<ActionPlanItem__c>>();
        for(ActionPlanItem__c apt : [select id,ActionPlanTemplateItemId__c,ActionPlanTemplateItemId__r.name,ActionPlanTemplateItemId__r.Priority__c, ActionPlanTemplateItemId__r.Subject__c,ActionPlanId__r.ActionPlanTemplateId__c,MissionTaskId__r.ParentId__r.RetailStoreGroupActionPlanTemplate__c from ActionPlanItem__c   where 
                                     ActionPlanId__r.ActionPlanTemplateId__c IN: ActionplanMAP.keyset() AND  MissionTaskId__r.ParentId__r.AccountId__r.Type ='HQ'])
        {
            String s = apt.ActionPlanId__r.ActionPlanTemplateId__c+'='+apt.MissionTaskId__r.ParentId__r.RetailStoreGroupActionPlanTemplate__c;
            if(!aptItems.containsKey(s))
                aptItems.put(s,new List<ActionPlanItem__c>());
            aptItems.get(s).add(apt);
        }
        if(junctionIds.size()>0){
            for(ID a: aapt.keyset()){
                WrapperData Wraper = new WrapperData();
                Wraper.junctionId =aapt.get(a).id;
                Wraper.Id = aapt.get(a).id;
                Wraper.name = aapt.get(a).RetailLocationId__r.Name;
                Wraper.ActionPlanTemplateId=aapt.get(a).ActionPlanTemplateId__c;
                String APTRSG =Wraper.ActionPlanTemplateId+'='+Wraper.junctionId;
                Wraper.APTRSG = APTRSG;
                Wraper.RecordTypeName = aapt.get(a).ActionPlanTemplateId__r.recordtype.DeveloperName;
                WrapList.add(Wraper);
                selectedRsgList.add(Wraper.Id);
                
                Map<string,List<Items>> aptiList = new Map<string,List<Items>>();
                if(aptItems != null && aptItems.size()>0){
                    for(ActionPlanItem__c api: aptItems.get(wraper.APTRSG)){
                        // for(String aptItem : aptItems.Keyset()){ 
                        // if(wraper.junctionId == aptItems.get(aptItem).ActionPlanTemplateId__c){  
                        Items aptiWrapp = new Items();  
                        aptiWrapp.id =api.ActionPlanTemplateItemId__c; 
                        aptiWrapp.name =  api.ActionPlanTemplateItemId__r.name; 
                        aptiWrapp.priority = api.ActionPlanTemplateItemId__r.Priority__c;   
                        aptiWrapp.subject = api.ActionPlanTemplateItemId__r.Subject__c; 
                        //saptiList.add(aptiWrapp);
                        if(!aptiList.containsKey(wraper.APTRSG))   //*S* 
                            aptiList.put(wraper.APTRSG, new List<Items>());  //*S* 
                        aptiList.get(wraper.APTRSG).add(aptiWrapp);  //*S* 
                        
                        //}
                        Wraper.items = aptiList;
                        //}
                    }
                }
                
            }
            
        }  
        
        //get rsg of each apt
        
        WraperDataWithAPTInfo wda= new WraperDataWithAPTInfo();
        wda.wraperList = WrapList;
        partialData =WrapList;
        for(WrapperData wd : partialData){
            if(wd.Items!=null && wd.Items.get(wd.APTRSG) != null && wd.Items.size()>0){
                for(Items i: wd.Items.get(wd.APTRSG)){
                    if(!rsgAptItems.containsKey(wd.APTRSG))
                        rsgAptItems.put(wd.APTRSG,new List<Items>());
                    rsgAptItems.get(wd.APTRSG).add(i);
                    
                } 
            } 
        }
        accountIds = new List<Id>();
        System.debug('selectedRSGList++'+selectedRSGList);
        if(selectedRSGList != null && selectedRSGList.size() > 0){ 
            //commented by rajesh juturi
            // for(AccountRetailStoreGroup__c arsg: [Select id,AccountId__c,RetailStoreGroupId__c,AccountId__r.ComplianceMechanism__c,AccountId__r.ShippingState from AccountRetailStoreGroup__c where RetailStoreGroupId__c IN :selectedRSGList and AccountId__c!=null and AccountId__r.Type != 'HQ']){    
            //     if(!rsgAccount.containsKey(arsg.RetailStoreGroupId__c)){
            //         rsgAccount.put(arsg.RetailStoreGroupId__c,new List<Id>());
            //     }
            //     rsgAccount.get(arsg.RetailStoreGroupId__c).add(arsg.AccountId__c);
            //     accountIds.add(arsg.AccountId__c);
            // }

            //added by rajesh juturi
            for(AccountActionPlanTemplate__c aap :  [select id,name,Account__c,Grouped_State__c from AccountActionPlanTemplate__c where id =: selectedRSGList]){
                accountIds.add(aap.Account__c);
                stateAaptIds.put(aap.Grouped_State__c, aap.id);
            }
        }
        System.debug('accountIds++'+accountIds);
    }    
 
    public Class WraperDataWithAPTInfo{
        
        public List<WrapperData> wraperList {get;set;}
        public void WraperDataWithAPTInfo(){
            
        }
        
    }
    Public Class WrapperData{
        public WrapperData(){
            
        }
        public ID ActionPlanTemplateId {get;set;}
        public ID junctionId {get;set;}
        public ID ID {get;set;}
        public String name {get;set;}
        public String RecordTypeName {get;set;}
        public string APTRSG{get;set;}
        public Map<String,List<Items>> items {get;set;}
        
    }
    public Class Items{
        
        public Id Id {get;set;}
        public String name {get;set;}
        public Id parentId {get;set;}
        public Boolean selected {get;set;}
        public String subject {get;set;}
        public String priority {get;set;}
        public Items(){
            selected = False;
        }
        
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select id,ShippingState, Name, ParentID,Type,ComplianceMechanism__c From Account WHERE ParentID IN: accountIds');
    }
    public void execute(Database.BatchableContext BC,List<Account> ChildAccounts){
        System.debug('Inside Execute');
        Set<Id> accSet = new Set<Id>();
        Map<ID,ID> accDoor = new Map<ID,ID>();
        Map<id,String> rsgAccountStateMap = new Map<id,String>();
        Set <ID> queryIDs = new Set <ID>();
        /////added bu rajesh juturi
        if (ChildAccounts.size() > 0) {
            for (Integer i = 0; i < ChildAccounts.size(); i++) {

                if(ChildAccounts[i].Type != 'HQ'){
                    //chunkChildAccIds.add(ChildAccounts[i].id);
                    rsgAccountStateMap.put(ChildAccounts[i].id, ChildAccounts[i].ShippingState);

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

        ///////
        for(Id a: rsgAccountStateMap.keySet()){
            accSet.add(a);
        }
        
        //System.debug('Wrapper total '+partialData);
        
        Map<String,Mission__c> mapKeyMission = new Map<String,Mission__c>();
        Map<Id,Id> rsgPlanogramsToUpdate = new Map<Id,Id>();
        for(WrapperData wd: partialData){
             system.debug('*** 8	'+wd.Id);
             if(rsgAccount.get(wd.Id) != null){
                  system.debug('*** 7');
                for(Id a: accSet){
                     system.debug('*** 6');
                    for(ID r :rsgAccount.get(wd.Id)){
                         system.debug('*** 5');
                        if(a==r){
                          system.debug('*** 4');
                           for(ActionPlanTemplate__c aa :selectedAPTQueried ){
                                system.debug('*** 3');
                                if(wd.ActionPlanTemplateId == aa.id){
                                     system.debug('*** 2');
                                    if(rsgAccount.get(wd.Id).contains(a)){
                                         system.debug('*** 1');
                                        // Create Missions
                                        String storeLocationKey = wd.junctionId+'-'+a;
                                       // if(rsgAptItems.get(wd.ActionPlanTemplateId+'='+wd.junctionId) != null && rsgAptItems.get(wd.ActionPlanTemplateId+'='+wd.junctionId).size()>0){
                                            system.debug('*** inside mission rsgitem');
                                            if((ISLMap.get(storeLocationKey)!=Null && ISLMap.size()>0 && !ISLMap.isEmpty())||Test.isRunningTest()){
                                            Mission__c m = new Mission__c();
                                            m.AccountId__c = a;
                                            if(MissionRT != null && !MissionRT.isEmpty() &&  MissionRT.get(wd.RecordTypeName)!=null)
                                                m.RecordTypeId = MissionRT.get(wd.RecordTypeName);
                                            //System.debug('MissionRT.get(wd.RecordTypeName)'+MissionRT.get(wd.RecordTypeName));
                                            m.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                                            if(ISLMap.get(storeLocationKey)!=Null && ISLMap.size()>0 && !ISLMap.isEmpty())     
                                            m.InStoreLocationId__c= ISLMap.get(storeLocationKey).id;
                                            //System.debug('wd.junctionId'+wd.junctionId);
                                            for(string field: APTMissionFieldsMap.keyset()){
                                                m.put(APTMissionFieldsMap.get(field),aa.get(field));
                                            }
                                            mapKeyMission.put(wd.Id+'='+a+'='+wd.ActionPlanTemplateId,m);
                                            //System.debug('mapKeyMission.keyset()'+mapKeyMission.keyset());
                                             }
                                       // }
                                    }
                                    
                                }
                            }
                        }}}
            }
        }
        List<Id> successRecords = new List<Id>();
        if(mapKeyMission.size()>0){
            List<Database.SaveResult> missionToInsertResults = Database.Insert(mapKeyMission.values(), true);
            List<Database.Error> missionToInsertError = new List <Database.Error>();
            for (Integer index = 0, size = missionToInsertResults.size(); index < size; index++) {
                if (!missionToInsertResults[index].isSuccess()) {
                    missionToInsertError.addAll(missionToInsertResults[index].getErrors());
                }else
                    successRecords.add(missionToInsertResults[index].id);
            }
            if (missionToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(missionToInsertError,class_Name,method_Name, 'Mission', operationType);
            }
            
            //Create AP
            Map<Id,ActionPlan__c> actionPlansToInsert = new Map<Id,ActionPlan__c>();
            for(WrapperData wd: partialData){
                for(Mission__c m: mapKeyMission.values()){
                    if( m.RetailStoreGroupActionPlanTemplate__c == wd.junctionID){
                        ActionPlan__c ap = new ActionPlan__c();
                        if(ActionPlanRT != null && !ActionPlanRT.isEmpty() && ActionPlanRT.get(wd.RecordTypeName)!=null)
                            ap.RecordTypeId = ActionPlanRT.get(wd.RecordTypeName);
                        ap.isProcessed__c = true;
                        ap.ActionPlanTemplateId__c = wd.ActionPlanTemplateId;
                        ap.Mission__c = m.Id;
                        actionPlansToInsert.put(m.Id,ap);  
                    }
                }
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
            
            //Creare Mission tasks
            for(WrapperData wd: partialData){
                if(rsgAccount.get(wd.Id) != null){
                    for(Id a: accSet){
                        if(rsgAccount.get(wd.Id).contains(a)){
                            Mission__c m = mapKeyMission.get(wd.Id+'='+a+'='+wd.ActionPlanTemplateId);
                            if(m!=null )
                                if(rsgAptItems.get(wd.ActionPlanTemplateId+'='+wd.junctionId)!=null)
                                for(Items i: rsgAptItems.get(wd.ActionPlanTemplateId+'='+wd.junctionId)){ 
                                    ActionPlanItem__c api = new ActionPlanItem__c();
                                    api.ActionPlanTemplateItemId__c =i.Id;
                                    if(actionPlansToInsert.get(m.Id) != null)
                                        api.ActionPlanId__c = actionPlansToInsert.get(m.Id).Id;
                                    MissionTask__c mtask = new MissionTask__c();
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
        }
        
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Inside Finish');
        List<ActionPlanTemplate__c> aptList = new list<ActionPlanTemplate__c>();
        AsyncApexJob j = [Select Id, CompletedDate,Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:BC.getJobId()];
        List<String> toAddresses = new List<String>();
        toAddresses.addAll((Label.BatchUserIDs).split(','));
        
        if(j.Status == 'Completed' && j.NumberOfErrors ==0) {
            List<ActionPlanTemplate__c> a = new List<ActionPlanTemplate__c>();
            for(ActionPlanTemplate__c aaa :selectedAPTQueried ){
                aaa.Status__c = 'Execution'; 
                aaa.Missions_Created__c=true;
                if(aaa.RecordType.DeveloperName == 'ResetActivityProcess')
                    aaa.Status__c = 'Vendor Execution';
                a.add(aaa);
            }
            update a;
        }else{
            List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
            for(AccountActionPlanTemplate__c a :[select id,cascadeToDoor__c from AccountActionPlanTemplate__c 
                                                 where RetailLocationId__c IN :selectedRsgList and ActionPlanTemplateId__c =: apt]){
                                                     a.cascadeToDoor__c = false;
                                                     cascadeToDoorList.add(a);
                                                     
                                                 }
            if(cascadeToDoorList.size()>0){
                update cascadeToDoorList;
            }
            
        }
        d = Label.Days;
        oldDate = system.today().addDays(Integer.valueof(d));
        string aPtApproved ='APT Approved & Locked';
        List<Actionplantemplate__c> aptListToProcess = new List<Actionplantemplate__c>();
        List<Actionplantemplate__c> apt = [SELECT Id,recordtype.name,Status__c,Mass_Cascade_Active_Flag_Date__c,Mass_Cascade_Flag__c,RequestedStartDate__c FROM actionplantemplate__C WHERE (RequestedStartDate__c  =: oldDate OR Mass_Cascade_Flag__c = true) and Status__c =: aPtApproved and In_Store_Locations_Created__c = true and Missions_Created__c != true];
        //Start - For JTP-177
        for(Actionplantemplate__c apt1 : apt)
        {
            if(apt1.Mass_Cascade_Active_Flag_Date__c != null){
            ActiveFlagDate = apt1.Mass_Cascade_Active_Flag_Date__c.addDays(Integer.valueof(daysToProcessAPT));//JTP-177
            System.debug('ActiveFlagDate : '+ActiveFlagDate);
                System.debug('Today : '+System.today());
            }
            if((ActiveFlagDate == System.today() && apt1.Mass_Cascade_Flag__c == true) || apt1.RequestedStartDate__c == oldDate)
            {
            aptListToProcess.add(apt1);
                break;
            }//End - For JTP-177
        }
        System.debug('aptListToProcess : '+aptListToProcess);
        if(aptListToProcess.size()>0)
        {
            Database.executeBatch(new KAMMissionBatch(),2);
        }else{
            List<ActionPlanTemplate__c> ActionPlanTemp = [select id,batch_details__c from ActionPlanTemplate__c where LastModifiedDate = TODAY  and CascadeFlag__c = false and Status__c='Execution' and LastModifiedById =: Label.BatchSchedulerID];
            if(ActionPlanTemp.size()>=0)
            totalAmtOfRecords = ActionPlanTemp.size();
           
            for(ActionPlanTemplate__c apt1 : ActionPlanTemp)
            {
                  system.debug('**********aptList'+1);
                if(j.Status == 'Completed' && j.NumberOfErrors == 0)
                    apt1.Batch_Details__c = 'Mission Batch Completed '+j.CompletedDate;
                
                if(j.NumberOfErrors > 0)
                    apt1.Batch_Details__c = 'Mission Batch Failed '+j.CompletedDate;
                aptList.add(apt1);
            }
            update aptList;
            system.debug('**********aptList'+aptList);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.add(j.CreatedBy.Email);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Mission Batch Status');
            mail.setPlainTextBody
                ('Below is status of Mission batch job:'  + '\n\n' +
                 'Job Status : ' + j.Status + '\n'+
                 'Job Id : ' + j.ID + '\n'+
                 'Total Records Processed Today : ' + totalAmtOfRecords + '\n' +
                 'Success : ' +(totalAmtOfRecords - j.NumberOfErrors)  +'\n' +
                 'Failed : '+ j.NumberOfErrors
                );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            
        }
        
        
    }
}