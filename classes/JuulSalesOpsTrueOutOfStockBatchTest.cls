@isTest 
public class JuulSalesOpsTrueOutOfStockBatchTest {
    @testSetup static void setup(){
        // create accounts
        List<Account> lstAccount= new List<Account>();
        for(Integer i=0; i < 5; i++){
            Account acc = new Account();
            acc.LastName = 'LastName'+i;
            acc.PersonEmail = 'abc'+i+'@test.com';
            acc.Phone = '1238901234';
            lstAccount.add(acc);
        }
        insert lstAccount;
        system.assertEquals(5, lstAccount.size(),  'Accounts created');
        
        // create products
        List<Product2> lstProducts = new List<Product2>();
        for(Integer i=0; i < 5; i++){
            Product2 prod = new Product2();
            prod.Name = 'Product'+i;
            lstProducts.add(prod);
        }
        insert lstProducts;
        System.assertEquals(5, lstProducts.size(), ' Products created');
        // create Out of Stock
        List<Out_Of_Stock__c> lstOOS = new List<Out_Of_Stock__c>();
        for(Integer i=0; i < 5; i++){
            Out_Of_Stock__c OOS = new Out_Of_Stock__c();     
            OOS.Account__c = lstAccount[i].Id;
            OOS.Product__c = lstProducts[i].Id;
            if(i == 0){
                OOS.Validated_By__c = 'CMK';
                OOS.Audit_Date__c = Date.parse('04/10/2019'); //Date.today();
            }else if(i == 1){
                OOS.Validated_By__c = 'JUUL';
                OOS.Audit_Date__c = Date.parse('04/05/2019'); //Date.today();
             }else if(i == 2){
                OOS.Validated_By__c = 'CMK';
                OOS.Audit_Date__c = Date.parse('04/04/2019'); //Date.today();
             }else if(i == 3){
                OOS.Validated_By__c = 'AGDC';
                OOS.Audit_Date__c = Date.parse('04/03/2019'); //Date.today();
             }else if(i == 4){
                OOS.Validated_By__c = 'CMK';
                OOS.Audit_Date__c = Date.parse('04/02/2019'); //Date.today();
            }else{
                OOS.Validated_By__c = 'AGDC';
                OOS.Audit_Date__c = Date.parse('03/31/2019'); //Date.today();
            }
            lstOOS.add(OOS);
        }
        insert lstOOS;
        System.assertEquals(5, lstOOS.size(), 'Out of stock created');
        
        True_Out_Of_Stock_ValidationPeriod__c obj = new True_Out_Of_Stock_ValidationPeriod__c();
        obj.Name = 'OOS NumDays Emails';
        obj.Admin_Emails__c = 'keerthana.guddeti@juul.com,keerthana.guddeti@juul.com';
        obj.OOS_Validation_Period_In_Days__c = 91;
        insert obj;
        System.assert(obj != null, 'Custom setting value created');
        
     /*   OOS_Batch_Emails_to_Admins__c objOOSBatchAdmins = new OOS_Batch_Emails_to_Admins__c();
        objOOSBatchAdmins.Name  = 'Admin Emails';
        objOOSBatchAdmins.Admin_Emails__c = 'keerthana.guddeti@juul.com,keerthana.guddeti@juul.com';
        insert objOOSBatchAdmins;
        System.assert(objOOSBatchAdmins != null, 'Custom setting value created'); */
        
        True_Out_Of_Stock_ValidationPeriod__c objCSValidation = True_Out_Of_Stock_ValidationPeriod__c.getValues('OOS NumDays Emails');
        Integer CSValidationPeriod = Integer.ValueOf(objCSValidation.OOS_Validation_Period_In_Days__c); 
        
        System.assertEquals(91, CSValidationPeriod);
        // create Sales Order
        List<salesOrder__c> lstSalesOrdr = new List<salesOrder__c>();
        for(Integer i=0; i < 5; i++){
            salesOrder__c so = new salesOrder__c();
            so.Name ='SalesOrder'+i;
            so.Customer__c = lstAccount[i].Id;
            if(i == 0){
            so.Date__c = '04/15/2019';//String.ValueOf(Date.today().addDays(CSValidationPeriod));
            } else if(i == 1){
                        so.Date__c = '03/10/2019';//String.ValueOf(Date.today().addDays(CSValidationPeriod));
            } else if(i == 2){
                        so.Date__c = '04/04/2019';//String.ValueOf(Date.today().addDays(CSValidationPeriod));
            } else if(i == 3){            
                so.Date__c = '03/03/2018';//String.ValueOf(Date.today().addDays(CSValidationPeriod));
            } else if(i == 4){
                so.Date__c = '03/01/2019';//String.ValueOf(Date.today().addDays(CSValidationPeriod));
            }  
             
            system.debug('##'+CSValidationPeriod);
            system.debug(so.Date__c);
            system.debug(so.Date_Ordered__c+ '@@@@' + so.Order_Date__c);
            lstSalesOrdr.add(so);
        }
        insert lstSalesOrdr;
  
        system.assertEquals(5, lstSalesOrdr.size());
        // create Document Detail
        List<Document_Details__c> lstDocumentDetails = new List<Document_Details__c>();
        for(Integer i=0; i < 5; i++){
            Document_Details__c dd = new Document_Details__c();
            dd.Name ='Document Details'+i;
            dd.salesOrderNumber__c = lstSalesOrdr[i].Id;
            dd.Product__c = lstProducts[i].Id;
            dd.quantity__c = 2+i;
            
            lstDocumentDetails.add(dd);
        }
        insert lstDocumentDetails;
            System.assertEquals(5, lstDocumentDetails.size());
    }
    static testMethod void JuulSalesOpsTrueOutOfStockBatch1() {
        
        Map<String, String> mapInputs = new Map<String, String>{
                'Validated_By__c' => '', 
                'Audit_Date__c'   => '',
                'overrideQuery'   =>  ' WHERE Audit_Date__c = 2019-04-10'
                };
                    
        Test.startTest();
        JuulSalesOpsTrueOutOfStockBatch OOSBatch = new JuulSalesOpsTrueOutOfStockBatch(mapInputs);
        DataBase.executeBatch(OOSBatch, 20);
        Test.stopTest();
    }
    
    static testMethod void JuulSalesOpsTrueOutOfStockBatch2() {
        
        Map<String, String> mapInputs = new Map<String, String>{
            'Validated_By__c'   => 'CMK', 
                'Audit_Date__c' => '2019-04-04',
                'overrideQuery' => ''
                };
                    
        Test.startTest();
        JuulSalesOpsTrueOutOfStockBatch OOSBatch = new JuulSalesOpsTrueOutOfStockBatch(mapInputs);
        DataBase.executeBatch(OOSBatch, 20);
        Test.stopTest();
    }
       static testMethod void JuulSalesOpsTrueOutOfStockBatch3() {
        
        Map<String, String> mapInputs = new Map<String, String>{
            'Validated_By__c'   => '', 
                'Audit_Date__c' => '',
                'overrideQuery' => ''
                };
                    
        Test.startTest();
        JuulSalesOpsTrueOutOfStockBatch OOSBatch = new JuulSalesOpsTrueOutOfStockBatch(mapInputs);
        DataBase.executeBatch(OOSBatch, 20);
        Test.stopTest();
    }
    
}