/************************************************************************************************/
/* VERSION   	AUTHOR                  DATE                           							*/
/*  1.0	     	Pushkar Gangwar         06-25-2020                     							*/
/* Class Name: KAMCreateTasksforVendorManager                    								*/
/* Description: Invocable class from process builder tp create task for vendor manager 	  		*/
/************************************************************************************************/
public class KAMCreateTasksforVendorManager {
    
    @InvocableMethod 
    public static void createTaskforVendorManager(List<ActionPlanTemplate__c> actionPlanTemplets){
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Report> VMreport = new List<Report>(); 
        String vendorManagerReportLink = '';
        VMreport = [SELECT Id,DeveloperName, Name FROM Report where 
                   DeveloperName = 'Promo_Participating_Door_Vendor_CQe' LIMIT 1];
        if(VMreport.size() > 0){
            vendorManagerReportLink = baseUrl+'/'+VMreport[0].Id;
        }
        Set<Id> accountIds = new Set<ID>();
        for(ActionPlanTemplate__c apt : actionPlanTemplets){
            if(apt.RequestedStartDate__c == System.today()){
                accountIds.add(apt.AccountId__c);
            }
        }
        system.debug('accountIds--'+ accountIds);
        
        if(accountIds.size() > 0){
            Map<ID, Account> accountIdAccountMap = new Map<ID, Account>([SELECT Id, Name, OwnerId FROM Account WHERE ID=:accountIds]);
        	List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
        	teamMemberList = [SELECT ID, AccountID, UserId, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole='Vendor Manager' AND AccountID=:accountIds ];
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
        		    taskItem.Subject = 'Complete Promo Activity Audit';
        		    taskItem.Description = 'Action Plan Template: '+ baseUrl+'/'+APT.Id+ '\n';
        		    taskItem.Description  += 'Link to Vendor Manager Report: '+ vendorManagerReportLink;
        		    List<AccountTeamMember> vendorManagerList= accountIDTeamMemberMap.get(APT.AccountId__c);
        		   	taskItem.OwnerId = vendorManagerList[0].UserId;
        	        //taskItem.WhatId = vendorManagerList[0].AccountId;
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