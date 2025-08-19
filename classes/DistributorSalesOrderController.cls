global without sharing class DistributorSalesOrderController {
    public String refURL { get;set; } //Reference URL for Community
    public String userName{get;set;}
    public List<User> communityUser{get;set;}
    public String mode{get;set;}
    public Boolean newOrderAdded{get;set;}
    
    public Boolean createEnabled{get;set;}
    public static Set<String> createEnabledDistributorAliases = new Set<String>{'UPD'};

    //Create Variables
    public Account distributorAccount { get;set; }
    
    //View Variables
    public List<salesOrder__c> currentSalesOrders{get;set;}
    public Map<Id,List<Document_Details__c>> salesOrderToDocumentDetails{get;set;}
    public Date startDate{get;set;}
    public Date endDate{get;set;}

    public DistributorSalesOrderController(){
        mode = 'Create';
        createEnabled = false;
        if( ApexPages.currentPage().getParameters().get('mode')!=null)
            mode =  ApexPages.currentPage().getParameters().get('mode');

        refURL = getCommunityURL();
        communityUser = [SELECT Id, Profile.UserLicense.Name, Contact.AccountId, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId()];
        //communityUser = [SELECT Id, FirstName, LastName , Profile.UserLicense.Name, Contact.AccountId FROM User WHERE Contact.Id = '0032C00000IGZIg' LIMIT 1];
        userName = communityUser[0].FirstName + ' ' + communityUser[0].LastName;

        if(mode == 'View'){
            queryExistingSalesOrders();
        } else if(mode == 'Create'){
            distributorAccount = new Account();
            try{
                distributorAccount = [SELECT Id, Name, Distributor_Abbreviation__c FROM Account WHERE ID =: communityUser[0].Contact.AccountId LIMIT 1];
                if(createEnabledDistributorAliases.contains(distributorAccount.Distributor_Abbreviation__c))
                    createEnabled = true;
            } catch(exception e){}

                System.debug('Distributor Account : ' + distributorAccount);
        }
    }

    @RemoteAction @ReadOnly
    global static Map<String, Object> getViewObject(Id distributorId){
        Map<String, Account> typeaheadData = new Map<String, Account>();
        for(Distributor_Retailer_Link__c drl : [SELECT Id, Retailer__c, Retailer__r.Name, Retailer__r.Does_Business_As_DBA__c, Retailer__r.BillingStreet, Retailer__r.BillingState, Retailer__r.BillingCity, Retailer__r.BillingCountry, Retailer__r.BillingPostalCode FROM Distributor_Retailer_Link__c WHERE Distributor__c = :distributorId AND Retailer__r.BillingStreet != null]){
            typeaheadData.put(drl.Retailer__r.Name + ' - ' + drl.Retailer__r.BillingStreet, drl.Retailer__r);
        }

        Datetime dtNow = DateTime.now();

        return new Map<String, Object>{
            'typeaheadData' => typeaheadData,
            'productData' => [SELECT Id, UPD_Sales_Item_Id__c, Label__c , Unit_Count__c, Distributor_Portal_Category__c FROM product2 WHERE Distributor_Portal_Enabled__c = true ORDER BY Distributor_Portal_Sort_Order__c ASC],
            'uploadVerification' => UserInfo.getName() + ' - ' + dtNow.format('MM/dd/yyyy hh:mm a') + ' - UPD'
        };
    }

    public void queryExistingSalesOrders(){
        newOrderAdded = false;
        salesOrderToDocumentDetails = new Map<Id,List<Document_Details__c>>();
               
        String currentSalesOrdersQuery = 'SELECT Id, Order_Date__c,Customer__c, Customer__r.Name, Customer__r.BillingStreet, Customer__r.BillingCity, Customer__r.BillingState, Customer__r.BillingPostalCode,(SELECT Id, Product_Description__c, Product__r.Name, Product__r.Label__c, Product__r.UPD_Sales_Item_Id__c, Quantity__c FROM Document_Details__r) FROM salesOrder__c WHERE (Created_By_Portal_User__c = \''+ communityUser[0].Id +'\')';
        
        currentSalesOrdersQuery += ' AND CreatedDate = THIS_MONTH';
        if(startDate != null)
            currentSalesOrdersQuery += ' AND Order_Date__c >= : startDate ';
        
        if(endDate != null)
            currentSalesOrdersQuery += ' AND Order_Date__c <= : endDate ';

        if(startDate == null && endDate == null)
            currentSalesOrdersQuery += ' AND Order_Date__c = LAST_N_DAYS: 7 ';
        
        currentSalesOrdersQuery += 'ORDER BY Order_Date__c DESC LIMIT 500';

        System.debug(currentSalesOrdersQuery);
        currentSalesOrders = database.query(currentSalesOrdersQuery);   
        //System.debug(currentSalesOrders[0].Document_Details__r);
    }
    
    public void switchToViewMode(){
        mode = 'View';
        if(newOrderAdded == null || newOrderAdded)
            queryExistingSalesOrders();
    }
    
    public void switchToCreateMode(){
        mode = 'Create';
    }

    @RemoteAction
    global static void saveSalesData(List<Sales_Data__c> salesDataToInsert, String uploadVerification, String distributorAccountId){
        saveSalesDataFuture(JSON.serialize(salesDataToInsert), uploadVerification, distributorAccountId);
    }

    @future
    global static void saveSalesDataFuture(String salesDataString, String uploadVerification, String distributorAccountId){
        List<Sales_Data__c> salesDataToInsert = (List<Sales_Data__c>) JSON.deserialize(salesDataString, List<Sales_Data__c>.class);
        for(Sales_Data__c sd : salesDataToInsert){
            if(sd.Retailer_SFDC_Account_Id__c == null){ // We just had the user create a new retailer
                sd.Retailer_DBA__c = sd.Retailer_DBA__c != null ? String.escapeSingleQuotes(sd.Retailer_DBA__c) : null;
                sd.Retailer_Name__c = sd.Retailer_Name__c != null ? String.escapeSingleQuotes(sd.Retailer_Name__c) : null;
                sd.Retailer_Address_1__c = sd.Retailer_Address_1__c != null ? String.escapeSingleQuotes(sd.Retailer_Address_1__c) : null;
                sd.Retailer_Address_2__c = sd.Retailer_Address_2__c != null ? String.escapeSingleQuotes(sd.Retailer_Address_2__c) : null;
                sd.Retailer_City__c = sd.Retailer_City__c != null ? String.escapeSingleQuotes(sd.Retailer_City__c) : null;
            }
        }
        insert salesDataToInsert;

        List<Sales_Data_Upload_Queue__c> existingQueue = [SELECT Id, Total_Accounts__c, Total_Sales_Orders__c, Total_Document_Details__c FROM Sales_Data_Upload_Queue__c WHERE Upload_Verification__c = : uploadVerification LIMIT 1];
        if(existingQueue.isEmpty()){
            insert(new Sales_Data_Upload_Queue__c(
                Name = UserInfo.getUserId() + ' - ' + system.now().getTime(),
                Upload_Verification__c = uploadVerification,
                Upload_Format__c = 'UPD',
                Distributor_Id__c = distributorAccountId,
                User_Name__c = UserInfo.getUserName(),
                User_Id__c = UserInfo.getUserId(),
                Total_Accounts__c = 1,
                Total_Sales_Orders__c = 1,
                Total_Document_Details__c = salesDataToInsert.size()
            ));
        }
        else{
            existingQueue[0].Total_Accounts__c++;
            existingQueue[0].Total_Sales_Orders__c++;
            existingQueue[0].Total_Document_Details__c += salesDataToInsert.size();
            update(existingQueue);
        }
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