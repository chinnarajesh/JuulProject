global class APTsMissionsBatchClass  implements Database.Batchable<sobject>,Database.Stateful{
    public Set<Actionplantemplate__c> aptsInfo; 
    public Integer totalAmtOfRecords = 0;
    public String class_Name = 'APTsMissionsBatchClass';
    public Date oldDate;
    public String numberOfDays;
    public String daysToProcessAPT;
    public Date activeFlagDate;

    Id accountAPRecordType;
    Id promoAPRecordType;
    Id resetAPRecordType;
    Id accountmissionRecordType;
    Id promomissionRecordType;
    Id resetmissionRecordType;

    String method_Name = 'Execute';
    String operationType = 'Database.Insert_Failed';
    String sourceAPTObjectFields = '';
    String aPtApproved ='APT Approved & Locked';

    List<Data_Mapping__mdt> aptMissionMapping = new List<Data_Mapping__mdt>();
    List<string> succussORfailledApts;

    Map<String,String> aptMissionFieldsMap = new Map<String,String>();
    Map<Id,ActionPlanTemplate__c> selectedAPTsInfo;
    Map<string,Id> missionRT = new Map<String,Id>();
    Map<string,Id> actionPlanRT = new Map<String,Id>();


    public APTsMissionsBatchClass(){ 
        aptsInfo = new Set<Actionplantemplate__c>();

        numberOfDays = Label.Days;
        Date oldDate = system.today().addDays(Integer.valueof(numberOfDays));
        daysToProcessAPT = Label.APT_Mass_Cascade;
        System.debug('OldaptsInfo : '+aptsInfo);
        
        for(Actionplantemplate__c aptRecord :[SELECT Id,recordtype.name,Status__c,Mass_Cascade_Active_Flag_Date__c,RequestedStartDate__c,Mass_Cascade_Flag__c FROM ActionPlanTemplate__c WHERE ((RequestedStartDate__c  <=: oldDate and RequestedStartDate__c >: system.today()) OR Mass_Cascade_Flag__c = true) and Status__c =: aPtApproved and In_Store_Locations_Created__c = true and Missions_Created__c != true and In_Store_Locations_Refreshed__c = true]){
            system.debug('Check loop');
            System.debug('aptRecord.id '+aptRecord.id);
           if(aptRecord.Mass_Cascade_Active_Flag_Date__c != null){
                activeFlagDate = aptRecord.Mass_Cascade_Active_Flag_Date__c.addDays(Integer.valueof(daysToProcessAPT));
            }
            if((activeFlagDate == System.today() && aptRecord.Mass_Cascade_Flag__c == true) || (aptRecord.RequestedStartDate__c <= oldDate && aptRecord.RequestedStartDate__c > system.today())){
                aptsInfo.add(aptRecord);
                //break;
            }
        }
        System.debug('aptsInfo : '+aptsInfo);
        System.debug('aptsInfo : '+aptsInfo.size());
        //Map to store similar fields between APT and (mission and action plan)  
        aptMissionMapping=[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt
                           where Source_Object__c='ActionPlanTemplate__c' AND Target_Object__c ='Mission__c'];
        for(Data_Mapping__mdt data: aptMissionMapping){
            aptMissionFieldsMap.put(data.Source_Field__c,data.Target_Field__c);  
            sourceAPTObjectFields += data.Source_Field__c+',';
        }
        if(sourceAPTObjectFields.endsWith(',')){
            sourceAPTObjectFields = sourceAPTObjectFields.substring(0, sourceAPTObjectFields.length() - 1);
        }

        selectedAPTsInfo = new Map<Id, ActionPlanTemplate__c>((List<ActionPlanTemplate__c>)Database.query('Select Id,Batch_Details__c,RecordType.DeveloperName, Status__c,CommercialActivityId__c,Cascade_Changes__c,Missions_Created__c,' 
        +sourceAPTObjectFields+' From ActionPlanTemplate__c Where id IN:aptsInfo'));
        System.debug(selectedAPTsInfo);
        
        accountAPRecordType = Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get('AccountPlan').getRecordTypeId();
        promoAPRecordType = Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get('PromotionalActivityProcess').getRecordTypeId();
        resetAPRecordType = Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        
        accountmissionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get('AccountPlan').getRecordTypeId();
        promomissionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get('PromotionalActivityProcess').getRecordTypeId();
        resetmissionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get('ResetActivityProcess').getRecordTypeId();
        
        
        missionRT.put('AccountPlan',accountmissionRecordType);
        missionRT.put('PromotionalActivityProcess',promomissionRecordType);
        missionRT.put('ResetActivityProcess',resetmissionRecordType);
        
        actionPlanRT.put('AccountPlan',accountAPRecordType);
        actionPlanRT.put('PromotionalActivityProcess',promoAPRecordType);
        actionPlanRT.put('ResetActivityProcess',resetAPRecordType);
    }
    public Database.QueryLocator Start(Database.BatchableContext BC){
        String accountType ='HQ';
        return Database.getQueryLocator('select id,RetailStoreGroupActionPlanTemplate__c,RetailLocationId__r.Name ,RetailLocationId__c,RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.recordtype.DeveloperName,RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c IN: aptsInfo and RetailLocationId__r.Type !=  \'' + accountType + '\'');
    }
    public void execute(Database.BatchableContext BC,List<InStoreLocation__c> ISLList){
        System.debug('Inside Execute ISLList count'+ISLList.size());
        Map<Id,InStoreLocation__c> islIdISLRecordMap = new Map<Id,InStoreLocation__c>();
        Set<Id> ISLidSet = new Set<Id>();
        for(InStoreLocation__c isl : ISLList){
            ISLidSet.add(isl.id);
            islIdISLRecordMap.put(isl.id,isl);
        }
        System.debug('islIdISLRecordMap : '+islIdISLRecordMap);
        Map<Id, Mission__c > existingISLMissionsMap = new Map<Id, Mission__c >();
        List<Mission__c> missionList =[select Id,InStoreLocationId__c from Mission__c where InStoreLocationId__c IN :ISLidSet];
        for(Mission__c ms : missionList){
            existingISLMissionsMap.put(ms.InStoreLocationId__c,ms);
        }
        System.debug('existingISLMissionsMap : '+existingISLMissionsMap);
        List<Mission__c> newMissionsList = new List<Mission__c>();
        Map<Id,Id> rsgPlanogramsToUpdate = new Map<Id,Id>();
        System.debug('selectedAPTsInfo : '+selectedAPTsInfo);
        //Creating Missions here based on ISL
        for(InStoreLocation__c islRec: ISLList){ 
            if(selectedAPTsInfo.containsKey(islRec.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c)){ 
                System.debug('mapKey : '+islRec.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c);
                if(!existingISLMissionsMap.containsKey(islRec.id)){
                    
                    Mission__c newMissionRec = new Mission__c();
                    newMissionRec.AccountId__c = islRec.RetailLocationId__c;
                    string RecordTypeName = islRec.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.recordtype.DeveloperName;
                    if(missionRT != null && !missionRT.isEmpty() &&  missionRT.get(RecordTypeName)!=null)
                        newMissionRec.RecordTypeId = missionRT.get(RecordTypeName);
                    newMissionRec.RetailStoreGroupActionPlanTemplate__c = islRec.RetailStoreGroupActionPlanTemplate__c;
                    newMissionRec.InStoreLocationId__c= islRec.id;
                    for(string field: aptMissionFieldsMap.keyset()){
                        //newMissionRec.put(aptMissionFieldsMap.get(field),aptRec.get(field));
                        newMissionRec.put(aptMissionFieldsMap.get(field),selectedAPTsInfo.get(islRec.RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c).get(field));
                    }
                    newMissionsList.add(newMissionRec);
                }
            }
        }
        System.debug('newMissionsList : '+newMissionsList);
        List<Id> successRecords = new List<Id>();
        // Insert Missions here
        if(newMissionsList.size()>0){
            totalAmtOfRecords = totalAmtOfRecords + newMissionsList.size();
            List<Database.SaveResult> missionToInsertResults = Database.Insert(newMissionsList, true);
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
            Map<Id,ActionPlan__c> newActionPlansList = new Map<Id,ActionPlan__c>();
            //Preparing Action Plans here based on Mission
            for(Mission__c missionRec: newMissionsList){
                if(islIdISLRecordMap.containsKey(missionRec.InStoreLocationId__c)){
                    ActionPlan__c newActionPlanRec = new ActionPlan__c();
                    string RecordTypeName = islIdISLRecordMap.get(missionRec.InStoreLocationId__c).RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.recordtype.DeveloperName;
                    if(actionPlanRT != null && !actionPlanRT.isEmpty() && actionPlanRT.get(RecordTypeName)!=null)
                        newActionPlanRec.RecordTypeId = actionPlanRT.get(RecordTypeName);
                    newActionPlanRec.isProcessed__c = true;
                    newActionPlanRec.ActionPlanTemplateId__c = islIdISLRecordMap.get(missionRec.InStoreLocationId__c).RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c;
                    newActionPlanRec.Mission__c = missionRec.Id;
                    newActionPlansList.put(missionRec.Id,newActionPlanRec); 
                }

            }

            System.debug('newActionPlansList : '+newActionPlansList);
            // Insert Action Plans here
            If(newActionPlansList != null && newActionPlansList.size()>0){
                List<Database.SaveResult> actionPlansToInsertResults = Database.Insert(newActionPlansList.values(), true);
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
        }
                
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Inside Finish');
        List<ActionPlanTemplate__c> aptList = new list<ActionPlanTemplate__c>();
        AsyncApexJob batchJobInfo = [Select Id, CompletedDate,Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        System.debug('batchJobInfo : '+batchJobInfo);
        List<String> toAddresses = new List<String>();
        toAddresses.addAll((Label.BatchUserIDs).split(','));

        succussORfailledApts = new List<string>();
        succussORfailledApts.add('=== succuss apts ===');

        List<Id> unprocessedAPTs = new List<Id>();
        List<Actionplantemplate__c> checkProcessedAPTs = [SELECT Id,Total_Instorelocations__c,Total_Mission__c FROM ActionPlanTemplate__c Where id IN:aptsInfo];
        for(Actionplantemplate__c checkProcessedAPT : checkProcessedAPTs){
            if(checkProcessedAPT.Total_Instorelocations__c != checkProcessedAPT.Total_Mission__c){
                unprocessedAPTs.add(checkProcessedAPT.Id);
            }else{
                succussORfailledApts.add(checkProcessedAPT.Id);
            }
        }
        succussORfailledApts.add('=== failled apts ===');
        if(unprocessedAPTs.size() > 0){
            for(Id unprocessedAPT : unprocessedAPTs){
                succussORfailledApts.add(unprocessedAPT);
            }
        }

        List<ActionPlanTemplate__c> aptsList = new List<ActionPlanTemplate__c>();
        if(batchJobInfo.Status == 'Completed' && batchJobInfo.NumberOfErrors == 0) {
            for(ActionPlanTemplate__c aptRec :selectedAPTsInfo.values()){
                if(!unprocessedAPTs.contains(aptRec.Id)){
                    System.debug('Condition Chekck 1');
                    aptRec.Status__c = 'Execution'; 
                    System.debug('aptRec.Status__c '+aptRec.Status__c);
                    aptRec.Missions_Created__c=true;
                    if(aptRec.RecordType.DeveloperName == 'ResetActivityProcess')
                        aptRec.Status__c = 'Vendor Execution';
                    
                    aptRec.Batch_Details__c = 'Mission Batch Completed '+batchJobInfo.CompletedDate;
                    aptsList.add(aptRec);
                }else{
                    aptRec.Batch_Details__c = 'Mission Batch Failed '+batchJobInfo.CompletedDate;
                    aptsList.add(aptRec);
                }
            }
            update aptsList;
            System.debug('aptsList '+aptsList);
        }else{
            for(ActionPlanTemplate__c aptRec :selectedAPTsInfo.values()){
                if(!unprocessedAPTs.contains(aptRec.Id)){
                    System.debug('Condition Chekck 2');
                    aptRec.Status__c = 'Execution'; 
                    System.debug('aptRec.Status__c '+aptRec.Status__c);
                    aptRec.Missions_Created__c=true;
                    if(aptRec.RecordType.DeveloperName == 'ResetActivityProcess')
                        aptRec.Status__c = 'Vendor Execution';
                    
                    aptRec.Batch_Details__c = 'Mission Batch Completed '+batchJobInfo.CompletedDate;
                    aptsList.add(aptRec);
                }else{
                    aptRec.Batch_Details__c = 'Mission Batch Failed '+batchJobInfo.CompletedDate;
                    aptsList.add(aptRec);
                }
            }
            update aptsList;
            System.debug('aptsList '+aptsList);
            //Need to check it is needed
            List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
            for(AccountActionPlanTemplate__c aaptsList :[select id,cascadeToDoor__c,ActionPlanTemplateId__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c =: aptsInfo]){ 
                if(unprocessedAPTs.size() > 0){
                    if(unprocessedAPTs.contains(aaptsList.ActionPlanTemplateId__c)){
                        aaptsList.cascadeToDoor__c = false;
                        cascadeToDoorList.add(aaptsList);   
                    }   
                }                                               
            }
            if(cascadeToDoorList.size()>0){
                update cascadeToDoorList;
            }
        }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.add(batchJobInfo.CreatedBy.Email);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Mission Batch Status');
            mail.setPlainTextBody
                ('Below is status of Mission batch job:'  + '\n\n' +
                 'Job Status : ' + batchJobInfo.Status + '\n'+
                 'Job Id : ' + batchJobInfo.Id + '\n'+
                 '' +(String.join(succussORfailledApts, '\n'))  +'\n' +
                 'Total Records Processed Today : ' + totalAmtOfRecords + '\n' +
                 'Total Success Records: ' +(totalAmtOfRecords - batchJobInfo.NumberOfErrors)  +'\n' +
                 'Total Failed Records: '+ batchJobInfo.NumberOfErrors
                );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}