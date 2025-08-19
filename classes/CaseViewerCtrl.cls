public class CaseViewerCtrl {

    @AuraEnabled
    public static Case updateCase(String caseId){
        insert new Case_Collision__c(
            User__c = UserInfo.getUserId(),
            Case__c = caseId
        );
        return new Case(Id = caseId);
    }

    @AuraEnabled
    public static User getLoginUser(){
        return [
            SELECT Id,Name
            FROM User
            WHERE Id =:UserInfo.getUserId()
            LIMIT 1
        ];
    }


    public static String getFirebase(){
        return getSetting('Case_Viewer_Firebase').Value__c;
    }

    public static Integer getFirebaseTimeOut(){
        Integer tm;
        App_Setting__mdt m = getSetting('Case_Viewer_Idle');
        if(m.Value__c <> NULL){
            tm = Integer.valueOf(m.Value__c);
        }
        return tm;
    }

    public static Boolean getIsAccessible(){
        return getSetting('Case_Viewer_Firebase').Active__c;
    }

    private static App_Setting__mdt getSetting(String setting){
        App_Setting__mdt m = new App_Setting__mdt();
        for(App_Setting__mdt mt : [
            SELECT Id, Active__c, Value__c
            FROM App_Setting__mdt
            WHERE DeveloperName =:setting LIMIT 1
        ]){
            m = mt;
        }
        return m;
    }
}