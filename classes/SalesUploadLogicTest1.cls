@isTest //(SEEALLDATA = FALSE)

private class SalesUploadLogicTest1 {
    
     static testMethod void testSalesDataUploadBatchAcumatica(){
        System.debug('Begin Test');
        
           ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
      
          List<Account> accList= new List<Account>();
        Account a1 = new Account(Name='Test',MagentoEntityId__c='1111');
        accList.add(a1);
       
        Product2 p = new Product2(Name='Test Product',ProductCode = '12345');
        insert(p);

        Product2 p2 = new Product2(Name='Test Product 2',ProductCode = '54321');
        insert(p2);

        Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2010-01-01', Customer__c = a1.Id, OrderType__c = 'BO', Name='TestOrder1');
        //insert existingSalesOrder1;

        Document_Details__c existingDocDetails1 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p.Id, Quantity__c = 1, Unique_Id__c = 'TestDocDetails1');
        //insert existingDocDetails1;
        
        //Test Case 1, New Sales Order + DD
        Sales_Data__c newSD = new Sales_Data__c();
        newSD.Retailer_External_Id__c = '1111';
       // newSD.Retailer_TDLinx_Id__c = null;
        newSD.JUUL_Item_Number__c = '12345';
        newSD.Date__c = '01/01/2010';
        newSD.Upload_Verification__c = 'Vivek R - 07/28/2018 1:00 PM - Acumatica';
        newSD.Quantity__c = '100';
        newSD.Sales_Order_Name__c = 'TestOrder2';
        newSD.Custom_Field_7__c = 'TestDocDetails2';
        newSD.Sales_Order_Status__c = 'Test Status';
        newSD.Custom_Field_1__c = '100';
        newSD.Custom_Field_2__c = 'Test Payment Method';
        newSD.Custom_Field_3__c = '100';
        newSD.Custom_Field_4__c = 'Test PO Number';
        newSD.Custom_Field_5__c = 'Test Acumatica Customer Id';
        newSD.Custom_Field_6__c = 'Test Acumatica DD ID';

       
        
        //Test Case 2, Add DD to existing SO
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Retailer_External_Id__c = '1111';
       // newSD2.Retailer_TDLinx_Id__c = '1212';
        newSD2.JUUL_Item_Number__c = '54321';
        newSD2.Date__c = '01/01/2010';
        newSD2.Sales_Order_Name__c = 'TestOrder1';
        newSD2.Upload_Verification__c = 'Vivek R - 07/28/2018 1:00 PM - Acumatica';
        newSD2.Quantity__c = '200';
        

