@isTest                             
private class SalesUploadLogicTest {
    static testMethod void testSalesDataUploadBatchAcumatica(){
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
        
        //Test Case 1, New Sales Order + DD
        Sales_Data__c newSD = new Sales_Data__c();
        newSD.Retailer_External_Id__c = '1111';
        newSD.JUUL_Item_Number__c = '12345';
        newSD.Date__c = '01/01/2010';
        newSD.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - Acumatica';
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
        newSD2.JUUL_Item_Number__c = '54321';
        newSD2.Date__c = '01/01/2010';
        newSD2.Sales_Order_Name__c = 'TestOrder1';
        newSD2.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - Acumatica';
        newSD2.Quantity__c = '200';

        //Test Case 3, Update existing DD
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Retailer_External_Id__c = '1111';
        newSD3.JUUL_Item_Number__c = '12345';
        newSD3.Date__c = '01/01/2010';
        newSD3.Sales_Order_Name__c = 'TestOrder1';
        newSD3.Custom_Field_7__c = 'TestDocDetails1';
        newSD3.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - Acumatica';
        newSD3.Quantity__c = '150';

                
        //Test Case 4, New Account + SO + DD
        
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Retailer_External_Id__c = '2222';
        newSD4.Retailer_Name__c = 'Test';
        newSD4.JUUL_Item_Number__c = '12345';
        newSD4.Date__c = '01/01/2010';
        newSD4.Sales_Order_Name__c = 'TestOrder3';
        newSD4.Custom_Field_7__c = 'TestDocDetails3';
        newSD4.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - Acumatica';
        newSD4.Quantity__c = '150';
        
        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD,newSD2,newSD3,newSD4};
        
        insert(sourceData);

        Map<String, String> params = new Map<String, String>{
            'selectedFormat'=>'Acumatica', 
            'uploadVerification'=>'Vivek Ravisankar - 07/28/2018 1:00 PM - Acumatica'
        };
        SalesDataUploadBatch con = new SalesDataUploadBatch(params);

