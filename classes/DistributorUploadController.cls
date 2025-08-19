public without sharing class DistributorUploadController {
    public String refURL { get;set; } //Reference URL for Community
    public String userName{get;set;}
    public Boolean isAdminUser {get;set;}
    public String distributorAccounts {get;set;}
    public Account distributorAccount {get;set;}

    public String pageError {get;set;}
    public String productData {get;set;}
    public DistributorUploadController(){
        userName = UserInfo.getName();
        refURL = getCommunityURL();
        List<User> salesforceUser = [SELECT Id, Profile.UserLicense.Name FROM User WHERE Id = :UserInfo.getUserId() AND Profile.UserLicense.Name IN ('Salesforce', 'Salesforce Platform')];
        isAdminUser = !salesforceUser.isEmpty();
        Map<Id, String> distributorAccountMap = new Map<Id, String>();
        Custom_Code_Configuration__c customCon = Custom_Code_Configuration__c.getInstance();
        
        if(isAdminUser){
            List<Id> distroIds = (customCon != null && customCon.Distributor_Ids_1__c!=null)? customCon.Distributor_Ids_1__c.split(',') : new List<Id>();
            
            for(Account a : [SELECT Id, Name FROM Account WHERE ID IN : distroIds]){
                distributorAccountMap.put(a.Id, a.Name);
            }
            distributorAccounts = JSON.serialize(distributorAccountMap);
        }
        else{ //Only use users distro
            List<User> communityUser = [SELECT Id, Profile.UserLicense.Name, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];

            for(Account a : [SELECT Id, Name, Distributor_Abbreviation__c FROM Account WHERE ID =: communityUser[0].Contact.AccountId AND Distributor_Abbreviation__c != null]){
                distributorAccountMap.put(a.Id, a.Distributor_Abbreviation__c);
                distributorAccount = a ;
            }
            distributorAccounts = JSON.serialize(distributorAccountMap);
            productData = JSON.serialize([SELECT Id, Distributor_Portal_Name__c , Unit_Count__c, Distributor_Portal_Category__c FROM product2 WHERE Distributor_Portal_Enabled__c = true ORDER BY Distributor_Portal_Sort_Order__c ASC]);
 
            if(distributorAccountMap.keySet().isEmpty())
                pageError = 'You are not assigned to a Distributor Account and are not enabled for the Distributor Portal. Please reach out to JUUL for help.';
        }


    }

    // @RemoteAction @ReadOnly
    // public static List<String> getUnmatchedAccounts(List<String> UPDToRetrieve){
    //     System.debug(UPDToRetrieve);
    //     List<Account> matchedAccounts = [SELECT Id, UPD_Upload_Id__c FROM Account WHERE UPD_Upload_Id__c IN :UPDToRetrieve];
    //     Set<String> matchedUPDs = new Set<String>();
    //     for(Account a : matchedAccounts){
    //         matchedUPDs.add(a.UPD_Upload_Id__c);
    //     }
    //     System.debug(matchedUPDs);
    //     List<String> unmatchedUPDs = new List<String>();
    //     for(String upd : UPDToRetrieve){
    //         if(!matchedUPDs.contains(upd))
    //             unmatchedUPDs.add(upd);
    //     }
    //     return unmatchedUPDs;
    // }

    /*
    @RemoteAction
    public static String kickOffDistributorUploadBatch(Map<String, String> param){
        HttpRequest req = new HttpRequest();   
        req.setEndpoint( 'https://revivo-paxlabs.cs19.force.com/distributoraccountcreation/services/apexrest/DistributorAccountCreation' );
        req.setMethod('POST');
        req.setBody(JSON.serialize(param));
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        try {
            Http http = new Http();
            
            if(Test.isRunningTest()) return null;
            HttpResponse response = http.send(req);
            System.debug(response.getBody());
            return response.getBody();
        } catch( System.Exception e) {
            System.debug('ERROR: '+ e);
            throw e;
        } 
    }
    */

    public static Boolean isAdminUser(){
        List<User> salesforceUser = [SELECT Id, Profile.UserLicense.Name FROM User WHERE Id = :UserInfo.getUserId() AND Profile.UserLicense.Name IN ('Salesforce', 'Salesforce Platform')];
        System.debug('Is Admin User ? ' + !salesforceUser.isEmpty());
        if(salesforceUser.isEmpty())
            return false;
        return true;
    }

    public static Boolean isCommunityUser(){
        List<User> communityUser = [SELECT Id, Profile.UserLicense.Name, Contact.AccountId, Contact.Account.Distributor_Abbreviation__c FROM User WHERE Id = :UserInfo.getUserId()];
        if(!communityUser.isEmpty() && communityUser[0].Contact.Account.Distributor_Abbreviation__c != null)
            return true;
        return false;
    }

    @RemoteAction
    public static void kickOffDistributorUploadBatchDirectly(Map<String, String> params){
        System.debug(params);
        if(!isAdminUser()) 
            return;
        if(!Test.isRunningTest()) 
            database.executeBatch(new DistributorSalesUploadBatch(params), 25);
    }

    @RemoteAction
    public static void insertSalesData(List<Sales_Data__c> allSalesData){
        if(!isAdminUser() && !isCommunityUser()) 
            return;
        insert(allSalesData);   
    }

    @RemoteAction
    public static String insertUploadQueue(Map<String, String> params){      
        List<User> communityUser = [SELECT Id, Name, Profile.UserLicense.Name, Contact.AccountId, Contact.Account.Distributor_Abbreviation__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(communityUser.isEmpty())
            return 'You are not enabled for Distributor Portal. Please contact JUUL for help.';

        if(communityUser[0].Contact.Account.Distributor_Abbreviation__c == null)
            return 'You are not assigned to a Distributor yet. Please contact JUUL for help.';

        Sales_Data_Upload_Queue__c newQueue = new Sales_Data_Upload_Queue__c();
        newQueue.Total_Accounts__c = Integer.ValueOf(params.get('totalAccounts'));
        newQueue.Total_Sales_Orders__c = Integer.ValueOf(params.get('totalSalesOrders'));
        newQueue.Total_Document_Details__c = Integer.ValueOf(params.get('totalDocumentDetails'));
        newQueue.Name = UserInfo.getUserId() + ' - ' + system.now().getTime(); 
        newQueue.Upload_Verification__c = String.ValueOf(params.get('uploadVerification'));
        //communityUser[0].Name + ' - ' + System.now().format('MM/dd/yyyy hh:mm a') + ' - ' + communityUser[0].Contact.Account.Distributor_Abbreviation__c; //params.get('uploadVerification');
        newQueue.Upload_Format__c=communityUser[0].Contact.Account.Distributor_Abbreviation__c;
        newQueue.Distributor_Id__c = communityUser[0].Contact.AccountId;
        newQueue.User_Name__c=UserInfo.getUserName();
        newQueue.User_Id__c=UserInfo.getUserId();
        insert(newQueue);
        return 'Your CSV will be uploaded within the next 24 hours.';
    }
    
     //Returns the URL prepend for navigating pages in the Community
    public static String getCommunityURL() {
        if( Network.getNetworkId() == null) {
            return '/apex/';
        }
        else{
            return '/community/apex/';
        }
    }
}