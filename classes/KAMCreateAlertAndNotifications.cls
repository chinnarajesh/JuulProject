/********************************************************************************************************************/
/* VERSION     AUTHOR                  DATE                                                                         */
/*  1.0      Pushkar Gangwar         06-25-2020                                                                     */
/* Class Name: KAMCreateAlertAndNotifications                                                                       */
/* Description: Helper class of Action plan template trigger to create alert, group alert and custom notifications  */
/********************************************************************************************************************/
public class KAMCreateAlertAndNotifications {
    Public static String basURL = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    //Method to check criteria to create alert, group alerts and custom notifications
    public static void checkConditionsToCreateAlert(Map<Id,ActionPlanTemplate__c> newMapATM, Map<Id, ActionPlanTemplate__c> oldMapATM){ 
        //Getting instance of Stage 2 custom settings
        ActionPlanTemplate0StageValues__c stage2Settings =  ActionPlanTemplate0StageValues__c.getInstance(); 
        List<ActionPlanTemplate__c> createRecordList = new List<ActionPlanTemplate__c> ();
        String AccountPlanRTId = ''; 
        String ResetRTId = '';
        String PromotionRTId = '';
        List<RecordType> recordTypeList = [SELECT Id, DeveloperName FROM RecordType 
                                           WHERE sObjectType = 'ActionPlanTemplate__c' AND (DeveloperName  = 'AccountPlan' OR DeveloperName  = 'ResetActivityProcess' 
                                                                                           OR DeveloperName  = 'PromotionalActivityProcess')];
        for(RecordType rt : recordTypeList){
            if(rt.DeveloperName == 'AccountPlan'){
                AccountPlanRTId = rt.Id;
            }else if(rt.DeveloperName == 'ResetActivityProcess'){
                ResetRTId = rt.Id;
            }else if(rt.DeveloperName == 'PromotionalActivityProcess'){
                PromotionRTId = rt.Id;
            }
        }
        for(ActionPlanTemplate__c apt : newMapATM.values()){
            String newStage = (String)newMapATM.get(apt.ID).get('Status__c');
            if(oldMapATM != null && (String)oldMapATM.get(apt.ID).get('Status__c') !=(String)newMapATM.get(apt.ID).get('Status__c') ){
                if((apt.RecordTypeId == AccountPlanRTId && newStage == stage2Settings.ActionPlanStage2__c)
                  || (apt.RecordTypeId == ResetRTId && newStage == stage2Settings.ResetActivityProcessStage2__c) 
                  || (apt.RecordTypeId == PromotionRTId && newStage == stage2Settings.PromotionalActivityProcessStage2__c)){
                    //KAMCreateAlertAndNotifications.createAlertandGroupAlert(apt);
                    createRecordList.add(apt);
                }
            }else{
                 if((apt.RecordTypeId == AccountPlanRTId && newStage == stage2Settings.ActionPlanStage2__c)
                  || (apt.RecordTypeId == ResetRTId && newStage == stage2Settings.ResetActivityProcessStage2__c) 
                  || (apt.RecordTypeId == PromotionRTId && newStage == stage2Settings.PromotionalActivityProcessStage2__c)){
                    //KAMCreateAlertAndNotifications.createAlertandGroupAlert(apt);
                     createRecordList.add(apt);
                }
            }
        }
        //Calling method to create alert and group alerts for filtered action plan template
        if(createRecordList.size() > 0){
            KAMCreateAlertAndNotifications.createAlertandGroupAlert(createRecordList);
        }
    }
    
