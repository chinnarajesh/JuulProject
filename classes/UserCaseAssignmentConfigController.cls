public with sharing class UserCaseAssignmentConfigController {
	public string productType {get;set;}
	private String serviceMgmtRoleName ='%Service Management';
	public Set<Id> serviceMgmt {get;Set;}
	public List<String> userRoles {get; set;}
	
	public List<SelectOption> productTypeOptions {get;set;}
	public UserCaseAssignmentConfigController(){
		//Add Users 
		productType = 'JUUL';
		productTypeOptions = new List<SelectOption>();
		if(String.isBlank(productType)){
			productTypeOptions.add(new SelectOption('JUUL', 'JUUL'));
		}else{
			productTypeOptions.add(new SelectOption(productType,productType));
		}
		if(String.isNotBlank(productType) && ! productType.contains(';')){
			serviceMgmtRoleName = productType + ' Service Management' ;
		}
		Set<Id> serviceMgmt = new Set<Id>();
		
		
		for(UserRole role :  [SELECT Id FROM UserRole WHERE Name like : serviceMgmtRoleName]){
			serviceMgmt.add(role.Id);
		}
		userRoles = new List<String>();
		for(UserRole role : [SELECT ID, NAME FROM UserRole WHERE ParentRoleId in :serviceMgmt Order by Name asc]){
			userRoles.add(role.Name);
		}
		
	}

	public void init(){
		if(String.isNotBlank(productType) && ! productType.contains(';')){
			serviceMgmtRoleName = productType + ' Service Management' ;
		}
		Set<Id> serviceMgmt = new Set<Id>();
		
		
		for(UserRole role :  [SELECT Id FROM UserRole WHERE Name like : serviceMgmtRoleName]){
			serviceMgmt.add(role.Id);
		}
		userRoles = new List<String>();
		for(UserRole role : [SELECT ID, NAME FROM UserRole WHERE ParentRoleId in :serviceMgmt Order by Name asc]){
			userRoles.add(role.Name);
		}
		addUsers();
	}
	
	public pageReference addUsers(){	
		
		List<UserCaseAssignmentRuleConfigSetting__c> configSettings = new List<UserCaseAssignmentRuleConfigSetting__c>();
		for(User u : [SELECT Id FROM User WHERE UserRole.Name in :userRoles AND Id not in (SELECT User__c FROM UserCaseAssignmentRuleConfigSetting__c) AND isActive = true]){
			configSettings.add(
				new UserCaseAssignmentRuleConfigSetting__c(
					User__c = u.Id
					, Active__c = true
			));
		}
		insert configSettings;
		return null;
	}
	
	@RemoteAction 
	public static List<LookupResult> searchUser(string userName){
		userName = userName + '%';
		List<LookupResult> results = new List<LookupResult>();
		if(String.isNotBlank(userName)){
			for(UserCaseAssignmentRuleConfigSetting__c config : [SELECT 
																		Id, User__r.Name, User__c , Tier__c
																	FROM 
																		UserCaseAssignmentRuleConfigSetting__c 
																	where 
																		User__r.isActive = true  			
																		AND User__r.Name like :	userName				
																		Order By User__r.Name desc 
																	Limit 10]){
				results.add(new LookupResult(config.User__c, config.User__r.Name, 'User'));
			}
				
		}
		return results;
	}
	
	@RemoteAction
	public static RemoteResponse save(List<CongigurationSetting> configurations){
		RemoteResponse response = new RemoteResponse();
		System.Savepoint sp = Database.setSavePoint();
		try{
			List<UserCaseAssignmentRuleConfigSetting__c> configs = new List<UserCaseAssignmentRuleConfigSetting__c>();
			
			Set<Id> userIds = new Set<Id>();
			Set<String> userIdsToAssign = new Set<String>();
			for(CongigurationSetting c : configurations){
				UserCaseAssignmentRuleConfigSetting__c config = c.config;
				config.Product__c =  c.getProducts();
				config.Issues_Selected__c =  c.getIssues();
				config.Record_Type__c =  c.getTypes();
				configs.add(config);
				userIds.add(config.User__c);
				if(config.Active__c){
					userIdsToAssign.add(config.User__c);
				}
			}
			update configs;
			response.isSuccess = true;
			
			
		}catch(Exception ex){
			Database.rollback(sp);
			response.isSuccess = false;
			response.errMsg = ex.getMessage();
		}
		return response;
	}
	
	@RemoteAction 
	public static List<LookupResult> getPickListVal(string pickListName, string currentUserType){
		List<LookupResult> results = new List<LookupResult>();
		List<Schema.PicklistEntry> picklistEntries = new List<Schema.PicklistEntry>();
		if(pickListName == 'Issue__c'){
			picklistEntries =  Case.Issue__c.getDescribe().getPicklistValues();
		}else if(pickListName == 'Product__c'){
			picklistEntries =  Case.Product__c.getDescribe().getPicklistValues();
		}else if(pickListName == 'Record_Type__c'){
			for(RecordType rt : [SELECT ID, Name FROM RecordType WHERE sobjectType ='Case' and isActive = true AND Name like : currentUserType +'%']){
					results.add(new LookupResult(rt.Name, rt.Name, rt.Name));
			}
			//picklistEntries =  UserCaseAssignmentRuleConfigSetting__c.Record_Type__c.getDescribe().getPicklistValues();
		}
		for(Schema.PicklistEntry pe : picklistEntries){
				results.add(new LookupResult(pe.getValue(), pe.getValue() , pickListName));
		}	
		return results;
	}
	
	
	@RemoteAction 
	public static List<CongigurationSetting> getConfigSettings(string userOrRoleId, boolean isActive, String metaLabel, String currentUserType){
		List<UserCaseAssignmentRuleConfigSetting__c> configs = new List<UserCaseAssignmentRuleConfigSetting__c>();
		if(String.isNotBlank(userOrRoleId)){
			System.debug(userOrRoleId);
			configs  = [SELECT 
						Id, User__r.Name, User__c , Issue__c, Product__c, Record_Type__c, User__r.SmallPhotoUrl,Active__c
						, Tier__c,Issues_Selected__c , User__r.UserRole.Name
						FROM 
							UserCaseAssignmentRuleConfigSetting__c 
						where 
							User__r.isActive = true  			
							AND User__r.UserRole.Name = :userOrRoleId
							AND Active__c =:isActive				
							Order By User__r.Name asc];
		}else{
		
			//Set<String> allProductTypes = new Set<String>();
			configs  = [SELECT 
						Id, User__r.Name, User__c , Issue__c, Product__c, Record_Type__c, User__r.SmallPhotoUrl,Active__c
						, Tier__c,Issues_Selected__c , User__r.UserRole.Name
						FROM 
							UserCaseAssignmentRuleConfigSetting__c 
						where 
							User__r.isActive = true  
							AND User__r.UserRole.Name like: currentUserType + ' Tier%'
							AND Active__c =:isActive				
							Order By User__r.Name asc];
		}
		List<CongigurationSetting> configurations = new List<CongigurationSetting>(); 
		for(UserCaseAssignmentRuleConfigSetting__c config : configs){
			configurations.add(new CongigurationSetting(config));
		}
		return configurations;
	}

	public Static String getAvailableProductType(){
		return 'JUUL';
	}
	
	public class CongigurationSetting{
		public UserCaseAssignmentRuleConfigSetting__c config;
		public List<String> products;
		public List<String> issues;
		public List<String> types;
		
		public List<LookupResult> productOptions;
		public List<LookupResult> issueOptions;
		public List<LookupResult> typeOptions;
		
		public String getProducts(){
			return this.joinLookup(products);
		}
		
		public String getIssues(){
			return this.joinLookup(issues);
		}
		
		public String getTypes(){
			return this.joinLookup(types);
		}
		
		private string joinLookup(List<String> selectedOptions){
			String value = '';
			for(String option : selectedOptions){
				//value += String.isBlank(value) ? option.id : ';' + option.id;
				value += String.isBlank(value) ? option : ';' + option;
			}
			return value;
		}
		
		private List<String> splitPickval(String value){
			List<String> options = new List<String>();
			if(String.isNotBlank(value)){
				for(String val : value.split(';')){
					//options.add(new String(val, val, ''));
					options.add(Val);
				}
			}
			return options;
		} 
		
		public CongigurationSetting(UserCaseAssignmentRuleConfigSetting__c config){
			this.config = config;
			products = this.splitPickval(config.Product__c);
			issues = this.splitPickval(config.Issues_Selected__c);
			types = this.splitPickval(config.Record_Type__c);
			/*if(String.isNotBlank(config.Product__c)){
				
			}*/
		}
		
	}
	
	
 	
	public class LookupResult{
		public String id {get;set;}
		public String label {get;set;}
		public String metaLabel {get;set;}
		
		public LookupResult(String id, String label, String metaLabel){
			this.id = id;
			this.label = label;
			this.metaLabel = metaLabel;
		}
	}
	
 	public class RemoteResponse{
 		public boolean isSuccess;
 		public String recordId;
 		public String errMsg;
 	}  
    
}