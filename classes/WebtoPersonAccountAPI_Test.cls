@isTest
private class WebtoPersonAccountAPI_Test{
    static testMethod void testPopulateAccount(){
        createSettings();
        WebtoPersonAccountAPI.populateAccount(
            new Map<String,String>{
                'Name' => 'Name'
            }
        );
    }
    
    static testMethod void testDoPost(){
        createSettings();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        WebtoPersonAccountAPI.doPost();
    }
    
    static void createSettings(){
        List<WebToPersonAccount__c> config = new List<WebToPersonAccount__c>{
            new WebToPersonAccount__c(
                Name = 'Name',
                Field_API_Name__c = 'Name'
            )
        };
        
        insert config;
    }
}