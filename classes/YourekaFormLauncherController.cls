public class YourekaFormLauncherController {
    // recordTitle: Allows the user to specify an additional field to return for display
    @AuraEnabled(cacheable=true)
    public static ObjectWrapper getRecord(String recordId, String recordTitle) {
        if(recordId != null) {
            String objectName = getObjectName(Id.valueOf(recordId));
            String query = 'SELECT Id';
            if(String.isNotBlank(recordTitle)) {
                query += ', ' + recordTitle;
            } else {
                query += '';
            }

            query += ' FROM ' + objectName + ' WHERE Id = \'' + recordId + '\'' + ' LIMIT 1';

            List<SObject> sObjects = Database.query(query);
            if(sObjects != null && sObjects.size() > 0) {
                return new ObjectWrapper(sObjects[0], objectName);
            }
        }

        return null;
    }

    // Gets the current UI Theme for the user to help determine LEX and Mobile experience
    @AuraEnabled(cacheable=true)
    public static String getUITheme() {
        return UserInfo.getUiTheme();
    }

    // Gets the object name from the record ID
    private static String getObjectName(Id recordId) {
        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String objectName = sobjectType.getDescribe().getName();
        return objectName;
    }

    // Wrapper class to return back the record and the object name
    public class ObjectWrapper
    {
        @AuraEnabled
        public SObject record;
        @AuraEnabled
        public String sObjectName;

        ObjectWrapper(SObject record, String sObjectName) {
            this.record = record;
            this.sObjectName = sObjectName;
        }
    }
}