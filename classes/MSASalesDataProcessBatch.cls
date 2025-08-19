/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Naveen         02-24-2020                                            */
/* Class Name:     MSASalesDataProcessBatch                                             */
/* Description:    Batch job to process weekly Sales data uploaded from MSA             */
/****************************************************************************************/

global class MSASalesDataProcessBatch implements schedulable, Database.Batchable<sObject>, Database.Stateful {
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    Map<String, String> params =  new Map<String, String>();
    Map<String, Decimal> mapDPD = new Map<String,Decimal>();
    Map<String, Product2> productsMap = new Map<String, Product2>();
    Map<String, String> mapMSAExtIdDPDKey = new Map<String,String>();
    Map<String, List<DPD_Effective_Window__c>> mapOfDPDEffectiveWindow = new Map<String,List<DPD_Effective_Window__c>>();
    String MapDPDEWindowOneTimeLoaded = 'No';
    Integer TotalRecords=0, TotalDeleteRecords=0, TotalUpdateRecords=0,TotalInsertRecords=0;
    Integer DeleteRecordsFound=0, DeleteRecordsNotFound=0, RecordsDeleted=0, RecordsErrorInDelete=0;
    Integer RecordsUpdated=0, RecordsErrorInUpdate=0, RecordsInserted=0, RecordsErrorInInsert=0;
    Integer DistiNFCounter=0, RetailerNFCounter=0, ProductNFCounter=0;
    Set<String> ProductsNotFound = new Set<String>();
    Set<String> DistributorsNotFound= new Set<String>();
    Set<String> RetailersNotFound = new Set<String>();
    String CountryDPDDates, AdminEmailIds; 
    String SOCurrency = null;
    
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
    
    //Inbound Params
    global String overrideQuery, processFlag, uploadVerification, countryLoad, invalidParams, strPriceMap='None';    
    
    global MSASalesDataProcessBatch(Map<String, String> params){
       this.params = params;
        //Inbound Parameters
        this.overrideQuery      = params.get('overrideQuery');
        this.processFlag        = params.get('processFlag');
        this.uploadVerification = params.get('uploadVerification');
        this.countryLoad        = params.get('CountryLoad');
        If (this.uploadVerification == null || this.uploadVerification == '') {
            this.uploadVerification = 'This is a required input parameter';
            this.invalidParams = 'Yes';
        }
        If (this.countryLoad == 'US') {
            SOCurrency = 'USD'; 
        }
        else if (this.countryLoad == 'CA') {
            SOCurrency = 'CAD'; 
        }
        else {
            this.countryLoad = 'This is a required input parameter and should be either US or CA';
            this.invalidParams = 'Yes';
        }
        MSASalesDataProcessBatch__c MSACustomSetting = MSASalesDataProcessBatch__c.getinstance('MSASalesDataProcessBatch');
        CountryDPDDates = MSACustomSetting.Country_List_for_DPD_Dates__c;
        AdminEmailIds   = MSACustomSetting.AdminEmailIds__c; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        String query;
        if (invalidParams == 'Yes') {
            query  = ' SELECT Id from Sales_Data__c Limit 0'; }
        else  {
            query  = ' SELECT Id, Distributor_External_Id__c, Retailer_External_Id__c, Product__c, Date__c, Quantity__c, Delta_Row__c, ';
            query += ' MSA_Sales_Order_External_ID__c, MSA_Shipment_Line_External_ID__c, Upload_Verification__c, Is_Processed__c, Error_Details__c ';
            query += ' FROM Sales_Data__c WHERE Upload_Verification__c = :uploadVerification ';
            
            if (processFlag == null || processFlag == '' || processFlag == 'false') {
                query += ' AND Is_Processed__c = false ';
            } else if (processFlag == 'true') {
                query += ' AND Is_Processed__c = true ';
            } 
            if (overrideQuery != null && overrideQuery != '') {
                query += 'AND ' + overrideQuery;
            }
            query += ' ORDER BY Date__c ASC';
        }
       // System.debug(query);
        return Database.getQueryLocator(query); 
    }
    
    /**********************************************************************************/
    /* Method Name:    execute                                                        /*
    /* Description:    execute method of Batchable Interface,                         /*
    /*                                                                                /*
    /**********************************************************************************/
    
    global void execute(Database.BatchableContext BC, List<Sales_Data__c> salesBatchData) { 
        map<String,Id> mapDelShipmentLineExternalID  = new map<String,Id>();
        map<String,Id> mapUpdSalesDatawithExternalId = new map<String,Id>(); 
        map<String,Id> mapMSASOExternalIDSOId       = new  map<String,Id>();
        map<String,String> mapMSASOExternalIDRetailerNumber   = new  map<String,String>();
        map<String,String> mapMSASOExternalIDDistiNumber     = new  map<String,String>();
        map<String,Sales_Data__c> mapofNewSalesDatawithExternalId = new map<String,Sales_Data__c>();
        Map<String,Distributor_Retailer_Link__c> mapdistributorToLinkedRetailers = new Map<String,Distributor_Retailer_Link__c>();
        Map<String, String> mapSOCurrency    = new Map<String, String>();
        Set<String> setSOExtIdsNewDocDetails = new Set<String>();
        Set<String> setNewSOExtIds           = new Set<String>();
        Set<String> setmsaProductIds         = new Set<String>();
        List<Document_Details__c> docDetailsToUpdate = new List<Document_Details__c> ();
        List<Distributor_Retailer_Link__c> newDistributorRetailerLinks = new List<Distributor_Retailer_Link__c>();
        String strDPDKey, strDRLKey, strMSADPExtIdKey;
        Decimal UnitPrice, TotalPrice;
        
        TotalRecords+=salesBatchData.size(); 
        for(Sales_Data__c salesData : salesBatchData){
            if(salesData.Delta_Row__c == 'D'){
                mapDelShipmentLineExternalID.put(salesData.MSA_Shipment_Line_External_ID__c,salesData.Id);
            } else if(salesData.Delta_Row__c == 'C'){
                if (MapDPDEWindowOneTimeLoaded == 'No') { OnetimeLoadProductPrice();   }
                mapUpdSalesDatawithExternalId.put(salesData.MSA_Shipment_Line_External_ID__c,salesData.Id);
                UnitPrice = null; TotalPrice = null;
                // Extract Price from DPD Dates or DPD
                if (salesData.Date__c != null)  {
                    strMSADPExtIdKey = SalesData.Product__c + '_' + SalesData.Distributor_External_Id__c;
                    if (mapMSAExtIdDPDKey.ContainsKey(strMSADPExtIdKey)) {
                        UnitPrice = getProductPrice(Date.Parse(salesData.Date__c),mapMSAExtIdDPDKey.get(strMSADPExtIdKey)); }
                }
                if (UnitPrice == null) {
                    if (productsMap.ContainsKey(SalesData.Product__c)) {
                        UnitPrice = productsMap.get(SalesData.Product__c).Default_Price__c; }
                }
                if (UnitPrice != null) {
                    TotalPrice = UnitPrice * Decimal.ValueOf(salesData.Quantity__c);  } 
                
                docDetailsToUpdate.add(new Document_Details__c(MSA_Shipment_Line_External_ID__c = salesData.MSA_Shipment_Line_External_ID__c,
                                                              Quantity__c = Decimal.ValueOf(salesData.Quantity__c),
                                                              Upload_Verification__c = salesData.Upload_Verification__c,
                                                              Discount_Unit_Price__c = UnitPrice,
                                                              Total_Price__c         = TotalPrice,
                                                              Logic_Process_Status__c = 'Complete'));
            } else if(salesData.Delta_Row__c == 'N'){
                if (MapDPDEWindowOneTimeLoaded == 'No') { OnetimeLoadProductPrice();   }
                mapofNewSalesDatawithExternalId.put(salesData.MSA_Shipment_Line_External_ID__c,salesData);
                setSOExtIdsNewDocDetails.add(salesData.MSA_Sales_Order_External_ID__c);
                setNewSOExtIds.add(salesData.MSA_Sales_Order_External_ID__c);
                if(salesData.Retailer_External_Id__c != null)  {
                   mapMSASOExternalIDRetailerNumber.put(salesData.MSA_Sales_Order_External_ID__c,salesData.Retailer_External_Id__c); }
                if(salesData.Distributor_External_Id__c != null)  {
                   mapMSASOExternalIDDistiNumber.put(salesData.MSA_Sales_Order_External_ID__c,salesData.Distributor_External_Id__c); }
                if(salesData.Product__c != null)  { setmsaProductIds.add(salesData.Product__c);   }
            }
        }
        
        TotalDeleteRecords+=mapDelShipmentLineExternalID.size();
        TotalUpdateRecords+=mapUpdSalesDatawithExternalId.size();
        TotalInsertRecords+=mapofNewSalesDatawithExternalId.size();

       // check if mapDelShipmentLineExternalID contains Id then Delete Related DOC Details
       if(mapDelShipmentLineExternalID.size()>0){
           toDeleteDocDetailsRecord(mapDelShipmentLineExternalID);
       }
       
       // check if mapUpdSalesDatawithExternalId contains Id then Update Related DOC Details
       if(mapUpdSalesDatawithExternalId.size()>0){
           toUpdateDocDetailsRecord(mapUpdSalesDatawithExternalId,docDetailsToUpdate);
       }
        
       // check if mapofNewSalesDatawithExternalId contains Id then Created Related DOC Details
       if(mapofNewSalesDatawithExternalId.size()>0){
           List<SalesOrder__c> SOList =[SELECT Id, MSA_Sales_Order_External_ID__c, CurrencyIsoCode 
                                                   FROM SalesOrder__c 
                                                   WHERE MSA_Sales_Order_External_ID__c IN : setSOExtIdsNewDocDetails];
           for(SalesOrder__c SO :SOList){
               mapMSASOExternalIDSOId.put(SO.MSA_Sales_Order_External_ID__c, SO.Id);
               mapSOCurrency.put(SO.MSA_Sales_Order_External_ID__c, SO.CurrencyIsoCode);
               setNewSOExtIds.remove(SO.MSA_Sales_Order_External_ID__c);
               mapMSASOExternalIDRetailerNumber.remove(SO.MSA_Sales_Order_External_ID__c);
               mapMSASOExternalIDDistiNumber.remove(SO.MSA_Sales_Order_External_ID__c);            
           }
           
           List<Document_Details__c> docDetailsToInsert = new List<Document_Details__c> ();
           List<salesOrder__c> newSalesOrders     = new List<salesOrder__c> ();
           List<Sales_Data__c> salesDataList     = new List<Sales_Data__c> ();
           Map<String, String> mapSOExtIdErrors    = new Map<String, String>();
           Map<String, String> mapSOInsertErrors   = new Map<String,String>();
           Map<String, Account> externalRetailerIdMap = new Map<String, Account>();                             
           Map<String, Id> externalDistributorIdMap = new Map<String, Id>();
          // Set<String> setRetailerIdFirstSO = new Set<String>();
          // Map<String, Id> mapRetailerIdFirstSOExtId = new Map<String, Id>();
          // List<Account> listRetailerFirstSOId   = new List<Account>();
           
           //Find Distributors
           for(Account msaAccount : [SELECT Id, MSA_Distributor_Id__c FROM Account 
                                     WHERE MSA_Distributor_Id__c != null AND RecordType.Name = 'Distributor' AND
                                     MSA_Distributor_Id__c IN : mapMSASOExternalIDDistiNumber.values() ORDER BY CreatedDate]) {
               if(msaAccount.MSA_Distributor_Id__c != null)
                   externalDistributorIdMap.put(msaAccount.MSA_Distributor_Id__c, msaAccount.Id);
           }
           System.debug('DistributorIdMap: ' + externalDistributorIdMap);
           
           //Find Retailers
           for(Account msaAccount : [SELECT Id, MSA_Retail_Number__c, CurrencyIsoCode, OwnerId, Customer_Success_Manager__c, First_Sales_Order__c 
                                     FROM Account WHERE MSA_Retail_Number__c != null 
                                     AND MSA_Retail_Number__c IN : mapMSASOExternalIDRetailerNumber.values()]) {
               if(msaAccount.MSA_Retail_Number__c != null) {
                   externalRetailerIdMap.put(msaAccount.MSA_Retail_Number__c, msaAccount); 
                   //if (msaAccount.First_Sales_Order__c == null){
                   //    setRetailerIdFirstSO.add(msaAccount.MSA_Retail_Number__c);
                   //}
                 }
           }
           System.debug('RetailerIdMap: ' + externalRetailerIdMap);
           
           String distributorId, ErrorDetails;
           Date orderDate;
           salesOrder__c newSalesOrder;
           Account retailerAccount;

           // New Sales Orders 
           for (Sales_Data__c SalesData :mapofNewSalesDatawithExternalId.values()) {
               distributorId   = null;
               ErrorDetails    = null;
               retailerAccount = new Account();

               if(setNewSOExtIds.contains(SalesData.MSA_Sales_Order_External_ID__c)){
                   distributorId      = externalDistributorIdMap.get(SalesData.Distributor_External_Id__c);
                   if (externalRetailerIdMap.ContainsKey(SalesData.Retailer_External_Id__c)){
                       retailerAccount    = externalRetailerIdMap.get(SalesData.Retailer_External_Id__c);
                   }

                   if (distributorId != null && retailerAccount.Id != null) {
                       newSalesOrder          = new salesOrder__c();
                       orderDate              = Date.Parse(salesData.Date__c);
                       newSalesOrder.Distributor__c = distributorId;
                       newSalesOrder.Date__c      = getDateStringFromCSVDate(salesData.Date__c);
                       newSalesOrder.Customer__c    = retailerAccount.Id;
                       newSalesOrder.OrderType__c   = 'MSA';
                       // newSalesOrder.currencyISOCode = retailerAccount.currencyISOCode; 
                       newSalesOrder.currencyISOCode = SOCurrency;
                       newSalesOrder.Customer_Success_Manager__c = retailerAccount.Customer_Success_Manager__c;
                       newSalesOrder.Territory_Sales_Manager__c  = retailerAccount.OwnerId;
                       newSalesOrder.MSA_Sales_Order_External_ID__c = SalesData.MSA_Sales_Order_External_ID__c;
                       newSalesOrder.Upload_Verification__c = uploadVerification;
                       newSalesOrder.Logic_Process_Status__c = 'Complete';
                       newSalesOrders.add(newSalesOrder);
                       //if (setRetailerIdFirstSO.contains(SalesData.Retailer_External_Id__c)){
                       //    mapRetailerIdFirstSOExtId.put(SalesData.MSA_Sales_Order_External_ID__c,retailerAccount.Id);
                       //    setRetailerIdFirstSO.remove(SalesData.Retailer_External_Id__c); }
                       
                       // Distributor Retailer Link record
                       strDRLKey = distributorId+'_'+retailerAccount.Id;
                       mapdistributorToLinkedRetailers.put(strDRLKey,new Distributor_Retailer_Link__c(External_ID__c=strDRLKey, Distributor__c=distributorId, Retailer__c = retailerAccount.Id, Link_Status__c='Active'));
                   }
                   else {
                       if (distributorId == null && retailerAccount.Id == null) {
                           ErrorDetails = 'Distributor and Retailer not found.'; 
                           DistributorsNotFound.add(SalesData.Distributor_External_Id__c);
                           RetailersNotFound.add(SalesData.Retailer_External_Id__c);
                       }
                       else if (distributorId == null) {
                           ErrorDetails = 'Distributor not found.'; 
                           DistributorsNotFound.add(SalesData.Distributor_External_Id__c);
                       }
                       else if (retailerAccount.Id == null) {
                           ErrorDetails = 'Retailer not found.'; 
                           RetailersNotFound.add(SalesData.Retailer_External_Id__c);
                       }
                       mapSOExtIdErrors.put(SalesData.MSA_Sales_Order_External_ID__c,ErrorDetails);
                   }
                   setNewSOExtIds.remove(SalesData.MSA_Sales_Order_External_ID__c);
               }
           }
           System.debug('mapSOExtIdErrors: ' + mapSOExtIdErrors);
           //Insert new Sales Orders
           if(newSalesOrders.size()>0) {
               List<Database.SaveResult> soSaveResults = Database.insert(newSalesOrders, false);
               for(Integer i=0; i<soSaveResults.size(); i++){
                   Database.SaveResult saveResult = soSaveResults[i];
                   if (saveResult.isSuccess()){
                       newSalesOrders[i].Id = saveResult.getId();
                       mapMSASOExternalIDSOId.put(newSalesOrders[i].MSA_Sales_Order_External_ID__c,saveResult.getId());
                       //if(mapRetailerIdFirstSOExtId.ContainsKey(newSalesOrders[i].MSA_Sales_Order_External_ID__c)) { 
                       //   listRetailerFirstSOId.add(new Account(Id=mapRetailerIdFirstSOExtId.Get(newSalesOrders[i].MSA_Sales_Order_External_ID__c),
                       //                                 FIrst_Sales_order__c = saveResult.getId()));   
                       //}
                   }
                   else{
                       System.debug('Error Creating Sales Order: ' + newSalesOrders[i].MSA_Sales_Order_External_ID__c + ' ' + saveResult.getErrors().get(0).getMessage());
                       mapSOInsertErrors.put(newSalesOrders[i].MSA_Sales_Order_External_ID__c, 'Error creating Sales Order: ' + saveResult.getErrors().get(0).getMessage());
                   }
               }
           }
           System.debug('mapSOInsertErrors: ' + mapSOInsertErrors);
           
            if(mapdistributorToLinkedRetailers.size()>0) {
              Schema.SObjectField ExtId = Distributor_Retailer_Link__c.Fields.External_ID__c;
              List<Database.UpsertResult> soSaveResults1 = Database.Upsert(mapdistributorToLinkedRetailers.Values(), ExtId, false);                
            }
    
           /***
               @Added Logic To get Price with Respective DPD Effective Window Date Range , We are retrive DPD_Effective_Window__c with Product and Account ID (Distributor) 
               And created Map of ProductID_DistributorID and List of Matching DPD Effective Window Date Range
           */
           
           //New Document Details                                   
           Product2 relatedProduct; 
           for(Sales_Data__c salesData: mapofNewSalesDatawithExternalId.Values()){
               
               if (mapSOExtIdErrors.containsKey(salesData.MSA_Sales_Order_External_ID__c)) {
                   salesDataList.add(new Sales_Data__c(ID = salesData.id, Is_Processed__c=false, 
                                                       Error_Details__c = mapSOExtIdErrors.get(salesData.MSA_Sales_Order_External_ID__c))); 
                   if (DistributorsNotFound.contains(salesData.Distributor_External_Id__c)){
                       DistiNFCounter++;
                   }
                   if (RetailersNotFound.contains(salesData.Retailer_External_Id__c)){
                       RetailerNFCounter++;
                   }
                   RecordsErrorInInsert++;
               } else if (mapSOInsertErrors.containsKey(salesData.MSA_Sales_Order_External_ID__c)) {
                   salesDataList.add(new Sales_Data__c(ID = salesData.id, Is_Processed__c=false, 
                                                       Error_Details__c = mapSOInsertErrors.get(salesData.MSA_Sales_Order_External_ID__c))); 
                   RecordsErrorInInsert++;
               } else if (!productsMap.containsKey(salesData.Product__c)) {
                   salesDataList.add(new Sales_Data__c(ID = salesData.id, Is_Processed__c=false, 
                                                       Error_Details__c = 'Product not found.')); 
                   ProductsNotFound.add(salesData.Product__c);
                   ProductNFCounter++;
                   RecordsErrorInInsert++;
                   System.debug('Product not found.: ' + salesData.Product__c);
               } else if (mapMSASOExternalIDSOId.containsKey(salesData.MSA_Sales_Order_External_ID__c)){  
                   orderDate = Date.Parse(salesData.Date__c);
                   relatedProduct = productsMap.get(salesData.Product__c);
                   Document_Details__c newDocDetail = new Document_Details__c();
                   newDocDetail.SalesOrderNumber__c = mapMSASOExternalIDSOId.get(salesData.MSA_Sales_Order_External_ID__c);
                   newDocDetail.Quantity__c = Decimal.ValueOf(salesData.Quantity__c);
                   newDocDetail.Product__c = relatedProduct.Id;  
                   newDocDetail.Product_Description__c  = relatedProduct.Name;  
                   newDocDetail.Sales_Data__c = salesData.Id; 
                   //if (externalRetailerIdMap.ContainsKey(SalesData.Retailer_External_Id__c)) {
                   //    newDocDetail.CurrencyISOCode = externalRetailerIdMap.get(SalesData.Retailer_External_Id__c).CurrencyISOCode;
                   //    system.debug('externalRetailerIdMap:###########: ' + externalRetailerIdMap.get(SalesData.Retailer_External_Id__c).CurrencyISOCode);
                   //} else if (mapSOCurrency.ContainsKey(salesData.MSA_Sales_Order_External_ID__c)) {
                   //    newDocDetail.CurrencyISOCode = mapSOCurrency.get(salesData.MSA_Sales_Order_External_ID__c); 
                   //    system.debug('mapSOCurrency:###########: ' + mapSOCurrency.get(salesData.MSA_Sales_Order_External_ID__c));
                   //}
                   newDocDetail.Upload_Verification__c = salesData.Upload_Verification__c;
                   newDocDetail.MSA_Shipment_Line_External_ID__c = salesData.MSA_Shipment_Line_External_ID__c;
                   newDocDetail.DDSKU__c = relatedProduct.ProductCode;
                   newDocDetail.MSA_Item_Number__c = salesData.Product__c;
                   newDocDetail.CurrencyISOCode = relatedProduct.CurrencyISOCode;
                   // Get Price From DPD effective window or DPD
                   strDPDKey = relatedProduct.Id+'_'+externalDistributorIdMap.get(SalesData.Distributor_External_Id__c);
                   UnitPrice = null;
                   if (salesData.Date__c != null)  {
                       UnitPrice = getProductPrice(Date.Parse(salesData.Date__c),strDPDKey); }
                   
                   if(UnitPrice == null){
                           UnitPrice = relatedProduct.Default_Price__c;}
                   newDocDetail.Discount_Unit_Price__c = UnitPrice;
                   newDocDetail.Logic_Process_Status__c = 'Complete';
                   if (UnitPrice != null) {
                       newDocDetail.Total_Price__c = UnitPrice * Decimal.ValueOf(salesData.Quantity__c);  } 
                   docDetailsToInsert.add(newDocDetail);   
               }
           }    
           
           //Insert Document Details                                     
           if(docDetailsToInsert.size()>0){
               List<Database.SaveResult> documentDetailsInsertResults = Database.insert(docDetailsToInsert, false);
               
               for(Integer i=0; i<documentDetailsInsertResults.size(); i++){
                   Database.SaveResult saveResult = documentDetailsInsertResults[i];
                   if (saveResult.isSuccess()){
                       docDetailsToInsert[i].Id = saveResult.getId();
                       salesDataList.add(new Sales_Data__c(ID = docDetailsToInsert[i].Sales_Data__c, Is_Processed__c=true, Error_Details__c=null));
                       RecordsInserted++; 
                   }
                   else{
                       System.debug('Error creating Doc Detail: ' + docDetailsToInsert[i].MSA_Shipment_Line_External_ID__c + ' ' + saveResult.getErrors().get(0).getMessage());
                       salesDataList.add(new Sales_Data__c(ID = docDetailsToInsert[i].Sales_Data__c, Is_Processed__c=false, 
                                                           Error_Details__c = 'Error creating Doc Detail: ' + saveResult.getErrors().get(0).getMessage())); 
                       RecordsErrorInInsert++;
                   }
               }
           }
           
           //if(listRetailerFirstSOId.size()>0){
           //    Database.SaveResult[] updateResult3 = Database.update(listRetailerFirstSOId, false);
           //}
           //System.debug('Update - Retail Account First Sales Orders: ' + listRetailerFirstSOId);
           
           if(salesDataList.size()>0){
               Database.SaveResult[] updateResult4 = Database.update(salesDataList, false);
           }
           System.debug('Update - Final salesDataList: ' + salesDataList);
       }
         
    }
       /**
       @Purpose : To Delete the DOC Details record on the basis of MSA Shipment Line External ID
       @Parameter : Set Of External Id 
       */
    
    public void toDeleteDocDetailsRecord( map<String, Id> recordIDSet ){       
        map<Id, String> mapDocDetailIdMSASLineExtId = new  map<Id, String>();
        List<Sales_Data__c> salesDataNewDeleteList = new List<Sales_Data__c> ();
        System.debug('recordIDSet@@::'+recordIDSet);
        List<Document_Details__c> docDetailList =[SELECT Id, Name, MSA_Shipment_Line_External_ID__c 
                                                   FROM Document_Details__c 
                                                   WHERE MSA_Shipment_Line_External_ID__c IN : recordIDSet.keyset()];
        DeleteRecordsFound += docDetailList.size(); 
        System.debug('docDetailList @@::'+docDetailList);  
        for (Document_Details__c  DocDetail :docDetailList ){
             mapDocDetailIdMSASLineExtId.put(DocDetail.Id, DocDetail.MSA_Shipment_Line_External_ID__c);
        }
                                                  
        if(docDetailList.size()>0){
            Database.deleteResult[] drList = Database.delete(docDetailList, false);
            // Iterate through each returned result 
        
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    salesDataNewDeleteList.add(new Sales_Data__c(Id = recordIDSet.get(mapDocDetailIdMSASLineExtId.get(dr.getId())), Is_Processed__c=true, Error_Details__c=null));
                    RecordsDeleted++;}
                else {
                    // Operation failed, so get all errors    
                    salesDataNewDeleteList.add(new Sales_Data__c(Id = recordIDSet.get(mapDocDetailIdMSASLineExtId.get(dr.getId())), Is_Processed__c=false, Error_Details__c='Error Deleting record: ' + dr.getErrors().get(0).getMessage()));            
                    RecordsErrorInDelete++;
                }
                recordIDSet.remove(mapDocDetailIdMSASLineExtId.get(dr.getId()));
            }
        }
        
        DeleteRecordsNotFound += recordIDSet.size();
        if(recordIDSet.size()>0){
            for(Id SalesDataId :recordIDSet.Values()){
                salesDataNewDeleteList.add(new Sales_Data__c(Id = SalesDataId, Is_Processed__c=true, Error_Details__c='Doc Detail record not found for Delete.'));
            }
        }
        if(salesDataNewDeleteList.size()>0){
            Database.SaveResult[] updateResult1 = Database.update(salesDataNewDeleteList, false);
        }
        System.debug('Delete - Final salesDataList: ' + salesDataNewDeleteList);
    }

       /**
       @Purpose : To Update the DOC Details record on the basis of MSA Shipment Line External ID
       @Parameter : Set Of External Id and Sale Data record MAp  
       */
        
    public void toUpdateDocDetailsRecord( map<String,Id> mapUpdSalesDatawithExternalId, List<Document_Details__c> docDetailsToUpdate ){
        System.debug('mapUpdSalesDatawithExternalId.keySet()::'+mapUpdSalesDatawithExternalId.keySet());
        map<Id,Id> mapDocDetailIdSalesDataId = new map<Id,Id>();
        List<Sales_Data__c> salesDataList = new List<Sales_Data__c> ();
        System.debug('docDetailList ::'+docDetailsToUpdate );

        if(docDetailsToUpdate.size()>0){
            //Database.SaveResult[] updateResult = Database.update(docDetailsToUpdate, Document_Details__c.MSA_Shipment_Line_External_ID__c, false);
            Database.UpsertResult[] results = Database.upsert(docDetailsToUpdate, Document_Details__c.MSA_Shipment_Line_External_ID__c, false);
            // Iterate through each returned result 
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    salesDataList.add(new Sales_Data__c(Id = mapUpdSalesDatawithExternalId.get(docDetailsToUpdate[index].MSA_Shipment_Line_External_ID__c), Is_Processed__c=true, Error_Details__c=null));
                    RecordsUpdated++;
                } else{
                    salesDataList.add(new Sales_Data__c(Id = mapUpdSalesDatawithExternalId.get(docDetailsToUpdate[index].MSA_Shipment_Line_External_ID__c), Is_Processed__c=false, Error_Details__c='Doc Detail record not found for Update.'));
                    RecordsErrorInUpdate++;
                }
            }
                        
            if(salesDataList.size()>0){ 
                Database.SaveResult[] updateResult2 = Database.update(salesDataList, false);
            }
            System.debug('Update - Final salesDataList: ' + salesDataList);
        }    
    }
    
    /**
       @Purpose : To Create the DOC Details record on the basis of MSA Shipment Line External ID
       @Parameter : Set Of External Id and Sale Data record MAp  
    */

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
    
    /**
    @PurPose : Onetime Load of global map DPD/DPD_Dates and ProductMap
    @Parameter : 
    **/
    public void OnetimeLoadProductPrice(){ 
        if (MapDPDEWindowOneTimeLoaded == 'No'){
                String strDPDKey, strMSADPExtIdKey;
                MapDPDEWindowOneTimeLoaded = 'Yes';
                if (CountryDPDDates != null) {
                    List<String> lstCountryDPDDates = CountryDPDDates.split(',');
                    if(lstCountryDPDDates.size()>0 && lstCountryDPDDates.contains(countryLoad)){
                        strPriceMap = 'DPD_Dates';
                        // Retrive from Distributor Product Dates for all product and Distributor__c
                        List<DPD_Effective_Window__c> dpdList = [Select ID , Name,Start_Date__c,End_Date__c,Price__c,DPD__r.Product__c,DPD__r.Distributor__c,
                                                                 DPD__r.Distributor__r.MSA_Distributor_Id__c, DPD__r.Product__r.MSA_Item_Id__c
                                                                 FROM DPD_Effective_Window__c  where DPD__r.Product__r.Product_Country__c = :countryLoad
                                                                 AND  DPD__r.Product__r.MSA_Item_Id__c !=null];                
                         for(DPD_Effective_Window__c dpd : dpdList){
                            strDPDKey = dpd.DPD__r.Product__c + '_' + dpd.DPD__r.Distributor__c; 
                            strMSADPExtIdKey  = dpd.DPD__r.Product__r.MSA_Item_Id__c + '_' + dpd.DPD__r.Distributor__r.MSA_Distributor_Id__c;
                            if(!mapOfDPDEffectiveWindow.containsKey(strDPDKey)) {
                                mapOfDPDEffectiveWindow.put(strDPDKey, new List<DPD_Effective_Window__c>()); }
                            mapOfDPDEffectiveWindow.get(strDPDKey).add(dpd);
                            mapMSAExtIdDPDKey.put(strMSADPExtIdKey, strDPDKey);   
                        }
                    }
                } 
                // Retrive from Distributor Product Pricing
                if (CountryDPDDates == null || strPriceMap != 'DPD_Dates') {  
                    strPriceMap = 'DPD';
                }
                for(Distributor_Product_Detail__c dpd : [SELECT Id, Distributor__c, Product__c, Distributor_Product_ID__c, Distributor_Product_Pricing__c,
                                                         Product__r.isActive, Distributor__r.MSA_Distributor_Id__c, Product__r.MSA_Item_Id__c 
                                                         FROM Distributor_Product_Detail__c WHERE Product__r.Product_Country__c = :countryLoad
                                                         AND Product__r.MSA_Item_Id__c !=null])
                {
                    strDPDKey = dpd.Product__c +'_'+ dpd.Distributor__c;
                    mapDPD.put(strDPDKey, dpd.Distributor_Product_Pricing__c); 
                    strMSADPExtIdKey  = dpd.Product__r.MSA_Item_Id__c + '_' + dpd.Distributor__r.MSA_Distributor_Id__c;
                    mapMSAExtIdDPDKey.put(strMSADPExtIdKey, strDPDKey);                                        
                }
                // }
                
               //Load Products Map
               for(Product2 msaProduct : [SELECT Id, MSA_Item_Id__c, Name,CurrencyISOCode, Default_Price__c, ProductCode 
                                          FROM product2 WHERE MSA_Item_Id__c !=null AND Product_Country__c = :countryLoad]){
                   productsMap.put(msaProduct.MSA_Item_Id__c, msaProduct);
               }
               // System.debug('productsMap: ' + productsMap);
        }
    }  
    
    /**
    @PurPose : To retrun the Price with respective DPD Effective Window and Sales order Date
    @Parameter : mapOfDPDEffectiveWindow and SalesORderDate
    **/
    public Decimal getProductPrice(Date salesOrderDate, String strDPDKey){  
        Decimal productPrice=null; 
        if (strPriceMap == 'DPD_Dates') {
            // Extract Price from DPD with Dates
            if (mapOfDPDEffectiveWindow.containsKey(strDPDKey))  {
                for(DPD_Effective_Window__c dew: mapOfDPDEffectiveWindow.get(strDPDKey)) {            
                    // check if data is in range  as well as checking if Distributor are same for salesorder and Distributor_Product_Dates
                    if(salesOrderDate >= dew.Start_Date__c && 
                       salesOrderDate <= dew.End_Date__c ){
                           productPrice = dew.Price__c;
                           Break;
                       }
                }
            }
        } 
        
        if (productPrice==null && mapDPD.ContainsKey(strDPDKey)) {  // Extract Price from DPD
            productPrice = mapDPD.get(strDPDKey);
        } 
        return productPrice;
    }   
  
    /*****************************************************************************/
    /* Method Name:    finish                                                    /*
    /* Description:    finish method of Batchable Interface                      /*
    /*****************************************************************************/
    global void finish(Database.BatchableContext BC) {
 
        if(!String.isEmpty(AdminEmailIds)){
            try{
                String NotFoundString = '', DistiNotFoundString = '', RetailerNotFoundString = '', ProductNotFoundString = '';
                If (DistributorsNotFound.size() >0) {
                    String StrDistri = ''+ DistributorsNotFound;
                    NotFoundString      += '\n Distributors Not Found: ' + DistributorsNotFound.size() +  ', Impacted Salesdata Records: ' + DistiNFCounter;
                    DistiNotFoundString += '\n List of Distributors Not Found: ' + StrDistri.substringBetween('{', '}');
                }
                If (RetailersNotFound.size() >0) {
                    String StrRetailer = ''+ RetailersNotFound;
                    NotFoundString         += '\n Retailers Not Found: ' + RetailersNotFound.size() +  ', Impacted Salesdata Records: ' + RetailerNFCounter;
                    RetailerNotFoundString += '\n List of Retailers Not Found: ' + StrRetailer.substringBetween('{', '}'); 
                }
                If (ProductsNotFound.size() >0) {
                    String StrProduct = ''+ ProductsNotFound;
                    NotFoundString        += '\n Products Not Found: ' + ProductsNotFound.size() +  ', Impacted Salesdata Records: ' + ProductNFCounter;
                    ProductNotFoundString += '\n List of Products Not Found: ' + StrProduct.substringBetween('{', '}');
                }
                
                String[] toAddresses= AdminEmailIds.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,CreatedDate, 
                                  CompletedDate, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String ElapsedTime='';
                datetime start = a.CreatedDate;
                datetime later = a.CompletedDate;
                decimal millisecs = decimal.valueOf(later.getTime() - start.getTime());
                decimal dDays = millisecs/1000/60/60/24;
                system.debug('dDays: ' +dDays);
                integer iDays = integer.valueOF(math.floor(dDays));
                decimal remainderDays = dDays- iDays;
                decimal dHours = remainderDays * 24;
                integer iHours = integer.valueOf(math.floor(dHours));
                decimal remainderHours = dHours - iHours;
                decimal dMinutes = remainderHours * 60;
                integer iMinutes = integer.valueOf(math.floor(dMinutes));
                decimal remainderMinutes = dMinutes - iMinutes;
                decimal dSeconds = remainderMinutes * 60;
                integer iSeconds = integer.valueOf(math.floor(dSeconds));
                decimal remainderSeconds = dSeconds - iSeconds;
                if(iDays >0) { ElapsedTime += iDays + ' Days ';  }
                if(iDays >0 || iHours >0) {ElapsedTime += iHours + ' Hrs '; }
                if(iHours >0 || iMinutes >0) {ElapsedTime += iMinutes + ' Min '; }  
                ElapsedTime += iSeconds + ' Sec';
                system.debug('Days: ' + iDays+' - '+'Hours: ' + iHours+' - '+'Minutes: ' + iMinutes+' - '+'Seconds: ' + iSeconds);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job MSASalesDataProcessBatch ' + a.Status);
                mail.setPlainTextBody(
                   '  The batch Apex job SalesDataOperationBatch processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + 
                    '\n The batch job started ' + a.CreatedDate + ' and completed '+ a.CompletedDate + ' with total elapsed time ' + ElapsedTime + '.' +
                    '\n **************** Input parameters provided **************** ' +
                    '\n processFlag (default is false): ' + params.get('processFlag') + 
                    '\n overrideQuery: ' + params.get('overrideQuery')                + 
                    '\n uploadVerification: ' + params.get('uploadVerification')      + 
                    '\n countryLoad: ' + params.get('CountryLoad')                    + 
                    '\n Product Price extracted from: ' + strPriceMap                 + 
                    '\n ********** Processed record & Error counts **************** ' +
                    '\n Total Records: ' + TotalRecords                               + 
                    '\n Total Records for Delete: ' + TotalDeleteRecords              + 
                    ',  Found for Delete: ' + DeleteRecordsFound                      + 
                    ',  Deleted: ' + RecordsDeleted                                   + 
                    ',  Error in Delete: ' + RecordsErrorInDelete                     + 
                    ',  Not Found for Delete : ' + DeleteRecordsNotFound              +  
                    '\n Total Records for Update: ' + TotalUpdateRecords              +
                    ',  Updated: ' + RecordsUpdated                                   +
                    ',  Error in Update: ' + RecordsErrorInUpdate                     +
                    '\n Total Records for Insert: ' + TotalInsertRecords              +
                    ',  Inserted: ' + RecordsInserted                                 +
                    ',  Error in Insert: ' + RecordsErrorInInsert                     +   
                    '\n *********************************************************** ' +                    
                    NotFoundString + DistiNotFoundString                              + 
                    RetailerNotFoundString + ProductNotFoundString +  '\n'); 
               system.debug('Email :'+ mail); 
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        }         
    }
}