    //Method to create Alert and Group Alerts
    public static void createAlertandGroupAlert(List<ActionPlanTemplate__c> actionPlanTemplate){
        //fetching all related reports
        List<Report> AllManagerReport = new List<Report>();
        String RevenueManagerReportId = '';
        String VendorManagerReportId = '';
        String DistributionManagerReportId = '';
        AllManagerReport = [SELECT Id,DeveloperName, Name FROM Report where 
                   DeveloperName = 'Promo_Participating_Door_Revenue_evn' OR DeveloperName = 'Promo_Participating_Door_Vendor_CQe' OR DeveloperName = 'Promo_Participating_Door_Distribution_bVs'];
        if(AllManagerReport.size() > 0){
            for(Report reportItem : AllManagerReport){
                if(reportItem.DeveloperName == 'Promo_Participating_Door_Revenue_evn'){
                    RevenueManagerReportId = reportItem.Id;
                }else if(reportItem.DeveloperName == 'Promo_Participating_Door_Vendor_CQe'){
                    VendorManagerReportId = reportItem.Id;
                }else if(reportItem.DeveloperName == 'Promo_Participating_Door_Distribution_bVs'){
                    DistributionManagerReportId = reportItem.Id;
                }
            }
        }
        
        List<AccountOrGroupAlert__c> groupAlertList = new  List<AccountOrGroupAlert__c>();
        Map<AccountOrGroupAlert__c, Alert__c> groupAlertandAlertMap = new Map<AccountOrGroupAlert__c, Alert__c>();
        //Creating Alert and group alert for all Action plan template
        for(ActionPlanTemplate__c actionPlanTemp : actionPlanTemplate ){
            //Creating alert
            Alert__c alert = new Alert__c();
            alert.subject__c = 'Commercial Activity Process has reached Stage 2.';
            alert.AlertType__c = 'Action Plan Template moved to Stage2';
            //String body = 'Account: '+ actionPlanTemp.AccountId__r.Name  +'\n';
            String body = 'Account: '+  basURL +'/'+ actionPlanTemp.AccountId__c +'\n';
            body += 'Action Plan Template: '+  basURL +'/'+ actionPlanTemp.Id +'\n';
            body += 'Number of Doors: ' + actionPlanTemp.NumberOfParticipatingDoors__c  +'\n' +'\n';
            body += 'Link to Revenue Manager Report: ' +   basURL +'/' + RevenueManagerReportId +'\n';
            body += 'Link to Vendor Manager Report: '  +  basURL +'/' +  VendorManagerReportId +'\n';
            body += 'Link to Distribution Manager Report: '  + basURL +'/' +  DistributionManagerReportId;
            alert.Body__c = body;
            
            //Creating Account or group alert
            AccountOrGroupAlert__c groupAlert = new AccountOrGroupAlert__c();
            groupAlert.AccountId__c = actionPlanTemp.AccountId__c;
            //adding to the map to map and insert the values
            groupAlertandAlertMap.put(groupAlert, alert);
        }
        
        //insert groupAlertandAlertMap.values();
        if (groupAlertandAlertMap.values() != null && groupAlertandAlertMap.values().size() > 0) {
            List < Database.SaveResult > insertAlertResults = Database.Insert(groupAlertandAlertMap.values(), false);
            List < Database.Error > listError = new List <Database.Error> ();
            for (Integer index = 0, size = insertAlertResults.size(); index < size; index++) {
                if (!insertAlertResults[index].isSuccess()) {
                    listError.addAll(insertAlertResults[index].getErrors());
                }
            } 
            if (listError.size() > 0) {
                system.debug('listError-- '+ listError);
                LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateAlertAndNotifications', 'createAlertandGroupAlert', 'Alert', 'Database.Insert_Failed');
            }
        }
        
        //Adding new Alert Ids into group alert record 
        for(AccountOrGroupAlert__c groupAlert : groupAlertandAlertMap.keySet()){
            groupAlert.AlertId__c = groupAlertandAlertMap.get(groupAlert).ID;
            groupAlertList.add(groupAlert);
        }
        //insert groupAlertList;
        if (groupAlertList != null && groupAlertList.size() > 0) {
            List < Database.SaveResult > insertGroupAlertResults = Database.Insert(groupAlertList, false);
            List < Database.Error > listError = new List <Database.Error> ();
            for (Integer index = 0, size = insertGroupAlertResults.size(); index < size; index++) {
                if (!insertGroupAlertResults[index].isSuccess()) {
                    listError.addAll(insertGroupAlertResults[index].getErrors());
                }
            }
            if (listError.size() > 0) {
                system.debug('listError-- '+ listError);
                LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateAlertAndNotifications', 'createAlertandGroupAlert', 'Group Alert', 'Database.Insert_Failed');
            }
        }
       system.debug('----- groupAlertandAlertMap.KeySet '+ groupAlertandAlertMap.KeySet());
        //Calling method to create custom notification
        KAMCreateAlertAndNotifications.createCustomNotifications(groupAlertandAlertMap.KeySet());
    }
    
