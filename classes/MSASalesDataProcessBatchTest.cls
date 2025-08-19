@isTest(seealldata = false)                             
private class MSASalesDataProcessBatchTest {
    private static Id DistriRecTypeId, RetailerRecTypeId;
    private static Id ConrecTypeId;
    private static Id recTypeId;
    private static account D1, D2, D3, R1, R2, R3;
    private static List<Account> sourceAccounts;
    
   public static void loadData(String DPD_Dates){
        ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
       
        MSASalesDataProcessBatch__c MSACustomSetting = new MSASalesDataProcessBatch__c();
        MSACustomSetting.Name = 'MSASalesDataProcessBatch';
       if (DPD_Dates == 'Yes') { MSACustomSetting.Country_List_for_DPD_Dates__c = 'US,CA';}
       else { MSACustomSetting.Country_List_for_DPD_Dates__c = null; }
        MSACustomSetting.AdminEmailIds__c = 'abc@gmail.com';
        insert MSACustomSetting;
		
        DistriRecTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        RetailerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        
        User CSM1 = new User(
            ProfileId = [Select Id from Profile Where Name='Customer Success User'].id,
            LastName = 'Test User1',
            Email = 'TestUser1@gmail.com',
            Username = 'Tst1User123456@gmail.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'TstUser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        Insert CSM1;
       
        D1 = new Account();
        D1.Name = 'Test Distributor1';
        D1.Status__c = 'Customer (Reporting)';
        D1.ShippingCountry = 'US';
        D1.CurrencyISOCode = 'USD';
        D1.recordTypeId = DistriRecTypeId;
        D1.MSA_Distributor_Id__c = 'D001';
       
        D2 = new Account();
        D2.Name = 'Test Distributor2';
        D2.Status__c = 'Customer (Reporting)';
        D2.ShippingCountry = 'US';
        D2.CurrencyISOCode = 'USD';
        D2.recordTypeId = DistriRecTypeId;
        D2.MSA_Distributor_Id__c = 'D002';

        R1 = new Account();
        R1.Name = 'Test Retailer1';
        R1.Status__c = 'Customer (Reporting)';
        R1.ShippingCountry = 'US';
        R1.CurrencyISOCode = 'USD';
        R1.recordTypeId = RetailerRecTypeId;
        R1.MSA_Retail_Number__c = 'R001';
        R1.Customer_Success_Manager__c = CSM1.Id;
        
        R2 = new Account();
        R2.Name = 'Test Retailer2';
        R2.Status__c = 'Customer (Reporting)';
        R2.ShippingCountry = 'US';
        R2.CurrencyISOCode = 'USD';
        R2.recordTypeId = RetailerRecTypeId;
        R2.MSA_Retail_Number__c = 'R002';
        R2.Customer_Success_Manager__c = CSM1.Id;
        
        R3 = new Account();
        R3.Name = 'Test Retailer3';
        R3.Status__c = 'Customer (Reporting)';
        R3.ShippingCountry = 'US';
        R3.CurrencyISOCode = 'USD';
        R3.recordTypeId = RetailerRecTypeId;
        R3.MSA_Retail_Number__c = 'R003';
        R3.Customer_Success_Manager__c = CSM1.Id;
       
        sourceAccounts = new List<Account>{D1,D2,R1,R2,R3};
        Insert(sourceAccounts);
       
        Product2 P1 = new Product2(Product_Country__c='US', Name='Test Product1',ProductCode = '11111', MSA_Item_Id__c ='P001', Default_Price__c=20.00);
        Product2 P2 = new Product2(Product_Country__c='US', Name='Test Product2',ProductCode = '22222', MSA_Item_Id__c ='P002', Default_Price__c=30.00);
        Product2 P3 = new Product2(Product_Country__c='US', Name='Test Product3',ProductCode = '33333', MSA_Item_Id__c ='P003', Default_Price__c=40.00);
        List<Product2> sourceProducts = new List<Product2>{P1,P2,P3};
        Insert(sourceProducts);
                                                         
       Distributor_Product_Detail__c DPD1 = new Distributor_Product_Detail__c(Distributor__c=D1.Id, Product__c=P1.Id, Distributor_Product_Pricing__c=15.00);
       Distributor_Product_Detail__c DPD2 = new Distributor_Product_Detail__c(Distributor__c=D1.Id, Product__c=P2.Id, Distributor_Product_Pricing__c=25.00);
       Distributor_Product_Detail__c DPD3 = new Distributor_Product_Detail__c(Distributor__c=D2.Id, Product__c=P1.Id, Distributor_Product_Pricing__c=16.00);
       Distributor_Product_Detail__c DPD4 = new Distributor_Product_Detail__c(Distributor__c=D2.Id, Product__c=P2.Id, Distributor_Product_Pricing__c=26.00);
       List<Distributor_Product_Detail__c> sourceDPD = new List<Distributor_Product_Detail__c>{DPD1,DPD2,DPD3,DPD4};
       Insert(sourceDPD); 
 
       DPD_Effective_Window__c DPDW1 = new DPD_Effective_Window__c(DPD__c=DPD1.Id,Start_Date__c=Date.newInstance(2018, 1, 1),End_Date__c=Date.newInstance(2020, 3, 1),  Price__c=14.00, Active__c=True);
       DPD_Effective_Window__c DPDW2 = new DPD_Effective_Window__c(DPD__c=DPD1.Id,Start_Date__c=Date.newInstance(2018, 3, 2),End_Date__c=Date.newInstance(2025, 12, 31),Price__c=12.00, Active__c=True);
       DPD_Effective_Window__c DPDW3 = new DPD_Effective_Window__c(DPD__c=DPD2.Id,Start_Date__c=Date.newInstance(2018, 1, 1),End_Date__c=Date.newInstance(2020, 3, 1),  Price__c=24.00, Active__c=True);
       DPD_Effective_Window__c DPDW4 = new DPD_Effective_Window__c(DPD__c=DPD2.Id,Start_Date__c=Date.newInstance(2018, 3, 2),End_Date__c=Date.newInstance(2025, 12, 31),Price__c=22.00, Active__c=True);
       List<DPD_Effective_Window__c> sourceDPDW = new List<DPD_Effective_Window__c>{DPDW1,DPDW2,DPDW3,DPDW4};
       Insert(sourceDPDW); 

        Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2020-03-01', Distributor__c = D1.Id, Customer__c = R1.Id,
                                                              OrderType__c = 'MSA', MSA_Sales_Order_External_ID__c = 'D001-R001-20200301');
       
        Salesorder__c existingSalesOrder2 = new Salesorder__c(Date__c = '2020-03-01', Distributor__c = D2.Id, Customer__c = R2.Id,
                                                              OrderType__c = 'MSA', MSA_Sales_Order_External_ID__c = 'D002-R002-20200301');
       
        List<Salesorder__c> sourceSO = new List<Salesorder__c>{existingSalesOrder1,existingSalesOrder2};
        Insert(sourceSO);

        Document_Details__c existingDocDetails1a = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c =P1.Id,
                                                                          Quantity__c = 1, MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001');
        Document_Details__c existingDocDetails1b = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c =P2.Id,
                                                                          Quantity__c = 1, MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P002');
        Document_Details__c existingDocDetails2a = new Document_Details__c(salesOrderNumber__c=existingSalesOrder2.Id, Product__c =P1.Id,
                                                                          Quantity__c = 1, MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P001');
        Document_Details__c existingDocDetails2b = new Document_Details__c(salesOrderNumber__c=existingSalesOrder2.Id, Product__c =P2.Id,
                                                                          Quantity__c = 1, MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P002');
        List<Document_Details__c> sourceDocDetails = new List<Document_Details__c>{existingDocDetails1a,existingDocDetails1b,existingDocDetails2a,existingDocDetails2b};
        Insert(sourceDocDetails);
    }
 
   static testMethod void testToDeleteDocDetailsRecord(){
       String DPD_Dates=null;
        loadData(DPD_Dates);
        
        //Test Case 1, Sales Data for Delete - Should get deleted successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/01/2020';
        newSD1.Quantity__c = '0';
        newSD1.Delta_Row__c = 'D';
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Delete';
       
        //Test Case 2, Sales Data for Delete - Should never get processed as record not found
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'D001';
        newSD2.Retailer_External_Id__c = 'R001';
        newSD2.Product__c = 'P001';
        newSD2.Date__c = '03/01/2020';
        newSD2.Quantity__c = '0';
        newSD2.Delta_Row__c = 'D';
        newSD2.MSA_Shipment_Line_External_ID__c = 'D0010-R0010-20200301-P0010';
        newSD2.MSA_Sales_Order_External_ID__c = 'D0010-R0010-20200301';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Delete';
        
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2};
        Insert(sourceData);
        
        Test.startTest();
            Map<String, String> params = new Map<String, String>();
            params.put('processFlag','false');
            params.put('overrideQuery','');
            params.put('CountryLoad','US');
            params.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Delete');
            database.executeBatch(new MSASalesDataProcessBatch(params),10);
        Test.stopTest();
       list<Document_Details__c>  docList = [Select ID from Document_Details__c where MSA_Shipment_Line_External_ID__c IN('D0010-R0010-20200301-P0010','D001-R001-20200301-P001')];
       system.assert(docList.size()==0, 'All doc Details are deleted');
       
       Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c FROM Sales_Data__c WHERE Id IN : sourceData]);

