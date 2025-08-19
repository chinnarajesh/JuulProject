public without sharing class JUULContactListCtrl {
	 @AuraEnabled(cacheable = true)
    public static List<Contact> fetchJUULContacts(String region){
        String query = ' SELECT Id,Name, Region__c, Phone, Title, Email';
        query += ' FROM Contact';
        query += ' WHERE RecordType.Name =\'Juul Contacts\'';
        
        if(region != '' && region != null) {
            query += ' AND Region__c = \'' + region + '\'';
        }
        system.debug('==query===' + query);
        system.debug(database.query(query));
        return (database.query(query));
      
    }
   
    
}