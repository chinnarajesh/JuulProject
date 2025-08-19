@isTest                             
private class SalesOrderProcessingBatchTest {
  static testMethod void testBatchLogic(){
    System.debug('Begin Test');

    Account a1 = new Account(Name='Testcus',MagentoEntityId__c='1111');
    insert(a1);
    Account a11 = new Account(Name='Testdis',MagentoEntityId__c='1110');
    insert(a11);
    Account a2 = new Account(Name='Test1',MagentoEntityId__c='2222');
    insert(a2);
    Account a3 = new Account(Name='Test2',MagentoEntityId__c='3333');
    insert(a3);

    Product2 p = new Product2(Name='Test Product',ProductCode = '12345');
    insert(p);

    Product2 p2 = new Product2(Name='Test Product 2',ProductCode = '54321');
    insert(p2);
   Distributor_Retailer_Link__c existingDisRetailer = new Distributor_Retailer_Link__c(Distributor__c = a2.id ,Retailer__c=a3.id,Link_Status__c = 'Active');
    insert(existingDisRetailer);
    Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2010-01-01', Customer__c = a1.Id,Distributor__c =a11.id, OrderType__c = 'BO', Name='TestOrder1');
    insert(existingSalesOrder1);

    Document_Details__c existingDocDetails1 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails1');
    insert(existingDocDetails1);

    Test.startTest();
      database.executeBatch(new SalesOrderProcessingBatch());
    Test.stopTest();
  }
  static testMethod void testSalesOrderLogic(){
    System.debug('Begin Test');

    Account a1 = new Account(Name='Test',MagentoEntityId__c='1111');
    insert(a1);

    Product2 p = new Product2(Name='Test Product',ProductCode = '12345');
    insert(p);

    Product2 p2 = new Product2(Name='Test Product 2',ProductCode = '54321');
    insert(p2);

    Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2010-01-01', Customer__c = a1.Id, OrderType__c = 'BO', Name='TestOrder1');
    insert(existingSalesOrder1);

    Document_Details__c existingDocDetails1 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails1');
    insert(existingDocDetails1);
    

    
  }

  static testMethod void testDocumentDetailsLogic(){
    System.debug('Begin Test');

    Account retailerAccount = new Account(Name='Test Retailer');
    insert(retailerAccount);

    Account distributorAccount = new Account(Name='Test Distributor', RecordTypeId='012700000005vMFAAY');
    insert(distributorAccount);

    Product2 p = new Product2(Name='Test Product',ProductCode = '12345');
    insert(p);

    Product2 p2 = new Product2(Name='Test Product 2',ProductCode = '54321');
    insert(p2);

    Distributor_Product_Detail__c prodDetail = new Distributor_Product_Detail__c(Distributor__c = distributorAccount.Id, Product__c = p2.Id);
    insert(prodDetail);

    Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2010-01-01', Distributor__c = distributorAccount.Id,  Customer__c = retailerAccount.Id, OrderType__c = 'UPD', Name='TestOrder1');
    insert(existingSalesOrder1);


    //Case 1, null product
    Document_Details__c existingDocDetails1 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails1');
    insert(existingDocDetails1);

    //Case 2, no matching product detail
    Document_Details__c existingDocDetails2 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails2');
    insert(existingDocDetails2);

    //Case 3, matching product detail
    Document_Details__c existingDocDetails3 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p2.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails3');
    insert(existingDocDetails3);

    Test.startTest();
      database.executeBatch(new SalesOrderProcessingBatch());
    Test.stopTest();
  }

  static testMethod void testDocumentDetailsModeLogic(){
    System.debug('Begin Test');

    Account retailerAccount = new Account(Name='Test Retailer');
    insert(retailerAccount);

    Account distributorAccount = new Account(Name='Test Distributor', RecordTypeId='012700000005vMFAAY');
    insert(distributorAccount);

    Product2 p = new Product2(Name='Test Product',ProductCode = '12345');
    insert(p);

    Product2 p2 = new Product2(Name='Test Product 2',ProductCode = '54321');
    insert(p2);

    Distributor_Product_Detail__c prodDetail = new Distributor_Product_Detail__c(Distributor__c = distributorAccount.Id, Product__c = p2.Id);
    insert(prodDetail);

    Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2010-01-01', Distributor__c = distributorAccount.Id,  Customer__c = retailerAccount.Id, OrderType__c = 'UPD', Name='TestOrder1');
    insert(existingSalesOrder1);


    //Case 1, null product
    Document_Details__c existingDocDetails1 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails1');
    insert(existingDocDetails1);

    //Case 2, no matching product detail
    Document_Details__c existingDocDetails2 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails2');
    insert(existingDocDetails2);

    //Case 3, matching product detail
    Document_Details__c existingDocDetails3 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p2.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails3');
    insert(existingDocDetails3);

    Test.startTest();
      database.executeBatch(new SalesOrderProcessingBatch('Document Detail'));
    Test.stopTest();
  }
}