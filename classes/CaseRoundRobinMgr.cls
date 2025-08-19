global with sharing class CaseRoundRobinMgr implements  Queueable {
	public static boolean isActive;
    
	static{
		isActive = false;
		CaseSkillBaseAssignment__c setting = CaseSkillBaseAssignment__c.getInstance();
		if(setting != null){
			isActive = setting.active__c;
		}	
	}
	
	
    
   public static boolean byPassTriger = false;
   public static boolean stopRecurrance = false;

   public void execute(QueueableContext context){
		system.debug('--CaseRoundRobinMgr--caseIds' + caseIds);
    	system.debug('--CaseRoundRobinMgr--userIds' + userIds);
    	
    	if(! caseIds.isEmpty()){
    		this.runForCases(caseIds);
    	}
    	if(! userIds.isEmpty()){
    		this.runFromAgentId(userIds);
    	}
    }

	Set<String> caseIds;
	Set<String> userIds;

	public CaseRoundRobinMgr(Set<String> caseIds , Set<String> userIds){
		this.caseIds = caseIds;
		this.userIds = userIds;
	}

	
   
   
    global static void run(Set<String> caseIds , Set<String> userIds){
        if(stopRecurrance == false || Test.isRunningTest()){
            stopRecurrance = true;
    		System.enqueueJob(new CaseRoundRobinMgr(caseIds, userIds));
    	}
    }
    
    private static set<String> inputQueueIds(){
        Set<String> queueIds = new Set<String>();
         Set<String> queueNames = new Set<String>();
        for(Assignment_Queues_Setting__mdt aqs: [SELECT Queue_Name__c from Assignment_Queues_Setting__mdt]){
            queueNames.add(aqs.Queue_Name__c);
            
        }
        for(queueSobject qs : [select queueid from queueSobject where queue.Name in: queueNames]){
            queueIds.add(qs.QueueId);
        }

		return queueIds;        
    } 
    
    private string getTierName(String roleName){
    	String val = 'Tier 1';
    	if(String.isBlank(roleName)){
    		val = 'Tier 1';
    	}else if(roleName.contains('1')){
	    	val = 'Tier 1';
	    }else if(roleName.contains('2')){
	    	val = 'Tier 2';
	    }else if(roleName.contains('3')){
	    	val = 'Tier 3';
	    }
	    return val;
    }
    
    
    private void runForCases(set<String> caseIds){
    	//1. Find user's configuration details
		Set<String> recordTypes = new Set<String>();
		Set<String> products = new Set<String>();
		Set<String> issues = new Set<String>();
		Database.DMLOptions dmo = new Database.DMLOptions();
//		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerAutoResponseEmail = false;
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerUserEmail  = false;

		List<UserConfiguration> availableAgents = new List<UserConfiguration>();
		for(UserCaseAssignmentRuleConfigSetting__c config : [SELECT 
																Id, User__r.Name, User__c , Issues_Selected__c, Product__c, Record_Type__c, User__r.SmallPhotoUrl,Active__c, Tier__c
																, User__r.UserRole.Name
															FROM 
																UserCaseAssignmentRuleConfigSetting__c 
															where 
																User__r.isActive = true AND Active__c = true
                                                             	AND User__r.UserRoleId != null
																AND User__c not in (SELECT OwnerId from Case where isClosed = false and Status != 'Pending' AND Owner.Type = 'User' and Skill_Routing_Exception__c = false)
															Order by User__r.UserRole.Name asc]){
			UserConfiguration agentConfig = new UserConfiguration(config);
			recordTypes.addAll(agentConfig.recordTypes);
			products.addAll(agentConfig.products);
			issues.addAll(agentConfig.issues);
			availableAgents.add(agentConfig);
		}		
		
		system.debug('--CaseRoundRobinMgr--availableAgents' + availableAgents);
		system.debug('--CaseRoundRobinMgr--products' + products);
		system.debug('--CaseRoundRobinMgr--issues' + issues);
						
    	//2. Find available case in queues
    	List<Case> casesToAssign = new List<Case>();
    	
    	for(Case openCase : [SELECT 
		    					Id, RecordType.Name, Product__c, Issue__c, OwnerId , Owner_Name__c, Slack_Count__c,Queue_Priority__c,Total_Case_Score__c
		    				FROM 
		    					Case 
		    				WHERE 
		    					isClosed = false AND Product__c in:products  AND Id in : caseIds
		    					AND Status != 'Pending'
		    					//AND Slack_Count__c = false
		    					AND Case_Owner_Role__c = null
		    					AND Skill_Routing_Exception__c = false
                             	AND Owner_Name__c != null
                                AND OwnerId in :inputQueueIds()
		    				Order by Queue_Priority__c desc, Slack_Count__c desc , Total_Case_Score__c desc ]){
		    String caseTier = 'Tier 1';
		    if(openCase.Owner_Name__c.contains('2')){
		    	caseTier = 'Tier 2';
		    }else if(openCase.Owner_Name__c.contains('3')){
		    	caseTier = 'Tier 3';
		    }
		    system.debug('---- openCase.Owner_Name__c' + openCase.Owner_Name__c);
    		Integer index = -1;
    		for(UserConfiguration agentConfig : availableAgents){
    			index++;
    			system.debug('---- getTierName' + getTierName(agentConfig.configDetail.User__r.UserRole.Name));
    			system.debug('---- Role Name' + agentConfig.configDetail.User__r.UserRole.Name);
    			if(openCase.Slack_Count__c >0 && agentConfig.configDetail.User__r.UserRole.Name.contains('+') == false && caseTier != 'Tier 3'){
    				continue;
    			}else if(getTierName(agentConfig.configDetail.User__r.UserRole.Name) != caseTier){
    				continue;
    			}
    			
    			
    			if((agentConfig.issues.isEmpty() ||  agentConfig.issues.contains(openCase.Issue__c))
    						&& agentConfig.products.contains(openCase.Product__c) 
    						&& (agentConfig.recordTypes.isEmpty() ||  agentConfig.recordTypes.contains(openCase.RecordType.Name) )){
    							
    				openCase.OwnerId = agentConfig.configDetail.User__c;			
    				casesToAssign.add(openCase);
    				availableAgents.remove(index);
    				break;
    			}
    			
    			
    			
    		}
    		if(availableAgents.isEmpty()){
    			break;
    		}
    		
    	}
    	//3. Assign to Users
    	byPassTriger = true;
    	Database.update(casesToAssign, dmo);
    }

    
    //Assumption - When case will be un assigned to user, that user don't have any other open case, hence new case will be searched and assigned to User
    private void runFromAgentId(Set<String> userIds){
    	//1. Find user's configuration details
		Set<String> recordTypes = new Set<String>();
		Set<String> products = new Set<String>();
		Set<String> issues = new Set<String>();
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerAutoResponseEmail = false;
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerUserEmail  = false;

		List<UserConfiguration> availableAgents = new List<UserConfiguration>();
		for(UserCaseAssignmentRuleConfigSetting__c config : [SELECT 
																Id, User__r.Name, User__c , Issues_Selected__c, Product__c, Record_Type__c, User__r.SmallPhotoUrl,Active__c, Tier__c
																, User__r.UserRole.Name
															FROM 
																UserCaseAssignmentRuleConfigSetting__c 
															where 
																User__r.isActive = true AND Active__c = true
                                                             	AND User__r.UserRoleId != null
																AND User__c not in (SELECT OwnerId from Case where isClosed = false and Status != 'Pending' AND Owner.Type = 'User' and Skill_Routing_Exception__c = false)
															Order by User__r.UserRole.Name asc]){
			UserConfiguration agentConfig = new UserConfiguration(config);
			recordTypes.addAll(agentConfig.recordTypes);
			products.addAll(agentConfig.products);
			issues.addAll(agentConfig.issues);
			availableAgents.add(agentConfig);
		}					
		
		system.debug('--- AGENT RUN --' + availableAgents);	
    	//2. Find available case in queues
    	List<Case> casesToAssign = new List<Case>();
    	for(Case openCase : [SELECT 
		    					Id, RecordType.Name, Product__c, Issue__c , Owner_Name__c, Slack_Count__c
		    				FROM 
		    					Case 
		    				WHERE 
		    					isClosed = false AND Product__c in:products 
		    					AND Status != 'Pending'
		    					//AND Slack_Count__c = false
		    					AND Case_Owner_Role__c = null
		    					AND Skill_Routing_Exception__c = false
                             	AND Owner_Name__c != null
                             	AND OwnerId in :inputQueueIds()
		    				Order by Queue_Priority__c desc, Slack_Count__c desc,Total_Case_Score__c desc]){
		    				//Order by 
		    				//LIMIT :availableAgents.size()]){
                                try{
                                Integer index = -1;
    		String caseTier = 'Tier 1';
                                
		    if(openCase.Owner_Name__c.contains('2')){
		    	caseTier = 'Tier 2';
		    }else if(openCase.Owner_Name__c.contains('3')){
		    	caseTier = 'Tier 3';
		    }
		    
    		
    		for(UserConfiguration agentConfig : availableAgents){
    			
    				system.debug('---- getTierName' + getTierName(agentConfig.configDetail.User__r.UserRole.Name));
    				system.debug('---- Role Name' + agentConfig.configDetail.User__r.UserRole.Name);	
    				system.debug('---- openCase.Owner_Name__c' + openCase.Owner_Name__c);
    			
    			index++;
    			if(openCase.Slack_Count__c >0 && agentConfig.configDetail.User__r.UserRole.Name.contains('+') == false && caseTier != 'Tier 3'){
    				continue;
    			}else if(getTierName(agentConfig.configDetail.User__r.UserRole.Name) != caseTier){
    				continue;
    			}
    			
    			if((agentConfig.issues.isEmpty() ||  agentConfig.issues.contains(openCase.Issue__c))
    						&& agentConfig.products.contains(openCase.Product__c) 
    						&& (agentConfig.recordTypes.isEmpty() ||  agentConfig.recordTypes.contains(openCase.RecordType.Name) )){
    							
    				openCase.OwnerId = agentConfig.configDetail.User__c;			
    				casesToAssign.add(openCase);
    				availableAgents.remove(index);
    				system.debug('---- ASSIGNED CASE to ' + agentConfig.configDetail.User__r.Name);
    				break;
    			}
    		}
    		if(availableAgents.isEmpty()){
    			break;
    		}
                                }catch(Exception ex){}
    	}
    	//3. Assign to Users
    	byPassTriger = true;
    	system.debug('----casesToAssign ' + casesToAssign);
    	database.update(casesToAssign,dmo);
    	
    }	
    
    public class UserConfiguration{
    	public UserCaseAssignmentRuleConfigSetting__c configDetail;
    	public Set<String> recordTypes ;
    	public Set<String> issues ;
    	public Set<String> products ;
    	
    	
    	public UserConfiguration(UserCaseAssignmentRuleConfigSetting__c configDetail){
    		this.configDetail = configDetail;
    		products = new Set<String>();
    		recordTypes = new Set<String>();
    		issues = new Set<String>();
    		if(String.isNotBlank(configDetail.Product__c)){
				for(String val : configDetail.Product__c.split(';')){
					products.add(val);
				}
			}
			
			if(String.isNotBlank(configDetail.Record_Type__c)){
				for(String val : configDetail.Record_Type__c.split(';')){
					recordTypes.add(val);
				}
			}
			
			
			if(String.isNotBlank(configDetail.Issues_Selected__c)){
				for(String val : configDetail.Issues_Selected__c.split(';')){
					issues.add(val);
				}
			}
    	}
    }
    
    
    
    
}