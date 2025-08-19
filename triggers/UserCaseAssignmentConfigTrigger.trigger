trigger UserCaseAssignmentConfigTrigger on UserCaseAssignmentRuleConfigSetting__c (after update) {
	if(CaseRoundRobinMgr.isActive){
		Set<Id> modifiedConfigIds = new Set<Id>();
		for(UserCaseAssignmentRuleConfigSetting__c config : Trigger.New){
			if(config.Product__c !=  Trigger.oldMap.get(config.id).Product__c 
						|| config.Issue__c !=  Trigger.oldMap.get(config.id).Issue__c
						|| config.Record_Type__c !=  Trigger.oldMap.get(config.id).Record_Type__c
						|| config.Active__c !=  Trigger.oldMap.get(config.id).Active__c ){
				modifiedConfigIds.add(config.id);
			}
			/*
			config.Product__c =  c.getProducts();
					config.Issue__c =  c.getIssues();
					config.Record_Type__c =  c.getTypes();
					config.Active__c
					*/
		}
		
		if(! modifiedConfigIds.isEmpty()){
			Set<Id> inActiveUserIds = new Set<Id>();
			Set<String> activeUserIds = new Set<String>();
			
			for(Id configId :  modifiedConfigIds){
				UserCaseAssignmentRuleConfigSetting__c config = Trigger.NewMap.get(configId);
				if(config.Active__c){
					activeUserIds.add(config.User__c);
				}else{
					inActiveUserIds.add(config.User__c);
				}
				/*
				config.Product__c =  c.getProducts();
						config.Issue__c =  c.getIssues();
						config.Record_Type__c =  c.getTypes();
						config.Active__c
						*/
			}
			List<Case> caseRecords = new List<Case>();
			List<QueueSobject> queuesUnAssigned = [SELECT Id,QueueId,SobjectType,Queue.Name FROM QueueSobject WHERE SobjectType = 'Case' and queue.Name = 'Unassigned'];
			List<GroupMember> groupMembers = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember where Group.Type = 'Queue' AND UserOrGroupId =:inActiveUserIds ];
			system.debug('----activeUserIds ' + activeUserIds);
			system.debug('----inActiveUserIds ' + inActiveUserIds);
			Set<String> caseIDs = new Set<string>();
			for(Case cs : [SELECT 
                           		Id, OwnerId, Previous_Queue_Owner_Id__c
                          FROM 
                           	Case  
                          Where  
                           	OwnerId in :inActiveUserIds  
                           		AND isClosed = false AND Status != 'Pending' for Update]){
				system.debug('----cs ' + cs);
				boolean isMatch = false;
				cs.Skill_Routing_Exception__c = false;
				caseIDs.add(cs.Id);
				if(String.isNotBlank(cs.Previous_Queue_Owner_Id__c)){
					cs.ownerId = cs.Previous_Queue_Owner_Id__c;
	                caseRecords.add(cs);
				}else{
					for(GroupMember gm : groupMembers){
						if(cs.OwnerId == gm.UserOrGroupId){
							cs.OwnerId = gm.UserOrGroupId;
							isMatch = true;

	                        //caseRecords.add(cs);
							break;
						}
					}
					
					if(!isMatch && queuesUnAssigned.size() > 0){
						cs.OwnerId = queuesUnAssigned[0].QueueId;
	                    caseRecords.add(cs);
					}
				}
				
				
			}
			
			
			update caseRecords;
			
			for(Case cs : [SELECT Id, OwnerId, Previous_Queue_Owner_Id__c FROM Case  Where (isClosed = false OR status = 'Solved') and OwnerId in:activeUserIds and Skill_Routing_Exception__c = false ]){
					activeUserIds.remove(cs.OwnerId);
			}	
			
			if((! activeUserIds.isEmpty() || !caseIDs.isEmpty()) && (CaseRoundRobinMgr.byPassTriger == false)){
				CaseRoundRobinMgr.run(caseIDs, activeUserIds);
			}
		}
	}
    
}