    //Method to create custom notification for related account team member
    public static void createCustomNotifications(Set<AccountOrGroupAlert__c> GroupAlertList){
        
        Apex_Code_Controller__c KAMAlertControl = Apex_Code_Controller__c.getInstance('KAMCreateAlertAndNotifications'); //Get Apex Controller Setting
        System.debug('---Creating feed items');
        List<FeedItem> customNotificationList = new List<FeedItem>();
        List<Id> accountIds =  new List<Id>();
        for(AccountOrGroupAlert__c groupAlertItem : GroupAlertList){
            accountIds.add(groupAlertItem.AccountId__c);
        }
        
        if(accountIds.size() > 0){
            //Map<ID, Account> accountIdAccountMap = new Map<ID, Account>([SELECT Id, Name, OwnerId FROM Account WHERE ID=:accountIds]);
            //Fetching all related team memebers
            List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
            teamMemberList = [SELECT ID, AccountID, UserId, TeamMemberRole FROM AccountTeamMember
                              WHERE (TeamMemberRole='Vendor Manager' OR  TeamMemberRole='Revenue Finance Manager'OR  TeamMemberRole='Distribution Manager') AND AccountID=:accountIds ];
            system.debug('teamMemberList--'+ teamMemberList);
            //mapping team member with account
            Map<ID, List<AccountTeamMember>> accountIDTeamMemberMap = new Map<ID, List<AccountTeamMember>>();
            if(teamMemberList.size() > 0){
                for(AccountTeamMember temMember :teamMemberList){
                    if(accountIDTeamMemberMap.get(temMember.AccountId) == null){
                        accountIDTeamMemberMap.put(temMember.AccountId, new List<AccountTeamMember>());
                    }
                    accountIDTeamMemberMap.get(temMember.AccountId).add(temMember);
                }
            }
            //Creating Custom notification for each group alert and its account's related team member
            if(KAMAlertControl != null && KAMAlertControl.Enabled__c ){
                for(AccountOrGroupAlert__c groupAlert : GroupAlertList){
                    List<AccountTeamMember> temMembers = accountIDTeamMemberMap.get(groupAlert.AccountId__c);
                    if(temMembers != null){
                        for(AccountTeamMember teammember : temMembers){
                            FeedItem post = new FeedItem();
                            post.ParentId = teammember.UserId;
                            post.Body = groupAlert.Body__c;
                            post.Title = 'Commercial Activity Process has reached Stage 2.';
                            post.LinkUrl = '/lightning/r/Alert/' + groupAlert.AlertId__c + '/view';
                            customNotificationList.add(post);
                        }
                    }
                }
            }
        }
        //Insert customNotificationList;
        if (customNotificationList != null && customNotificationList.size() > 0) {
            List < Database.SaveResult > insertNotificationResults = Database.Insert(customNotificationList, false);
            List < Database.Error > listError = new List <Database.Error> ();
            for (Integer index = 0, size = insertNotificationResults.size(); index < size; index++) {
                if (!insertNotificationResults[index].isSuccess()) {
                    listError.addAll(insertNotificationResults[index].getErrors());
                }
            }
            if (listError.size() > 0) {
                system.debug('listError-- '+ listError);
                LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateAlertAndNotifications', 'createCustomNotifications', 'Feed Item', 'Database.Insert_Failed');
            }
        }
        system.debug('----- Custom noti: '+ customNotificationList);
    }
    
    
    
    
    
    
    

}