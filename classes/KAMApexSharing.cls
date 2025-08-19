/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        06-16-2020                     */
/* Class Name: KAMApexSharing                       */
/* Description: Class for giving access to Account team members by creating share records */
/**********************************************************************/
public class KAMApexSharing {
    public static String class_Name='KAMApexSharing';
    //get AccountID and Account Team memeber map by AccountIds
    public static Map<id,List<AccountTeamMember>> getAccountTeamMemberMap(Set<Id> accountIds){
        Map<id,List<AccountTeamMember>> accountTeamMemberMap = new Map<id,List<AccountTeamMember>>();
        for(AccountTeamMember a: [Select id,UserId,AccountId from AccountTeamMember where AccountId IN :accountIds]){
            if(!accountTeamMemberMap.containsKey(a.AccountId)){
                accountTeamMemberMap.put(a.AccountId, new List<AccountTeamMember>());
            }
            
            accountTeamMemberMap.get(a.AccountId).add(a);
        }
        return accountTeamMemberMap;
    }
    
    
    public static void shareAPTRecords(Map<Id,ActionPlanTemplate__c> newMapAPT, Map<Id,ActionPlanTemplate__c> oldMapAPT){
        String method_Name='shareAPTRecords';
        String operationType = 'Database.Insert_Failed';
        List<Database.Error> listError = new  List<Database.Error>();
        Set<Id> successRecords = new Set<Id>();
        Map<id,id> aptAccount = new Map<id,id>();
        Map<id,List<AccountTeamMember>> accountTeamMemberMap = new Map<id,List<AccountTeamMember>>();
        List<ActionPlanTemplate__Share> aptShare  = new List<ActionPlanTemplate__Share>();
        
        for(ActionPlanTemplate__c apt: newMapAPT.values()){
            aptAccount.put(apt.Id,apt.AccountId__c);
        }
        Set<Id> accounIds = new Set<Id>();
        accounIds.addAll(aptAccount.values());
        accountTeamMemberMap = KAMApexSharing.getAccountTeamMemberMap(accounIds);
        for(Id apt: aptAccount.keySet()){
            List<AccountTeamMember> relatedATM = new List<AccountTeamMember> ();
            relatedATM = accountTeamMemberMap.get(aptAccount.get(apt));
            if(relatedATM != null && relatedATM.size()>0){
                for(AccountTeamMember atm: relatedATM){
                    if(atm.UserId != newMapAPT.get(apt).OwnerId){
                        ActionPlanTemplate__Share apts = new ActionPlanTemplate__Share();
                        apts.ParentId= apt;
                        apts.AccessLevel= 'Edit';
                        apts.UserOrGroupId = atm.UserId;
                        apts.RowCause =Schema.ActionPlanTemplate__Share.RowCause.Manual;
                        aptShare.add(apts);
                    }
                }
            }
        }
        
        if(aptShare.size()>0){
            //insert aptShare;
    		List < Database.SaveResult > insertaptShareResults = Database.Insert(aptShare, false);
    		for (Integer index = 0, size = insertaptShareResults.size(); index < size; index++) {
        		if (!insertaptShareResults[index].isSuccess()) {
            		listError.addAll(insertaptShareResults[index].getErrors());
        		}
    		}
    		if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, class_Name, method_Name , 'Action Plan Template Share', operationType);
    		}
        } 
    }
    
    public static void removeAPTAccess(Map<Id,ActionPlanTemplate__c> newMapAPT, Map<Id,ActionPlanTemplate__c> oldMapAPT){
        set<Id> acctIDSet = new set<Id>();
        set<Id> memberIdSet = new set<Id>();
        List<Database.Error> listError = new  List<Database.Error>();
        Map<id,List<AccountTeamMember>> accountTeamMemberMap = new Map<id,List<AccountTeamMember>>();
        for(ActionPlanTemplate__c oldAPT : oldMapAPT.values()){
            if(oldAPT.AccountId__c != null){
                acctIDSet.add(oldAPT.AccountId__c);
            }
        }
        
        if(acctIDSet.size() == 0)
            return;
        List<AccountTeamMember> teamMemberList = [Select id,UserId,AccountId from AccountTeamMember where AccountId IN :acctIDSet];
        for(AccountTeamMember member : teamMemberList){
            memberIdSet.add(member.UserId);
        }
        List<ActionPlanTemplate__Share> aptShare  = new List<ActionPlanTemplate__Share>();
        aptShare = [SELECT ID FROM ActionPlanTemplate__Share WHERE ParentId =:newMapAPT.keySet() AND UserOrGroupId=:memberIdSet AND RowCause='Manual'];
        if(aptShare.size()>0){
    		List < Database.DeleteResult > deleteAPTShareListResults = Database.Delete(aptShare, false);
    		for (Integer index = 0, size = deleteAPTShareListResults.size(); index < size; index++) {
        		if (!deleteAPTShareListResults[index].isSuccess()) {
            		listError.addAll(deleteAPTShareListResults[index].getErrors());
        		}
    		}
    		if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, 'KAMApexSharing', 'removeAPTAccess' , 'Action Plan Template Share', 'Datbase.Delete');
    		}
        }  
    }
    
    public static void shareAlertRecords(Map<Id,AccountOrGroupAlert__c> newMapAccGrpAlrt, Map<Id,AccountOrGroupAlert__c> oldMapAccGrpAlrt){
        String method_Name='shareAlertRecords';
        String operationType = 'Database.Insert_Failed';
        List<Database.Error> listError = new  List<Database.Error>();
        Set<Id> successRecords = new Set<Id>();      
        Map<id,id> alertAccount = new Map<id,id>();
        Map<id,List<AccountTeamMember>> accountTeamMemberMap = new Map<id,List<AccountTeamMember>>();
        List<Alert__share> alertShare  = new List<Alert__share>();
        Set<ID> acctIDSet = new Set<ID>();
        for(AccountOrGroupAlert__c a: newMapAccGrpAlrt.values()){
            if(a.AccountId__c != null)
            	acctIDSet.add(a.AccountId__c);
        }
        
        if(acctIDSet.size() == 0)
            return;
        
        accountTeamMemberMap = KAMApexSharing.getAccountTeamMemberMap(acctIDSet);    
        for(AccountOrGroupAlert__c a:[Select id,AccountId__c,AlertId__c,AlertId__r.ownerId from AccountOrGroupAlert__c where AccountId__c!= null AND id IN :newMapAccGrpAlrt.keySet()]){
            if(a.AccountId__c != null && accountTeamMemberMap.get(a.AccountId__c) != null){
                for(AccountTeamMember atm : accountTeamMemberMap.get(a.AccountId__c)){
                    if(atm.UserId != a.AlertId__r.ownerId){
                        Alert__share alerts = new Alert__share();
                        alerts.ParentId= a.AlertId__c;
                        alerts.AccessLevel= 'Edit';
                        alerts.UserOrGroupId = atm.UserId;
                        alerts.RowCause =Schema.Alert__share.RowCause.Manual;
                        alertShare.add(alerts);
                    }
                }
            }
        }
        
        if(alertShare.size()>0){
            //insert alertShare;
    		List < Database.SaveResult > insertalertShareResults = Database.Insert(alertShare, false);
    		for (Integer index = 0, size = insertalertShareResults.size(); index < size; index++) {
        		if (!insertalertShareResults[index].isSuccess()) {
            		listError.addAll(insertalertShareResults[index].getErrors());
        		}
    		}
    		if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, class_Name, method_Name , 'Alert Share', operationType);
    		}
        } 
        
       /* for(AccountOrGroupAlert__c a: [Select id,AccountId__c,AlertId__c from AccountOrGroupAlert__c where AccountId__c!= null AND id IN :newMapAccGrpAlrt.keySet()]){
            alertAccount.put(a.AlertId__c,a.AccountId__c);
            alertGrpAccount.put(a.id, a.AccountId__c);
        }
        
        for(AccountTeamMember a: [Select id,UserId,AccountId from AccountTeamMember where AccountId IN :alertAccount.values()]){
            if(!accountTeamMemberMap.containsKey(a.AccountId)){
                accountTeamMemberMap.put(a.AccountId, new List<AccountTeamMember>());
            }
            
            accountTeamMemberMap.get(a.AccountId).add(a);
        }
        
        for(Id aga: alertGrpAccount.keySet()){
            List<AccountTeamMember> relatedATM = new List<AccountTeamMember> ();
            relatedATM = accountTeamMemberMap.get(alertGrpAccount.get(aga));
            if(relatedATM != null && relatedATM.size()>0){
                for(AccountTeamMember atm: relatedATM){
                    if(atm.UserId != newMapAccGrpAlrt.get(aga).OwnerId){
                        AccountOrGroupAlert__share agas = new AccountOrGroupAlert__share();
                        agas.ParentId= aga;
                        agas.AccessLevel= 'Edit';
                        agas.UserOrGroupId = atm.UserId;
                        agas.RowCause =Schema.AccountOrGroupAlert__share.RowCause.Manual;
                        alertGrpAccountShare.add(agas);
                    }
                }
            }
        }
        
        List<Alert__c> alertList = new List<Alert__c>();
        alertList = [Select id,OwnerId from Alert__c where id in: alertAccount.keySet()];
        
        
        Map<Id,Id> newMapAlrt = new  Map<Id,Id>(); 
        for(Alert__c a : alertList ){
            newMapAlrt.put(a.id, a.ownerID);
        }
        
        for(Id alert: alertAccount.keySet()){
            List<AccountTeamMember> relatedATM = new List<AccountTeamMember> ();
            relatedATM = accountTeamMemberMap.get(alertAccount.get(alert));
            if(relatedATM != null && relatedATM.size()>0){
                for(AccountTeamMember atm: relatedATM){
                    if(atm.UserId != newMapAlrt.get(alert)){
                        Alert__share alerts = new Alert__share();
                        alerts.ParentId= alert;
                        alerts.AccessLevel= 'Edit';
                        alerts.UserOrGroupId = atm.UserId;
                        alerts.RowCause =Schema.Alert__share.RowCause.Manual;
                        alertShare.add(alerts);
                    }
                }//inner for loop
            }//outer if
        }
        
        
        if(alertShare.size()>0){
            insert alertShare;       
        } 
        if(alertGrpAccountShare.size()>0){
            insert alertGrpAccountShare;       
        } */
    }
    
    
    /// Code Added by Pushkar
    public static void shareMissionRecords(List<Id> missionIds){
        String method_Name='shareMissionRecords';
        String operationType = 'Database.Insert_Failed';
        List<Database.Error> listError = new  List<Database.Error>();
        Set<Id> successRecords = new Set<Id>();      
        Map<id,id> alertAccount = new Map<id,id>();
        Map<id,List<AccountTeamMember>> accountTeamMemberMap = new Map<id,List<AccountTeamMember>>();
        List<Mission__share> missionShareList = new List<Mission__share>();
        Set<ID> acctIDSet = new Set<ID>();
        List<Mission__c> missionList = [SELECT ID, Name,ownerId, AccountId__c FROM MISSION__c WHERE Id=:missionIds];
        for(Mission__c mission: missionList){
            if(mission.AccountId__c != null)
            	acctIDSet.add(mission.AccountId__c);
        }
        
        if(acctIDSet.size() == 0)
            return;
        
        accountTeamMemberMap = KAMApexSharing.getAccountTeamMemberMap(acctIDSet);
        for(Mission__c a:missionList){
            if(a.AccountId__c != null && accountTeamMemberMap.get(a.AccountId__c) != null){
                for(AccountTeamMember atm : accountTeamMemberMap.get(a.AccountId__c)){
                    if(atm.UserId != a.ownerId){
                        Mission__share missionShare = new Mission__share();
                        missionShare.ParentId= a.id;
                        missionShare.AccessLevel= 'Edit';
                        missionShare.UserOrGroupId = atm.UserId;
                        missionShare.RowCause =Schema.Alert__share.RowCause.Manual;
                        missionShareList.add(missionShare);
                    }
                }
            }
        }
        if(missionShareList.size()>0){
            //insert alertShare;
    		List < Database.SaveResult > insertmissionShareListResults = Database.Insert(missionShareList, false);
    		for (Integer index = 0, size = insertmissionShareListResults.size(); index < size; index++) {
        		if (!insertmissionShareListResults[index].isSuccess()) {
            		listError.addAll(insertmissionShareListResults[index].getErrors());
                }else{
                    system.debug('inserted suuccessfully');
                }
    		}
    		if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, 'KAMApexSharing', method_Name , 'Mission Share', operationType);
    		}
        }         
    }

    //Share Child Accounts (Trigger Method)
        public static void shareAccountRecords(List<Account> accountList, Map<Id, Account> oldAccounts){
        String method_Name='shareAccountRecords';
        String operationType = 'Database.Insert_Failed';
        List<Database.Error> listError = new  List<Database.Error>();
        Set<Id> successRecords = new Set<Id>();      
        Map<id,id> alertAccount = new Map<id,id>();
        Map<id,List<AccountTeamMember>> accountTeamMemberMap = new Map<id,List<AccountTeamMember>>();
        List<AccountShare> shareAccountList = new List<AccountShare>();
        Set<ID> acctIDSet = new Set<ID>();
        //List<Account> StoreList = [SELECT ID, Name, RetailLocationId__c FROM InStoreLocation__c WHERE Id=:inStoreLocationIds];
        for(Account ac: accountList){
        	if((oldAccounts == null && ac.ParentId != null) || (oldAccounts!=null && oldAccounts.get(ac.ID).ParentId != ac.ParentId && ac.ParentId != null) )
           //if(ac.ParentId != null && oldAccounts.get(ac.ID).ParentId != ac.ParentId )  
            	acctIDSet.add(ac.ParentId);
        }        
        if(acctIDSet.size() == 0)
            return;
        accountTeamMemberMap = KAMApexSharing.getAccountTeamMemberMap(acctIDSet);
        for(Account a:accountList){
            if(a.ParentId != null && accountTeamMemberMap.get(a.ParentId) != null){
                for(AccountTeamMember atm : accountTeamMemberMap.get(a.ParentId)){
                    if(atm.UserId != a.ownerId){
                        Accountshare shareAccount = new Accountshare();
                        shareAccount.AccountId= a.Id;
                        shareAccount.accountaccesslevel = 'Edit';
						shareAccount.OpportunityAccessLevel = 'None';
						shareAccount.CaseAccessLevel = 'None';
                        shareAccount.UserOrGroupId = atm.UserId;
                        shareAccount.RowCause =Schema.Alert__share.RowCause.Manual;
                        shareAccountList.add(shareAccount);
                    }
                }
            }
        }
        if(shareAccountList.size()>0){
            //insert alertShare;
    		List < Database.SaveResult > insertAccountShareListResults = Database.Insert(shareAccountList, false);
    		for (Integer index = 0, size = insertAccountShareListResults.size(); index < size; index++) {
        		if (!insertAccountShareListResults[index].isSuccess()) {
            		listError.addAll(insertAccountShareListResults[index].getErrors());
        		}
    		}
    		if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, 'KAMApexSharing', method_Name , 'Account Share', operationType);
    		}
        }         
    }
    
    // Add Row Case conditionn
    // Remove Child Account accesss (Trigger Method)
	public static void removeAccessAccountRecords(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        List<Database.Error> listError = new  List<Database.Error>();
        Set<ID> parentAcctIDSet = new Set<ID>();
        Set<ID> childAcctIDSet = new Set<ID>();
        for(Account ac: oldMap.values()){
            if(ac.ParentId != null && newMap.get(ac.ID).ParentId != ac.ParentId)
            	parentAcctIDSet.add(ac.ParentId);
            	childAcctIDSet.add(ac.Id);
        }
        if(parentAcctIDSet.size() == 0)
            return;
        
        Set<ID> memberIdSet = new Set<ID>();
        List<AccountTeamMember> teamMemberList = [Select id,UserId,AccountId from AccountTeamMember where AccountId IN :parentAcctIDSet];
        for(AccountTeamMember member : teamMemberList){
            memberIdSet.add(member.UserId);
        }
        
        List<Accountshare> shareRecords = new List<Accountshare>();
    	shareRecords = [SELECT Id FROM Accountshare WHERE AccountId=:childAcctIDSet AND UserOrGroupId=:memberIdSet AND RowCause='Manual' ];
        if(shareRecords.size()>0){
    		List < Database.DeleteResult > deleteAccountShareListResults = Database.Delete(shareRecords, false);
    		for (Integer index = 0, size = deleteAccountShareListResults.size(); index < size; index++) {
        		if (!deleteAccountShareListResults[index].isSuccess()) {
            		listError.addAll(deleteAccountShareListResults[index].getErrors());
        		}
    		}
    		if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, 'KAMApexSharing', 'removeAccessAccountRecords' , 'Account Share', 'Datbase.Delete');
    		}
        }         
    }
}