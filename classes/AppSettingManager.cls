public class AppSettingManager {
	static Map<String, App_Setting__mdt> settings;


	public static App_Setting__mdt getSetting(String name){
		return getAppSettings().get(name);
	}

	public static Boolean isActive(String name){
		return getAppSettings().get(name) != NULL && getAppSettings().get(name).Active__c;
	}


	private static Map<String, App_Setting__mdt> getAppSettings(){
		if(settings == NULL){
			settings = new Map<String, App_Setting__mdt>();
			for(App_Setting__mdt a : [
				SELECT Id, Active__c, MasterLabel, DeveloperName
				FROM App_Setting__mdt
			]){
				settings.put(a.DeveloperName, a);
			}
		}

		return settings;
	}
}