        Test.startTest();
            database.executeBatch(con,10);
        Test.stopTest();

        Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c FROM Sales_Data__c WHERE Id IN : sourceData]);
        System.debug(salesDataMap);
        System.debug([SELECT Id, Order_Date__c, Name, Customer__r.MagentoEntityId__c FROM SalesOrder__c]);
        //Test Case 1
        List<Salesorder__c> salesOrderCaseTest1 = [SELECT Id, Order_Date__c FROM Salesorder__c WHERE customer__c = : a1.Id];
        System.assertEquals(2, salesOrderCaseTest1.size());
        System.debug( salesOrderCaseTest1[0].Order_Date__c);
        System.assertEquals(Date.newInstance(2010,1,1), salesOrderCaseTest1[0].Order_Date__c);
        System.assertEquals(Date.newInstance(2010,1,1), salesOrderCaseTest1[1].Order_Date__c);

        List<Salesorder__c> salesOrderCase1 = [SELECT Id, Order_Date__c, Name, Status__c, OrderTotal__c, Payment_Method__c, Days_Since_Previous_Order__c, Customer_PO_Number__c, AcumaticaId__c FROM Salesorder__c WHERE customer__c = : a1.Id AND Id != : existingSalesOrder1.Id];
        System.assertEquals(1, salesOrderCase1.size());
        System.assertEquals('TestOrder2',salesOrderCase1[0].Name);
        System.assertEquals('Test Status',salesOrderCase1[0].Status__c);
        System.assertEquals(100,salesOrderCase1[0].OrderTotal__c);
        System.assertEquals('Test Payment Method',salesOrderCase1[0].Payment_Method__c);
        //System.assertEquals(100,salesOrderCase1[0].Days_Since_Previous_Order__c);
        System.assertEquals('Test PO Number',salesOrderCase1[0].Customer_PO_Number__c);
        System.assertEquals('Test Acumatica Customer Id',salesOrderCase1[0].AcumaticaId__c);

        List<Document_Details__c> docDetailsCase4 = [SELECT Id, Quantity__c, Product__c,AcumaticaID__c, Unique_Id__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase1[0].Id];
        System.assertEquals(1, docDetailsCase4.size());
        System.assertEquals(100, docDetailsCase4[0].Quantity__c);
        System.assertEquals(p.Id, docDetailsCase4[0].Product__c);
        System.assertEquals('Test Acumatica DD ID', docDetailsCase4[0].AcumaticaID__c);
        System.assertEquals('TestDocDetails2', docDetailsCase4[0].Unique_Id__c);

        
        //Test Case 2
        List<Salesorder__c> salesOrderCase2 = [SELECT Id, Order_Date__c FROM Salesorder__c WHERE customer__c = : a1.Id and Id = :existingSalesOrder1.Id];
        List<Document_Details__c> docDetailsCaseTest = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase2[0].Id];
        System.assertEquals(2, docDetailsCaseTest.size());

        List<Document_Details__c> docDetailsCase2 = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase2[0].Id And Product__r.ProductCode = '54321'];
        System.assertEquals(1, docDetailsCase2.size());
        System.assertEquals(200, docDetailsCase2[0].Quantity__c);
        

        //Test Case 3
        List<Document_Details__c> docDetailsCase3 = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase2[0].Id And Product__r.ProductCode = '12345'];
        System.assertEquals(1, docDetailsCase3.size());
        System.assertEquals(150, docDetailsCase3[0].Quantity__c);
        
        //Test Case 4
        System.assertEquals(2,[SELECT Count() FROM Account] );
        System.assertEquals(3,[SELECT Count() FROM SalesOrder__c] );
    }
    static testMethod void testSalesDataUploadBatchMSA(){
        System.debug('Begin Test');
        Account a = new Account(Name='Test',MSA_Distributor_Id__c='TestDistributor');
        insert(a);
        
        Account a2 = new Account(Name='Test',MSA_Retail_Number__c='TestRetailer');
        insert(a2);

        Account a3 = new Account(Name='Test',TDLinx_Id__c='TestTDLinx');
        insert(a3);
        
        Product2 p = new Product2(Name='Test Product',MSA_Item_Id__c = 'TestProduct');
        insert(p);

        Product2 p2 = new Product2(Name='Test Product 2',MSA_Item_Id__c = 'TestProduct2');
        insert(p2);

        Salesorder__c existingSalesOrder1 = new Salesorder__c(Date__c = '2010-01-01', Distributor__c = a.Id, Customer__c = a2.Id, OrderType__c = 'MSA');
        insert(existingSalesOrder1);

        Document_Details__c existingDocDetails1 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder1.Id, Product__c = p.Id, Quantity__c = 1);
        insert(existingDocDetails1);
        
        Salesorder__c existingSalesOrder2 = new Salesorder__c(Date__c='2010-01-01', Distributor__c = a.Id, Customer__c = a3.Id, OrderType__c = 'MSA');
        insert(existingSalesOrder2);

        Document_Details__c existingDocDetails2 = new Document_Details__c(salesOrderNumber__c=existingSalesOrder2.Id, Product__c = p.Id, Quantity__c = 1);
        insert(existingDocDetails2);

        //Test Case 1, Distro is missing
        Sales_Data__c newSD = new Sales_Data__c();
        newSD.Distributor_External_Id__c = 'FAKEDISTRO';
        newSD.Retailer_External_Id__c = 'TestRetailer';
        newSD.Product__c = 'TestProduct';
        newSD.Date__c = '07/16/2018';
        newSD.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD.Quantity__c = '100';

        //Test Case 2, Retailer is missing
        Sales_Data__c newSD2 = new Sales_Data__c();
        newSD2.Distributor_External_Id__c = 'TestDistributor';
        newSD2.Retailer_External_Id__c = 'FAKERETAILER';
        newSD2.Product__c = 'TestProduct';
        newSD2.Date__c = '07/16/2018';
        newSD2.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD2.Quantity__c = '100';

        //Test Case 3, Product is missing
        Sales_Data__c newSD3 = new Sales_Data__c();
        newSD3.Distributor_External_Id__c = 'TestDistributor';
        newSD3.Retailer_External_Id__c = 'TestRetailer';
        newSD3.Product__c = 'FAKEPRODUCT';
        newSD3.Date__c = '07/16/2018';
        newSD3.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD3.Quantity__c = '100';

        //Test Case 4, Match by TD LINX, Brand new SO
        Sales_Data__c newSD4 = new Sales_Data__c();
        newSD4.Distributor_External_Id__c = 'TestDistributor';
        newSD4.Retailer_TDLinx_Id__c = 'TestTDLinx';
        newSD4.Retailer_External_Id__c = 'FAKERETAILER';
        newSD4.Product__c = 'TestProduct';
        newSD4.Date__c = '01/01/2099';
        newSD4.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD4.Quantity__c = '4';

        //Test Case 5, missing TD Linx, Match by Retailer, Brand new SO
        Sales_Data__c newSD5 = new Sales_Data__c();
        newSD5.Distributor_External_Id__c = 'TestDistributor';
        newSD5.Retailer_TDLinx_Id__c = 'FAKETDLINX';
        newSD5.Retailer_External_Id__c = 'TestRetailer';
        newSD5.Product__c = 'TestProduct';
        newSD5.Date__c = '01/01/2099';
        newSD5.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD5.Quantity__c = '5';

        //Test Case 6, match existing SO by Retailer and existing DD
        Sales_Data__c newSD6 = new Sales_Data__c();
        newSD6.Distributor_External_Id__c = 'TestDistributor';
        newSD6.Retailer_TDLinx_Id__c = 'FAKETDLINX';
        newSD6.Retailer_External_Id__c = 'TestRetailer';
        newSD6.Product__c = 'TestProduct';
        newSD6.Date__c = '01/01/2010';
        newSD6.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD6.Quantity__c = '6';

        //Test Case 7, match existing SO by Retailer and new DD
        Sales_Data__c newSD7 = new Sales_Data__c();
        newSD7.Distributor_External_Id__c = 'TestDistributor';
        newSD7.Retailer_TDLinx_Id__c = 'FAKETDLINX';
        newSD7.Retailer_External_Id__c = 'TestRetailer';
        newSD7.Product__c = 'TestProduct2';
        newSD7.Date__c = '01/01/2010';
        newSD7.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD7.Quantity__c = '7';


        //Test Case 8, match existing SO by TD Linx and existing DD
        Sales_Data__c newSD8 = new Sales_Data__c();
        newSD8.Distributor_External_Id__c = 'TestDistributor';
        newSD8.Retailer_TDLinx_Id__c = 'TestTDLinx';
        newSD8.Retailer_External_Id__c = 'TestRetailer';
        newSD8.Product__c = 'TestProduct';
        newSD8.Date__c = '01/01/2010';
        newSD8.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD8.Quantity__c = '8';

        //Test Case 9, match existing SO by TD Linx and new DD
        Sales_Data__c newSD9 = new Sales_Data__c();
        newSD9.Distributor_External_Id__c = 'TestDistributor';
        newSD9.Retailer_TDLinx_Id__c = 'TestTDLinx';
        newSD9.Retailer_External_Id__c = 'TestRetailer';
        newSD9.Product__c = 'TestProduct2';
        newSD9.Date__c = '01/01/2010';
        newSD9.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD9.Quantity__c = '9';

        List<Sales_Data__c> sourceData = new List<Sales_Data__c>{newSD,newSD2,newSD3,newSD4,newSD5,newSD6,newSD7,newSD8,newSD9};
        
        insert(sourceData);

        Map<String, String> params = new Map<String, String>{
            'selectedFormat'=>'MSA', 
            'uploadVerification'=>'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA'
        };
        SalesDataUploadBatch con = new SalesDataUploadBatch(params);

        Test.startTest();
            database.executeBatch(con,10);
        Test.stopTest();

        Map<Id,Sales_Data__c> salesDataMap = new Map<Id,Sales_Data__c>([SELECT Id, Is_Processed__c, Error_Details__c FROM Sales_Data__c WHERE Id IN : sourceData]);

        //Test Case 1
        System.assertEquals('Distributor not found.', salesDataMap.get(newSD.Id).Error_Details__c);

        //Test Case 2
        System.assertEquals('Retailer not found.', salesDataMap.get(newSD2.Id).Error_Details__c);

        //Test Case 3
        System.assertEquals('Product not found.', salesDataMap.get(newSD3.Id).Error_Details__c);

        System.debug([SELECT Id, Order_Date__c, Date__c, Customer__r.Name FROM Salesorder__c ORDER BY Customer__c]);

        //Test Case 4
        List<Salesorder__c> salesOrderCase4 = [SELECT Id, Order_Date__c FROM Salesorder__c WHERE customer__c = : a3.Id and Id != : existingSalesOrder2.Id];
        System.assertEquals(1, salesOrderCase4.size());
        System.debug( salesOrderCase4[0].Order_Date__c);
        System.assertEquals(Date.newInstance(2099,1,1), salesOrderCase4[0].Order_Date__c);

        List<Document_Details__c> docDetailsCase4 = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase4[0].Id];
        System.assertEquals(1, docDetailsCase4.size());
        System.assertEquals(4, docDetailsCase4[0].Quantity__c);
        System.assertEquals(p.Id, docDetailsCase4[0].Product__c);

        //Test Case 5
        List<Salesorder__c> salesOrderCase5 = [SELECT Id, Order_Date__c FROM Salesorder__c WHERE customer__c = : a2.Id and Id != :existingSalesOrder1.Id];
        System.assertEquals(1, salesOrderCase5.size());
        System.assertEquals(Date.newInstance(2099,1,1), salesOrderCase5[0].Order_Date__c);

        List<Document_Details__c> docDetailsCase5 = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase5[0].Id];
        System.assertEquals(1, docDetailsCase5.size());
        System.assertEquals(5, docDetailsCase5[0].Quantity__c);
        System.assertEquals(p.Id, docDetailsCase5[0].Product__c);

        //Test Case 6
        Salesorder__c salesOrderCase6 = [SELECT Id, Order_Date__c FROM Salesorder__c WHERE customer__c = : a2.Id and Id =: existingSalesOrder1.Id];
        System.assertEquals(Date.newInstance(2010,1,1), salesOrderCase6.Order_Date__c);

        List<Document_Details__c> docDetailsCase6 = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase6.Id ORDER BY CreatedDate ASC];
        System.assertEquals(2, docDetailsCase6.size());
        System.assertEquals(6, docDetailsCase6[0].Quantity__c);
        System.assertEquals(p.Id, docDetailsCase6[0].Product__c);

        //Test Case 7
        System.assertEquals(7, docDetailsCase6[1].Quantity__c);
        System.assertEquals(p2.Id, docDetailsCase6[1].Product__c);

        
        //Test Case 8
        Salesorder__c salesOrderCase8 = [SELECT Id, Order_Date__c FROM Salesorder__c WHERE customer__c = : a3.Id and Id =: existingSalesOrder2.Id];
        System.assertEquals(Date.newInstance(2010,1,1), salesOrderCase8.Order_Date__c);

        List<Document_Details__c> docDetailsCase8 = [SELECT Id, Quantity__c, Product__c FROM Document_Details__c WHERE salesOrderNumber__c = :salesOrderCase8.Id ORDER BY CreatedDate ASC];
        System.assertEquals(2, docDetailsCase8.size());
        System.assertEquals(8, docDetailsCase8[0].Quantity__c);
        System.assertEquals(p.Id, docDetailsCase8[0].Product__c);

        //Test Case 9
        System.assertEquals(9, docDetailsCase8[1].Quantity__c);
        System.assertEquals(p2.Id, docDetailsCase8[1].Product__c);
        
    }
    
    static testMethod void testSalesDataUploadBatchUPD(){
        Account a = new Account(Name='Test',MSA_Distributor_Id__c='TestDistributor');
        insert(a);
        
        Account a2 = new Account(Name='Test',MSA_Retail_Number__c='TestRetailer');
        insert(a2);
        
        Product2 p = new Product2(Name='Test Product',MSA_Item_Id__c = 'TestProduct');
        insert(p);

        Sales_Data__c newSD = new Sales_Data__c();
        newSD.Distributor_External_Id__c = 'TestDistributor';
        newSD.Retailer_External_Id__c = 'TestRetailer';
        newSD.Product__c = 'TestProduct';
        newSD.Date__c = '07/16/2018';
        newSD.Upload_Verification__c = 'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA';
        newSD.Quantity__c = '100';

        insert(newSD);

        Map<String, String> params = new Map<String, String>{
            'selectedFormat'=>'MSA', 
            'uploadVerification'=>'Vivek Ravisankar - 07/28/2018 1:00 PM - MSA'
        };
        SalesDataUploadBatch con = new SalesDataUploadBatch(params);

        Test.startTest();
            database.executeBatch(con,10);
        Test.stopTest();

    }
    
}