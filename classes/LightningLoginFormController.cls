global without sharing class LightningLoginFormController {

    public LightningLoginFormController() {
        
    }
    @AuraEnabled
    global static Boolean checkUserEmail(String email) {
        // checks if user with the email exists already in salesforce
        // TBC - email or username is the reference?

        List<User> users = [SELECT Id FROM User WHERE Username = :email or Email=:email];
        if (users.size() > 0) {
            return true;
        } 
        return false;
    }

    @AuraEnabled
    public static String login(String username, String password, String startUrl,String storeLocatorId) {
        try{ 
            if(storeLocatorId!=null && storeLocatorId!=''){
            List<AccountContactRelation> acrList=new List<AccountContactRelation>();
            list<Account> accountList=[select id,name,Retailer_Community_Claimed__c from Account where Store_Locator_ID__c=:Integer.valueof(storeLocatorId)];
            list<user> userRecordList=[select username,contactId from user where username=:username and isactive=:true];
            Map<String,Set<String>> accountidToContactId=new  Map<String,Set<String>>();
                for(AccountContactRelation existingACR:[select Accountid,Contactid from AccountContactRelation where accountid in:accountList]){
                   if(!accountidToContactId.containsKey(existingACR.Accountid))
                    accountidToContactId.put(existingACR.Accountid, new Set<String> ());
                    accountidToContactId.get(existingACR.Accountid).add(existingACR.contactid);  
                }
                for(Account acc:AccountList){
                   if(acc.Retailer_Community_Claimed__c==false)
                      acc.Retailer_Community_Claimed__c=true;
                for(user userRecord:userRecordList){
                    if(!accountidToContactId.containskey(acc.id)|| (accountidToContactId.containskey(acc.id) && !accountidToContactId.get(acc.id).contains(userRecord.contactId))){                  
                         AccountContactRelation acr=new AccountContactRelation(
                         Accountid=acc.id,
                             ContactId=userRecord.contactId
                         );
                        acrList.add(acr);
                    }
                        
                }
            }
                insert acrList;
                update accountList;
            }
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }   
}