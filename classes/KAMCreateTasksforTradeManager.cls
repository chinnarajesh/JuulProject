/************************************************************************************************/
/* VERSION     AUTHOR                  DATE                           							*/
/*  1.0	     Pushkar Gangwar         06-23-2020                     							*/
/* Class Name: KAMCreateTasksforTradeManager                    								*/
/* Description: Invocable class from process builder tp create task for Trade control manager	*/
/************************************************************************************************/
public class KAMCreateTasksforTradeManager  {
    
    @InvocableMethod
    public static void createTaskforTradeCollateralManager(List<ActionPlanTemplate__c> actionPlanTemplets){
        system.debug('actionPlanTemplets---'+ actionPlanTemplets);
       	String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Report> RMreport = new List<Report>();
        String revenueManagerReportLink = '';
        RMreport = [SELECT Id,DeveloperName, Name FROM Report where 
                   DeveloperName = 'Trade_Collaterals_Planning_BwS' LIMIT 1];
        if(RMreport.size()> 0){
            revenueManagerReportLink = baseUrl+'/'+RMreport[0].Id;
        }
        
        Set<Id> accountIds = new Set<ID>();
        for(ActionPlanTemplate__c apt : actionPlanTemplets){
                accountIds.add(apt.AccountId__c);
        }
        
        system.debug('accountIds--'+ accountIds);
        if(accountIds.size() > 0){
        	Map<ID, Account> accountIdAccountMap = new Map<ID, Account>([SELECT Id, Name, OwnerId FROM Account WHERE ID=:accountIds]);
        
        	List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
        	teamMemberList = [SELECT ID, AccountID, UserId, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole='Trade Marketing Manager' AND AccountID=:accountIds ];
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
        	    	taskItem.Subject = 'Initiate planning for Trade Collaterals';
        	    	taskItem.Description = 'Action Plan Template: '+ baseUrl+'/'+APT.Id+ '\n';
                    taskItem.Description = taskItem.Description+ 'Trade Collaterals Planning Report: '+revenueManagerReportLink;
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
        				LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateTasksforManagers', 'createTaskforVendorManager', 'Task', 'Database.Insert_Failed');
    				}
				}
        	
        	}
        }
    }

}