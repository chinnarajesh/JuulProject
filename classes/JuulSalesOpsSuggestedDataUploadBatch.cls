public with sharing class JuulSalesOpsSuggestedDataUploadBatch implements Database.Batchable<sObject>, Database.Stateful {
    //Inbound Params
    public String userId;
    public String overrideQuery;
    public String uploadVerification;
    public String dataFormat; //Format of the Data i.e. UPD, P & K

    //Results

    //Tracking
    //public Set<String> failedSuggestedOrders;
    public Set<String> suggestedDataQueryFields;

    public static Map<String, String> accountCreationFields = new Map<String, String>{
        'Name' => 'Account_Name__c',
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

    public static Map<String, String> suggestedOrderFieldToSuggestedDataFieldMap = new Map<String, String>{
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
        'SOShipping_Zip__c' => 'Retailer_Zip_Code__c'
    };

    public static Map<String, String> suggestedItemToSuggestedDataFieldMap = new Map<String, String>{
        'UPC_ProductId__c' => 'UPC_ProductId__c',
        'DDSKU__c' => 'JUUL_Item_Number__c'
    };

    public JuulSalesOpsSuggestedDataUploadBatch(Map<String, String> params){
        
        //Inbound Parameters
        this.overrideQuery = '';
        this.dataFormat = params.get('selectedFormat');
        //this.uploadVerification = params.get('uploadVerification');
        this.userId = UserInfo.getUserId();

        suggestedDataQueryFields = new Set<String>();

        Map<String, Schema.SObjectField> suggestedDataFieldMap = Schema.getGlobalDescribe().get('Suggested_data__c').getDescribe().fields.getMap();
        
        for(String sObjField : suggestedDataFieldMap.keySet()){
            //if(suggestedDataFieldMap.get(sObjField).getDescribe().isUpdateable())
                suggestedDataQueryFields.add(sObjField);
        }
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        
        String query = 'SELECT ' + String.join(new List<String>(suggestedDataQueryFields), ',') + ' FROM Suggested_data__c WHERE Is_Processed__c = false ';
        //query += ' WHERE Upload_Verification__c = :uploadVerification '; 
        query += this.overrideQuery;

        if(this.overrideQuery == null || this.overrideQuery == '')
          query += ' ORDER BY Id ASC';
        
        return Database.getQueryLocator(query); 
    }

    public void execute(Database.BatchableContext ctx, List<Suggested_data__c> suggestedBatchData) {
      try{ 
        if(dataFormat == 'CMK' || dataFormat == 'AGDC' || dataFormat == 'JUUL'){
          Long startTime = DateTime.now().getTime();          
          Map<String,List<Suggested_Order_Item__c>> suggestedOrderToSugItemMap = new Map<String,List<Suggested_Order_Item__c>>();
          
          //Maps
          
          Map<String, Id> externalRetailerTDLinxIdMap = new Map<String, Id>();          
          Map<String, Product2> productsMap = new Map<String, Product2>();
          Map<String,Suggested_Order__c> suggestedOrderMap = new Map<String,Suggested_Order__c>();
          Map<String,Suggested_Order__c> suggestedOrderTDLinxMap = new Map<String,Suggested_Order__c>();
          Map<String,Suggested_Order_Item__c> suggestedOrderItemMap = new Map<String,Suggested_Order_Item__c>();
          
          //Sets         
          Set<String> upcTDLinxIds = new Set<String>();
          Set<String> upcSfdcIds = new Set<String>();
          Set<String> upcVipIds = new Set<String>();
          Set<String> upcProductIds = new Set<String>();
          Set<Date> upcDates = new Set<Date>();
        
          //Gather  Retailer Ids
        for(Suggested_data__c suggestedData : suggestedBatchData){
                        
            if(suggestedData.Retailer_TDLinx_Id__c != null){
                upcTDLinxIds.add(suggestedData.Retailer_TDLinx_Id__c);
            }else if(suggestedData.SFDC_ID__c != null){
                upcSfdcIds.add(suggestedData.SFDC_ID__c);
            }else if(suggestedData.VIP_ID__c != null){
                upcVipIds.add(suggestedData.VIP_ID__c);
            }
              

            if(suggestedData.Date__c != null)
              upcDates.add(Date.Parse(suggestedData.Date__c));

            if(suggestedData.UPC__c != null)  
              upcProductIds.add(suggestedData.UPC__c);    
        }
        
          //Find Products
          for(Product2 upcProduct : [SELECT Id, UPC_ID__c, Name, ProductCode FROM product2 WHERE UPC_ID__c IN : upcProductIds]){
            productsMap.put(upcProduct.UPC_ID__c, upcProduct);
          }
          
          //Find Retailers by TD Linx ID
          for(Account upcAccount : [SELECT id,TDLinx_ID__c,VIP_ID__c FROM Account WHERE (TDLinx_ID__c IN : upcTDLinxIds OR id IN : upcSfdcIds OR VIP_ID__c IN : upcVipIds) ORDER BY CreatedDate]){
            if(upcAccount.TDLinx_ID__c != null){
              externalRetailerTDLinxIdMap.put(upcAccount.TDLinx_ID__c, upcAccount.Id);
            }
            if(upcAccount.VIP_ID__c != null){
              externalRetailerTDLinxIdMap.put(upcAccount.VIP_ID__c, upcAccount.Id);
            }
            externalRetailerTDLinxIdMap.put(upcAccount.id, upcAccount.Id);
          }
          
          Set<Id> existingsuggestedOrderIds = new Set<Id>();

          //Find Suggested Orders
          for(Suggested_Order__c suggestedOrder : [SELECT Id, Suggested_Order_Date__c, Customer__c, Customer__r.TDLinx_ID__c FROM Suggested_Order__c WHERE Suggested_Order_Date__c IN : upcDates AND Customer__r.TDLinx_ID__c IN : upcTDLinxIds AND (OrderType__c = 'CMK' OR OrderType__c = 'AGDC' OR OrderType__c = 'JUUL') AND CreatedDate > 2018-07-28T00:00:00Z ORDER BY CreatedDate ASC]){
            
            String retailerId = suggestedOrder.Customer__c;
            Date orderDate = suggestedOrder.Suggested_Order_Date__c;
            String suggestedOrderKey = retailerId + orderDate;

            suggestedOrderMap.put(suggestedOrderKey, suggestedOrder);
            existingsuggestedOrderIds.add(suggestedOrder.Id);
          }
          
          // Retrieve all existing suggested order item detail based on suggested order and upcDeltaProducts and add to appriopriate map
          for(Suggested_Order_Item__c suggestedOrdItemDetail : [SELECT Id, Quantity__c, Product_Description__c, Product__r.UPC_ID__c, Suggested_Order__r.Distributor__c, Suggested_Order__r.Suggested_Order_Date__c, Suggested_Order__r.Customer__c, Suggested_Order__r.Customer__r.BillingStreet, Product__c, Suggested_Order__r.Customer__r.TDLinx_ID__c FROM Suggested_Order_Item__c WHERE Suggested_Order__c IN :existingsuggestedOrderIds AND Product__r.UPC_ID__c IN :upcProductIds ORDER BY CreatedDate ASC]){              
              String retailerId = suggestedOrdItemDetail.Suggested_Order__r.Customer__c;
              Date orderDate = suggestedOrdItemDetail.Suggested_Order__r.Suggested_Order_Date__c;
              String suggestedOrdItemDetailKey = retailerId + orderDate + suggestedOrdItemDetail.Product__r.UPC_ID__c;

              suggestedOrderItemMap.put(suggestedOrdItemDetailKey, suggestedOrdItemDetail);
          }
          
          List<Suggested_Order__c> newsuggestedOrders = new List<Suggested_Order__c>();               
          List<Suggested_data__c> validsuggestedData = new List<Suggested_data__c>();                   
          List<Account> newRetailers = new List<Account>();
          Account newRetailer ;
          for(Suggested_data__c suggestedData : suggestedBatchData){
              
            String existingRetailer;
            if(suggestedData.Retailer_TDLinx_Id__c != null){
                existingRetailer = externalRetailerTDLinxIdMap.get(suggestedData.Retailer_TDLinx_Id__c);
            }else if(suggestedData.SFDC_ID__c != null){
                existingRetailer = externalRetailerTDLinxIdMap.get(suggestedData.SFDC_ID__c);
            }else if(suggestedData.VIP_ID__c != null){
                existingRetailer = externalRetailerTDLinxIdMap.get(suggestedData.VIP_ID__c);
            }
                    
            if(existingRetailer == null && suggestedData.Retailer_TDLinx_Id__c != null){
              
              newRetailer = new Account();            
              newRetailer.TDLinx_ID__c=suggestedData.Retailer_TDLinx_Id__c;
              newRetailer.Created_By_Distributor_Portal__c = true;
              newRetailer.Created_By_Portal_User__c = userId;
              newRetailer.RecordTypeId = suggestedData.Retailer_Record_Type_Id__c;
              newRetailer.TD_Store_code__c = suggestedData.TD_Store_code__c;

              for(String accountField : accountCreationFields.keySet()){
                newRetailer.put(accountField, (String)suggestedData.get(accountCreationFields.get(accountField)));
              }

              if(newRetailer.RecordTypeId == null)
                newRetailer.RecordTypeId = DistributorSalesUploadBatch.accountRecordTypeMap.get('Unprocessed');
              
              newRetailers.add(newRetailer);
              
            }
          }          
          List<Database.SaveResult> retailerSaveResults = Database.insert(newRetailers, false);
          Map<String,String> retailerInsertErrors = new Map<String,String>();
          
          Database.SaveResult saveResult;
          for(Integer i=0; i<retailerSaveResults.size(); i++){
              saveResult = retailerSaveResults[i];
              if (!saveResult.isSuccess()){
                String retailerKey = newRetailers[i].TDLinx_ID__c;
                
                retailerInsertErrors.put(retailerKey, saveResult.getErrors().get(0).getMessage());                
              }
              else{
                newRetailers[i].Id = saveResult.getId();
                externalRetailerTDLinxIdMap.put(newRetailers[i].TDLinx_ID__c,newRetailers[i].Id);
              }
          }
          //Create Suggested Orders
          for(Suggested_data__c suggestedData : suggestedBatchData){
              
            String retailerId;
            if(suggestedData.Retailer_TDLinx_Id__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.Retailer_TDLinx_Id__c);
            }else if(suggestedData.SFDC_ID__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.SFDC_ID__c);
            }else if(suggestedData.VIP_ID__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.VIP_ID__c);
            }
                        
            Product2 relatedProduct = productsMap.get(suggestedData.UPC__c);
            Date orderDate = Date.Parse(suggestedData.Date__c);

            String suggestedOrderKey = retailerId + orderDate;
            if(retailerInsertErrors.get(suggestedData.Retailer_TDLinx_Id__c) != null){
              suggestedData.Error_Details__c = 'Error Inserting Retailer. ' + retailerInsertErrors.get(suggestedData.Retailer_TDLinx_Id__c);
            }
            else if(retailerId == null){
              
              suggestedData.Error_Details__c = 'Retailer not found.';
              
            }else if(suggestedOrderMap.get(suggestedOrderKey) != null){              
              validsuggestedData.add(suggestedData);
            }else{              
              validsuggestedData.add(suggestedData);

              Suggested_Order__c newsuggestedOrder = new Suggested_Order__c();
              
              newsuggestedOrder.Date__c = getDateStringFromCSVDate(suggestedData.Date__c);
              newsuggestedOrder.Customer__c = retailerId;
              newsuggestedOrder.Order_Type__c  = dataFormat;
              
              for(String soField : suggestedOrderFieldToSuggestedDataFieldMap.keySet()){
                  String suggestedDataField = suggestedOrderFieldToSuggestedDataFieldMap.get(soField);
                  if(suggestedData.get(suggestedDataField) != null) 
                      newsuggestedOrder.put(soField, suggestedData.get(suggestedDataField));
              }

              suggestedOrderMap.put(suggestedOrderKey, newsuggestedOrder);
              newsuggestedOrders.add(newsuggestedOrder);
            }
          }
          
          //Insert new Sales Orders
          List<Database.SaveResult> soSaveResults = Database.insert(newsuggestedOrders, false);
          Map<String,String> suggestedOrderInsertErrors = new Map<String,String>();

          for(Integer i=0; i<soSaveResults.size(); i++){
              
              if (!soSaveResults[i].isSuccess()){
                String suggestedOrderKey = newsuggestedOrders[i].Customer__c + '' + Date.Parse(getCSVDateStringFromDate(newsuggestedOrders[i].Date__c));                
                suggestedOrderInsertErrors.put(suggestedOrderKey, soSaveResults[i].getErrors().get(0).getMessage());                
              }
              else{
                newsuggestedOrders[i].Id = soSaveResults[i].getId();
              }
          }
          List<Suggested_Order_Item__c> suggestedOrdItemDetailsToUpsert = new List<Suggested_Order_Item__c>();
          Map<Id,Suggested_Order_Item__c> suggestedDataTosuggestedOrderItemMap = new Map<Id,Suggested_Order_Item__c>();
          List<Suggested_data__c> secondaryValidData = new List<Suggested_data__c>();
          Set<String> processedsuggestedOrdItemDetails = new Set<String>();

          //Create Suggested item Details
          for(Suggested_data__c suggestedData : validsuggestedData){
            
            String retailerId;
            if(suggestedData.Retailer_TDLinx_Id__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.Retailer_TDLinx_Id__c);
            }else if(suggestedData.SFDC_ID__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.SFDC_ID__c);
            }else if(suggestedData.VIP_ID__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.VIP_ID__c);
            }
            Product2 relatedProduct = productsMap.get(suggestedData.UPC__c);
            String productId = relatedProduct.Id;
            Date orderDate = Date.Parse(suggestedData.Date__c);
            Decimal quantity = Decimal.ValueOf(suggestedData.Quantity__c);

            String suggestedOrderKey = retailerId + orderDate;
            String suggestedOrdItemKey = retailerId + orderDate + relatedProduct.UPC_ID__c;

            if(suggestedOrderInsertErrors.containsKey(suggestedOrderKey)){              
              suggestedData.Error_Details__c = 'Error Inserting Sales Order : ' + suggestedOrderInsertErrors.get(suggestedOrderKey);
            }
            else if(!suggestedOrderMap.containsKey(suggestedOrderKey) || suggestedOrderMap.get(suggestedOrderKey).Id == null){              
              suggestedData.Error_Details__c = 'Unknown Failure : Cannot find Sales Order.';
            }
            else if(processedsuggestedOrdItemDetails.contains(suggestedOrdItemKey)){
              
              suggestedData.Error_Details__c = 'Unknown Failure : Document Details has already been keyed.';
            }
            else if(suggestedOrderItemMap.containsKey(suggestedOrdItemKey)){
              
              processedsuggestedOrdItemDetails.add(suggestedOrdItemKey);
              Suggested_Order_Item__c existingsuggestedOrdItem = suggestedOrderItemMap.get(suggestedOrdItemKey);
              existingsuggestedOrdItem.Quantity__c = quantity;
              existingsuggestedOrdItem.DDSKU__c = relatedProduct.ProductCode;
              existingsuggestedOrdItem.UPC_ProductId__c = suggestedData.UPC__c;
              existingsuggestedOrdItem.Upload_Verification__c = uploadVerification;

              suggestedDataTosuggestedOrderItemMap.put(suggestedData.Id, existingsuggestedOrdItem);
              secondaryValidData.add(suggestedData);
              
              if(existingsuggestedOrdItem.id != null){
                  suggestedOrdItemDetailsToUpsert.add(existingsuggestedOrdItem);
              }
              
            }
            else{
              
              Suggested_Order_Item__c newsuggestedOrdItem = new Suggested_Order_Item__c();
              newsuggestedOrdItem.Suggested_Order__c = suggestedOrderMap.get(suggestedOrderKey).Id;
              newsuggestedOrdItem.Quantity__c = quantity;
              newsuggestedOrdItem.Product__c = relatedProduct.Id; 
              newsuggestedOrdItem.Product_Description__c  = relatedProduct.Name;
              
              for(String ddfield : suggestedItemToSuggestedDataFieldMap.keySet()){
                  String suggestedDataField = suggestedItemToSuggestedDataFieldMap.get(ddfield);
                  if(suggestedData.get(suggestedDataField) != null)
                      newsuggestedOrdItem.put(ddfield, suggestedData.get(suggestedDataField));
              }

              newsuggestedOrdItem.DDSKU__c = relatedProduct.ProductCode;
              newsuggestedOrdItem.UPC_ProductId__c =suggestedData.UPC__c;
              newsuggestedOrdItem.Upload_Verification__c = uploadVerification;

              suggestedDataTosuggestedOrderItemMap.put(suggestedData.Id, newsuggestedOrdItem);
              secondaryValidData.add(suggestedData);
              suggestedOrdItemDetailsToUpsert.add(newsuggestedOrdItem);
              /*String retailerIdKey;
              if(suggestedData.Retailer_TDLinx_Id__c != null){
                 retailerIdKey =suggestedData.Retailer_TDLinx_Id__c; 
              }else if(suggestedData.VIP_ID__c != null){
                 retailerIdKey =suggestedData.VIP_ID__c; 
              }else{
                 retailerIdKey =suggestedData.SFDC_ID__c; 
              }
              String suggestedOrdItemDetailKey = retailerIdKey + suggestedData.Date__c + suggestedData.UPC__c;*/
              suggestedOrderItemMap.put(suggestedOrdItemKey, newsuggestedOrdItem);
            }
          }
          //Insert Document Details
          List<Database.UpsertResult> documentDetailsUpsertResults = Database.upsert(suggestedOrdItemDetailsToUpsert, true);
          Map<String,String> documentdetailsInsertErrors = new Map<String,String>();
          
          Database.UpsertResult DocdetailssaveResult;
          for(Integer i=0; i<documentDetailsUpsertResults.size(); i++){
              DocdetailssaveResult = documentDetailsUpsertResults[i];
              
              if (!DocdetailssaveResult.isSuccess()){
                
                String suggestedOrdItemDetailErrorKey = suggestedOrdItemDetailsToUpsert[i].Suggested_Order__c + '' + suggestedOrdItemDetailsToUpsert[i].Product__c;
                documentdetailsInsertErrors.put(suggestedOrdItemDetailErrorKey, DocdetailssaveResult.getErrors().get(0).getMessage());                
              }
              else{
                
                suggestedOrdItemDetailsToUpsert[i].Id = DocdetailssaveResult.getId();
              }
          }

          for(Suggested_data__c suggestedData : secondaryValidData){
            
            String retailerId;
            if(suggestedData.Retailer_TDLinx_Id__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.Retailer_TDLinx_Id__c);
            }else if(suggestedData.SFDC_ID__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.SFDC_ID__c);
            }else if(suggestedData.VIP_ID__c != null){
                retailerId = externalRetailerTDLinxIdMap.get(suggestedData.VIP_ID__c);
            }
            Product2 relatedProduct = productsMap.get(suggestedData.UPC__c);
            String productId = relatedProduct.Id;
            Date orderDate = Date.Parse(suggestedData.Date__c);

            String suggestedOrderKey = retailerId + orderDate;
            String suggestedOrdItemKey = retailerId + orderDate + relatedProduct.UPC_ID__c;

            Id suggestedOrderId = suggestedOrderMap.get(suggestedOrderKey).Id;

            if(suggestedOrderId == null){
              
              suggestedData.Error_Details__c = 'Unknown Failure : Unable to find Sales Order Id. Line : ' + currentLineNumber();
            }
            else if(documentdetailsInsertErrors.containsKey(suggestedOrderId + productId)){
              
              suggestedData.Error_Details__c = 'Error Upserting Document Details : ' + documentdetailsInsertErrors.get(suggestedOrderId + productId);
            }
            else if(suggestedDataTosuggestedOrderItemMap.get(suggestedData.Id) == null || suggestedDataTosuggestedOrderItemMap.get(suggestedData.Id).Id == null){
              
              suggestedData.Error_Details__c = 'Unknown Failure : Unable to find Document Details Id. Line : ' + currentLineNumber();
            }
            else{
              suggestedData.is_Processed__c = true;
              suggestedData.Error_Details__c = '';
            }
          }

          update(suggestedBatchData);
          
        }
      }catch (Exception e){
         System.debug('Exception--> ' + e.getMessage());
         EventLogger.log(e);
         if (!Test.isRunningTest()) throw e;
      } 
    }

    public String getDateStringFromCSVDate(String csvDateString){
        
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