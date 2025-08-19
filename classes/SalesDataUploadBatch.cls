public with sharing class SalesDataUploadBatch implements Database.Batchable<sObject>, Database.Stateful {
    //Inbound Params
    public String userId;
    public String overrideQuery;
    public String uploadVerification;
    public String dataFormat; //Format of the Data i.e. UPD, P & K
    public String currencyFormat;
    //Results

    //Tracking
    public Set<String> failedSalesOrders;
    public Set<String> salesDataQueryFields;

    public static Map<String, String> accountCreationFields = new Map<String, String>{
        'Name' => 'Retailer_Name__c',
        'BillingStreet' => 'Retailer_Address_1__c',
        'BillingCity' => 'Retailer_City__c',
        'BillingState' => 'Retailer_State__c',
        'BillingPostalCode' => 'Retailer_Zip_Code__c',
        'ShippingStreet' => 'Retailer_Address_1__c',
        'ShippingCity' => 'Retailer_City__c',
        'ShippingState' => 'Retailer_State__c',
        'ShippingPostalCode' => 'Retailer_Zip_Code__c',
        'Phone'=>'Retailer_Phone__c',
        'Email__c'=>'Retailer_Email__c'
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
        'SOShipping_Zip__c' => 'Retailer_Zip_Code__c',
        'MSA_Sales_Order_External_ID__c' => 'MSA_Sales_Order_External_ID__c'
    };

    public static Map<String, String> docDetailToSalesDataFieldMap = new Map<String, String>{
        'MSA_Item_Number__c' => 'MSA_Item_Number__c',
        'DDSKU__c' => 'JUUL_Item_Number__c',
        'MSA_Shipment_Line_External_ID__c' => 'MSA_Shipment_Line_External_ID__c'
    };

    public SalesDataUploadBatch(Map<String, String> params){
        //Inbound Parameters
        this.overrideQuery = '';
        this.dataFormat = params.get('selectedFormat');
        this.uploadVerification = params.get('uploadVerification');
        this.userId = UserInfo.getUserId();
        this.currencyFormat = params.get('currencyFormat') != null ? params.get('currencyFormat') : 'USD';
        salesDataQueryFields = new Set<String>();

        Map<String, Schema.SObjectField> salesDataFieldMap = Schema.getGlobalDescribe().get('Sales_Data__c').getDescribe().fields.getMap();
        
        for(String sObjField : salesDataFieldMap.keySet()){
            if(salesDataFieldMap.get(sObjField).getDescribe().isUpdateable())
                salesDataQueryFields.add(sObjField);
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
        if(dataFormat == 'MSA'){
          Long startTime = DateTime.now().getTime();
          System.debug('Start Time' + startTime);
          Map<String,List<Document_Details__c>> salesOrderToDocDetailMap = new Map<String,List<Document_Details__c>>();
          
          //Maps
          Map<String, Id> externalRetailerIdMap = new Map<String, Id>();
          Map<String, Id> externalRetailerTDLinxIdMap = new Map<String, Id>();
          Map<String, Id> externalDistributorIdMap = new Map<String, Id>();
          Map<String, Product2> productsMap = new Map<String, Product2>();
          Map<String,SalesOrder__c> salesOrderMap = new Map<String,SalesOrder__c>();
          Map<String,SalesOrder__c> salesOrderTDLinxMap = new Map<String,SalesOrder__c>();
          Map<String,Document_Details__c> docDetailsMap = new Map<String,Document_Details__c>();

          //Sets
          Set<String> msaDistributorIds = new Set<String>();
          Set<String> msaRetailerIds = new Set<String>();
          Set<String> msaTDLinxIds = new Set<String>();
          Set<String> msaProductIds = new Set<String>();
          Set<Date> msaDates = new Set<Date>();
        
          //Gather Distributor Ids, Retailer Ids
          for(Sales_Data__c salesData : salesBatchData){
            if(salesData.Distributor_External_Id__c != null)
              msaDistributorIds.add(salesData.Distributor_External_Id__c);
            
            if(salesData.Retailer_External_Id__c != null)
              msaRetailerIds.add(salesData.Retailer_External_Id__c);
            
            if(salesData.Retailer_TDLinx_Id__c != null)
              msaTDLinxIds.add(salesData.Retailer_TDLinx_Id__c);

            if(salesData.Date__c != null)
              msaDates.add(Date.Parse(salesData.Date__c));

            if(salesData.Product__c != null)  
              msaProductIds.add(salesData.Product__c);    
          }

          System.debug(msaDistributorIds);
          System.debug(msaTDLinxIds);
          System.debug(msaRetailerIds);
          System.debug(msaDates);

          //Find Products
          for(Product2 msaProduct : [SELECT Id, MSA_Item_Id__c, Name, ProductCode FROM product2 WHERE MSA_Item_Id__c IN : msaProductIds]){
            productsMap.put(msaProduct.MSA_Item_Id__c, msaProduct);
          }

          System.debug('Post Product Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          //Find Distributors
          for(Account msaAccount : [SELECT id, MSA_Distributor_Id__c, MSA_Retail_Number__c FROM Account WHERE MSA_Distributor_Id__c != null AND MSA_Distributor_Id__c IN : msaDistributorIds ORDER BY CreatedDate]){
            if(msaAccount.MSA_Distributor_Id__c != null)
              externalDistributorIdMap.put(msaAccount.MSA_Distributor_Id__c, msaAccount.Id);
          }

          System.debug('Post Distributor Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          //System.debug(externalDistributorIdMap);

          //Find Retailers
          for(Account msaAccount : [SELECT id, MSA_Distributor_Id__c, MSA_Retail_Number__c FROM Account WHERE MSA_Retail_Number__c != null AND MSA_Retail_Number__c IN : msaRetailerIds ORDER BY CreatedDate]){
            if(msaAccount.MSA_Retail_Number__c != null)
              externalRetailerIdMap.put(msaAccount.MSA_Retail_Number__c, msaAccount.Id);
          }

          System.debug('Post Retailer Search : ' + (DateTime.now().getTime() - startTime) );
          //System.debug(externalRetailerIdMap);

          //Find Retailers by TD Linx ID
          for(Account msaAccount : [SELECT id, TDLinx_ID__c FROM Account WHERE TDLinx_ID__c != null AND TDLinx_ID__c IN : msaTDLinxIds ORDER BY CreatedDate]){
            if(msaAccount.TDLinx_ID__c != null)
              externalRetailerTDLinxIdMap.put(msaAccount.TDLinx_ID__c, msaAccount.Id);
          }

          System.debug('Post TD Linx Search : ' + (DateTime.now().getTime() - startTime) );
          //System.debug(externalRetailerIdMap);

          Set<Id> existingSalesOrderIds = new Set<Id>();

          //Find Sales Orders
          for(SalesOrder__c salesOrder : [SELECT Id, Order_Date__c, Distributor__c, Customer__c, Customer__r.MSA_Retail_Number__c, Customer__r.TDLinx_ID__c, Distributor__r.MSA_Distributor_Id__c FROM SalesOrder__c WHERE Order_Date__c IN : msaDates AND (Customer__r.MSA_Retail_Number__c IN : msaRetailerIds OR Customer__r.TDLinx_ID__c IN : msaTDLinxIds) AND Distributor__r.MSA_Distributor_Id__c IN : msaDistributorIds AND OrderType__c = 'MSA' AND CreatedDate > 2018-07-28T00:00:00Z ORDER BY CreatedDate ASC]){
            String distributorId = salesOrder.Distributor__c;
            String retailerId = salesOrder.Customer__c;
            Date orderDate = salesOrder.Order_Date__c;
            String salesOrderKey = distributorId + retailerId + orderDate;

            System.debug('Sales Order Key : ' + salesOrderKey);

            salesOrderMap.put(salesOrderKey, salesOrder);
            existingSalesOrderIds.add(salesOrder.Id);
          }

          System.debug('Post Sales Order Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(salesOrderMap);

          // Retrieve all existing Doc detail based on sales order and msaDeltaProducts and add to appriopriate map
          for(Document_Details__c docDetail : [SELECT Id, Quantity__c, Product_Description__c, Product__r.MSA_Item_Id__c, salesOrderNumber__r.Distributor__c, salesOrderNumber__r.Order_Date__c, salesOrderNumber__r.Customer__c, salesOrderNumber__r.Customer__r.BillingStreet, Product__c, salesOrderNumber__r.Customer__r.MSA_Retail_Number__c, salesOrderNumber__r.Customer__r.TDLinx_ID__c, Upload_Verification__c FROM Document_Details__c WHERE salesOrderNumber__c IN :existingSalesOrderIds AND Product__r.MSA_Item_Id__c IN :msaProductIds ORDER BY CreatedDate ASC]){
              String distributorId = docDetail.salesOrderNumber__r.Distributor__c;
              String retailerId = docDetail.salesOrderNumber__r.Customer__c;
              Date orderDate = docDetail.salesOrderNumber__r.Order_Date__c;
              String docDetailKey = distributorId + retailerId + orderDate + docDetail.Product__c;

              docDetailsMap.put(docDetailKey, docDetail);
          }

          System.debug('Post Doc Details Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          List<salesOrder__c> newSalesOrders = new List<salesOrder__c>();               
          List<Sales_Data__c> validSalesData = new List<Sales_Data__c>();

          //Create Sales Orders
          for(Sales_Data__c salesData : salesBatchData){
            String distributorId = externalDistributorIdMap.get(salesData.Distributor_External_Id__c);
            String retailerId = externalRetailerTDLinxIdMap.get(salesData.Retailer_TDLinx_Id__c) != null ? externalRetailerTDLinxIdMap.get(salesData.Retailer_TDLinx_Id__c) : externalRetailerIdMap.get(salesData.Retailer_External_Id__c);
            Product2 relatedProduct = productsMap.get(salesData.Product__c);
            Date orderDate = Date.Parse(salesData.Date__c);

            String salesOrderKey = distributorId + retailerId + orderDate;
            
            //System.debug('Sales Order Key : ' + salesOrderKey);
            //if(failedSalesOrders.containsKey(salesOrderKey)){
            //  salesData.Error_Details__c = 'Auto-failed due to another row in this Sales Order failing.'
            //}
            if(distributorId == null){
              salesData.Error_Details__c = 'Distributor not found.';
              //failedSalesOrders.add(salesOrderKey);
            }
            else if(retailerId == null){
              salesData.Error_Details__c = 'Retailer not found.';
              //failedSalesOrders.add(salesOrderKey);
            }
            else if(relatedProduct == null || relatedProduct.Id == null){
              salesData.Error_Details__c = 'Product not found.';
              //failedSalesOrders.add(salesOrderKey);
            }
            else if(salesOrderMap.get(salesOrderKey) != null){
              System.debug('Found existing Sales Order');            
              validSalesData.add(salesData);
            }
            else{
              System.debug('Create new Sales Order');
              validSalesData.add(salesData);

              SalesOrder__c newSalesOrder = new SalesOrder__c();
              newSalesOrder.Distributor__c = distributorId;
              newSalesOrder.Date__c = getDateStringFromCSVDate(salesData.Date__c);
              newSalesOrder.Customer__c = retailerId;
              newSalesOrder.OrderType__c  = 'MSA';
              newSalesOrder.currencyISOCode = currencyFormat;
              for(String soField : salesOrderFieldToSalesDataFieldMap.keySet()){
                  String salesDataField = salesOrderFieldToSalesDataFieldMap.get(soField);
                  if(salesData.get(salesDataField) != null) 
                      newSalesOrder.put(soField, salesData.get(salesDataField));
              }

              salesOrderMap.put(salesOrderKey, newSalesOrder);
              newSalesOrders.add(newSalesOrder);
            }
          }

          System.debug('Post Sales Order Create : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          //Insert new Sales Orders
          List<Database.SaveResult> soSaveResults = Database.insert(newSalesOrders, false);
          Map<String,String> salesOrderInsertErrors = new Map<String,String>();

          System.debug('Post Sales Order Insert : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          for(Integer i=0; i<soSaveResults.size(); i++){
              Database.SaveResult saveResult = soSaveResults[i];
              if (!saveResult.isSuccess()){
                String salesOrderKey = newSalesOrders[i].Distributor__c + '' + newSalesOrders[i].Customer__c + '' + Date.Parse(getCSVDateStringFromDate(newSalesOrders[i].Date__c));
                System.debug('Sales Order Key ' + salesOrderKey);
                System.debug(saveResult.getErrors().get(0).getMessage());
                salesOrderInsertErrors.put(salesOrderKey, saveResult.getErrors().get(0).getMessage());                
              }
              else{
                newSalesOrders[i].Id = saveResult.getId();
              }
          }
          
          System.debug('Post Sales Order Insert Processing : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          List<Document_Details__c> docDetailsToUpsert = new List<Document_Details__c>();
          Map<Id,Document_Details__c> salesDataToDocDetailsMap = new Map<Id,Document_Details__c>();
          List<Sales_Data__c> secondaryValidData = new List<Sales_Data__c>();
          Set<String> processedDocDetails = new Set<String>();

          //Create Document Details
          for(Sales_Data__c salesData : validSalesData){
            String distributorId = externalDistributorIdMap.get(salesData.Distributor_External_Id__c);
            String retailerId = externalRetailerTDLinxIdMap.get(salesData.Retailer_TDLinx_Id__c) != null ? externalRetailerTDLinxIdMap.get(salesData.Retailer_TDLinx_Id__c) : externalRetailerIdMap.get(salesData.Retailer_External_Id__c);
            Product2 relatedProduct = productsMap.get(salesData.Product__c);
            String productId = relatedProduct.Id;
            Date orderDate = Date.Parse(salesData.Date__c);
            Decimal quantity = Decimal.ValueOf(salesData.Quantity__c);

            String salesOrderKey = distributorId + retailerId + orderDate;
            String docDetailsKey = distributorId + retailerId + orderDate + productId;

            //System.debug('Sales Order Key : ' + salesOrderKey);
            //System.debug('Document Details Key : ' + docDetailsKey);

            if(salesOrderInsertErrors.containsKey(salesOrderKey)){
              System.debug('Error Inserting Sales Order : ' + salesOrderInsertErrors.get(salesOrderKey));
              salesData.Error_Details__c = 'Error Inserting Sales Order : ' + salesOrderInsertErrors.get(salesOrderKey);
            }
            else if(!salesOrderMap.containsKey(salesOrderKey) || salesOrderMap.get(salesOrderKey).Id == null){
              System.debug('Unknown Failure : Cannot find Sales Order.');
              salesData.Error_Details__c = 'Unknown Failure : Cannot find Sales Order.';
            }
            else if(processedDocDetails.contains(docDetailsKey)){
              System.debug('Unknown Failure : Document Details has already been keyed.');
              salesData.Error_Details__c = 'Unknown Failure : Document Details has already been keyed.';
            }
            else if(docDetailsMap.containsKey(docDetailsKey)){
              System.debug('Existing Document Details Found, check if upload verification is from later');
              processedDocDetails.add(docDetailsKey);
              Document_Details__c existingDocDetail = docDetailsMap.get(docDetailsKey);
              Boolean validUpdate = true;
              if(existingDocDetail.Upload_Verification__c != null){
                DateTime existingDocDetailDate = DateTime.parse(existingDocDetail.Upload_Verification__c.split(' - ').get(1).trim());
                DateTime newDocDetailDate = DateTime.parse(salesData.Upload_Verification__c.split(' - ').get(1).trim());
                if(existingDocDetailDate > newDocDetailDate)
                  validUpdate = false;
              }
              if(validUpdate){
                existingDocDetail.Quantity__c = quantity;
                existingDocDetail.DDSKU__c = relatedProduct.ProductCode;
                existingDocDetail.MSA_Item_Number__c = salesData.Product__c;
                existingDocDetail.Upload_Verification__c = uploadVerification;
                existingDocDetail.Logic_Process_Status__c = 'New';

                salesDataToDocDetailsMap.put(salesData.Id, existingDocDetail);
                secondaryValidData.add(salesData);
                docDetailsToUpsert.add(existingDocDetail);
              }
            }
            else{
              System.debug('Create new Document Details');
              Document_Details__c newDocDetail = new Document_Details__c();
              newDocDetail.SalesOrderNumber__c = salesOrderMap.get(salesOrderKey).Id;
              newDocDetail.Quantity__c = quantity;
              newDocDetail.Product__c = relatedProduct.Id; 
              newDocDetail.Product_Description__c  = relatedProduct.Name;
              newDocDetail.Sales_Data__c = salesData.Id;
              newDocDetail.CurrencyISOCode = currencyFormat;
              
              for(String ddfield : docDetailToSalesDataFieldMap.keySet()){
                  String salesDataField = docDetailToSalesDataFieldMap.get(ddfield);
                  if(salesData.get(salesDataField) != null){
                      newDocDetail.put(ddfield, salesData.get(salesDataField));
                      salesData.Error_Details__c = 'INFO : Found match but did not update because the Document Detail has a later Upload Verification of :' + newDocDetail.Upload_Verification__c;
                  }
              }

              newDocDetail.DDSKU__c = relatedProduct.ProductCode;
              newDocDetail.MSA_Item_Number__c = salesData.Product__c;
              newDocDetail.Upload_Verification__c = uploadVerification;

              salesDataToDocDetailsMap.put(salesData.Id, newDocDetail);
              secondaryValidData.add(salesData);
              docDetailsToUpsert.add(newDocDetail);
            }
          }

          System.debug('Post Doc Details Create : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(docDetailsToUpsert);

          //Insert Document Details
          List<Database.UpsertResult> documentDetailsUpsertResults = Database.upsert(docDetailsToUpsert, true);
          Map<String,String> documentdetailsInsertErrors = new Map<String,String>();

          System.debug('Post Doc Details Insert : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(documentDetailsUpsertResults);

          for(Integer i=0; i<documentDetailsUpsertResults.size(); i++){
              Database.UpsertResult saveResult = documentDetailsUpsertResults[i];
              System.debug(saveResult);
              if (!saveResult.isSuccess()){
                System.debug(saveResult.getErrors().get(0).getMessage());
                String docDetailErrorKey = docDetailsToUpsert[i].SalesOrderNumber__c + '' + docDetailsToUpsert[i].Product__c;
                documentdetailsInsertErrors.put(docDetailErrorKey, saveResult.getErrors().get(0).getMessage());                
              }
              else{
                //System.debug(saveResult.getId());
                docDetailsToUpsert[i].Id = saveResult.getId();
              }
          }

          System.debug('Post Doc Details Insert Processing : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(docDetailsToUpsert);
          System.debug(documentdetailsInsertErrors);
          System.debug(salesDataToDocDetailsMap);

          for(Sales_Data__c salesData : secondaryValidData){
            String distributorId = externalDistributorIdMap.get(salesData.Distributor_External_Id__c);
            String retailerId = externalRetailerTDLinxIdMap.get(salesData.Retailer_TDLinx_Id__c) != null ? externalRetailerTDLinxIdMap.get(salesData.Retailer_TDLinx_Id__c) : externalRetailerIdMap.get(salesData.Retailer_External_Id__c);
            Product2 relatedProduct = productsMap.get(salesData.Product__c);
            String productId = relatedProduct.Id;
            Date orderDate = Date.Parse(salesData.Date__c);

            String salesOrderKey = distributorId + retailerId + orderDate;
            String docDetailsKey = distributorId + retailerId + orderDate + productId;

            Id salesOrderId = salesOrderMap.get(salesOrderKey).Id;

            if(salesOrderId == null){
              System.debug('Unknown Failure : Unable to find Sales Order Id. Line : ' + currentLineNumber());
              salesData.Error_Details__c = 'Unknown Failure : Unable to find Sales Order Id. Line : ' + currentLineNumber();
            }
            else if(documentdetailsInsertErrors.containsKey(salesOrderId + productId)){
              System.debug('Upsert Error with Document Details.');
              salesData.Error_Details__c = 'Error Upserting Document Details : ' + documentdetailsInsertErrors.get(salesOrderId + productId);
            }
            else if(salesDataToDocDetailsMap.get(salesData.Id) == null || salesDataToDocDetailsMap.get(salesData.Id).Id == null){
              System.debug('Unknown Failure : Unable to find Document Details Id. Line : ' + currentLineNumber());
              salesData.Error_Details__c = 'Unknown Failure : Unable to find Document Details Id. Line : ' + currentLineNumber();
            }
            else{
              salesData.is_Processed__c = true;
              salesData.Error_Details__c = '';
            }
          }

          update(salesBatchData);
          System.debug('Post Sales Data Update : ' + (DateTime.now().getTime() - startTime)/1000.0 );
        }
        else if(dataFormat == 'Acumatica'){
          Long startTime = DateTime.now().getTime();
          System.debug('Start Time' + startTime);
          Map<String,List<Document_Details__c>> salesOrderToDocDetailMap = new Map<String,List<Document_Details__c>>();

          Map<String, Account> externalRetailerMap = new Map<String, Account>();
          Map<String, Product2> productsMap = new Map<String, Product2>();
          Map<String,SalesOrder__c> salesOrderMap = new Map<String,SalesOrder__c>();
          Map<String,Document_Details__c> docDetailsMap = new Map<String,Document_Details__c>();

          Set<String> externalRetailerIds = new Set<String>();
          Set<String> externalProductIds = new Set<String>();
          Set<String> salesOrderNames = new Set<String>();
          Set<String> docDetailsUniqueIds = new Set<String>();

          for(Sales_Data__c salesData : salesBatchData){
            if(salesData.Retailer_External_Id__c != null)
              externalRetailerIds.add(salesData.Retailer_External_Id__c);
            
            if(salesData.Sales_Order_Name__c != null)
              salesOrderNames.add(salesData.Sales_Order_Name__c);

            if(salesData.JUUL_Item_Number__c != null)  
              externalProductIds.add(salesData.JUUL_Item_Number__c);    

            if(salesData.Custom_Field_7__c != null)  
              docDetailsUniqueIds.add(salesData.Custom_Field_7__c);    
          }

          System.debug(externalRetailerIds);
          System.debug(salesOrderNames);
          System.debug(externalProductIds);
          System.debug(docDetailsUniqueIds);

          //Find Products
          for(Product2 sfdcProduct : [SELECT Id, MSA_Item_Id__c, Name, ProductCode FROM product2 WHERE ProductCode IN : externalProductIds]){
            productsMap.put(sfdcProduct.ProductCode, sfdcProduct);
          }

          System.debug('Post Product Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          //Find Retailers
          for(Account sfdcAccount : [SELECT id, MagentoEntityId__c FROM Account WHERE MagentoEntityId__c != null AND MagentoEntityId__c IN : externalRetailerIds ORDER BY CreatedDate]){
            if(sfdcAccount.MagentoEntityId__c != null)
              externalRetailerMap.put(sfdcAccount.MagentoEntityId__c, sfdcAccount);
          }

          System.debug('Post Retailer Search : ' + (DateTime.now().getTime() - startTime) );

          Set<Id> existingSalesOrderIds = new Set<Id>();

          //Find Sales Orders
          for(SalesOrder__c salesOrder : [SELECT Id, Name, Order_Date__c, Distributor__c, Customer__c FROM SalesOrder__c WHERE Name IN : salesOrderNames ORDER BY CreatedDate ASC]){
            System.debug('Sales Order Key : ' + salesOrder.Name);

            salesOrderMap.put(salesOrder.Name, salesOrder);
            existingSalesOrderIds.add(salesOrder.Id);
          }

          System.debug('Post Sales Order Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(salesOrderMap);

          //Find Document Details
          for(Document_Details__c docDetail : [SELECT Id, Name, Unique_Id__c FROM Document_Details__c WHERE Unique_Id__c IN : docDetailsUniqueIds ORDER BY CreatedDate ASC]){
            System.debug('Doc Details : ' + docDetail.Unique_Id__c);

            docDetailsMap.put(docDetail.Unique_Id__c, docDetail);
          }

          System.debug('Post Doc Details Search : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(docDetailsMap);

          System.debug('Account Creation');
          List<Account> newRetailers = new List<Account>();

          for(Sales_Data__c salesData : salesBatchData){
            Account existingRetailer = externalRetailerMap.get(salesData.Retailer_External_Id__c);
            if(existingRetailer == null){
              System.debug('Retailer : ' + salesData.Retailer_External_Id__c + ' not found. Creating Account.');
              Account newRetailer = new Account();
              newRetailer.MagentoEntityId__c=salesData.Retailer_External_Id__c;
              newRetailer.Created_By_Distributor_Portal__c = true;
              newRetailer.Created_By_Portal_User__c = userId;
              newRetailer.RecordTypeId = salesData.Retailer_Record_Type_Id__c;

              for(String accountField : accountCreationFields.keySet()){
                newRetailer.put(accountField, (String)salesData.get(accountCreationFields.get(accountField)));
              }

              if(newRetailer.RecordTypeId == null)
                newRetailer.RecordTypeId = DistributorSalesUploadBatch.accountRecordTypeMap.get('Unprocessed');
              
              newRetailers.add(newRetailer);
              externalRetailerMap.put(newRetailer.MagentoEntityId__c, newRetailer);
            }
          }

          List<Database.SaveResult> retailerSaveResults = Database.insert(newRetailers, false);
          Map<String,String> retailerInsertErrors = new Map<String,String>();

          System.debug('Post Retailer Insert : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          for(Integer i=0; i<retailerSaveResults.size(); i++){
              Database.SaveResult saveResult = retailerSaveResults[i];
              if (!saveResult.isSuccess()){
                String retailerKey = newRetailers[i].MagentoEntityId__c;
                System.debug('Retailer Key ' +  newRetailers[i].MagentoEntityId__c);
                System.debug(saveResult.getErrors().get(0).getMessage());
                retailerInsertErrors.put(retailerKey, saveResult.getErrors().get(0).getMessage());                
              }
              else{
                newRetailers[i].Id = saveResult.getId();
              }
          }

          List<salesOrder__c> newSalesOrders = new List<salesOrder__c>();               
          List<Sales_Data__c> validSalesData = new List<Sales_Data__c>();

          //Create Sales Orders
          for(Sales_Data__c salesData : salesBatchData){
            Account retailerAccount = externalRetailerMap.get(salesData.Retailer_External_Id__c);

            Product2 relatedProduct = productsMap.get(salesData.JUUL_Item_Number__c);
            Date orderDate = Date.Parse(salesData.Date__c);
            String salesOrderKey = salesData.Sales_Order_Name__c;
            
            if(retailerInsertErrors.get(salesData.Retailer_External_Id__c) != null){
              salesData.Error_Details__c = 'Error Inserting Retailer. ' + retailerInsertErrors.get(salesData.Retailer_External_Id__c);
            }
            else if(retailerAccount == null || retailerAccount.Id == null){
              salesData.Error_Details__c = 'Retailer not found.';
              //failedSalesOrders.add(salesOrderKey);
            }
            else if(salesOrderMap.get(salesOrderKey) != null){
              System.debug('Found existing Sales Order');            
              validSalesData.add(salesData);
            }
            else{
              System.debug('Create new Sales Order');
              validSalesData.add(salesData);

              SalesOrder__c newSalesOrder = new SalesOrder__c();
              newSalesOrder.Date__c = getDateStringFromCSVDate(salesData.Date__c);
              newSalesOrder.Customer__c = retailerAccount.Id;
              newSalesOrder.OrderType__c  = 'BO';
              newSalesOrder.Upload_Verification__c = uploadVerification;

              for(String soField : salesOrderFieldToSalesDataFieldMap.keySet()){
                  String salesDataField = salesOrderFieldToSalesDataFieldMap.get(soField);
                  if(salesData.get(salesDataField) != null) 
                      newSalesOrder.put(soField, salesData.get(salesDataField));
              }
              newSalesOrder.Name = salesData.Sales_Order_Name__c;
              if(!Test.isRunningTest()){
                newSalesOrder.Distributor__c = Custom_Code_Configuration__c.getInstance().JUUL_Labs_Account_Id__c;
              }

              newSalesOrder.Status__c = salesData.Sales_Order_Status__c;
              newSalesOrder.orderTotal__c = salesData.Custom_Field_1__c != null ? Decimal.ValueOf(salesData.Custom_Field_1__c.replaceAll('[^.\\d]','')) : null;
              newSalesOrder.Payment_Method__c = salesData.Custom_Field_2__c;
              newSalesOrder.Days_Since_Previous_Order__c = salesData.Custom_Field_3__c != null ? Integer.ValueOf(salesData.Custom_Field_3__c.replaceAll('[^.\\d]','')) : null;
              newSalesOrder.Customer_PO_Number__c = salesData.Custom_Field_4__c;
              newSalesOrder.AcumaticaId__c = salesData.Custom_Field_5__c;            
              System.debug(newSalesOrder.Days_Since_Previous_Order__c );
              salesOrderMap.put(salesOrderKey, newSalesOrder);
              newSalesOrders.add(newSalesOrder);
            }
          }

          System.debug('Post Sales Order Create : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          //Insert new Sales Orders
          List<Database.SaveResult> soSaveResults = Database.insert(newSalesOrders, false);
          Map<String,String> salesOrderInsertErrors = new Map<String,String>();

          System.debug('Post Sales Order Insert : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          for(Integer i=0; i<soSaveResults.size(); i++){
              Database.SaveResult saveResult = soSaveResults[i];
              if (!saveResult.isSuccess()){
                String salesOrderKey = newSalesOrders[i].Name;
                System.debug('Sales Order Key ' + salesOrderKey);
                System.debug(saveResult.getErrors().get(0).getMessage());
                salesOrderInsertErrors.put(salesOrderKey, saveResult.getErrors().get(0).getMessage());                
              }
              else{
                newSalesOrders[i].Id = saveResult.getId();
              }
          }
          
          System.debug('Post Sales Order Insert Processing : ' + (DateTime.now().getTime() - startTime)/1000.0 );

          List<Document_Details__c> docDetailsToUpsert = new List<Document_Details__c>();
          Map<Id,Document_Details__c> salesDataToDocDetailsMap = new Map<Id,Document_Details__c>();
          List<Sales_Data__c> secondaryValidData = new List<Sales_Data__c>();
          Set<String> processedDocDetails = new Set<String>();

          //Create Document Details
          for(Sales_Data__c salesData : validSalesData){
            Account retailerAccount = externalRetailerMap.get(salesData.Retailer_External_Id__c);
            Product2 relatedProduct = productsMap.get(salesData.JUUL_Item_Number__c);
            String productId = relatedProduct != null ? relatedProduct.Id : null;
            Date orderDate = Date.Parse(salesData.Date__c);
            Decimal quantity = salesData.Quantity__c != null ? Decimal.ValueOf(salesData.Quantity__c.replaceAll('[^.\\d]','')) : 0;

            String salesOrderKey = salesData.Sales_Order_Name__c;
            String docDetailsKey = salesData.Custom_Field_7__c;

            //System.debug('Sales Order Key : ' + salesOrderKey);
            //System.debug('Document Details Key : ' + docDetailsKey);

            if(salesOrderInsertErrors.containsKey(salesOrderKey)){
              System.debug('Error Inserting Sales Order : ' + salesOrderInsertErrors.get(salesOrderKey));
              salesData.Error_Details__c = 'Error Inserting Sales Order : ' + salesOrderInsertErrors.get(salesOrderKey);
            }
            else if(!salesOrderMap.containsKey(salesOrderKey) || salesOrderMap.get(salesOrderKey).Id == null){
              System.debug('Unknown Failure : Cannot find Sales Order.');
              salesData.Error_Details__c = 'Unknown Failure : Cannot find Sales Order.';
            }
            else if(processedDocDetails.contains(docDetailsKey)){
              System.debug('Unknown Failure : Document Details has already been keyed.');
              salesData.Error_Details__c = 'Unknown Failure : Document Details has already been keyed.';
            }
            else if(docDetailsMap.containsKey(docDetailsKey)){
              System.debug('Existing Document Details Found');
              processedDocDetails.add(docDetailsKey);
              Document_Details__c existingDocDetail = docDetailsMap.get(docDetailsKey);
              existingDocDetail.Quantity__c = quantity;
              existingDocDetail.DDSKU__c = salesData.JUUL_Item_Number__c;
              existingDocDetail.AcumaticaId__c = salesData.Custom_Field_6__c;           
              existingDocDetail.Upload_Verification__c = uploadVerification;

              salesDataToDocDetailsMap.put(salesData.Id, existingDocDetail);
              secondaryValidData.add(salesData);
              docDetailsToUpsert.add(existingDocDetail);
            }
            else{
              System.debug('Create new Document Details');
              Document_Details__c newDocDetail = new Document_Details__c();
              newDocDetail.SalesOrderNumber__c = salesOrderMap.get(salesOrderKey).Id;
              newDocDetail.Quantity__c = quantity;
              newDocDetail.Product__c = productId;
              newDocDetail.Product_Description__c  = salesData.Product__c;
              newDocDetail.Sales_Data__c = salesData.Id;
              
              for(String ddfield : docDetailToSalesDataFieldMap.keySet()){
                  String salesDataField = docDetailToSalesDataFieldMap.get(ddfield);
                  if(salesData.get(salesDataField) != null)
                      newDocDetail.put(ddfield, salesData.get(salesDataField));
              }

              newDocDetail.DDSKU__c = salesData.JUUL_Item_Number__c;
              newDocDetail.AcumaticaId__c = salesData.Custom_Field_6__c;                
              newDocDetail.Unique_Id__c = salesData.Custom_Field_7__c;  
              newDocDetail.Upload_Verification__c = uploadVerification;

              salesDataToDocDetailsMap.put(salesData.Id, newDocDetail);
              secondaryValidData.add(salesData);
              docDetailsToUpsert.add(newDocDetail);
            }
          }

          System.debug('Post Doc Details Create : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(docDetailsToUpsert);

          //Insert Document Details
          List<Database.UpsertResult> documentDetailsUpsertResults = Database.upsert(docDetailsToUpsert, true);
          Map<String,String> documentdetailsInsertErrors = new Map<String,String>();

          System.debug('Post Doc Details Insert : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(documentDetailsUpsertResults);

          for(Integer i=0; i<documentDetailsUpsertResults.size(); i++){
              Database.UpsertResult saveResult = documentDetailsUpsertResults[i];
              System.debug(saveResult);
              if (!saveResult.isSuccess()){
                System.debug(saveResult.getErrors().get(0).getMessage());
                String docDetailErrorKey = docDetailsToUpsert[i].Unique_Id__c;
                documentdetailsInsertErrors.put(docDetailErrorKey, saveResult.getErrors().get(0).getMessage());                
              }
              else{
                //System.debug(saveResult.getId());
                docDetailsToUpsert[i].Id = saveResult.getId();
              }
          }

          System.debug('Post Doc Details Insert Processing : ' + (DateTime.now().getTime() - startTime)/1000.0 );
          System.debug(docDetailsToUpsert);
          System.debug(documentdetailsInsertErrors);
          System.debug(salesDataToDocDetailsMap);

          for(Sales_Data__c salesData : secondaryValidData){
            Account retailerAccount = externalRetailerMap.get(salesData.Retailer_External_Id__c);
            Product2 relatedProduct = productsMap.get(salesData.JUUL_Item_Number__c);
            Date orderDate = Date.Parse(salesData.Date__c);

            String salesOrderKey = salesData.Sales_Order_Name__c;
            String docDetailsKey = salesData.Custom_Field_7__c;

            Id salesOrderId = salesOrderMap.get(salesOrderKey).Id;

            if(salesOrderId == null){
              System.debug('Unknown Failure : Unable to find Sales Order Id. Line : ' + currentLineNumber());
              salesData.Error_Details__c = 'Unknown Failure : Unable to find Sales Order Id. Line : ' + currentLineNumber();
            }
            else if(documentdetailsInsertErrors.containsKey(docDetailsKey)){
              System.debug('Upsert Error with Document Details.');
              salesData.Error_Details__c = 'Error Upserting Document Details : ' + documentdetailsInsertErrors.get(docDetailsKey);
            }
            else if(salesDataToDocDetailsMap.get(salesData.Id) == null || salesDataToDocDetailsMap.get(salesData.Id).Id == null){
              System.debug('Unknown Failure : Unable to find Document Details Id. Line : ' + currentLineNumber());
              salesData.Error_Details__c = 'Unknown Failure : Unable to find Document Details Id. Line : ' + currentLineNumber();
            }
            else{
              salesData.is_Processed__c = true;
              salesData.Error_Details__c = '';
            }
          }

          update(salesBatchData);
          System.debug('Post Sales Data Update : ' + (DateTime.now().getTime() - startTime)/1000.0 );
        }
    }

    public String getDateStringFromCSVDate(String csvDateString){
        //System.debug('Get Date String');
        try{
            DateTime csvDateTime = DateTime.parse(csvDateString);
            return csvDateTime.format('YYYY-MM-dd h:m:s');
        } catch(Exception e) {
            Date csvDate = Date.parse(csvDateString);
            return DateTime.newInstance(csvDate.year(), csvDate.month(), csvDate.day()).format('YYYY-MM-dd');
        }
    }

    public String getCSVDateStringFromDate(String soDateString){
        Date soDate = Date.valueOf(soDateString);
        return DateTime.newInstance(soDate.year(), soDate.month(), soDate.day()).format('MM/dd/YYYY');
    }

    public void finish(Database.BatchableContext BC) {
        if(Test.isRunningTEst()) currentLineNumber();
    }   

    public static Integer currentLineNumber() {
      try {
          Integer x = 0 / 0;
      } catch(Exception e) {
          String line2 = e.getStackTraceString().split('\n')[1];
          Pattern patt = Pattern.compile('([a-z0-9_.]+): line (\\d+)');
          Matcher match = patt.matcher(line2);
          match.find();
          return Integer.valueOf(match.group(2));
      }
      return null;
  }
}