public with sharing class DistributorSalesUploadBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public String overrideQuery;
    public Integer totalSalesOrdersInserted;
    public Integer totalFailedRows;
    public Integer totalRows;
    public Boolean useExistingSalesOrder;
    public Set<String> salesDataQueryFields;

    public Map<String, Id> externalAccountIdMap;
    public Map<String, Id> externalDistributorIdMap;
    public Set<String> failedSOExternalIds; // List of Failed UPD SO so we don't try to create new SOs
    public Set<String> failedAccExternalIds; // List of Failed Account Ext Ids so we don't try to create new Accounts
    public String dataFormat; //Format of the Data i.e. UPD, P & K
    public String retailerExternalIdField; //Field Name for the internal Retailer Id on Accounts.
    public Boolean useRetailerExternalIdField; 
    public Boolean forceRetailerExternalIdMatch;
    public String productExternalIdField;
    public Boolean useProductExternalIdField; 
    public Boolean isScheduled;
    public String distributorOrderType; //Distributor Alias i..e UPD = UD
    public Id distributorId;
    public Account distributorAccount;
    public String retryEmail;
    public String errorEmail;
    public String additionalEmail;
    public String uploadVerification;
    public String uploadDate;
    public String salesDataUploadQueueId;
    public Id userId;

    public Boolean singleRunOnly;

    public Map<String,Map<String,Id>> accExternalIdToSalesOrderMap;
    
    public static final Set<String> ACTIVE_JOB_STATUSES = new Set<String> {'Holding', 'Queued', 'Preparing', 'Processing'};
    
    public static Map<String,String> distributorAliasMap = new Map<String,String>{
        'P & K' => 'PK',
        'P&K' => 'PK',
        'PK'=>'PK',
        'UPD' => 'UD',
        'UD' => 'UD',
        'UPD Distributor Portal' => 'UD',
        'GL' => 'GL',
        'Greenlane' => 'GL',
        'Acumatica'=>'BO',
        'Smoke Ltd'=>'IS',
        'IS'=>'IS',
        'IL'=>'IL',
        'US'=>'US'
    };

    public static Map<String, String> salesOrderFieldToSalesDataFieldMap = new Map<String, String>{
        'SOBilling_Address_1__c' => 'Retailer_Address_1__c',
        'SOBilling_Address_2__c' => 'Retailer_Address_2__c',
        'SOBilling_City__c' => 'Retailer_City__c',
        'SOBilling_State__c' => 'Retailer_State__c',
        'SOBilling_Zip__c' => 'Retailer_Zip_Code__c',
        'SOBilling_Phone__c'=>'Retailer_Phone__c',
        'SOBilling_Country__c'=>'Retailer_Country__c',
        'Billing_Email__c'=>'Retailer_Email__c',
        'SOShipping_Address_1__c' => 'Retailer_Address_1__c',
        'SOShipping_Address_2__c' => 'Retailer_Address_2__c',
        'SOShipping_City__c' => 'Retailer_City__c',
        'SOShipping_State__c' => 'Retailer_State__c',
        'SOShipping_Country__c'=>'Retailer_Country__c',
        'SOShipping_Zip__c' => 'Retailer_Zip_Code__c',
        'Distributor__c' => 'Distributor_SFDC_Account_Id__c'
    };

    public static Map<String, String> docDetailToSalesDataFieldMap = new Map<String, String>{
        'Product_Description__c' => 'Product__c',
        'DDSKU__c' => 'JUUL_Item_Number__c'
    };

    public static Map<String, String> requiredAccountFields = new Map<String, String>{
        'Name' => 'Retailer_Name__c',
        'BillingStreet' => 'Retailer_Address_1__c',
        'BillingCountry' => 'Retailer_Country__c',
        'BillingCity' => 'Retailer_City__c',
        'BillingState' => 'Retailer_State__c',
        'BillingPostalCode' => 'Retailer_Zip_Code__c',
        'ShippingStreet' => 'Retailer_Address_1__c',
        'ShippingCountry' => 'Retailer_Country__c',
        'ShippingCity' => 'Retailer_City__c',
        'ShippingState' => 'Retailer_State__c',
        'ShippingPostalCode' => 'Retailer_Zip_Code__c',
        'Phone'=>'Retailer_Phone__c',
        'Email__c'=>'Retailer_Email__c'
    };

    public static Set<String> salesDataFields = new Set<String>{'Retailer_Name__c','Date__c','Retailer_Address_1__c','Retailer_City__c','Retailer_State__c','Retailer_Zip_Code__c','Product__c','Quantity__c','Upload_Verification__c'};
    public static Set<String> otherSalesDataFields = new Set<String>{'Retailer_Address_2__c', 'Retailer_Country__c','Retailer_Phone__c','Retailer_Email__c','Distributor_SFDC_Account_Id__c'};
    public static Set<String> DocDetailFields = new Set<String>{'Product_Description__c','JUUL_Item_Number__c'};

    public DistributorSalesUploadBatch(Map<String, String> params){
        System.debug(params);
        this.overrideQuery = '';
        this.totalSalesOrdersInserted = 0;
        this.useProductExternalIdField = false;
        this.dataFormat = params.get('selectedFormat');
        this.distributorId = params.get('distributorId');
        this.accExternalIdToSalesOrderMap = new Map<String,Map<String,Id>>();
        this.failedSOExternalIds = new Set<String>();
        this.failedAccExternalIds = new Set<String>();
        this.externalAccountIdMap = new Map<String, Id>();
        this.externalDistributorIdMap = new Map<String,Id>();
        this.totalFailedRows = 0;
        this.totalRows = 0;
        this.uploadVerification = params.get('uploadVerification');
        this.uploadDate = this.uploadVerification.split('-')[1].trim();
        this.useExistingSalesOrder = params.containsKey('useExistingSalesOrder') ? Boolean.valueOf(params.get('useExistingSalesOrder')) : false;
        this.isScheduled = params.containsKey('isScheduled') ? Boolean.valueOf(params.get('isScheduled')) : false;
        this.additionalEmail = params.containsKey('additionalEmail') ? params.get('additionalEmail') : '';
        this.userId = params.get('userId') != null ? params.get('userId') : UserInfo.getUserId();
        this.retailerExternalIdField = params.get('retailerExternalIdField');
        this.forceRetailerExternalIdMatch = params.containsKey('forceRetailerExternalIdMatch') ? Boolean.valueOf(params.get('forceRetailerExternalIdMatch')) : false;
        this.salesDataUploadQueueId = params.get('salesDataUploadQueueId');
        this.useRetailerExternalIdField = false;

        if(this.distributorId != null){
            this.distributorAccount = [SELECT Id, Name, Distributor_Abbreviation__c FROM Account WHERE Id = : this.distributorId LIMIT 1];
            if(this.distributorAccount.Distributor_Abbreviation__c==null) this.distributorAccount.Distributor_Abbreviation__c = this.distributorAccount.Name;
            this.dataFormat = this.dataFormat == null ? distributorAccount.Distributor_Abbreviation__c : this.dataFormat;
        }

        this.distributorOrderType = distributorAliasMap.get(this.dataFormat);
        
        //Distributor Portal Mapping
        if(this.isScheduled){
            this.useProductExternalIdField = true;
            this.productExternalIdField = 'Distributor_Portal_Name__c';
            this.distributorOrderType = 'CO';
        }
         if(this.dataFormat == 'IL' || this.dataFormat == 'US') {
            distributorwrapper wrapperval = getDistributor(this.dataformat);
            this.useProductExternalIdField = true;
            this.productExternalIdField = 'StockKeepingUnit';
            this.distributorOrderType = wrapperval.orderType;
        }
        if(this.retailerExternalIdField != null && this.retailerExternalIdField != '')
            this.useRetailerExternalIdField = true;

        salesDataQueryFields = new Set<String>();

        Map<String, Schema.SObjectField> salesDataFieldMap = Schema.getGlobalDescribe().get('Sales_Data__c').getDescribe().fields.getMap();
        
        for(String sObjField : salesDataFieldMap.keySet()){
            if(salesDataFieldMap.get(sObjField).getDescribe().isUpdateable())
                salesDataQueryFields.add(sObjField);
        }
        System.debug('salesDataQueryFields ********************* '+salesDataQueryFields);
        String headerRowString = String.join(new List<String>(salesDataQueryFields), ',');
        System.debug('headerRowString ******************* '+headerRowString );
        this.retryEmail = headerRowString + '\n';
        this.errorEmail = headerRowString + ',Error Message\n';
    }

    public DistributorSalesUploadBatch(){}

    public static Map<String, String> constructParamFromQueueObject(){
        List<Sales_Data_Upload_Queue__c> uploadQueueObjects = [SELECT Id, Upload_Verification__c, Distributor_Id__c, Upload_Format__c, User_Id__c FROM Sales_Data_Upload_Queue__c WHERE Is_Processed__c = false ORDER BY CreatedDate ASC LIMIT 1];

        //If we complete the queue, than mark that Communities is no longer in progress
        if(uploadQueueObjects.isEmpty()){
            Custom_Code_Configuration__c codeConfig = Custom_Code_Configuration__c.getOrgDefaults();
            codeConfig.Communities_Upload_In_Progress__c = false;
            update(codeConfig);
        }
        else{ 
            for(Sales_Data_Upload_Queue__c uploadQueueObject : uploadQueueObjects){ // Will only be looped once
                uploadQueueObject.Is_Processed__c = true;
                Map<String, String> params = new Map<String, String>();
                params.put('uploadVerification', uploadQueueObject.Upload_Verification__c);
                params.put('selectedFormat', uploadQueueObject.Upload_Format__c);
                params.put('userId', uploadQueueObject.User_Id__c);
                params.put('distributorId', uploadQueueObject.Distributor_Id__c);
                params.put('isScheduled', 'true');
                params.put('salesDataUploadQueueId', uploadQueueObject.Id);
                System.debug(params);

                update uploadQueueObjects;
                return params;
            }
        }
        return null;
    }

    public static void executeBatch(){  
        Map<String, String> params = constructParamFromQueueObject();
        if(params != null){
            DistributorSalesUploadBatch distBatch = new DistributorSalesUploadBatch(params);
            Database.executeBatch(distBatch);
        }
    }

    public static void schedule(){
        System.schedule('Distributor Sales Upload Batch', '0 12 * * * ?', new DistributorSalesUploadBatch());
    }

    public void execute(SchedulableContext sc){
        // If there's an existing batch running, we shouldn't run a new one.
        Custom_Code_Configuration__c codeConfig = Custom_Code_Configuration__c.getOrgDefaults();

        if(!codeConfig.Communities_Upload_In_Progress__c){
            codeConfig.Communities_Upload_In_Progress__c = true;
            update(codeConfig);
            executebatch();
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        System.debug('Sales Data Fields ' + salesDataQueryFields);
        String query = 'SELECT Id, ' + String.join(new List<String>(salesDataQueryFields), ',') + ' FROM Sales_Data__c WHERE Upload_Verification__c = :uploadVerification ';
        query += this.overrideQuery;
        if(this.overrideQuery == null || this.overrideQuery == '')
            query += ' ORDER BY Id ASC';
            
        System.debug(query);
        return Database.getQueryLocator(query); 
    }

    public void execute(Database.BatchableContext ctx, List<Sales_Data__c> salesBatchData) {
        List<salesOrder__c> newSalesOrders = new List<salesOrder__c>();       
        List<Document_Details__c> documentDetailsToUpsert = new List<Document_Details__c>();
        Map<String,Map<String,salesOrder__c>> salesOrderMap = new Map<String,Map<String,salesOrder__c>>();
        Map<String,List<Document_Details__c>> salesOrderToDocDetailMap = new Map<String,List<Document_Details__c>>();
        Map<String,List<Integer>> salesOrderToIndexMap = new Map<String,List<Integer>>();
        Map<String,Account> externalAccountMap = new Map<String,Account>();
        List<Map<String, Object>> dataMaps = new List<Map<String, Object>>();
        Map<String,Product2> productsMap = new Map<String,Product2>();
        /* ******************
        * Pre-Processing, figuring out existing accounts
        * ******************/

        // If we decide to use Retailer_External_Id__c for checking existing retailer accounts, we query the accounts with the external retailer ids and add them to externalAccountIdMap
        Set<String> retailerExternalIds = new Set<String>();
        Set<String> retailerSFDCIds = new Set<String>();  //Added by Mahesh on 08/14/2019
        if(useRetailerExternalIdField != null && useRetailerExternalIdField){
            for(Sales_Data__c salesData : salesBatchData ){
                if(salesData.Retailer_External_Id__c != null && salesData.Retailer_External_Id__c != '') {                  
                        retailerExternalIds.add(salesData.Retailer_External_Id__c);
                }
                if((this.dataFormat == 'IL' || this.dataFormat == 'US') && salesData.Retailer_SFDC_Account_Id__c !=null && salesData.Retailer_SFDC_Account_Id__c != '') {
                    retailerSFDCIds.add(salesData.Retailer_SFDC_Account_Id__c);
                }
            }

             if(this.dataFormat != 'IL' && this.dataFormat != 'US') {
                    for(Account a : Database.query('SELECT Id, ' + retailerExternalIdField + ' FROM Account WHERE ' + retailerExternalIdField + ' != null AND ' + retailerExternalIdField + ' IN : retailerExternalIds AND isDeleted = false')){
                        externalAccountIdMap.put((String) a.get(retailerExternalIdField), a.Id);
                    }
                }else {
                    for(string strAccId : retailerSFDCIds) {
                        externalAccountIdMap.put(strAccId,strAccId);
                    }
                }
        }
        
        System.debug('External Account Id Map : ' + externalAccountIdMap);

        /* ******************
        * Pre-Processing, figuring out product mappings
        * ******************/
        Set<String> productExternalIds = new Set<String>();
        if(useProductExternalIdField != null && useProductExternalIdField){
            for(Sales_Data__c salesData : salesBatchData ){
                if(salesData.Product__c != null && salesData.Product__c != '')
                    productExternalIds.add(salesData.Product__c);
            }

            for(Product2 p : Database.query('SELECT Id, CurrencyIsoCode, Description, ' + productExternalIdField + ' FROM Product2 WHERE ' + productExternalIdField + ' != null AND ' + productExternalIdField + ' IN : productExternalIds')){
                productsMap.put((String) p.get(productExternalIdField), p);
            }
        }
        
        System.debug('External Product Id Map : ' + productsMap);


        /* ******************
        * Account Creation & Update
        * ******************/

        Map<String, Account> accountsToInsertMap = new Map<String, Account>();
        Map<String, List<Integer>> accountInverseIndexMap = new Map<String, List<Integer>>();
        Map<String, List<Integer>> accountExtIdToSalesDataIdxMap = new Map<String, List<Integer>>();
        Map<Id, Date> salesDateMap = new Map<Id, Date>();

        for(Integer i=0;i<salesBatchData.size();i++ ){
            Sales_Data__c salesData = salesBatchData[i];
            // salesData.Date__c should be in MM/DD/YYYY format
            List<String> dateStrings = salesData.Date__c.split('/');
            Integer year = dateStrings[2].length() == 2 ? Integer.valueOf('20'+dateStrings[2]) : Integer.valueOf(dateStrings[2]);
            Date salesDate = Date.newInstance(year, Integer.valueOf(dateStrings[0]), Integer.valueOf(dateStrings[1]));
            //Date salesDate = Date.newInstance(Integer.valueOf(dateStrings[2]), Integer.valueOf(dateStrings[0]), Integer.valueOf(dateStrings[1]));
            salesDateMap.put(salesData.Id, salesDate);
            /* ******************
            * Construct Data Map from Sales Data
            * ******************/
            Map<String, Object> dataMap = new Map<String, Object>{'salesData' => salesData};

            // Add Ext Id fields
             if(distributorOrderType == 'IL' || distributorOrderType == 'US') {
                dataMap.put('AccExternalId', salesData.Retailer_SFDC_Account_Id__c);
            }else if(useRetailerExternalIdField){
                dataMap.put('AccExternalId', salesData.Retailer_External_Id__c);
            } else {
                dataMap.put('AccExternalId', salesData.Retailer_Name__c.trim().toLowerCase() + salesData.Retailer_Address_1__c.trim().toLowerCase());
            }
           
            dataMap.put('SOExternalId', dataMap.get('AccExternalId') + String.valueOf(salesDate));
            if(distributorOrderType == 'IS' || distributorOrderType == 'IL' || distributorOrderType == 'US'){
                dataMap.put('SOExternalId', dataMap.get('SOExternalId') + salesData.Distributor_SFDC_Account_Id__c.trim());
            } 

            // Add Retry String, so we can use it quickly later.
            String retryString = '';
            String delimiter = ',';

            for(String field : salesDataQueryFields){ //Put all Sales Data Fields into the CSV
                String colVal = String.valueOf(salesData.get(field));
                if(String.isEmpty(colVal))
                    colVal = '';
                retryString += (colVal).escapeCSV() + delimiter;
            }

            retryString = retryString.removeEnd(delimiter);
            dataMap.put('retryString', retryString);

            //Generate Account
            Account generatedAccount = new Account();
            if(!externalAccountIdMap.containsKey((String) dataMap.get('AccExternalId'))){
                for(String accountField : requiredAccountFields.keySet()){
                    generatedAccount.put(accountField, (String)salesData.get(requiredAccountFields.get(accountField)));
                }

                if(useRetailerExternalIdField){
                    generatedAccount.put(retailerExternalIdField,salesData.Retailer_External_Id__c);
                }
                generatedAccount.RecordTypeId = DistributorSalesUploadBatch.accountRecordTypeMap.get('Unprocessed');

                generatedAccount.Created_By_Distributor_Portal__c = true;
                generatedAccount.Created_By_Portal_User__c = userId;
                if(salesData.Retailer_SFDC_Account_Id__c != null){
                    generatedAccount.Id = salesData.Retailer_SFDC_Account_Id__c;
                }

                dataMap.put('account', generatedAccount);
            }

            String accExternalId = (String) dataMap.get('AccExternalId');
            String soExternalId = (String) dataMap.get('SOExternalId');
            //System.debug(dataMap);

            // System.debug('Failed Acc IDs' + failedAccExternalIds);
            // System.debug('Failed SO Ids ' + failedSOExternalIds);
            if(!externalAccountIdMap.containsKey(accExternalId) && forceRetailerExternalIdMatch){//If we're forcing Account Match, don't add to inverse maps
                System.debug('Did not find Account Match, do not generate Account.');
                dataMaps.add(dataMap);
            }
            else if(failedAccExternalIds.contains(accExternalId)){// If current Account External has failed before, don't create failed Account, add to retry email
                System.debug('Prior Account Failure.');
                retryEmail += (String)dataMap.get('retryString') + '\n';
            } else if(failedSOExternalIds.contains(soExternalId)){ // If current Upload Id Sales Order has failed before, don't create failed Sales Order, add to retry email
                System.debug('Prior Sales Order Failure.');
                retryEmail += (String)dataMap.get('retryString') + '\n';
            } else {
                if(!accountInverseIndexMap.containsKey(accExternalId))
                    accountInverseIndexMap.put(accExternalId, new List<Integer>());
                accountInverseIndexMap.get(accExternalId).add(dataMaps.size());

                dataMaps.add(dataMap);
                // If the accExternalId doesn't exist in externalAccountIdMap, create account
                if(generatedAccount != null && !externalAccountIdMap.containsKey(accExternalId)){
                    accountsToInsertMap.put(accExternalId, generatedAccount);
                    if(!accountExtIdToSalesDataIdxMap.containsKey(accExternalId)){
                        accountExtIdToSalesDataIdxMap.put(accExternalId, new List<Integer>());
                    }
                    accountExtIdToSalesDataIdxMap.get(accExternalId).add(i);
                }
            }
        }

        List<Account> accountToInsert = accountsToInsertMap.values();
        System.debug(accountToInsert);
        if(!accountToInsert.isEmpty()){
            List<Database.UpsertResult> accUpsertResults = Database.upsert(accountToInsert, false);
            for(Integer i=0; i<accUpsertResults.size(); i++){
                Database.UpsertResult upsertResult = accUpsertResults[i];
                if (!upsertResult.isSuccess()){
                    String accExternalId;
                    if(!useRetailerExternalIdField)
                        accExternalId = accountToInsert[i].Name.trim().toLowerCase() + accountToInsert[i].BillingStreet.trim().toLowerCase();
                    else {
                        accExternalId = (String)accountToInsert[i].get(retailerExternalIdField);
                    }
                    totalFailedRows++;
                    String errorMessage = ((String) upsertResult.getErrors().get(0).getMessage()).unescapeHtml4();
                    // Add all rows under the current accExternalId that has failed to error and retry email
                    for(Integer dataMapIndex : accountInverseIndexMap.get(accExternalId)){
                        String SOExternalId = (String)dataMaps[dataMapIndex].get('SOExternalId');
                        failedSOExternalIds.add(SOExternalId);
                        failedAccExternalIds.add(accExternalId);
                        retryEmail += (String)dataMaps[dataMapIndex].get('retryString') + '\n';
                        errorEmail += generateCsvBodyOneRow((String)dataMaps[dataMapIndex].get('retryString'), '[Account Insertion]\n' + errorMessage) + '\n';
                    }
                    if(accountExtIdToSalesDataIdxMap.get(accExternalId) != null){
                        errorMessage = errorMessage.length() > 255 ? errorMessage.substring(0, 255) : errorMessage;
                        for(Integer idx : accountExtIdToSalesDataIdxMap.get(accExternalId)){
                            salesBatchData[i].Error_Details__c = errorMessage;
                        }
                    }
                }
            }
        }

        // Populate externalAccountIdMap
        for(String accExternalId : accountsToInsertMap.keySet()){
            externalAccountIdMap.put(accExternalId, accountsToInsertMap.get(accExternalId).Id);
        } 

        System.debug(externalAccountIdMap);
        System.debug(externalDistributorIdMap);

        /* ******************
        * Sales Order Creation
        * ******************/

        // AccExternal + sales order date to data maps index map, used for error csv handling
        Map<String, List<Integer>> salesOrderInverseIndexMap = new Map<String, List<Integer>>();
        
        //Create New Sales Orders
        for(Integer i=0; i<dataMaps.size(); i++){
            System.debug(dataMaps[i]);
            String accExternalId = (String)dataMaps[i].get('AccExternalId');
            if(failedAccExternalIds.contains(accExternalId))
                continue;
            String SOExternalId = (String)dataMaps[i].get('SOExternalId');
            Sales_Data__c salesData = (Sales_Data__c)dataMaps[i].get('salesData');
            Date salesDate = salesDateMap.get(salesData.Id);

            if(!accExternalIdToSalesOrderMap.containsKey(accExternalId)){
                accExternalIdToSalesOrderMap.put(accExternalId, new Map<String,Id>());
            }
            if(!salesOrderMap.containsKey(accExternalId)){ 
                salesOrderMap.put(accExternalId, new Map<String,SalesOrder__c>());
            }

            System.debug('External Acc Id ' + accExternalId);
            System.debug(accExternalIdToSalesOrderMap.get(accExternalId).keySet());

            System.debug(salesOrderMap.get(accExternalId));
            if(forceRetailerExternalIdMatch && !externalAccountIdMap.containsKey(accExternalId)){ //If we are forcing an external Account Id match, skip this SO and log an error
                System.debug('No Account Match');
                totalFailedRows++;
                failedSOExternalIds.add(SOExternalId);
                retryEmail += (String)dataMaps[i].get('retryString') + '\n';
                errorEmail += generateCsvBodyOneRow((String)dataMaps[i].get('retryString'), 'Matched Account by External Id not Found.');
            } // If sales order doesn't exist in both the global accExternalIdToSalesOrderMap and the local salesOrderMap, we create new sales order
            else if(!accExternalIdToSalesOrderMap.get(accExternalId).containsKey(SOExternalId) && !salesOrderMap.get(accExternalId).containsKey(SOExternalId)){
                SalesOrder__c newSalesOrder = new SalesOrder__c(customer__c = externalAccountIdMap.get(accExternalId), Date__c = String.valueOf(salesDate), Created_By_Portal_User__c=userId);
                //System.debug('SO DATE ' + newSalesOrder.Date__c);
                newSalesOrder.OrderType__c = distributorOrderType;
                salesOrderMap.get(accExternalId).put(SOExternalId, newSalesOrder);
                newSalesOrders.add(newSalesOrder);
                //Set Fields on Sales Order
                for(String soField : salesOrderFieldToSalesDataFieldMap.keySet()){
                    String salesDataField = salesOrderFieldToSalesDataFieldMap.get(soField);
                    if(salesData.get(salesDataField) != null) 
                        newSalesOrder.put(soField, salesData.get(salesDataField));
                }
                if(distributorAccount != null)
                    newSalesOrder.Distributor__c = distributorAccount.Id;

                //Acumatica Fields
                if(dataFormat == 'Acumatica'){
                    //Copy over Acumatica Specific Fields
                    newSalesOrder.Name = salesData.Sales_Order_Name__c;
                    newSalesOrder.orderTotal__c = salesData.Custom_Field_1__c != null ? Decimal.ValueOf(salesData.Custom_Field_1__c.replaceAll('[^.\\d]','')) : null;
                    newSalesOrder.Payment_Method__c = salesData.Custom_Field_2__c;
                    newSalesOrder.Days_Since_Previous_Order__c = salesData.Custom_Field_3__c != null ? Integer.ValueOf(salesData.Custom_Field_3__c.replaceAll('[^.\\d]','')) : null;
                    newSalesOrder.Customer_PO_Number__c = salesData.Custom_Field_4__c;
                    newSalesOrder.AcumaticaId__c = salesData.Custom_Field_5__c;                  
                }
                
                //  Assign Currency Code and Order Type values to sales order record
                distributorwrapper wrapperval = getDistributor(dataformat);                
                newSalesOrder.CurrencyIsoCode = wrapperval.currencyCode;
                newSalesOrder.orderType__c = wrapperval.orderType;
                
                newSalesOrder.Upload_Verification__c = uploadVerification;
                System.debug(salesData);
                System.debug(newSalesOrder);
                salesOrderInverseIndexMap.put(newSalesOrder.customer__c + String.valueOf(salesDate), new List<Integer>{i});
            // If sales order exists already, we record the index
            } else {
                String salesOrderKey = externalAccountIdMap.get(accExternalId) + String.valueOf(salesDate);
                System.debug(salesOrderInverseIndexMap.get(salesOrderKey));
                
                if(!salesOrderInverseIndexMap.containsKey(salesOrderKey))
                    salesOrderInverseIndexMap.put(salesOrderKey, new List<Integer>{i});
                else
                    salesOrderInverseIndexMap.get(salesOrderKey).add(i);
            }
        }
        System.debug(newSalesOrders);
        //System.debug('New Sales Orders' + newSalesOrders);
        List<Database.SaveResult> soSaveResults = Database.insert(newSalesOrders, false);
        for(Integer i=0; i<soSaveResults.size(); i++){
            Database.SaveResult saveResult = soSaveResults[i];
            if (!saveResult.isSuccess()){
                String salesOrderKey = newSalesOrders[i].customer__c + newSalesOrders[i].Date__c;
                totalFailedRows++;
                // Gather all related failed rows and add to error and retry csv
                for(Integer dataMapIndex : salesOrderInverseIndexMap.get(salesOrderKey)){
                    Sales_Data__c salesData = (Sales_Data__c)dataMaps[dataMapIndex].get('salesData');
                    String SOExternalId = (String)dataMaps[dataMapIndex].get('SOExternalId');
                    String errorMessage = ((String) saveResult.getErrors().get(0).getMessage()).unescapeHtml4();
                    failedSOExternalIds.add(SOExternalId);
                    retryEmail += (String)dataMaps[dataMapIndex].get('retryString') + '\n';
                    errorEmail += generateCsvBodyOneRow((String)dataMaps[dataMapIndex].get('retryString'), '[Sales Order Insertion]\n' + errorMessage) + '\n';
                    salesData.Error_Details__c = errorMessage.length() > 255 ? errorMessage.substring(0, 255) : errorMessage;
                }
            }
        }
        totalSalesOrdersInserted += newSalesOrders.size();

        // Populate accExternalIdToSalesOrderMap with the newly inserted Sales Orders
        for(String accExternalId : salesOrderMap.keySet()){
            for(String SOExternalId : salesOrderMap.get(accExternalId).keySet()){
                if(!accExternalIdToSalesOrderMap.get(accExternalId).containsKey(SOExternalId) && salesOrderMap.get(accExternalId).get(SOExternalId).Id != null)
                    accExternalIdToSalesOrderMap.get(accExternalId).put(SOExternalId, salesOrderMap.get(accExternalId).get(SOExternalId).Id);
            }
        }

        /* ******************
        * Document Detail Creation
        * ******************/

        Map<String, Document_Details__c> existingDocDetails = new Map<String, Document_Details__c>();

        // Create new Document Details
        for(Integer i=0; i<dataMaps.size(); i++){
            String accExternalId = (String)dataMaps[i].get('AccExternalId');
            
            if(failedAccExternalIds.contains(accExternalId))
                continue;
            String SOExternalId = (String)dataMaps[i].get('SOExternalId');
            Sales_Data__c salesData = (Sales_Data__c)dataMaps[i].get('salesData');
            String deltaRow = salesData.Delta_Row__c;
            Date salesDate = salesDateMap.get(salesData.Id);

            String docDetailExternalId = SOExternalId + salesData.Product__c.trim().toLowerCase();
            // The sales order was not created, we already added to error email, skip creating Doc Detail
            if(!accExternalIdToSalesOrderMap.get(accExternalId).containsKey(SOExternalId))
                continue;

            if(!salesOrderToDocDetailMap.containsKey(SOExternalId)){
                salesOrderToDocDetailMap.put(SOExternalId, new List<Document_Details__c>());
            }
            if(!salesOrderToIndexMap.containsKey(SOExternalId)){
                salesOrderToIndexMap.put(SOExternalId, new List<Integer>());
            }
            Document_Details__c documentDetailToUpsert;
            if(!existingDocDetails.containsKey(docDetailExternalId) || deltaRow != 'C'){
                documentDetailToUpsert = new Document_Details__c();
                documentDetailToUpsert.Sales_Data__c = salesData.Id;
                documentDetailToUpsert.SalesOrderNumber__c = accExternalIdToSalesOrderMap.get((String)dataMaps[i].get('AccExternalId')).get(SOExternalId); // use accExternalIdToSalesOrderMap, because the SO might be from previous batch slice
                documentDetailToUpsert.Quantity__c = Integer.valueOf(Decimal.valueOf(salesData.Quantity__c.replaceAll('[^-.\\d]','')));
                 documentDetailToUpsert.Total_Price__c = salesData.DD_Total_Price__c != null ? Integer.valueOf(Decimal.valueOf(salesData.DD_Total_Price__c.replaceAll('[^-.\\d]',''))) : null; //Integer.valueOf(Decimal.valueOf(salesData.DD_Total_Price__c.replaceAll('[^-.\\d]',''))) : null;
                for(String ddfield : docDetailToSalesDataFieldMap.keySet()){
                    String salesDataField = docDetailToSalesDataFieldMap.get(ddfield);
                    if(salesData.get(salesDataField) != null)
                        documentDetailToUpsert.put(ddfield, salesData.get(salesDataField));
                }
                try{
                    if(useProductExternalIdField != null && useProductExternalIdField){
                        if(productsMap.get(salesData.Product__c) != null) {
                           documentDetailToUpsert.Product__c = productsMap.get(salesData.Product__c).Id;
                           if(dataFormat == 'IL' || dataFormat == 'US') {
                              documentDetailToUpsert.Product_Description__c = productsMap.get(salesData.Product__c).Description;
                              documentDetailToUpsert.CurrencyIsoCode = productsMap.get(salesData.Product__c).CurrencyIsoCode;
                              }
                        }

                    }
                }catch(exception e){}
                System.debug(documentDetailToUpsert);
                try{
                    if(isScheduled && documentDetailToUpsert.Product__c == null)
                        documentDetailToUpsert.Product__c = salesData.Product__c;
                }catch(exception e){}
                
                //Acumatica Fields
                if(dataFormat == 'Acumatica'){
                    //Copy over Acumatica Specific Fields
                    documentDetailToUpsert.DDSKU__c = salesData.JUUL_Item_Number__c;
                    documentDetailToUpsert.AcumaticaId__c = salesData.Custom_Field_6__c;                
                    documentDetailToUpsert.Unique_Id__c = salesData.Custom_Field_7__c;  
                }
                if(dataFormat == 'IL' || dataFormat == 'US') {
                    documentDetailToUpsert.DDSKU__c = salesData.Product__c;
                }
                documentDetailToUpsert.Upload_Verification__c = uploadVerification;
            } else {
                documentDetailToUpsert = existingDocDetails.get(docDetailExternalId);
                documentDetailToUpsert.Quantity__c = Integer.valueOf(Decimal.valueOf(salesData.Quantity__c));
            }

            documentDetailsToUpsert.add(documentDetailToUpsert);
            salesOrderToDocDetailMap.get(SOExternalId).add(documentDetailToUpsert);
            salesOrderToIndexMap.get(SOExternalId).add(i);
        }

        List<Database.UpsertResult> upsertResults = Database.upsert(documentDetailsToUpsert, false);

        totalRows += documentDetailsToUpsert.size();
        Set<SalesOrder__c> salesOrderToDelete = new Set<SalesOrder__c>();
        Set<Document_Details__c> docDetailToDeleteSet = new Set<Document_Details__c>();
        for(Integer i=0; i<upsertResults.size(); i++){
            Database.UpsertResult upsertResult = upsertResults[i];
            if (!upsertResult.isSuccess()){
                // Do special delete logic for Distributor Portal mode
                if(distributorOrderType == 'UD' || distributorOrderType == 'UPD' || distributorOrderType == 'CO'){
                    String SOExternalId = (String)dataMaps[i].get('SOExternalId');
                    salesOrderToDelete.add(new SalesOrder__c(Id=documentDetailsToUpsert[i].SalesOrderNumber__c));
                    if(!failedSOExternalIds.contains(SOExternalId)){
                        docDetailToDeleteSet.addAll(salesOrderToDocDetailMap.get(SOExternalId));
                        // Gather all salesBatchData indexes under the current SOExternalId and add those rows to retryEmail
                        for(Integer idx : salesOrderToIndexMap.get(SOExternalId))
                            retryEmail += (String)dataMaps[idx].get('retryString') + '\n';
                    }
                    failedSOExternalIds.add(SOExternalId);
                }
                totalFailedRows++;


                Sales_Data__c salesData = (Sales_Data__c)dataMaps[i].get('salesData');
                String errorMessage = ((String) upsertResult.getErrors().get(0).getMessage()).unescapeHtml4();
                // construct error CSV (Will only show the failed rows)
                errorEmail += generateCsvBodyOneRow((String)dataMaps[i].get('retryString'), '[Document Detail Insertion]\n' + errorMessage) + '\n';
                salesData.Error_Details__c = errorMessage.length() > 255 ? errorMessage.substring(0, 255) : errorMessage;
            }
        }
        
        /********************
        * Update Sales Data to Processed
        *) ******************/
        for(Sales_Data__c salesData : salesBatchData)
            salesData.Is_Processed__c = true;

        update(salesBatchData);

        /* ******************
        * Delete records that are related to failed ones, since retry csv will include them
        * ******************/

        // Remove doc details without Id, those are the ones that failed to insert, so we don't need to delete them
        List<Document_Details__c> docDetailToDelete = new List<Document_Details__c>(docDetailToDeleteSet);
        for(Integer i=0; i<docDetailToDelete.size(); i++){
            Document_Details__c doc = docDetailToDelete[i];
            if(doc.Id == null)
                docDetailToDelete.remove(i);
        }

        //delete(salesBatchData);
        delete(docDetailToDelete);
        delete(new List<SalesOrder__c>(salesOrderToDelete));
    }

    public static String generateCsvBodyOneRow(String retryString, String additionalCol){
        String csvBody = retryString;
        if(additionalCol != null)
            csvBody += ',' + additionalCol.escapeCsv();
        else
            csvBody = csvBody.removeEnd(',');
        csvBody += '\r';
        return csvBody;
    }
    
    public static Map<String,Id> accountRecordTypeMap{
        get{
            if(accountRecordTypeMap==null){
                accountRecordTypeMap = new Map<String,Id>();

                for(RecordType rType : [SELECT id, Name FROM RecordType WHERE sObjectType = 'Account'])
                    accountRecordTypeMap.put(rType.Name, rType.Id);
                System.debug('RUN QUERY');
            }
            return accountRecordTypeMap;
        }
        set{

        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug(totalFailedRows);
        System.debug(isScheduled);
        // Build and Send CSV Emails
        Custom_Code_Configuration__c customCon = Custom_Code_Configuration__c.getInstance();
        System.debug(customCon);
        List<String> errorEmailAddressee = (customCon != null && customCon.Distributor_Upload_Emails__c!=null)? customCon.Distributor_Upload_Emails__c.split(',') : null;

        String emailBodyInternal = constructInternalEmailBody(true, totalFailedRows, totalRows, dataFormat, uploadDate, externalAccountIdMap.size(), totalSalesOrdersInserted, failedSOExternalIds.size(), uploadVerification);
        String emailBodyCustomer = constructCustomerEmailBody(totalRows, uploadDate, externalAccountIdMap.size(), totalSalesOrdersInserted);
        String emailSubjectCustomer = 'Sales Data Upload Complete';

        //try{

        if(isScheduled){
            List<User> u = [SELECT Id, Email FROM User WHERE Id = :userId];
            System.debug('Community User ' + u);
            sendEmail(new List<String>{u[0].Email}, emailBodyCustomer, emailSubjectCustomer, new Map<String, String>(), additionalEmail);
        }

        if(totalFailedRows == 0){
            String emailSubject = 'Sales Uploader Complete : ' + dataFormat + ' - ' + uploadDate;
            sendEmail(errorEmailAddressee, emailBodyInternal, emailSubject, new Map<String, String>(), additionalEmail);
        } else {
            String emailSubject = 'Sales Uploader Complete with Errors : ' + dataFormat + ' - ' + uploadDate;
            sendEmail(errorEmailAddressee, emailBodyInternal, emailSubject, new Map<String, String>{'SalesDataUploadBatchErrors.csv' => errorEmail, 'SalesDataUploadBatchRetry.csv' => retryEmail}, additionalEmail);
        }
        //} catch(exception e){
        //    System.debug(e);
        //}
        // Schedule next sales upload queue object batch
        if(isScheduled){
            Sales_Data_Upload_Queue__c queueObj = new Sales_Data_Upload_Queue__c(Id=salesDataUploadQueueId, Total_Error_Rows__c = totalFailedRows);
            System.debug(queueObj);
            update(queueObj);
            
            if(singleRunOnly == null || singleRunOnly != true)
                executebatch();
        }
    }

    public static String constructCustomerEmailBody(Integer totalRows, String uploadDate, Integer uniqueAccounts, Integer totalSO){
        String bodyString = '';
        bodyString += '<div>';
        bodyString +=     '<p>Thank you for using JUUL Salesforce Community. We appreciate your partnership in growing JUUL to improve the lives of the world\'s one billion adult smokers.  In order to accomplish this goal we need clean and accurate data from our partners to advise us on future programs.</p>';
        bodyString +=     '<p>Your upload was completed on ' + uploadDate + ' and includes ' + totalSO + ' sales orders, ' + totalRows + ' line items on ' + uniqueAccounts + ' unique stores.</p>';
        bodyString +=     '<p>We are reviewing the data for any errors, and everything will be fully uploaded within 24 hours.</p>';
        bodyString +=     '<p>Thank you!</p>';
        bodyString +=     '<p>-JUUL Sales</p>';
        bodyString += '</div>';
        return bodyString;
    }

    public static String constructInternalEmailBody(Boolean hasCSV, Integer totalFailedRows, Integer totalRows, String dataFormat, String uploadDate, Integer uniqueAccounts, Integer totalSO, Integer totalFailedSO, String uploadVerification){
        Boolean hasError = (totalFailedRows > 0);
        String bodyString = '';
        bodyString += '<div>';
        bodyString +=      '<ul>';
        bodyString +=          '<li>Upload completed' + (hasError ? ' (with Errors)' : '') + ' for ' + dataFormat + ' Format on ' + uploadDate + '.</li>';
        bodyString +=          '<li>Upload Verification Value : ' + uploadVerification + '.</li>';
        bodyString +=          '<li>Total Unique Accounts : ' + uniqueAccounts + '</li>';
        bodyString +=          '<li>Total Sales Orders : ' + totalSO + '</li>';
        bodyString +=          '<li>Total Document Details : ' + totalRows + '</li>';
        if(hasError){
            bodyString +=          '<li>Total Sales Orders with Errors : ' + totalFailedSO + '</li>';
            if(hasCSV){
                bodyString +=          '<li>The Errored Rows have been attached to the email below. The first CSV will show you the rows with errors. Fix these errors in the second CSV and re-upload. </li>';
                bodyString +=          '<li>Note : If a Sales Order has a single row with an error, the entire Sales Order is skipped. This is why you will usually find more rows in the "Retry" CSV over the "Error" CSV.</li>';
            } else {
                bodyString +=          '<li>Please reach out to JUUL for help</li>';
            }
        }
        bodyString +=      '</ul>';
        bodyString +=  '</div>';
        return bodyString;
    }

    public static void sendEmail( List<String> addressList,
                                  String emailText,
                                  String emailSubject,
                                  Map<String, String> attachmentMap,
                                  String additionalEmail){
        
        if(addressList == null ) return;
        try{
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            if(!String.isEmpty(additionalEmail)){
                addressList.add(additionalEmail);
            }
            singleEmail.setSenderDisplayName('JUUL Upload Notification');
            singleEmail.setToAddresses(addressList);
            singleEmail.setSubject(emailSubject);
            singleEmail.setHtmlBody(emailText);
            if (attachmentMap != null){
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                for(String fileName : attachmentMap.keySet()){
                    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                    Blob csvBlob = Blob.valueOf(attachmentMap.get(fileName));
                    csvAttc.setFileName(fileName);
                    csvAttc.setBody(csvBlob);
                    attachments.add(csvAttc);
                }
                singleEmail.setFileAttachments(attachments);
            }
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmail });  
        } catch(exception e){}
    }
    
     // Query Custom Metadata to store Currency Code and Order Type values based on the Data Format selection(IL & US Fields)
    public static distributorwrapper getDistributor(String dataformat)
    {
        distributorwrapper wrapper = new distributorwrapper();
        Map<String,String> currencyCode = new Map<String,String>();
        Map<String,String> orderType = new Map<String,String>();
        List<Distributor_Sale__mdt> distributorsaleslst = [SELECT label, Order_Type__c ,Currency__c FROM Distributor_Sale__mdt];
        for(Distributor_Sale__mdt metadata: distributorsaleslst)
        {
            currencyCode.put(metadata.label, metadata.Currency__c);
            orderType.put(metadata.label, metadata.Order_Type__c);
            //IL & US Fields
            if(currencyCode.containsKey(dataFormat)){                
                wrapper.currencyCode = currencyCode.get(dataformat);
                wrapper.orderType = orderType.get(dataformat); 
            }      
        }       
        return wrapper;
    }
    public class distributorwrapper
    {
        public string currencyCode{get;set;}
        public string orderType{get;set;}       
    }
}