        //Test Results
        System.assertEquals(true, salesDataMap.get(newSD1.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD2.Id).Is_Processed__c);
        System.assertEquals('Doc Detail record not found for Delete.', salesDataMap.get(newSD2.Id).Error_Details__c);
   } 
   
   static testMethod void testToUpdateDocDetailsRecord_DPDDates(){
        String DPD_Dates='Yes';
        loadData(DPD_Dates);
        //Test Case 1, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/01/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'C';
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update'; 
       
        //Test Case 2, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'D001';
        newSD2.Retailer_External_Id__c = 'R001';
        newSD2.Product__c = 'P002';
        newSD2.Date__c = '03/01/2020';
        newSD2.Quantity__c = '200';
        newSD2.Delta_Row__c = 'C';
        newSD2.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P002';
        newSD2.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';
       
        //Test Case 3, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Distributor_External_Id__c = 'D002';
        newSD3.Retailer_External_Id__c = 'R002';
        newSD3.Product__c = 'P001';
        newSD3.Date__c = '03/01/2020';
        newSD3.Quantity__c = '100';
        newSD3.Delta_Row__c = 'C';
        newSD3.MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P001';
        newSD3.MSA_Sales_Order_External_ID__c = 'D002-R002-20200301';
        newSD3.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';
       
        //Test Case 4, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Distributor_External_Id__c = 'D002';
        newSD4.Retailer_External_Id__c = 'R002';
        newSD4.Product__c = 'P002';
        newSD4.Date__c = '03/01/2020';
        newSD4.Quantity__c = '200';
        newSD4.Delta_Row__c = 'C';
        newSD4.MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P002';
        newSD4.MSA_Sales_Order_External_ID__c = 'D002-R002-20200301';
        newSD4.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';
       
       //Test Case 5, Sales Data for Update - Should never get processed as record not found
        Sales_Data__c newSD5 = new Sales_Data__c();
        newSD5.Distributor_External_Id__c = 'D0020';
        newSD5.Retailer_External_Id__c = 'R0020';
        newSD5.Product__c = 'P0020';
        newSD5.Date__c = '03/01/2020';
        newSD5.Quantity__c = '200';
        newSD5.Delta_Row__c = 'C';
        newSD5.MSA_Shipment_Line_External_ID__c = 'D0020-R0020-20200301-P0020';
        newSD5.MSA_Sales_Order_External_ID__c = 'D0020-R0020-20200301';
        newSD5.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';

        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2,newSD3,newSD4,newSD5};
        Insert(sourceData); 
        Test.startTest();
            Map<String, String> params = new Map<String, String>();
            params.put('processFlag','false');
            params.put('overrideQuery','Error_Details__c = NULL');
            params.put('CountryLoad','US');
            params.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Update');
            database.executeBatch(new MSASalesDataProcessBatch(params),10);
        Test.stopTest();
       Document_Details__c  doc = [Select ID,Quantity__c from Document_Details__c where MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P002' limit 1];
       system.assert(Decimal.ValueOf(newSD5.Quantity__c) ==doc.Quantity__c, 'Quantity updated');
       
       Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c, MSA_Shipment_Line_External_ID__c FROM Sales_Data__c WHERE Id IN : sourceData]);
       Set<String> SetDocExternaID = new Set<String>();
       for (Sales_Data__c sd : salesDataMap.values()){
            SetDocExternaID.add(sd.MSA_Shipment_Line_External_ID__c); 
       }
       
       Map<String,Document_Details__c> DocDMap = new Map<String,Document_Details__c>(); 
       List<Document_Details__c> DocDlst = new List<Document_Details__c>([SELECT Id, MSA_Shipment_Line_External_ID__c, Quantity__c,Discount_Unit_Price__c,Total_Price__c FROM Document_Details__c WHERE MSA_Shipment_Line_External_ID__c IN : SetDocExternaID]); 
       for (Document_Details__c sd : DocDlst){
           DocDMap.put(sd.MSA_Shipment_Line_External_ID__c,sd);
       }
       //Test Results
        String ExtId1='D001-R001-20200301-P001', ExtId2='D001-R001-20200301-P002',ExtId3='D002-R002-20200301-P001',ExtId4='D002-R002-20200301-P002';
        System.assertEquals(true, salesDataMap.get(newSD1.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD2.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD3.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD4.Id).Is_Processed__c);
        System.assertEquals(false, salesDataMap.get(newSD5.Id).Is_Processed__c);
        System.assertEquals('Doc Detail record not found for Update.', salesDataMap.get(newSD5.Id).Error_Details__c);
        System.assertEquals(14.00, DocDMap.get('D001-R001-20200301-P001').Discount_Unit_Price__c);
        System.assertEquals(1400.00, DocDMap.get('D001-R001-20200301-P001').Total_Price__c); 
        System.assertEquals(24.00, DocDMap.get('D001-R001-20200301-P002').Discount_Unit_Price__c);
        System.assertEquals(4800.00, DocDMap.get('D001-R001-20200301-P002').Total_Price__c);
        System.assertEquals(16.00, DocDMap.get('D002-R002-20200301-P001').Discount_Unit_Price__c);
        System.assertEquals(1600.00, DocDMap.get('D002-R002-20200301-P001').Total_Price__c);
        System.assertEquals(26.00, DocDMap.get('D002-R002-20200301-P002').Discount_Unit_Price__c);
        System.assertEquals(5200.00, DocDMap.get('D002-R002-20200301-P002').Total_Price__c);
   }
    
   
   static testMethod void testToUpdateDocDetailsRecord_DPD(){
       String DPD_Dates=null;
        loadData(DPD_Dates);

        //Test Case 1, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/01/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'C';
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update'; 
       
        //Test Case 2, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'D001';
        newSD2.Retailer_External_Id__c = 'R001';
        newSD2.Product__c = 'P002';
        newSD2.Date__c = '03/01/2020';
        newSD2.Quantity__c = '200';
        newSD2.Delta_Row__c = 'C';
        newSD2.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P002';
        newSD2.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';
       
        //Test Case 3, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Distributor_External_Id__c = 'D002';
        newSD3.Retailer_External_Id__c = 'R002';
        newSD3.Product__c = 'P001';
        newSD3.Date__c = '03/01/2020';
        newSD3.Quantity__c = '100';
        newSD3.Delta_Row__c = 'C';
        newSD3.MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P001';
        newSD3.MSA_Sales_Order_External_ID__c = 'D002-R002-20200301';
        newSD3.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';
       
        //Test Case 4, Sales Data for Update - Should get updated successfully
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Distributor_External_Id__c = 'D002';
        newSD4.Retailer_External_Id__c = 'R002';
        newSD4.Product__c = 'P002';
        newSD4.Date__c = '03/01/2020';
        newSD4.Quantity__c = '200';
        newSD4.Delta_Row__c = 'C';
        newSD4.MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P002';
        newSD4.MSA_Sales_Order_External_ID__c = 'D002-R002-20200301';
        newSD4.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';
       
       //Test Case 5, Sales Data for Update - Should never get processed as record not found
        Sales_Data__c newSD5 = new Sales_Data__c();
        newSD5.Distributor_External_Id__c = 'D0020';
        newSD5.Retailer_External_Id__c = 'R0020';
        newSD5.Product__c = 'P0020';
        newSD5.Date__c = '03/01/2020';
        newSD5.Quantity__c = '200';
        newSD5.Delta_Row__c = 'C';
        newSD5.MSA_Shipment_Line_External_ID__c = 'D0020-R0020-20200301-P0020';
        newSD5.MSA_Sales_Order_External_ID__c = 'D0020-R0020-20200301';
        newSD5.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Update';

        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2,newSD3,newSD4,newSD5};
        Insert(sourceData);
       
        Test.startTest();
            Map<String, String> params = new Map<String, String>();
            params.put('processFlag','false');
            params.put('overrideQuery','Error_Details__c = NULL');
            params.put('CountryLoad','US');
            params.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Update');
            database.executeBatch(new MSASalesDataProcessBatch(params),10);
        Test.stopTest();
       Document_Details__c  doc = [Select ID,Quantity__c from Document_Details__c where MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P002' limit 1];
       system.assert(Decimal.ValueOf(newSD5.Quantity__c) ==doc.Quantity__c, 'Quantity updated');
       
       Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c, MSA_Shipment_Line_External_ID__c FROM Sales_Data__c WHERE Id IN : sourceData]);
       Set<String> SetDocExternaID = new Set<String>();
       for (Sales_Data__c sd : salesDataMap.values()){
            SetDocExternaID.add(sd.MSA_Shipment_Line_External_ID__c); 
       }
       
       Map<String,Document_Details__c> DocDMap = new Map<String,Document_Details__c>(); 
       List<Document_Details__c> DocDlst = new List<Document_Details__c>([SELECT Id, MSA_Shipment_Line_External_ID__c, Quantity__c,Discount_Unit_Price__c,Total_Price__c FROM Document_Details__c WHERE MSA_Shipment_Line_External_ID__c IN : SetDocExternaID]); 
       for (Document_Details__c sd : DocDlst){
           DocDMap.put(sd.MSA_Shipment_Line_External_ID__c,sd);
       }
       //Test Results
        System.assertEquals(true, salesDataMap.get(newSD1.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD2.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD3.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD4.Id).Is_Processed__c);
        System.assertEquals(false, salesDataMap.get(newSD5.Id).Is_Processed__c);
        System.assertEquals('Doc Detail record not found for Update.', salesDataMap.get(newSD5.Id).Error_Details__c);
        System.assertEquals(15.00, DocDMap.get('D001-R001-20200301-P001').Discount_Unit_Price__c);
        System.assertEquals(1500.00, DocDMap.get('D001-R001-20200301-P001').Total_Price__c); 
        System.assertEquals(25.00, DocDMap.get('D001-R001-20200301-P002').Discount_Unit_Price__c);
        System.assertEquals(5000.00, DocDMap.get('D001-R001-20200301-P002').Total_Price__c);
        System.assertEquals(16.00, DocDMap.get('D002-R002-20200301-P001').Discount_Unit_Price__c);
        System.assertEquals(1600.00, DocDMap.get('D002-R002-20200301-P001').Total_Price__c);
        System.assertEquals(26.00, DocDMap.get('D002-R002-20200301-P002').Discount_Unit_Price__c);
        System.assertEquals(5200.00, DocDMap.get('D002-R002-20200301-P002').Total_Price__c);
   }
 
      static testMethod void testTocreatedDocDetailsRecord_DPDDates(){
        String DPD_Dates='Yes';
        loadData(DPD_Dates);
    
        //Test Case 1, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/04/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'N';
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200304-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200304';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 2, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'D001';
        newSD2.Retailer_External_Id__c = 'R001';
        newSD2.Product__c = 'P002';
        newSD2.Date__c = '03/04/2020';
        newSD2.Quantity__c = '200';
        newSD2.Delta_Row__c = 'N';
        newSD2.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200304-P002';
        newSD2.MSA_Sales_Order_External_ID__c = 'D001-R001-20200304';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
     
       //Test Case 2a, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD2a = new Sales_Data__c();
        newSD2a.Distributor_External_Id__c = 'D001';
        newSD2a.Retailer_External_Id__c = 'R003';
        newSD2a.Product__c = 'P002';
        newSD2a.Date__c = '03/04/2020';
        newSD2a.Quantity__c = '200';
        newSD2a.Delta_Row__c = 'N';
        newSD2a.MSA_Shipment_Line_External_ID__c = 'D001-R003-20200304-P002';
        newSD2a.MSA_Sales_Order_External_ID__c = 'D001-R003-20200304';
        newSD2a.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
     
        //Test Case 3, Sales Data for Insert - Should get created Doc Detail successfully, existing SO
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Distributor_External_Id__c = 'D002';
        newSD3.Retailer_External_Id__c = 'R002';
        newSD3.Product__c = 'P003';
        newSD3.Date__c = '03/01/2020';
        newSD3.Quantity__c = '100';
        newSD3.Delta_Row__c = 'N';
        newSD3.MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P003';
        newSD3.MSA_Sales_Order_External_ID__c = 'D002-R002-20200301';
        newSD3.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 4, Sales Data for Insert - Should get error for Distributor Not Found
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Distributor_External_Id__c = 'DXX1'; //Invalid Distributor
        newSD4.Retailer_External_Id__c = 'R002';
        newSD4.Product__c = 'P001';
        newSD4.Date__c = '03/04/2020';
        newSD4.Quantity__c = '200';
        newSD4.Delta_Row__c = 'N';
        newSD4.MSA_Shipment_Line_External_ID__c = 'DXX1-R002-20200304-P001';
        newSD4.MSA_Sales_Order_External_ID__c = 'DXX1-R002-20200304';
        newSD4.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 4a, Sales Data for Insert - Should get error for Distributor Not Found
        Sales_Data__c newSD4a = new Sales_Data__c();
        newSD4a.Distributor_External_Id__c = 'DXX1'; //Invalid Distributor
        newSD4a.Retailer_External_Id__c = 'RXX2';    //Invalid Retailer
        newSD4a.Product__c = 'P002';
        newSD4a.Date__c = '03/04/2020';
        newSD4a.Quantity__c = '200';
        newSD4a.Delta_Row__c = 'N';
        newSD4a.MSA_Shipment_Line_External_ID__c = 'DXX1-RXX2-20200304-P002';
        newSD4a.MSA_Sales_Order_External_ID__c = 'DXX1-RXX2-20200304';
        newSD4a.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
       //Test Case 5, Sales Data for Insert - Should get error for Retailer Not Found
        Sales_Data__c newSD5 = new Sales_Data__c();
        newSD5.Distributor_External_Id__c = 'D002';
        newSD5.Retailer_External_Id__c = 'RXX2';    //Invalid Retailer
        newSD5.Product__c = 'P001';
        newSD5.Date__c = '03/04/2020';
        newSD5.Quantity__c = '100';
        newSD5.Delta_Row__c = 'N';
        newSD5.MSA_Shipment_Line_External_ID__c = 'D0020-RXX2-20200304-P001';
        newSD5.MSA_Sales_Order_External_ID__c = 'D0020-RXX2-20200304';
        newSD5.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';

        //Test Case 5a, Sales Data for Insert - Should get error for Retailer Not Found
        Sales_Data__c newSD5a = new Sales_Data__c();
        newSD5a.Distributor_External_Id__c = 'D002';
        newSD5a.Retailer_External_Id__c = 'RXX2';    //Invalid Retailer
        newSD5a.Product__c = 'P002';
        newSD5a.Date__c = '03/01/2020';
        newSD5a.Quantity__c = '200';
        newSD5a.Delta_Row__c = 'N';
        newSD5a.MSA_Shipment_Line_External_ID__c = 'D0020-RXX2-20200301-P002';
        newSD5a.MSA_Sales_Order_External_ID__c = 'D0020-RXX2-20200301';
        newSD5a.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';

        //Test Case 6, Sales Data for Insert - Should get error for Product Not Found
        Sales_Data__c newSD6 = new Sales_Data__c();
        newSD6.Distributor_External_Id__c = 'D002';
        newSD6.Retailer_External_Id__c = 'R002';
        newSD6.Product__c = 'PXX3';               //Invalid Product
        newSD6.Date__c = '03/03/2020';
        newSD6.Quantity__c = '100';
        newSD6.Delta_Row__c = 'N';
        newSD6.MSA_Shipment_Line_External_ID__c = 'D0020-R002-20200303-PXX3';
        newSD6.MSA_Sales_Order_External_ID__c = 'D0020-R002-20200303';
        newSD6.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';

       List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2,newSD2a,newSD3,newSD4,newSD4a,newSD5,newSD5a,newSD6};
         
        Insert(sourceData);
       
        Test.startTest();
            Map<String, String> params = new Map<String, String>();
            params.put('CountryLoad','US');
            params.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Insert');
            MSASalesDataProcessBatch BatchMSA = new MSASalesDataProcessBatch(params);
            DataBase.executeBatch(BatchMSA, 10);
        Test.stopTest();
       list<Document_Details__c>  docList = [Select ID from Document_Details__c ];
       Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c, MSA_Shipment_Line_External_ID__c FROM Sales_Data__c WHERE Id IN : sourceData]);
       Map<Id, Account> RetailerMap  = new Map<Id,Account>([select Id  from Account where Id in : sourceAccounts]);

       Set<String> SetDocExternaID = new Set<String>();
       for (Sales_Data__c sd : salesDataMap.values()){
            SetDocExternaID.add(sd.MSA_Shipment_Line_External_ID__c); 
       }
       
       Map<String,Document_Details__c> DocDMap = new Map<String,Document_Details__c>(); 
       List<Document_Details__c> DocDlst = new List<Document_Details__c>([SELECT Id, MSA_Shipment_Line_External_ID__c, Quantity__c,Discount_Unit_Price__c,Total_Price__c FROM Document_Details__c WHERE MSA_Shipment_Line_External_ID__c IN : SetDocExternaID]); 
       for (Document_Details__c sd : DocDlst){
           DocDMap.put(sd.MSA_Shipment_Line_External_ID__c,sd);
       }
        //Test Results
        System.assert(docList.size()>0, 'Doc Details Created');
        System.assertEquals(true, salesDataMap.get(newSD1.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD2.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD3.Id).Is_Processed__c);
        System.assertEquals(false, salesDataMap.get(newSD4.Id).Is_Processed__c);
        System.assertEquals('Distributor not found.', salesDataMap.get(newSD4.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD4a.Id).Is_Processed__c);
        System.assertEquals('Distributor and Retailer not found.', salesDataMap.get(newSD4a.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD5.Id).Is_Processed__c);
        System.assertEquals('Retailer not found.', salesDataMap.get(newSD5.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD5a.Id).Is_Processed__c);
        System.assertEquals('Retailer not found.', salesDataMap.get(newSD5a.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD6.Id).Is_Processed__c);
        System.assertEquals('Product not found.', salesDataMap.get(newSD6.Id).Error_Details__c);  
        System.assertEquals(12.00, DocDMap.get('D001-R001-20200304-P001').Discount_Unit_Price__c);
        System.assertEquals(1200.00, DocDMap.get('D001-R001-20200304-P001').Total_Price__c); 
        System.assertEquals(22.00, DocDMap.get('D001-R001-20200304-P002').Discount_Unit_Price__c);
        System.assertEquals(4400.00, DocDMap.get('D001-R001-20200304-P002').Total_Price__c);
        System.assertEquals(22.00,   DocDMap.get('D001-R003-20200304-P002').Discount_Unit_Price__c);
        System.assertEquals(4400.00, DocDMap.get('D001-R003-20200304-P002').Total_Price__c);
        System.assertEquals(40.00, DocDMap.get('D002-R002-20200301-P003').Discount_Unit_Price__c);
        System.assertEquals(4000.00, DocDMap.get('D002-R002-20200301-P003').Total_Price__c);
  }
  
   static testMethod void testTocreatedDocDetailsRecord_DPD(){
        String DPD_Dates = null;
        loadData(DPD_Dates);
       
        //Test Case 1, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/04/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'N';
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200304-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200304';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 2, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'D001';
        newSD2.Retailer_External_Id__c = 'R001';
        newSD2.Product__c = 'P002';
        newSD2.Date__c = '03/04/2020';
        newSD2.Quantity__c = '200';
        newSD2.Delta_Row__c = 'N';
        newSD2.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200304-P002';
        newSD2.MSA_Sales_Order_External_ID__c = 'D001-R001-20200304';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
       //Test Case 2a, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD2a = new Sales_Data__c();
        newSD2a.Distributor_External_Id__c = 'D001';
        newSD2a.Retailer_External_Id__c = 'R003';
        newSD2a.Product__c = 'P002';
        newSD2a.Date__c = '03/04/2020';
        newSD2a.Quantity__c = '200';
        newSD2a.Delta_Row__c = 'N';
        newSD2a.MSA_Shipment_Line_External_ID__c = 'D001-R003-20200304-P002';
        newSD2a.MSA_Sales_Order_External_ID__c = 'D001-R003-20200304';
        newSD2a.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 3, Sales Data for Insert - Should get created Doc Detail successfully, existing SO
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Distributor_External_Id__c = 'D002';
        newSD3.Retailer_External_Id__c = 'R002';
        newSD3.Product__c = 'P003';
        newSD3.Date__c = '03/01/2020';
        newSD3.Quantity__c = '100';
        newSD3.Delta_Row__c = 'N';
        newSD3.MSA_Shipment_Line_External_ID__c = 'D002-R002-20200301-P003';
        newSD3.MSA_Sales_Order_External_ID__c = 'D002-R002-20200301';
        newSD3.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 4, Sales Data for Insert - Should get error for Distributor Not Found
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Distributor_External_Id__c = 'DXX1'; //Invalid Distributor
        newSD4.Retailer_External_Id__c = 'R002';
        newSD4.Product__c = 'P001';
        newSD4.Date__c = '03/04/2020';
        newSD4.Quantity__c = '200';
        newSD4.Delta_Row__c = 'N';
        newSD4.MSA_Shipment_Line_External_ID__c = 'DXX1-R002-20200304-P001';
        newSD4.MSA_Sales_Order_External_ID__c = 'DXX1-R002-20200304';
        newSD4.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
        //Test Case 4a, Sales Data for Insert - Should get error for Distributor Not Found
        Sales_Data__c newSD4a = new Sales_Data__c();
        newSD4a.Distributor_External_Id__c = 'DXX1'; //Invalid Distributor
        newSD4a.Retailer_External_Id__c = 'RXX2';    //Invalid Retailer
        newSD4a.Product__c = 'P002';
        newSD4a.Date__c = '03/04/2020';
        newSD4a.Quantity__c = '200';
        newSD4a.Delta_Row__c = 'N';
        newSD4a.MSA_Shipment_Line_External_ID__c = 'DXX1-RXX2-20200304-P002';
        newSD4a.MSA_Sales_Order_External_ID__c = 'DXX1-RXX2-20200304';
        newSD4a.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
       
       //Test Case 5, Sales Data for Insert - Should get error for Retailer Not Found
        Sales_Data__c newSD5 = new Sales_Data__c();
        newSD5.Distributor_External_Id__c = 'D002';
        newSD5.Retailer_External_Id__c = 'RXX2';    //Invalid Retailer
        newSD5.Product__c = 'P001';
        newSD5.Date__c = '03/04/2020';
        newSD5.Quantity__c = '100';
        newSD5.Delta_Row__c = 'N';
        newSD5.MSA_Shipment_Line_External_ID__c = 'D0020-RXX2-20200304-P001';
        newSD5.MSA_Sales_Order_External_ID__c = 'D0020-RXX2-20200304';
        newSD5.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';

        //Test Case 5a, Sales Data for Insert - Should get error for Retailer Not Found
        Sales_Data__c newSD5a = new Sales_Data__c();
        newSD5a.Distributor_External_Id__c = 'D002';
        newSD5a.Retailer_External_Id__c = 'RXX2';    //Invalid Retailer
        newSD5a.Product__c = 'P002';
        newSD5a.Date__c = '03/01/2020';
        newSD5a.Quantity__c = '200';
        newSD5a.Delta_Row__c = 'N';
        newSD5a.MSA_Shipment_Line_External_ID__c = 'D0020-RXX2-20200301-P002';
        newSD5a.MSA_Sales_Order_External_ID__c = 'D0020-RXX2-20200301';
        newSD5a.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';

        //Test Case 6, Sales Data for Insert - Should get error for Product Not Found
        Sales_Data__c newSD6 = new Sales_Data__c();
        newSD6.Distributor_External_Id__c = 'D002';
        newSD6.Retailer_External_Id__c = 'R002';
        newSD6.Product__c = 'PXX3';               //Invalid Product
        newSD6.Date__c = '03/03/2020';
        newSD6.Quantity__c = '100';
        newSD6.Delta_Row__c = 'N';
        newSD6.MSA_Shipment_Line_External_ID__c = 'D0020-R002-20200303-PXX3';
        newSD6.MSA_Sales_Order_External_ID__c = 'D0020-R002-20200303';
        newSD6.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
 
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2,newSD2a,newSD3,newSD4,newSD4a,newSD5,newSD5a,newSD6};
         
        Insert(sourceData);
       
        Test.startTest();
            Map<String, String> params = new Map<String, String>();
            params.put('CountryLoad','US');
            params.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Insert');
            MSASalesDataProcessBatch BatchMSA = new MSASalesDataProcessBatch(params);
            DataBase.executeBatch(BatchMSA, 10);
        Test.stopTest();
       list<Document_Details__c>  docList = [Select ID from Document_Details__c ];
       Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c, MSA_Shipment_Line_External_ID__c FROM Sales_Data__c WHERE Id IN : sourceData]);
       Map<Id, Account> RetailerMap  = new Map<Id,Account>([select Id  from Account where Id in : sourceAccounts]);

       Set<String> SetDocExternaID = new Set<String>();
       for (Sales_Data__c sd : salesDataMap.values()){
            SetDocExternaID.add(sd.MSA_Shipment_Line_External_ID__c); 
       }
       
       Map<String,Document_Details__c> DocDMap = new Map<String,Document_Details__c>(); 
       List<Document_Details__c> DocDlst = new List<Document_Details__c>([SELECT Id, MSA_Shipment_Line_External_ID__c, Quantity__c,Discount_Unit_Price__c,Total_Price__c FROM Document_Details__c WHERE MSA_Shipment_Line_External_ID__c IN : SetDocExternaID]); 
       for (Document_Details__c sd : DocDlst){
           DocDMap.put(sd.MSA_Shipment_Line_External_ID__c,sd);
       }
        //Test Results
        System.assert(docList.size()>0, 'Doc Details Created');
        System.assertEquals(true, salesDataMap.get(newSD1.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD2.Id).Is_Processed__c);
        System.assertEquals(true, salesDataMap.get(newSD3.Id).Is_Processed__c);
        System.assertEquals(false, salesDataMap.get(newSD4.Id).Is_Processed__c);
        System.assertEquals('Distributor not found.', salesDataMap.get(newSD4.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD4a.Id).Is_Processed__c);
        System.assertEquals('Distributor and Retailer not found.', salesDataMap.get(newSD4a.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD5.Id).Is_Processed__c);
        System.assertEquals('Retailer not found.', salesDataMap.get(newSD5.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD5a.Id).Is_Processed__c);
        System.assertEquals('Retailer not found.', salesDataMap.get(newSD5a.Id).Error_Details__c);
        System.assertEquals(false, salesDataMap.get(newSD6.Id).Is_Processed__c);
        System.assertEquals('Product not found.', salesDataMap.get(newSD6.Id).Error_Details__c);
        System.assertEquals(15.00, DocDMap.get('D001-R001-20200304-P001').Discount_Unit_Price__c);
        System.assertEquals(1500.00, DocDMap.get('D001-R001-20200304-P001').Total_Price__c); 
        System.assertEquals(25.00, DocDMap.get('D001-R001-20200304-P002').Discount_Unit_Price__c);
        System.assertEquals(5000.00, DocDMap.get('D001-R001-20200304-P002').Total_Price__c);
        System.assertEquals(25.00, DocDMap.get('D001-R003-20200304-P002').Discount_Unit_Price__c);
        System.assertEquals(5000.00, DocDMap.get('D001-R003-20200304-P002').Total_Price__c);
        System.assertEquals(40.00, DocDMap.get('D002-R002-20200301-P003').Discount_Unit_Price__c);
        System.assertEquals(4000.00, DocDMap.get('D002-R002-20200301-P003').Total_Price__c);
  }

   static testMethod void testTocreatedDocDetailsRecord1(){
        String DPD_Dates=null;
        loadData(DPD_Dates);
        //Test Case 1, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/01/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'N';
        newSD1.Is_Processed__c = true;
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
 
        //Test Case 2, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'D001';
        newSD2.Retailer_External_Id__c = 'R001';
        newSD2.Product__c = 'P002';
        newSD2.Date__c = '03/01/2020';
        newSD2.Quantity__c = '200';
        newSD2.Delta_Row__c = 'N';
        newSD2.Is_Processed__c = true;
        newSD2.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P002';
        newSD2.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
  
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2};
        Insert(sourceData);
       
        List<MSASalesDataProcessBatch__c> lstMSACustomSetting = [Select Id, Name, Country_List_for_DPD_Dates__c, AdminEmailIds__c from MSASalesDataProcessBatch__c limit 1];
        for(MSASalesDataProcessBatch__c MSACustomSetting1: lstMSACustomSetting) { 
            MSACustomSetting1.Name = 'MSASalesDataProcessBatch';
            MSACustomSetting1.Country_List_for_DPD_Dates__c = '';  
            MSACustomSetting1.AdminEmailIds__c = 'abc@gmail.com'; }
            update lstMSACustomSetting; 
       
        Test.startTest();
            Map<String, String> params = new Map<String, String>();
            params.put('processFlag','true');
            params.put('CountryLoad','US');
            params.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Insert');
            MSASalesDataProcessBatch BatchMSA = new MSASalesDataProcessBatch(params);
            DataBase.executeBatch(BatchMSA, 10);
        Test.stopTest();
       list<Document_Details__c>  docList = [Select ID from Document_Details__c ];
       Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c FROM Sales_Data__c WHERE Id IN : sourceData]);

       //Test Results 
       System.assert(docList.size()>0, 'Doc Details Created');
       System.assertEquals(false, salesDataMap.get(newSD1.Id).Is_Processed__c);
       System.assertEquals(false, salesDataMap.get(newSD2.Id).Is_Processed__c);  
   }  
  
   static testMethod void testTocreatedDocDetailsRecord2(){
        String DPD_Dates=null;
        loadData(DPD_Dates);
       
        //Test Case 1, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/01/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'N';
        newSD1.Is_Processed__c = true;
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1};
        Insert(sourceData);
       
        List<MSASalesDataProcessBatch__c> lstMSACustomSetting = [Select Id, Name, Country_List_for_DPD_Dates__c, AdminEmailIds__c from MSASalesDataProcessBatch__c limit 1];
        for(MSASalesDataProcessBatch__c MSACustomSetting1: lstMSACustomSetting) { 
            MSACustomSetting1.Name = 'MSASalesDataProcessBatch';
            MSACustomSetting1.Country_List_for_DPD_Dates__c = '';  
            MSACustomSetting1.AdminEmailIds__c = 'abc@gmail.com'; }
            update lstMSACustomSetting;
       
        Test.startTest();
            Map<String, String> params1 = new Map<String, String>();
            params1.put('processFlag','true');
            params1.put('uploadVerification','SB - 03/04/2020 1:00 PM - MSA Insert'); 
            MSASalesDataProcessBatch BatchMSA1 = new MSASalesDataProcessBatch(params1);
            DataBase.executeBatch(BatchMSA1, 10);
        Test.stopTest(); 
   } 
     static testMethod void testTocreatedDocDetailsRecord3(){
        String DPD_Dates=null;
        loadData(DPD_Dates);
       
        //Test Case 1, Sales Data for Insert - Should get created SO and Doc Detail successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'D001';
        newSD1.Retailer_External_Id__c = 'R001';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '03/01/2020';
        newSD1.Quantity__c = '100';
        newSD1.Delta_Row__c = 'N';
        newSD1.Is_Processed__c = true;
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Insert';
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1};
        Insert(sourceData);
       
        List<MSASalesDataProcessBatch__c> lstMSACustomSetting = [Select Id, Name, Country_List_for_DPD_Dates__c, AdminEmailIds__c from MSASalesDataProcessBatch__c limit 1];
        for(MSASalesDataProcessBatch__c MSACustomSetting1: lstMSACustomSetting) { 
            MSACustomSetting1.Name = 'MSASalesDataProcessBatch';
            MSACustomSetting1.Country_List_for_DPD_Dates__c = '';  
            MSACustomSetting1.AdminEmailIds__c = 'abc@gmail.com'; }
            update lstMSACustomSetting; 
         
        Test.startTest();
            Map<String, String> params2 = new Map<String, String>();
            params2.put('processFlag','true');
            params2.put('CountryLoad','US'); 
            MSASalesDataProcessBatch BatchMSA2 = new MSASalesDataProcessBatch(params2);
            DataBase.executeBatch(BatchMSA2, 10);
        Test.stopTest();
   }  
}