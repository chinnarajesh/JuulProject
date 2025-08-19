public class PhotoLibraryHelper {
    public PhotoLibraryHelper() {

    }
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, List<String> selectedRecId, String label) {
        List<SObjectResult> sObjectResultList = new List<SObjectResult>();
        List<Account> ultimateAccList = new List<Account>();
        if(selectedRecId == null)
            selectedRecId = new List<String>();

        if(String.isNotEmpty(value)) {
            String query;
            Set<Id> ultimateAccSet = new Set<Id>();
            String filterQuery;
            if (fieldName == 'Ultimate_Parent_Account__c') {
                for (Account acc : [SELECT Ultimate_Parent_Account__c FROM Account WHERE Ultimate_Parent_Account__c != null AND Ultimate_Parent_Account__r.Name LIKE :('%' + value.trim() + '%')]) {
                    ultimateAccSet.add(acc.Ultimate_Parent_Account__c);
                }
            }
            System.debug('value  '+value);
            if (label == 'Search by Account KAM') {
                List<Id> ownerIds = new List<Id>();
                for (Account acc : [SELECT Ultimate_Parent_Account_Owner__c FROM Account WHERE Ultimate_Parent_Account_Owner__r.isActive = true AND Ultimate_Parent_Account_Owner__r.Name LIKE :('%' + value.trim() + '%')]) {
                    if (acc.Ultimate_Parent_Account_Owner__c != null) {
                        ownerIds.add(acc.Ultimate_Parent_Account_Owner__c);
                    }
                }
                filterQuery = 'SELECT Id, ' + fieldName + 
                ' FROM ' + ObjectName + 
                ' WHERE ' + fieldName + 
                ' LIKE \'%' + value.trim() + '%\' ' + 
                ' AND Id IN :ownerIds ' + 
                ' ORDER BY ' + fieldName + ' ASC ' +
                'LIMIT 500';
            }else if(label == 'Search by Door Owner'){
                filterQuery = 'SELECT Id, ' + fieldName + 
              ' FROM ' + ObjectName + 
              ' WHERE ' + fieldName + 
              ' LIKE \'%' + value.trim() + '%\' ' + 
              ' AND isActive = true ' +
              ' AND (UserRole.Name LIKE \'%Territory Manager%\' ' + 
              ' OR UserRole.Name LIKE \'%Territory Sales Specialist%\' ' +
              ' OR UserRole.Name LIKE \'%Division Manager%\' ' + 
              ' OR UserRole.Name LIKE \'%Director%\') ' +
              ' ORDER BY ' + fieldName + ' ASC ' +
              ' LIMIT 500';
            }
            System.debug('ultimateAccSet  '+ultimateAccSet);
            System.debug('fffff '+fieldName);
            if (selectedRecId != null && !selectedRecId.isEmpty()) {
                if(fieldName == 'Ultimate_Parent_Account__c'){
                
                   
                    query = 'SELECT Id,Name ' + 
                    ' FROM ' + ObjectName + 
                    ' WHERE Name' +  
                    ' LIKE \'%' + value.trim() + '%\' ' + 
                    'AND Id IN :ultimateAccSet ' +
                    ' AND Id NOT IN :selectedRecId ' + 
                    ' ORDER BY Name ASC ' +
                    'LIMIT 500';
                    fieldName = 'Name';
                }else{
                    query = 'SELECT Id, ' + fieldName + 
                    ' FROM ' + ObjectName + 
                    ' WHERE ' + fieldName + 
                    ' LIKE \'%' + value.trim() + '%\' ' + 
                    'AND Id NOT IN :selectedRecId ' + 
                    'ORDER BY ' + fieldName + ' ASC ' +
                    'LIMIT 500';
                }
                
            } else {
                if(fieldName =='Ultimate_Parent_Account__c'){
                    query = 'SELECT Id, Name' + 
                    ' FROM ' + ObjectName + 
                    ' WHERE Name' + 
                    ' LIKE \'%' + value.trim() + '%\' ' + 
                    'AND Id IN :ultimateAccSet ' +
                    ' ORDER BY Name ASC ' +
                    'LIMIT 500';
                    fieldName = 'Name';
                }else{
                    if(filterQuery != null){
                        query = filterQuery;
                    }else{
                        query = 'SELECT Id, ' + fieldName + 
                        ' FROM ' + ObjectName + 
                        ' WHERE ' + fieldName + 
                        ' LIKE \'%' + value.trim() + '%\' ' + 
                        'ORDER BY ' + fieldName + ' ASC ' +
                        'LIMIT 500';
                    }
                   
                }
               
            }
            
            System.debug('Query '+query);
            List<sObject> sObjList = Database.Query(query);
            for(sObject so : sObjList) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
            System.debug('sObjectResultList '+sObjectResultList);
        }
        return sObjectResultList;
    }
    
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        public SObJectResult() {
          
        }
    }
}