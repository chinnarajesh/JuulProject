public class KAMCreateTasksForRevenueManager {
    
    @InvocableMethod
    public static void createTaskforRevenuelManager(List<ActionPlanTemplate__c> actionPlanTemplets){
        System.debug('Method called FROM Process builder');
        Set<Id> accountIds = new Set<ID>();
        for(ActionPlanTemplate__c apt : actionPlanTemplets){
                accountIds.add(apt.AccountId__c);
        }
        
        if(accountIds.size() > 0){
        	Map<ID, Account> accountIdAccountMap = new Map<ID, Account>([SELECT Id, Name, OwnerId FROM Account WHERE ID=:accountIds]);
        
        	List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
        	teamMemberList = [SELECT ID, AccountID, UserId, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole='Revenue Finance Manager' AND AccountID=:accountIds ];
        	system.debug('teamMemberList--'+ teamMemberList);
        	Map<ID, List<AccountTeamMember>> accountIDTeamMemberMap = new Map<ID, List<AccountTeamMember>>();
        	if(teamMemberList.size() > 0){
            	for(AccountTeamMember temMember :teamMemberList){
            		if(accountIDTeamMemberMap.get(temMember.AccountId) == null){
                		accountIDTeamMemberMap.put(temMember.AccountId, new List<AccountTeamMember>());
            		}
        		    accountIDTeamMemberMap.get(temMember.AccountId).add(temMember);
        		}
            	 system.debug('accountIDTeamMemberMap--'+ accountIDTeamMemberMap);
        	}
        	//Creating tasks 
        	List<Task> taskList = new List<Task>();
        	if(! accountIDTeamMemberMap.isEmpty()){
            	for(ActionPlanTemplate__c APT  : actionPlanTemplets){
        	    	Task taskItem = new Task();
        	    	taskItem.Subject = 'Upload INMAR Payment status for the Participating Doors for Chain Name.';
        	    	taskItem.Description = 'generate status updates for payments and upload data from INMAR to SFDC based on Promo end date per chain. \n';
                    List<AccountTeamMember> TradeManagerList= accountIDTeamMemberMap.get(APT.AccountId__c);
        		   	taskItem.OwnerId = TradeManagerList[0].UserId;
            	    //taskItem.WhatId = TradeManagerList[0].AccountId;
            	    taskItem.WhatId = APT.Id;
        		    taskList.add(taskItem);
        		}
        		if (taskList != null && taskList.size() > 0) {
    				List < Database.SaveResult > insertTaskResults = Database.Insert(taskList, false);
    				List < Database.Error > listError = new List <Database.Error> ();
    				for (Integer index = 0, size = insertTaskResults.size(); index < size; index++) {
        				if (!insertTaskResults[index].isSuccess()) {
            				listError.addAll(insertTaskResults[index].getErrors());
                	    }
    				}
    				if (listError.size() > 0) {
        				LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateTasksForRevenueManager', 'createTaskforRevenuelManager', 'Task', 'Database.Insert_Failed');
    				}
				}
        	
        	}
        }
    }

    
}