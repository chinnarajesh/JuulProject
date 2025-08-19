public class OpportunityTriggerHandler {
   public static Id recTypeOpptRACS;
   public static Id recTypeCaseRACS;
   Public static Boolean isFirstTime=false;
   Public static Boolean isBatchFirstTime=false;
    public OpportunityTriggerHandler(){
        // Get Opportunity RecordTypes 
        Map<String,Schema.RecordTypeInfo> rtMapOpportunity = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
        // Get Case RecordTypes 
        Map<String,Schema.RecordTypeInfo> rtMapCase = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        recTypeOpptRACS = rtMapOpportunity.get('RACS Independent Onboarding').getRecordTypeId();
        recTypeCaseRACS = rtMapCase.get('RACS Independent Installation').getRecordTypeId();
    }

    public void validationRACS(List<Opportunity> listOpp, Map<Id,Opportunity> oldTrigger, Boolean isInsert, Boolean isBefore){
     for(Opportunity oppRec : listOpp){
         if(oppRec.RecordTypeId == recTypeOpptRACS){
             //SFDC - 0000000252
             if((oppRec.Post_Implementation_Audit_3_Result__c == 'Fail - AV' || oppRec.Post_Implementation_Audit_3_Result__c == 'Fail - BP') && oppRec.StageName == 'Pending Certification'){
                if(oppRec.Further_Disciplinary_Action_Needed__c == false)
                    oppRec.Further_Disciplinary_Action_Needed__c.addError('Please mark this checked !!');
             }
             // SFDC - 0000000242
             if(oppRec.Additional_Follow_Up_Necessary__c == true && oppRec.StageName == 'Recruit'){
                 if(oppRec.Party_Responsible_for_Follow_Up__c == null)
                    oppRec.Party_Responsible_for_Follow_Up__c.addError(Label.Mandatory_Error_Message);
                 if(oppRec.Additional_RSM_CSM_Follow_Up_Date__c == null)
                    oppRec.Additional_RSM_CSM_Follow_Up_Date__c.addError(Label.Mandatory_Error_Message);
                }
             //SFDC - 0000000244
             if(oppRec.POS_Followup_Needed_to_Confirm_Order__c == true && oppRec.stageName == 'Onboard'){
                 if(oppRec.POS_Follow_Up_Date__c == null)
                    oppRec.POS_Follow_Up_Date__c.addError(Label.Mandatory_Error_Message);
                 if(oppRec.POS_Follow_Up_Notes__c == null)
                    oppRec.POS_Follow_Up_Notes__c.addError(Label.Mandatory_Error_Message);       
                 }
             if(oppRec.Current_POS__c == 'No POS (Register)' && oppRec.stageName == 'Qualify'){
                 if(oppRec.Version_of_POS_In_Use__c != null)
                   oppRec.Version_of_POS_In_Use__c.addError(Label.NOT_Mandatory_Error_Message); 
             } 
             //SFDC - 0000000238   
             if(oppRec.Potential_Concerns__c <> NULL && oppRec.Potential_Concerns__c.Contains('Other')){
                 if(oppRec.Other_Potential_Concerns__c == null)
                    oppRec.Other_Potential_Concerns__c.addError(Label.Mandatory_Error_Message);
                }
             if(oppRec.Current_POS__c == 'Other'){
                 if(oppRec.Other_POS__c == null)
                    oppRec.Other_POS__c.addError(Label.Mandatory_Error_Message);
             }
             if(oppRec.Current__c == 'Other'){
                 if(oppRec.Other_Payment_Processor__c == null)
                    oppRec.Other_Payment_Processor__c.addError(Label.Mandatory_Error_Message);  
             }
             
             //SFDC - 0000000248
             if(oppRec.Installation_Support_Level_Required__c == '3rd Party Installation' && oppRec.StageName == 'Install'){
                 if(oppRec.White_Glove_Schedule_Date__c == null)
                    oppRec.White_Glove_Schedule_Date__c.addError(Label.Mandatory_Error_Message);
             }
             if(oppRec.Installation_Support_Level_Required__c == 'Self-Installation' && oppRec.StageName == 'Install'){
                 if(oppRec.POS_Installation_Date1__c != null)
                    oppRec.POS_Installation_Date1__c.addError(Label.NOT_Mandatory_Error_Message);
                 if(oppRec.POS_Installation_Date2__c != null)
                    oppRec.POS_Installation_Date2__c.addError(Label.NOT_Mandatory_Error_Message);
                 if(oppRec.POS_Installation_Date3__c != null)
                    oppRec.POS_Installation_Date3__c.addError(Label.NOT_Mandatory_Error_Message);
                 if(oppRec.POS_Installation_Date4__c != null)
                    oppRec.POS_Installation_Date4__c.addError(Label.NOT_Mandatory_Error_Message);
                 if(oppRec.POS_Installation_Notes__c != null)
                    oppRec.POS_Installation_Notes__c.addError(Label.NOT_Mandatory_Error_Message);
                 if(oppRec.White_Glove_Schedule_Date__c != null)
                    oppRec.White_Glove_Schedule_Date__c.addError(Label.NOT_Mandatory_Error_Message);
                 if(oppRec.White_Glove_Installation_Notes__c != null)
                    oppRec.White_Glove_Installation_Notes__c.addError(Label.NOT_Mandatory_Error_Message);
                 }
             //SFDC - 0000000250    
             if(oppRec.Additional_Post_Install_Support_Required__c == 'SKU Migration' && oppRec.StageName == 'Install'){
                 if(oppRec.SKU_Migration_Support_Date__c == null)
                    oppRec.SKU_Migration_Support_Date__c.addError(Label.Mandatory_Error_Message);
                 }
             if(oppRec.Second_RSS_Post_Install_Followup_Needed__c == true && oppRec.StageName == 'Install'){
                 if(oppRec.Second_Post_Install_RSS_Followup_Date__c == null)
                    oppRec.Second_Post_Install_RSS_Followup_Date__c.addError(Label.Mandatory_Error_Message);
                 }
             if(oppRec.Additional_Post_Install_Support_Required__c == 'Additional RSM follow-up visit' && oppRec.StageName == 'Install'){
                 if(oppRec.RSM_Post_Install_Followup_Visit_Date__c == null)
                    oppRec.RSM_Post_Install_Followup_Visit_Date__c.addError(Label.Mandatory_Error_Message);
             } 
             //SFDC - 0000000241 && SFDC - 0000000243
             if(oppRec.RACS_Ops_Prioritization_Result__c == 'Pitch RACS' && oppRec.StageName == 'Qualify'){
              //   if(oppRec.RACS_Offer_Applied_to_Retailer__c == null)
              //      oppRec.RACS_Offer_Applied_to_Retailer__c.addError(Label.Mandatory_Error_Message);
                 
                 if(oppRec.Party_Assigned_to_Pitch__c == null)
                    oppRec.Party_Assigned_to_Pitch__c.addError(Label.Mandatory_Error_Message);
                 }
             if((oppRec.RACS_Ops_Prioritization_Result__c == 'Nurture' && oppRec.StageName == 'Qualify') || (oppRec.Chosen_Path_Forward__c == 'Nurture'
                 && (oppRec.StageName == 'Recruit' || oppRec.StageName == 'Onboard' || oppRec.StageName == 'Install' || oppRec.StageName == 'Pending Certification'))){
                 if(oppRec.Nurture_Date__c == null)
                    oppRec.Nurture_Date__c.addError(Label.Mandatory_Error_Message);
                 if(oppRec.RACS_Phase_Transitioned_to_Nurture__c == null)
                    oppRec.RACS_Phase_Transitioned_to_Nurture__c.addError(Label.Mandatory_Error_Message);
                 if(oppRec.Nurture_Reason__c == null)
                    oppRec.Nurture_Reason__c.addError(Label.Mandatory_Error_Message);
                 if(oppRec.Other_Nurture_Reason__c == null)
                    oppRec.Other_Nurture_Reason__c.addError(Label.Mandatory_Error_Message);
                 } 
             if(oppRec.Chosen_Path_Forward__c <> NULL && (oppRec.Chosen_Path_Forward__c == 'New POS System' || oppRec.Chosen_Path_Forward__c == 'Upgrade Current POS')
                && (oppRec.StageName == 'Recruit' || oppRec.StageName == 'Onboard' || oppRec.StageName == 'Install' || oppRec.StageName == 'Pending Certification')){
                 if(oppRec.POS_Provider_for_RACS_Compliance__c == null)
                    oppRec.POS_Provider_for_RACS_Compliance__c.addError(Label.Mandatory_Error_Message);
                 }           
             }
         }
     }
     /***
      Added By: Anil Male <Anil.Male@juul.com>
      Reference: https://juullabs.lightning.force.com/lightning/r/ticket__c/aAN1O000000PH76WAG/view
      Description: This method will create the RACS Installation Case when we change the POS Order Date from blank to populated.
     ***/
     public void createRACSInstallationCase(List<Opportunity> listOpp, Map<Id,Opportunity> oldTrigger, Boolean isUpdate, Boolean isAfter){
        Set<Id> OpportunityIds = new Set<Id>();
        List<Case> listCaseToInsert = new List<Case>();
        for(Opportunity oppRec : listOpp){
            if(oldTrigger <> NULL && oppRec.POS_Order_Date__c <> NULL && oppRec.POS_Order_Date__c != oldTrigger.get(oppRec.id).POS_Order_Date__c &&  
               oldTrigger.get(oppRec.id).POS_Order_Date__c == null){
                OpportunityIds.add(oppRec.id);
            }
        } 
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([Select Id,Account.Name,(SELECT Id, ContactId,OpportunityId from OpportunityContactRoles LIMIT 1),
                                                                                (SELECT Id,RACS_Opportunity__c from Cases__r Where RecordTypeId =: recTypeCaseRACS LIMIT 1) 
                                                                                from Opportunity Where Id IN : OpportunityIds]);
        Group RACSQueue = [SELECT Id,Name FROM Group WHERE DeveloperName = 'RACS_Install_Team' AND Type = 'Queue' LIMIT 1];                  
        for(Opportunity oppRec : listOpp){
            if(mapOpportunity != null && mapOpportunity.containsKey(oppRec.id) && mapOpportunity.get(oppRec.id).Cases__r.size() == 0){
                Case caRec = new Case();
                  caRec.AccountId = oppRec.AccountId;
                  caRec.Origin = 'RACS';
                  caRec.OwnerId = RACSQueue.id;
                  caRec.Subject  = 'Install Setup - '+mapOpportunity.get(oppRec.Id).Account.Name;
                  caRec.RACS_Opportunity__c = oppRec.id;
                  caRec.ContactId =mapOpportunity.get(oppRec.id).OpportunityContactRoles.size()>0 &&  mapOpportunity.get(oppRec.id).OpportunityContactRoles <> NULL ? mapOpportunity.get(oppRec.id).OpportunityContactRoles[0].contactId : null;
                  caRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RACS Independent Installation').getRecordTypeId();
                listCaseToInsert.add(caRec);  
            }    
        }
        if(listCaseToInsert != null && listCaseToInsert.size()>0){
           List<Database.SaveResult> insertCaseResults = Database.Insert(listCaseToInsert, false);
             List<Database.Error> listError = new List<Database.Error>();
             for(Integer index = 0, size = insertCaseResults.size(); index < size; index++) {
               if(!insertCaseResults[index].isSuccess()){
                 listError.addAll(insertCaseResults[index].getErrors());
               }
           }
         LogEventTriggerHandler.insertBatchLog(listError, 'OpportunityTriggerHandler', 'createRACSInstallationCase', 'Case', 'Database.Insert_Failed');  
         }
     }  
    
    // This method used to post Chatter Notification on Account Detail Page When RACS Opportunity StageName is changed.
    public void SendChatterNotificationToAccount(List<Opportunity> oppList, Map<Id,Opportunity> oldmap, Boolean isUpdate) {
        List<FeedItem> customNotificationList = new List<FeedItem>();
        Map<String,Schema.RecordTypeInfo> rtMapOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        for(Opportunity opp: oppList) {
            if(opp.StageName != null && opp.RecordTypeId == rtMapOpp.get('RACS_Independent_Onboarding').getRecordTypeId()) {
                if((oldmap != null && oldMap.get(opp.Id).StageName != opp.StageName) || isUpdate == false) {
                    FeedItem post = new FeedItem();
                    post.ParentId = opp.AccountId;
                    post.Body = '\''+opp.Name+'\' RACS Opportunity stage changed to \''+opp.StageName+'\'. Reach out to the RACS team if you have any questions.';
                    customNotificationList.add(post); 
                }            
            }
        }
        if (customNotificationList != null && customNotificationList.size() > 0) {
            List<Database.SaveResult> insertNotificationResults = Database.Insert(customNotificationList, false);
            system.debug('insertNotificationResults=='+insertNotificationResults);
            List<Database.Error> listError = new List<Database.Error> ();
            for (Integer index = 0, size = insertNotificationResults.size(); index < size; index++) {
                if (!insertNotificationResults[index].isSuccess()) {
                    listError.addAll(insertNotificationResults[index].getErrors());
                }
            }
            if (listError.size() > 0) {
                system.debug('listError-- '+ listError);
                LogEventTriggerHandler.insertBatchLog(listError, 'OpportunityTriggerHandler', 'SendChatterNotificationToAccount', 'Feed Item', 'Database.Insert_Failed');
            }
        }                    
    }
    
    
    //This method is used to update all account records referenced in the path opportunity>EAC RSG>RSG>Store Location
        public void UpdateRSGsAccount(List<Opportunity> oppnew,  Map<Id, Opportunity> oldMap) {
        set<Id> oppID = new set<Id>();
        Map<Id,Opportunity> RSGMap = new Map<Id,Opportunity>();
        List<string> oppStage = new List<string> {'Not contacted','Not committed','Committed','Piloting','Ready','Closed/Won','Closed Lost','Closed Won'};
            
            for(Opportunity opp: oppnew) {
                if(oppStage.contains(opp.StageName)) {
                    oppID.add(opp.id);                  
                }
            }
        if(oppID!=null){   
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select id,AccountId,StageName,Current_POS__c,Manager_Override__c,Comitted_Date__c,Date_Certified__c,Ready_Start_date__c,EST_Implementation_Date__c from Opportunity where ID IN:oppID]);
            for(EAC_RSG__c eacrsg : [Select Retail_Store_Group__c, Opportunity__c from EAC_RSG__c where Opportunity__c IN : oppID]) {
                RSGMap.put(eacrsg.Retail_Store_Group__c, oppMap.get(eacrsg.Opportunity__c));
            }
           
            if(!RSGMap.isEmpty() && RSGMap.size()>0){
                for(ID RSGID : RSGMap.keyset()){
                EACOpportunityBatch e = new EACOpportunityBatch(RSGID,RSGMap.get(RSGID));
                Database.executeBatch(e,1);
                }
            }
        }
        }
    
    // This method used to update the account referenced by opportunity.account
    public void UpdateOppAccount(List<Opportunity> oppnew,  Map<Id, Opportunity> oldMap) {
        List<Account> accList = new List<Account>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<String> AcctCurrentPOSProviderPickList = new List<String>();  
        Schema.SObjectType s = Schema.getGlobalDescribe().get('Account') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('CurrentPOSProvider__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            AcctCurrentPOSProviderPickList.add(pickListVal.getValue());
        }  
        List<string> oppStage = new List<string> {'Not contacted','Not committed','Committed','Piloting','Ready','Closed/Won','Closed Lost','Closed Won'};
            for(Opportunity opp: oppnew) {
                if(oppStage.contains(opp.StageName)) {
                    oppMap.put(opp.AccountId,opp);
                }
            }       
        List<Account> accRecs = [select RACS_Status__c,CurrentPOSProvider__c,Manager_Override__c,Date_RACS_Committed__c,Racs_Certified_Date__c,X2D_Bar_Scanner__c,AV_Capable__c, QPL_Capable__c from Account where ID IN:OppMap.keyset()];
        for(Account a:accRecs) {
            if(OppMap.containskey(a.Id)) { 
                if((oppMap.get(a.Id).StageName != 'Closed/Won' ||oppMap.get(a.Id).StageName != 'Closed Won' ||oppMap.get(a.Id).StageName != 'Closed Lost')) {     
                        a.Ready_Date_Confirmed__c =OppMap.get(a.Id).Ready_Start_date__c; 
                        a.Ready_Date_Estimated__c = OppMap.get(a.Id).EST_Implementation_Date__c;                   
                    }
                if(OppMap.get(a.Id).StageName != 'Closed/Won') {     
                    a.RACS_Status__c = OppMap.get(a.Id).StageName;                    
                }
                if(OppMap.get(a.Id).StageName == 'Committed') {    
                    if(AcctCurrentPOSProviderPickList.contains(OppMap.get(a.Id).Current_POS__c))
                    a.CurrentPOSProvider__c = OppMap.get(a.Id).Current_POS__c;
                    a.Manager_Override__c = OppMap.get(a.Id).Manager_Override__c;
                    a.Date_RACS_Committed__c = OppMap.get(a.Id).Comitted_Date__c;
                }
                if(OppMap.get(a.Id).StageName == 'Ready') {     
                    a.QPL_Capable__c = true;
                    a.AV_Capable__c = true;
                    a.X2D_Bar_Scanner__c = true;
                }
                if(oppMap.get(a.Id).StageName == 'Closed/Won') {
                     a.Racs_Certified_Date__c = system.today();
                    //a.Racs_Certified_Date__c = oppMap.get(a.Id).Date_Certified__c;
                    a.RACS_Status__c = 'Certified';                        
                }
                accList.add(a);                 
            }
        }
        
        if (accList != null && accList.size() > 0) {
            List<Database.SaveResult> insertNotificationResults =  Database.Update(accList, false);
            system.debug('insertNotificationResults=='+insertNotificationResults);
            List<Database.Error> listError = new List<Database.Error> ();
            for (Integer index = 0, size = insertNotificationResults.size(); index < size; index++) {
                if (!insertNotificationResults[index].isSuccess()) {
                    listError.addAll(insertNotificationResults[index].getErrors());
                }
            }
            if (listError.size() > 0) {
                system.debug('listError-- '+ listError);
                LogEventTriggerHandler.insertBatchLog(listError, 'OpportunityTriggerHandler', 'UpdateOppAccount', 'Opportunity', 'Database.Insert_Failed');
            }
        }  
    }
    
     /***
      Added By: Shreya Raut
      Reference: https://juullabs.lightning.force.com/lightning/r/ticket__c/aAN4T000000CduVWAS/view
      Description: Validation that does not allow more than one active RACS Opportunity
     ***/
    
    public static void validateRACOpp (List<Opportunity> oppList){
        
        Set<ID> accountIDs = new Set<ID>();
        Id OppRACRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
       for(Opportunity opp: oppList) 
        {
            accountIDs.add(opp.AccountId);
        }
       Map<Id,Opportunity> OppMap = new Map<ID,Opportunity>();
        if(accountIDs.size()>0){
            for(Opportunity oppty : [Select id,AccountId,Active_RACS_Opportunity__c,RecordType.Name,Account.name from Opportunity WHERE AccountId IN : accountIDs and RecordType.Name IN ('RACS Independent Onboarding') and Active_RACS_Opportunity__c = true])
            {
                OppMap.put(oppty.AccountId,oppty);
            }
        } 
        System.debug('OppMap'+OppMap);
        for(Opportunity oprty: oppList)
        {
            if(OppMap.size()>0 || !OppMap.isEmpty())
            if((OppMap.containsKey(oprty.accountID))&& oprty.recordtypeId ==OppRACRecordTypeId && oprty.Active_RACS_Opportunity__c == True ){
                oprty.addError('Account is already linked with Active RACS Opportunity');
            }
        }
    }
    
     
}