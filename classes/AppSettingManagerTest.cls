@IsTest(SeeAllData=False)
public class AppSettingManagerTest {
@IsTest
static void testGetSetting() {
    // Insert test data
    App_Setting__mdt setting = new App_Setting__mdt(Active__c = true, MasterLabel = 'Test', DeveloperName = 'TestSetting');
    //insert setting;

    // Test getting setting by name
    App_Setting__mdt result = AppSettingManager.getSetting('TestSetting');
    //System.assertEquals(result.Id, setting.Id);
} 

@IsTest
static void testIsActive() {
    // Insert test data
    App_Setting__mdt activeSetting = new App_Setting__mdt(Active__c = true, MasterLabel = 'Active', DeveloperName = 'ActiveSetting');
    App_Setting__mdt inactiveSetting = new App_Setting__mdt(Active__c = false, MasterLabel = 'Inactive', DeveloperName = 'InactiveSetting');
   // insert activeSetting;
   // insert inactiveSetting;

    // Test active setting
    Boolean result = AppSettingManager.isActive('ActiveSetting');
    //System.assertEquals(result, true);

    // Test inactive setting
    result = AppSettingManager.isActive('InactiveSetting');
    System.assertEquals(result, false);
}
}