@isTest
public class JuulSalesOpsSuggestedDataBatch_Test{
    public static testMethod void testSuggestedDataUploadBatch1(){
        Map<String, String> params = new Map<String,String>();
        params.put('selectedFormat','CMK');
        params.put('uploadVerification','uploadVerification');
        JuulSalesOpsSuggestedDataUploadBatch sugbatch = new JuulSalesOpsSuggestedDataUploadBatch(params);
        sugBatch.dataFormat = 'CMK';
        /*//Distributer
        Account accDis = new Account();
        accDis.Name = 'Distributer';
        accDis.MSA_Distributor_Id__c = 'Distributer1';
        Insert accDis;
        
        //Retailer
        Account accRetail = new Account();
        accRetail.Name = 'Retailer';
        accRetail.MSA_Retail_Number__c = 'Retailer1';
        Insert accRetail;*/
        
        //Retailers by TD Linx ID
        Account accTD = new Account();
        accTD.Name = 'TDlinx';
        accTD.TDLinx_ID__c = 'TDlinx1';
        Insert accTD;
        
        //Products
        Product2 pro1 = new Product2();
        pro1.Name = 'Product';
        pro1.UPC_ID__c = '1234';
        Insert pro1;
        
        //Suggested Orders
        Suggested_Order__c sugOrd1 = new Suggested_Order__c();
        //sugOrd1.Distributor__c = accDis.id;
        sugOrd1.Customer__c = accTD.id;
        sugOrd1.Suggested_Order_Date__c = date.parse('03/19/2019');
        Insert sugOrd1;
        
        //suggested order item
        Suggested_Order_Item__c sugOrdItem1 = new Suggested_Order_Item__c();
        sugOrdItem1.Suggested_Order__c = sugOrd1.id;
        sugOrdItem1.Product__c = pro1.id;
        insert sugOrdItem1;
        
        //Suggested Data
        Suggested_data__c sugData1 = new Suggested_data__c();
        //sugData1.Distributor_External_Id__c = 'Distributer1';
        //sugData1.Retailer_External_Id__c = 'Retailer1';
        sugData1.Retailer_TDLinx_Id__c = 'TDlinx1';
        sugData1.Date__c = '03/19/2019';
        sugData1.UPC__c = '1234';
        sugData1.Quantity__c = '1';
        sugData1.Upload_Verification__c = 'uploadVerification';
        Insert sugData1;
        Id batExecute = DataBase.executeBatch(sugBatch);
    }
    
    
    public static testMethod void testSuggestedDataUploadBatch2(){
        Map<String, String> params = new Map<String,String>();
        params.put('selectedFormat','CMK');
        params.put('uploadVerification','uploadVerification');
        JuulSalesOpsSuggestedDataUploadBatch sugbatch = new JuulSalesOpsSuggestedDataUploadBatch(params);
        sugBatch.dataFormat = 'CMK';
        /*//Distributer
        Account accDis = new Account();
        accDis.Name = 'Distributer';
        accDis.MSA_Distributor_Id__c = 'Distributer1';
        Insert accDis;
        
        //Retailer
        Account accRetail = new Account();
        accRetail.Name = 'Retailer';
        accRetail.MSA_Retail_Number__c = 'Retailer1';
        Insert accRetail;*/
        
        //Retailers by TD Linx ID
        Account accTD = new Account();
        accTD.Name = 'TDlinx';
        accTD.TDLinx_ID__c = 'TDlinx1';
        Insert accTD;
        
        //Products
        Product2 pro1 = new Product2();
        pro1.Name = 'Product';
        pro1.UPC_ID__c= 'Product1';
        Insert pro1;
        
        //Suggested Orders
        Suggested_Order__c sugOrd1 = new Suggested_Order__c();
        //sugOrd1.Distributor__c = accDis.id;
        sugOrd1.Customer__c = accTD.id;
        sugOrd1.Suggested_Order_Date__c = date.parse('03/19/2019');
        Insert sugOrd1;
        
        //suggested order item
        Suggested_Order_Item__c sugOrdItem1 = new Suggested_Order_Item__c();
        sugOrdItem1.Suggested_Order__c = sugOrd1.id;
        sugOrdItem1.Product__c = pro1.id;
        insert sugOrdItem1;
        
        //Suggested Data
        Suggested_data__c sugData1 = new Suggested_data__c();
        //sugData1.Distributor_External_Id__c = 'Distributer1';
        //sugData1.Retailer_External_Id__c = 'Retailer1';
        sugData1.Retailer_TDLinx_Id__c = 'TDlinx2';
        sugData1.Date__c = '03/19/2019';
        sugData1.UPC__c= 'Product1';
        sugData1.Quantity__c = '1';
        sugData1.Upload_Verification__c = 'uploadVerification';
        Insert sugData1;
        Id batExecute = DataBase.executeBatch(sugBatch);
    }
    public static testMethod void testSuggestedDataUploadBatch3(){
        Map<String, String> params = new Map<String,String>();
        params.put('selectedFormat','CMK');
        params.put('uploadVerification','uploadVerification');
        JuulSalesOpsSuggestedDataUploadBatch sugbatch = new JuulSalesOpsSuggestedDataUploadBatch(params);
        sugBatch.dataFormat = 'CMK';
        /*//Distributer
        Account accDis = new Account();
        accDis.Name = 'Distributer';
        accDis.MSA_Distributor_Id__c = 'Distributer1';
        Insert accDis;
        
        //Retailer
        Account accRetail = new Account();
        accRetail.Name = 'Retailer';
        accRetail.MSA_Retail_Number__c = 'Retailer1';
        Insert accRetail;*/
        
        //Retailers by TD Linx ID
        Account accTD = new Account();
        accTD.Name = 'TDlinx';
        accTD.TDLinx_ID__c = 'TDlinx1';
        Insert accTD;
        
        //Products
        Product2 pro1 = new Product2();
        pro1.Name = 'Product';
        pro1.UPC_ID__c= 'Product1';
        Insert pro1;
        
        //Suggested Orders
        Suggested_Order__c sugOrd1 = new Suggested_Order__c();
        //sugOrd1.Distributor__c = accDis.id;
        sugOrd1.Customer__c = accTD.id;
        sugOrd1.Suggested_Order_Date__c = date.parse('03/19/2019');
        sugOrd1.OrderType__c = 'CMK';
        Insert sugOrd1;
        
        //suggested order item
        Suggested_Order_Item__c sugOrdItem1 = new Suggested_Order_Item__c();
        sugOrdItem1.Suggested_Order__c = sugOrd1.id;
        sugOrdItem1.Product__c = pro1.id;
        insert sugOrdItem1;
        
        //Suggested Data
        Suggested_data__c sugData1 = new Suggested_data__c();
        //sugData1.Distributor_External_Id__c = 'Distributer1';
        //sugData1.Retailer_External_Id__c = 'Retailer1';
        sugData1.Retailer_TDLinx_Id__c = 'TDlinx1';
        sugData1.Date__c = '03/19/2019';
        sugData1.UPC__c= 'Product1';
        sugData1.Quantity__c = '1';
        sugData1.Upload_Verification__c = 'uploadVerification';
        Insert sugData1;
        Id batExecute = DataBase.executeBatch(sugBatch);
    }
    public static testMethod void testSuggestedDataUploadBatch4(){
        Map<String, String> params = new Map<String,String>();
        params.put('selectedFormat','CMK');
        params.put('uploadVerification','uploadVerification');
        JuulSalesOpsSuggestedDataUploadBatch sugbatch = new JuulSalesOpsSuggestedDataUploadBatch(params);
        sugBatch.dataFormat = 'CMK';
        /*//Distributer
        Account accDis = new Account();
        accDis.Name = 'Distributer';
        accDis.MSA_Distributor_Id__c = 'Distributer1';
        Insert accDis;
        
        //Retailer
        Account accRetail = new Account();
        accRetail.Name = 'Retailer';
        accRetail.MSA_Retail_Number__c = 'Retailer1';
        Insert accRetail;*/
        
        //Retailers by TD Linx ID
        Account accTD = new Account();
        accTD.Name = 'TDlinx';
        accTD.VIP_ID__c = 'TDlinx1';
        Insert accTD;
        
        //Products
        Product2 pro1 = new Product2();
        pro1.Name = 'Product';
        pro1.UPC_ID__c= '1111';
        Insert pro1;
        
        Product2 pro2 = new Product2();
        pro2.Name = 'Product';
        pro2.UPC_ID__c= '2222';
        Insert pro2;
        
        
        //Suggested Orders
        Suggested_Order__c sugOrd1 = new Suggested_Order__c();
        //sugOrd1.Distributor__c = accDis.id;
        sugOrd1.Customer__c = accTD.id;
        sugOrd1.Suggested_Order_Date__c = date.parse('03/19/2019');
        sugOrd1.OrderType__c = 'CMK';
        Insert sugOrd1;
        
        //suggested order item
        /*Suggested_Order_Item__c sugOrdItem1 = new Suggested_Order_Item__c();
        sugOrdItem1.Suggested_Order__c = sugOrd1.id;
        sugOrdItem1.Product__c = pro1.id;
        insert sugOrdItem1;
        Suggested_Order_Item__c sugOrdItem2 = new Suggested_Order_Item__c();
        sugOrdItem2.Suggested_Order__c = sugOrd1.id;
        sugOrdItem2.Product__c = pro2.id;
        insert sugOrdItem2;*/
        
        //Suggested Data
        Suggested_data__c sugData1 = new Suggested_data__c();
        //sugData1.Distributor_External_Id__c = 'Distributer1';
        //sugData1.Retailer_External_Id__c = 'Retailer1';
        sugData1.VIP_ID__c = 'TDlinx1';
        sugData1.Date__c = '03/19/2019';
        sugData1.UPC__c= '1111';
        sugData1.Quantity__c = '1';
        sugData1.Upload_Verification__c = 'uploadVerification';
        Insert sugData1;
        Suggested_data__c sugData2 = new Suggested_data__c();
        //sugData1.Distributor_External_Id__c = 'Distributer1';
        //sugData1.Retailer_External_Id__c = 'Retailer1';
        sugData2.Retailer_TDLinx_Id__c = 'TDlinx1';
        sugData2.Date__c = '03/19/2019';
        sugData2.UPC__c= '2222';
        sugData2.Quantity__c = '1';
        sugData2.Upload_Verification__c = 'uploadVerification';
        Insert sugData2;
        sugBatch.getCSVDateStringFromDate('2019-03-19');
        Id batExecute = DataBase.executeBatch(sugBatch);
        
    }
}