        //Test Case 3, Update existing DD
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Retailer_External_Id__c = '1111';
        //newSD3.Retailer_TDLinx_ID__c = null;
        newSD3.JUUL_Item_Number__c = '12345';
        newSD3.Date__c = '01/01/2010';
        newSD3.Sales_Order_Name__c = 'TestOrder1';
        newSD3.Custom_Field_7__c = 'TestDocDetails1';
        newSD3.Upload_Verification__c = 'Vivek R - 07/28/2018 1:00 PM - Acumatica';
        newSD3.Quantity__c = '150';

                
        //Test Case 4, New Account + SO + DD
        
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Retailer_External_Id__c = '2222';
        newSD4.Retailer_Name__c = 'Test';
        newSD4.JUUL_Item_Number__c = '12345';
        newSD4.Date__c = '01/01/2010';
        newSD4.Sales_Order_Name__c = 'TestOrder3';
        newSD4.Custom_Field_7__c = 'TestDocDetails3';
       // newSD4.Retailer_TDLinx_Id__c = null;
        newSD4.Upload_Verification__c = 'Vivek R - 07/28/2018 1:00 PM - Acumatica';
        newSD4.Quantity__c = '150';
        
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD,newSD2,newSD3,newSD4};
        
        insert(sourceData);

        Map<String, String> params = new Map<String, String>{
            'selectedFormat'=>'Acumatica', 
            'uploadVerification'=>'Vivek R - 07/28/2018 1:00 PM - Acumatica'
        };
            
        SalesDataUploadBatch con = new SalesDataUploadBatch(params);

        Test.startTest();
            database.executeBatch(con,10);
        Test.stopTest();

        
    
    
    }
  
     static testMethod void testSalesDataUploadBatchUPDNew(){
     
         ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
     
      account D1, D2, D3, R1, R2, R3;
      List<Account> sourceAccounts;
     Id DistriRecTypeId, RetailerRecTypeId;
     
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
     /*  
        D1 = new Account();
        D1.Name = 'TestDistributor';
      //  D1.Status__c = 'Cusztomer (Reporting)';
        //D1.ShippingCountry = 'US';
       // D1.CurrencyISOCode = 'USD';
        D1.recordTypeId = DistriRecTypeId;
        D1.MSA_Distributor_Id__c = 'TestDistributor';
       
        D2 = new Account();
        D2.Name = 'TestDistributor2';
        D2.Status__c = 'Customer (Reporting)';
       D2.ShippingCountry = 'US';
        D2.CurrencyISOCode = 'USD';
        D2.recordTypeId = DistriRecTypeId;
        D2.MSA_Distributor_Id__c = 'TestDistributor2';

        R1 = new Account();
        R1.Name = 'TestRetailer';
       R1.Status__c = 'Customer (Reporting)';
        R1.ShippingCountry = 'US';
        R1.CurrencyISOCode = 'USD';
        R1.recordTypeId = RetailerRecTypeId;
        R1.MSA_Retail_Number__c = 'TestRetailer';
        R1.Customer_Success_Manager__c = CSM1.Id;
        
        R2 = new Account();
        R2.Name = 'TestRetailer2';
        R2.Status__c = 'Customer (Reporting)';
        R2.ShippingCountry = 'US';
        R2.CurrencyISOCode = 'USD';
        R2.recordTypeId = RetailerRecTypeId;
        R2.MSA_Retail_Number__c = 'TestRetailer2';
        R2.Customer_Success_Manager__c = CSM1.Id;
        
        R3 = new Account();
        R3.Name = 'TestRetailer3';
        R3.Status__c = 'Customer (Reporting)';
        R3.ShippingCountry = 'US';
        R3.CurrencyISOCode = 'USD';
        R3.recordTypeId = RetailerRecTypeId;
        R3.MSA_Retail_Number__c = 'TestRetailer3';
        R3.Customer_Success_Manager__c = CSM1.Id;
       
       //Retailers by TD Linx ID
        Account accTD = new Account();
        accTD.Name = 'TDlinx';
        accTD.TDLinx_ID__c = 'TDlinx1';
        //accTD.RACS_Status__c='';
              
              
              Insert accTD;
        
       // sourceAccounts = new List<Account>{D1,R1,accTD};
       // Insert(sourceAccounts);
       */
                 List<Account> accList2= new List<Account>();

          Account a = new Account(Name='Test',MSA_Distributor_Id__c='TestDistributor');
        accList2.add(a);
        
        Account a2 = new Account(Name='Test2',MSA_Retail_Number__c='TestRetailer');
                Account a3 = new Account(Name = 'TDlinx',TDLinx_ID__c = 'TDlinx1');
        
        Account personA = new Account();
        personA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        personA.LastName = 'test';   
        personA.NSL_Effective_Date__c = system.today();
        personA.CurrencyIsoCode = 'USD';
        personA.PersonEmail = 'xyz@gmail.com';
        personA.Phone = '1234567890';
       // insert personA;
        
        Account businnessA = new Account();
        businnessA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        businnessA.Name = 'Test';
        businnessA.CurrencyIsoCode = 'USD';
     //   insert businnessA;
      
        
        accList2.add(a2);
                accList2.add(a3);
                
                                accList2.add(personA);

                                accList2.add(businnessA);

insert accList2;
       
        Product2 P1 = new Product2(Product_Country__c='US', Name='Test Product1',ProductCode = '11111', MSA_Item_Id__c ='P001', Default_Price__c=20.00);
        Product2 P2 = new Product2(Product_Country__c='US', Name='Test Product2',ProductCode = '22222', MSA_Item_Id__c ='P002', Default_Price__c=30.00);
        Product2 P3 = new Product2(Product_Country__c='US', Name='Test Product3',ProductCode = '33333', MSA_Item_Id__c ='P003', Default_Price__c=40.00);
        List<Product2> sourceProducts = new List<Product2>{P1,P2,P3};
        Insert(sourceProducts);
                                   
           
        //Test Case 1, Sales Data for Delete - Should get deleted successfully
        Sales_Data__c newSD1 = new Sales_Data__c();
        newSD1.Distributor_External_Id__c = 'TestDistributor';
        newSD1.Retailer_External_Id__c = 'TestRetailer';
        newSD1.Product__c = 'P001';
        newSD1.Date__c = '07/29/2018';//'03/01/2020';
        newSD1.Quantity__c = '0';
        newSD1.Delta_Row__c = 'D';
        newSD1.MSA_Shipment_Line_External_ID__c = 'D001-R001-20200301-P001';
        newSD1.MSA_Sales_Order_External_ID__c = 'D001-R001-20200301';
        newSD1.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Delete';
               newSD1.Sales_Order_Name__c = 'TestOrder1';


        //Test Case 2, Sales Data for Delete - Should never get processed as record not found
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'TestDistributor';
        newSD2.Retailer_External_Id__c = 'TestRetailer';
        newSD2.Product__c = 'P002';
        newSD2.Date__c = '07/29/2018';//'03/01/2020';
        newSD2.Quantity__c = '0';
        newSD2.Delta_Row__c = 'D';
        newSD2.MSA_Shipment_Line_External_ID__c = 'D0010-R0010-20200301-P0010';
        newSD2.MSA_Sales_Order_External_ID__c = 'D0010-R0010-20200301';
        newSD2.Upload_Verification__c = 'SB - 03/04/2020 1:00 PM - MSA Delete';
                       newSD2.Sales_Order_Name__c = 'TestOrder2';

           Sales_Data__c newSD = new Sales_Data__c();
        newSD.Distributor_External_Id__c = 'TestDistributor';
        newSD.Retailer_External_Id__c = 'TestRetailer';
        newSD.Retailer_TDLinx_Id__c = 'TDlinx1';
        newSD.Product__c = 'P003';
        newSD.Date__c = '07/29/2018';
        newSD.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD.Quantity__c = '100';
                       newSD.Sales_Order_Name__c = 'TestOrder3';

   Sales_Data__c testSD = new Sales_Data__c();
        testSD.Distributor_External_Id__c = 'TestDistributor';
        testSD.Retailer_External_Id__c = 'TestRetailer';
        testSD.Retailer_TDLinx_Id__c = 'TDlinx1';
        testSD.Product__c = 'P003';
        testSD.Date__c = '08/29/2018';
        testSD.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        testSD.Quantity__c = '100';
                       testSD.Sales_Order_Name__c = 'TestOrder3';


        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD1,newSD2,newSD,testSD};
        Insert(sourceData);
        
        test.startTest();
        
        
        List<SalesOrder__c> SalesOrders = new  List<SalesOrder__c>();
               Salesorder__c newSalesOrder = new Salesorder__c();
              newSalesOrder.Distributor__c = a.Id;
              newSalesOrder.Date__c ='07/29/2018';//'2010-01-01'; 
              newSalesOrder.Customer__c =  a.Id;
              newSalesOrder.OrderType__c  = 'MSA';
              newSalesOrder.currencyISOCode = 'USD';
                             newSalesOrder.name = 'TestOrder1';

             // newSalesOrder.MSA_Retail_Number__c=a2.id;
           SalesOrders.add(newSalesOrder);
        
        Salesorder__c newSalesOrder1 = new Salesorder__c();
              newSalesOrder1.Distributor__c = a.Id;
              newSalesOrder1.Date__c ='07/29/2018';//'2010-01-01';     
                       newSalesOrder1.Customer__c =  a3.Id;
              newSalesOrder1.OrderType__c  = 'MSA';
              newSalesOrder1.currencyISOCode = 'USD';
                                           newSalesOrder1.name = 'TestOrder2';

           SalesOrders.add(newSalesOrder1);
             
               
        salesOrder__c salesOrder3 = new salesOrder__c();
        salesOrder3.Name = 'TestOrder3';
        salesOrder3.Customer__c = personA.Id;
        salesOrder3.Distributor__c = businnessA.Id;
        salesOrder3.CurrencyIsoCode = 'USD';
        salesOrder3.Date__c = '07/29/2018';//string.valueof(system.now()+5);
      //  salesOrder3.Sales_Order_Name__c = 'TestOrder3';

      //  insert salesOrder3; 
        
        SalesOrders.add(salesOrder3);
            
          salesOrder__c so = new salesOrder__c();
            so.Name ='TestOrder1';
            so.Customer__c = a.Id;
            so.Distributor__c =  a.id;
            so.Date__c ='07/29/2018'; //'03/01/2020';   
          // so.Sales_Order_Name__c = 'TestOrder1';
 
     //   insert so;
        
       SalesOrders.add(so);
       
       
         Salesorder__c salesOrder4 = new Salesorder__c();
              salesOrder4.Distributor__c = a.Id;
              salesOrder4.Date__c ='07/29/2018';
              salesOrder4.Customer__c =  a.Id;
              salesOrder4.OrderType__c  = 'MSA';
              salesOrder4.currencyISOCode = 'USD';
             // newSalesOrder.MSA_Retail_Number__c=a2.id;
                        salesOrder4.name = 'TestOrder2';

           SalesOrders.add(salesOrder4);
        
        Salesorder__c salesOrder5 = new Salesorder__c();
              salesOrder5.Distributor__c = personA.Id;
              salesOrder5.Date__c ='07/29/2018';//'2010-01-01';     
                       salesOrder5.Customer__c =  businnessA.Id;
              salesOrder5.OrderType__c  = 'MSA';
              salesOrder5.currencyISOCode = 'USD';
              salesOrder5.name='TestOrder2';
           SalesOrders.add(salesOrder5);
             
               
        salesOrder__c salesOrder6 = new salesOrder__c();
        salesOrder6.Name = 'TestOrder3';
        salesOrder6.Customer__c = a3.Id;
        salesOrder6.Distributor__c = a3.Id;
        salesOrder6.CurrencyIsoCode = 'USD';
        salesOrder6.Date__c = '07/29/2018';//string.valueof(system.now()+5);
      //  insert salesOrder3; 
        
        SalesOrders.add(salesOrder6);
            
          salesOrder__c so2 = new salesOrder__c();
            so2.Name ='TestOrder2';
            so2.Customer__c = a2.Id;
            so2.Distributor__c =  a2.id;
            so2.Date__c = '07/29/2018';//'03/01/2020';    
     //   insert so;
        
       SalesOrders.add(so2);
       
       
        salesOrder__c so3 = new salesOrder__c();
            so3.Name ='TestOrder2';
            so3.Customer__c = a2.Id;
            so3.Distributor__c =  a2.id;
            so3.Date__c = '08/29/2018';//'03/01/2020';    
     //   insert so;
        
       SalesOrders.add(so3);
       
       
       insert SalesOrders;
        
                  List<Document_Details__c> docList= new List<Document_Details__c>();

           Document_Details__c ddRec = new Document_Details__c();
            ddRec.Name='Test Document Detail';
            ddRec.Quantity__c = 4;
            ddRec.Product__c = p3.id;
            ddRec.salesOrderNumber__c = newSalesOrder1.id;//so.id;
            
           //insert ddRec;
           
           
           document_Details__c ddRec2 = new Document_Details__c();
            ddRec2.Name='Test Document Detail2';
            ddRec2.Quantity__c = 4;
            ddRec2.Product__c = p3.id;
            ddRec2.salesOrderNumber__c =newSalesOrder1.id;// newSalesOrder.id;
            
            document_Details__c ddRec3 = new Document_Details__c();
            ddRec3.Name='Test Document Detail3';
            ddRec3.Quantity__c = 4;
            ddRec3.Product__c = p3.id;
            ddRec3.salesOrderNumber__c =newSalesOrder1.id;// newSalesOrder1.id;
            
            document_Details__c ddRec4 = new Document_Details__c();
            ddRec4.Name='Test Document Detail4';
            ddRec4.Quantity__c = 4;
            ddRec4.Product__c = p3.id;
            ddRec4.salesOrderNumber__c = newSalesOrder1.id;//salesOrder3.id;
            
              document_Details__c ddRec5 = new Document_Details__c();
            ddRec5.Name='Test Document Detail4';
            ddRec5.Quantity__c = 4;
            ddRec5.Product__c = p3.id;
            ddRec5.salesOrderNumber__c = so3.id;//salesOrder3.id;
           docList.add(ddRec5);
            
           docList.add(ddRec);
                      docList.add(ddRec2);

           docList.add(ddRec3);

           docList.add(ddRec4);

     insert docList;
      /*  
          List<Account> accList2= new List<Account>();
        Account a = new Account(Name='Test',MSA_Distributor_Id__c='TestDistributor');
        accList2.add(a);
        
        Account a2 = new Account(Name='Test',MSA_Retail_Number__c='TestRetailer');
        accList2.add(a2);
        
        Product2 p = new Product2(Name='Test Product',MSA_Item_Id__c = 'TestProduct');
        insert(p);

     
        insert(newSD);
        */

        Map<String, String> params = new Map<String, String>{
            'selectedFormat'=>'MSA', 
            'uploadVerification'=>'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA'
        };
        SalesDataUploadBatch con = new SalesDataUploadBatch(params);

     //   Test.startTest();
            database.executeBatch(con,10);
        Test.stopTest();

    }
    
}