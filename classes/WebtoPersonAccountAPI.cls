@RestResource(urlMapping='/webtoPersonAccount/*')
global with sharing class WebtoPersonAccountAPI{

    @HttpPost   
    global static void doPost() {
        try{
            RestRequest req = RestContext.request;
            Map<String,String> paramToValueMap = req.params;
            Account personAcc = new Account();   
            personAcc = populateAccount(paramToValueMap);
            upsert personAcc;
           
            RestContext.response.statusCode = 200;
        }
        catch(Exception e){
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    @TestVisible
    private static Account populateAccount(Map<String,String> paramToValueMap){
        Boolean isValid = false;
        Map<String,WebToPersonAccount__c> nameToSettingMap = new Map<String,WebToPersonAccount__c>();
        Account personAccount= new Account();
        
        for(WebToPersonAccount__c setting : WebToPersonAccount__c.getAll().values()){
            nameToSettingMap.put(setting.Name.toLowerCase(),setting);
        }
        
        for(String param : paramToValueMap.KeySet()){
            if(nameToSettingMap.containsKey(param.toLowerCase())){
                isValid = true;
                personAccount.put(nameToSettingMap.get(param.toLowerCase()).Field_API_Name__c,paramToValueMap.get(param));
            }
        }
        Account personAccountNew = findExistingAccount(personAccount);
        if(isValid){
            return personAccountNew ;
        }else{
            return null;
        }
        
    }
    
    @TestVisible
    private static Account findExistingAccount(Account personAccount){
        Account acc = personAccount;
        List<Account> existingAcc =new List<Account>([
            SELECT Id,FirstName,LastName,personEmail 
            FROM Account 
            WHERE isPersonAccount = true AND PersonEmail =: personAccount.PersonEmail AND PersonEmail != NULL
        ]);
        If(!existingAcc.isEmpty()){
            acc.Id = existingAcc[0].Id;
        }
        
        return acc;
    }
  
}