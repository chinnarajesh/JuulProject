public class SalesOrderProcessingBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
  public String mode;
  public String overrideQuery;
  public String extendedQueryFilter;
  public Integer batchSize;
  public static Map<Id,SalesOrder__c> salesOrderProcessingMap;
  public static Map<Id,Document_Details__c> documentDetailsProcessingMap;
  public static Set<String> pricingEnabledDistributors = new Set<String>();
  public void execute(SchedulableContext sc) {
    Database.executeBatch(this, batchSize); 
  }

  public SalesOrderProcessingBatch(){   
    mode = 'Sales Order';
    batchSize = 25;
    pricingEnabledDistributors.addAll(label.PricingEnabledDistributors.split(';'));
  }

  public SalesOrderProcessingBatch(String m){   
    mode = m;
    batchSize = 25;
    list<string> lstDistributos = label.PricingEnabledDistributors.split(';');
    pricingEnabledDistributors.addAll(lstDistributos);
    system.debug('test@@@'+pricingEnabledDistributors+'@@'+lstDistributos);
  }

  public Database.QueryLocator start(Database.BatchableContext BC){  
    if(overrideQuery != null)
      return Database.getQueryLocator(overrideQuery);
    if(mode == 'Sales Order'){
      if(extendedQueryFilter != null)
        return Database.getQueryLocator('SELECT Id FROM SalesOrder__c WHERE ' + extendedQueryFilter);
      else {
        return Database.getQueryLocator('SELECT Id FROM SalesOrder__c WHERE Logic_Process_Status__c = \'New\' AND CreatedDate > 2018-12-24T00:00:00Z');
      }
    }
    else if(mode == 'Document Detail'){
      if(extendedQueryFilter != null)
        return Database.getQueryLocator('SELECT Id, SalesOrderNumber__c FROM Document_Details__c WHERE ' + extendedQueryFilter);
      else {
        return Database.getQueryLocator('SELECT Id, SalesOrderNumber__c FROM Document_Details__c WHERE Logic_Process_Status__c = \'New\' AND CreatedDate > 2018-12-24T00:00:00Z');
      }
    }
    return null;
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope){
    Set<Id> objIds = new Set<Id>();
    for(sObject obj : scope){
      objIds.add(obj.Id);
    }
    
    if(mode == 'Sales Order')
      processSalesOrders(objIds);
    else if(mode == 'Document Detail')
      processDocumentDetails(objIds);
  }
  
  public static void processSalesOrders(Set<Id> salesOrderIds){
    System.debug('Begin Processing Sales Orders ' + salesOrderIds);

    SalesOrderProcessingBatch.populateSalesOrderProcessingMap(salesOrderIds);

    //****** ERROR CHECKS *********************************
    for(SalesOrder__c salesOrder : salesOrderProcessingMap.values()){
      //Reset Errors
      salesOrder.Logic_Process_Errors__c = '';
      salesOrder.Logic_Process_Status__c = 'New';

      if(salesOrder.OrderType__c =='BO' && salesOrder.Distributor__c == null){
        salesOrder.Distributor__c = Custom_Code_Configuration__c.getInstance().JUUL_Labs_Account_Id__c;
        salesOrder.Logic_Process_Errors__c += 'INFO: Populated Distributor__c due to BO Order Type.';
      }

      if(salesOrder.OrderType__c =='BO' && salesOrder.Distributor__c == null){
        salesOrder.Distributor__c = '0013900001bwQGn';
        salesOrder.Logic_Process_Errors__c += 'INFO: Populated Distributor__c due to PK Order Type.';
      }

      //Basic Errors
      if(salesOrder.Distributor__c == null){
        salesOrder.Logic_Process_Errors__c += 'ERROR: Distributor Missing.';
      }
      if(salesOrder.Customer__c == null){
        salesOrder.Logic_Process_Errors__c += '\nERROR: Retailer/Customer Missing.';
      }
    }


    //****** DISTRIBUTOR RETAILER LINK LOGIC *********************************
    handleDistributorRetailerLink(salesOrderIds);

    //****** Process Document Details *********************************
    processDocumentDetails(new Map<Id,Document_Details__c>([SELECT Id FROM Document_Details__c WHERE salesOrderNumber__c IN : salesOrderIds]).keySet());

    for(SalesOrder__c salesOrder : salesOrderProcessingMap  .values()){
      if(!salesOrder.Logic_Process_Errors__c.contains('ERROR'))
        salesOrder.Logic_Process_Status__c = 'Complete';
      else {
         salesOrder.Logic_Process_Status__c = 'Complete with Errors';
      }
    }

    System.debug(salesOrderProcessingMap);
    update(salesOrderProcessingMap.values());
  }

  public static void processDocumentDetails(Set<Id> documentDetailIds){
    SalesOrderProcessingBatch.populateDocumentDetailsProcessingMap(documentDetailIds);

    Set<Id> salesOrderIds = new Set<Id>();

    for(Document_Details__c documentDetail : documentDetailsProcessingMap.values())
      salesOrderIds.add(documentDetail.salesOrderNumber__c);

    SalesOrderProcessingBatch.populateSalesOrderProcessingMap(salesOrderIds);

    for(Document_Details__c documentDetail : documentDetailsProcessingMap.values()){
      documentDetail.Logic_Process_Status__c = 'New';
      documentDetail.Logic_Process_Errors__c = '';
    }

     //****** PRODUCT MATCHING LOGIC *********************************
    handleProductDetailLookup(documentDetailIds);

    for(Document_Details__c documentDetail : documentDetailsProcessingMap.values()){
      if(!documentDetail.Logic_Process_Errors__c.contains('ERROR'))
        documentDetail.Logic_Process_Status__c = 'Complete';
      else{
        documentDetail.Logic_Process_Status__c = 'Complete with Errors';
        salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Logic_Process_Errors__c += '\nERROR: Document Detail : ' + documentDetail.Id + ' has Errors.';
      }
    }

    update(documentDetailsProcessingMap.values());
  }

  public static void handleDistributorRetailerLink(Set<Id> salesOrderIds){
    System.debug('Begin Distributor Retailer Link Handling');
    System.debug(salesOrderIds);

    SalesOrderProcessingBatch.populateSalesOrderProcessingMap(salesOrderIds);
    Set<Id> distributorIds = new Set<Id>();
    Set<Id> retailerIds = new Set<Id>();

    for(SalesOrder__c salesOrder : salesOrderProcessingMap.values()){
      if(salesOrder.Distributor__c != null){
        distributorIds.add(salesOrder.Distributor__c);
      }
      if(salesOrder.Customer__c != null){
        retailerIds.add(salesOrder.Customer__c);
      }
    }

    Map<Id,Set<Id>> distributorToLinkedRetailers = new Map<Id,Set<Id>>();

    for(Distributor_Retailer_Link__c distributorRetailerLink : [SELECT Id, Distributor__c, Retailer__c FROM Distributor_Retailer_Link__c WHERE Distributor__c IN : distributorIds AND Retailer__c IN : retailerIds]){
      if(!distributorToLinkedRetailers.containsKey(distributorRetailerLink.Distributor__c))
        distributorToLinkedRetailers.put(distributorRetailerLink.Distributor__c, new Set<Id>());

      distributorToLinkedRetailers.get(distributorRetailerLink.Distributor__c).add(distributorRetailerLink.Retailer__c);
    }

    List<Distributor_Retailer_Link__c> newDistributorRetailerLinks = new List<Distributor_Retailer_Link__c>();

    for(SalesOrder__c salesOrder : salesOrderProcessingMap.values()){
      if(salesOrder.Distributor__c != null && salesOrder.Customer__c != null && (!distributorToLinkedRetailers.containsKey(salesOrder.Distributor__c) || !distributorToLinkedRetailers.get(salesOrder.Distributor__c).contains(salesOrder.Customer__c))){
        newDistributorRetailerLinks.add(new Distributor_Retailer_Link__c(Distributor__c=salesOrder.Distributor__c, Retailer__c = salesOrder.Customer__c, Link_Status__c='Active'));
        
        if(!distributorToLinkedRetailers.containsKey(salesOrder.Distributor__c))
          distributorToLinkedRetailers.put(salesOrder.Distributor__c, new Set<Id>());

        distributorToLinkedRetailers.get(salesOrder.Distributor__c).add(salesOrder.Customer__c);
      }
    }

    System.debug(newDistributorRetailerLinks);
    insert(newDistributorRetailerLinks);
  }

  public static void handleProductDetailLookup(Set<Id> documentDetailIds){
    System.debug('Begin Handle Product Detail Lookup');
    System.debug(documentDetailIds);
    SalesOrderProcessingBatch.populateDocumentDetailsProcessingMap(documentDetailIds);

    Set<Id> distributorIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<String> productCodes = new Set<String>();
    Set<String> productDDSKUs = new Set<String>();
    Set<String> productDescriptions = new Set<String>();

    for(Document_Details__c documentDetail : documentDetailsProcessingMap.values()){
      if(documentDetail.Product_Description__c == null && documentDetail.Product__c == null && documentDetail.DDSKU__c == null)
        documentDetail.Logic_Process_Errors__c += '\nERROR: Product__c, Product_Description__c, and DDSKU__c are all not populated.';

      if(documentDetail.Quantity__c == null)
        documentDetail.Logic_Process_Errors__c += '\nERROR: Quantity not populated.';

      if(documentDetail.Product__c != null)
        productIds.add(documentDetail.Product__c);

      if(documentDetail.DDSKU__c != null)
        productDDSKUs.add(documentDetail.DDSKU__c);

      if(documentDetail.Product_Description__c != null)
        productDescriptions.add(documentDetail.Product_Description__c);

      if(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Distributor__c != null)
        distributorIds.add(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Distributor__c);
    }
    
    //Match Product Description -> Product Name
    Map<String,Product2> productsByNameMap = new Map<String,Product2>();

    for(Product2 matchedProduct : [SELECT Id, isActive, Default_Price__c, Name, ProductCode FROM Product2 WHERE Name IN : productDescriptions ]){
      productsByNameMap.put(matchedProduct.Name, matchedProduct);
    }

    Map<Id,Map<Id,Distributor_Product_Detail__c>> detailsByProductIdMap = new Map<Id,Map<Id,Distributor_Product_Detail__c>>();
    Map<Id,Map<String,Distributor_Product_Detail__c>> detailsByExternalProductIdMap = new Map<Id,Map<String,Distributor_Product_Detail__c>>();

    for(Distributor_Product_Detail__c prodDetail : [SELECT Id, Distributor__c, Product__c, Distributor_Product_ID__c, Distributor_Product_Pricing__c, Product__r.isActive FROM Distributor_Product_Detail__c WHERE (Distributor_Product_ID__c IN : productDDSKUs OR Distributor_Product_ID__c IN : productDescriptions OR Product__c IN : productIds) AND Distributor__c IN : distributorIds]){
      if(!detailsByExternalProductIdMap.containsKey(prodDetail.Distributor__c))
        detailsByExternalProductIdMap.put(prodDetail.Distributor__c, new Map<String,Distributor_Product_Detail__c>());

      detailsByExternalProductIdMap.get(prodDetail.Distributor__c).put(prodDetail.Distributor_Product_ID__c, prodDetail);

      if(!detailsByProductIdMap.containsKey(prodDetail.Distributor__c))
        detailsByProductIdMap.put(prodDetail.Distributor__c, new Map<Id,Distributor_Product_Detail__c>());

       detailsByProductIdMap.get(prodDetail.Distributor__c).put(prodDetail.Product__c, prodDetail);
    }
    list<string> lstDistributos = label.PricingEnabledDistributors.split(';');
    pricingEnabledDistributors.addAll(lstDistributos);
    for(Document_Details__c documentDetail : documentDetailsProcessingMap.values()){
      Boolean pricingEnabled = (pricingEnabledDistributors.contains(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).OrderType__c) && (documentDetail.Total_Price__c == null));
      
      if(!pricingEnabled)
        documentDetail.Logic_Process_Errors__c += '\nINFO : Pricing is not enabled on this Document Detail due to Order Type or already being populated.';

      Map<Id,Distributor_Product_Detail__c> currentDistroDetailsByProductIdMap = detailsByProductIdMap.get(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Distributor__c) != null ? detailsByProductIdMap.get(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Distributor__c) : new Map<Id,Distributor_Product_Detail__c>();
      Map<String,Distributor_Product_Detail__c> currentDistroDetailsByExternalProductIdMap = detailsByExternalProductIdMap.get(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Distributor__c) != null ? detailsByExternalProductIdMap.get(salesOrderProcessingMap.get(documentDetail.salesOrderNumber__c).Distributor__c) : new Map<String,Distributor_Product_Detail__c>();
      
      Distributor_Product_Detail__c matchedDetail = null;
      //Check if Product__c != null and DPD Match Found
      if(documentDetail.Product__c != null && currentDistroDetailsByProductIdMap.containsKey(documentDetail.Product__c)){
        matchedDetail = currentDistroDetailsByProductIdMap.get(documentDetail.Product__c);
        documentDetail.Logic_Process_Errors__c += '\nINFO : Distributor_Product_Detail__c match found via Product__c.';
      }//Check if DDSKU__c != null and DPD Match Found
      else if(documentDetail.DDSKU__c != null && currentDistroDetailsByExternalProductIdMap.containsKey(documentDetail.DDSKU__c)){
        matchedDetail = currentDistroDetailsByExternalProductIdMap.get(documentDetail.DDSKU__c);
        documentDetail.Logic_Process_Errors__c += '\nINFO : Distributor_Product_Detail__c match found via DDSKU__c.';
      } //Check if Product_Description__c != null and DPD Match Found
      else if(documentDetail.Product_Description__c != null && currentDistroDetailsByExternalProductIdMap.containsKey(documentDetail.Product_Description__c)){
        matchedDetail = currentDistroDetailsByExternalProductIdMap.get(documentDetail.Product_Description__c);
        documentDetail.Logic_Process_Errors__c += '\nINFO : Distributor_Product_Detail__c match found via Product_Description__c.';
      }

      if(matchedDetail != null && matchedDetail.Product__r.isActive){
        documentDetail.Distributor_Product_Detail__c = matchedDetail.Id;
        documentDetail.Product__c = documentDetail.Product__c == null ? matchedDetail.Product__c : documentDetail.Product__c;

        if(matchedDetail.Distributor_Product_Pricing__c == null){
          documentDetail.Logic_Process_Errors__c += '\nERROR : Distributor_Product_Detail__c match does not have Distributor_Product_Pricing__c populated.';
        }
        else if(pricingEnabled)
          documentDetail.Total_Price__c = documentDetail.Quantity__c != null ? matchedDetail.Distributor_Product_Pricing__c*documentDetail.Quantity__c : null;
      }
      else if(matchedDetail != null && !matchedDetail.Product__r.isActive){
        documentDetail.Logic_Process_Errors__c += '\nERROR : Distributor_Product_Detail__c match is tied to an inactive Product.';
      }
      else{
        Product2 matchedProduct = null;

        if(documentDetail.Product__c != null){
          documentDetail.Logic_Process_Errors__c += '\nINFO : Product__c match found via Product__c.';
          matchedProduct = documentDetail.Product__r;
        }
        else if(documentDetail.Product_Description__c != null && productsByNameMap.containsKey(documentDetail.Product_Description__c)){
          documentDetail.Logic_Process_Errors__c += '\nINFO : Product__c match found via Product_Description__c.';
          matchedProduct = productsByNameMap.get(documentDetail.Product_Description__c);
        }

        if(matchedProduct != null && matchedProduct.isActive){
          documentDetail.Product__c = documentDetail.Product__c == null ? matchedProduct.Id : documentDetail.Product__c;
          
          if(matchedProduct.Default_Price__c == null){
            documentDetail.Logic_Process_Errors__c += '\nERROR : Product2 match does not have Default_Price__c populated.';
          }
          else if(pricingEnabled)
            documentDetail.Total_Price__c = documentDetail.Quantity__c != null ? matchedProduct.Default_Price__c*documentDetail.Quantity__c : null;
        }
        else if(matchedProduct != null && !matchedProduct.isActive){
          documentDetail.Logic_Process_Errors__c += '\nERROR : Product2 match is inactive.';
        }
        else{
          documentDetail.Logic_Process_Errors__c += '\nERROR : No Distributor_Product_Detail__c or Product__c matches found.';
        }
      }
      System.debug(documentDetailsProcessingMap.values());
    }
  }

  public static void populateDocumentDetailsProcessingMap(Set<Id> documentDetailIds){
    if(documentDetailsProcessingMap == null)
      documentDetailsProcessingMap = new Map<Id,Document_Details__c>([SELECT Id, Product__c, Product__r.Name, Product__r.Default_Price__c, Product__r.isActive, Product_Description__c, Logic_Process_Status__c, Logic_Process_Errors__c, Quantity__c, salesOrderNumber__r.Distributor__c, salesOrderNumber__c, salesOrderNumber__r.Logic_Process_Status__c, salesOrderNumber__r.Logic_Process_Errors__c, SalesorderNumber__r.OrderType__c, DDSKU__c FROM Document_Details__c WHERE ID IN : documentDetailIds]);

    System.debug(documentDetailsProcessingMap);
  }

  public static void populateSalesOrderProcessingMap(Set<Id> salesOrderIds){
    if(salesOrderProcessingMap == null)
      salesOrderProcessingMap = new Map<Id,SalesOrder__c>([SELECT Id, OrderType__c, Logic_Process_Status__c, Logic_Process_Errors__c ,Distributor__c, Customer__c FROM SalesOrder__c WHERE ID IN : salesOrderIds]);

    System.debug(salesOrderProcessingMap);
  }
  
  public void finish(Database.BatchableContext BC){
        
  }
}