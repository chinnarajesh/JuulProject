@isTest(SeeAllData = False)
public class SalesOrderTriggerHandlerTest {
 /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/    
  @testSetup
  public static void prepData(){
    Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='SalesOrderTrigger',Enabled__c=true);
        insert(triggerController);
    List<SalesOrder__c> listSoToInsert = new List<SalesOrder__c>();
    List<Account> listAccountToInsert = new List<Account>();
      
    /**** Creation of Account records *****/   
       for(Integer i=0; i<5; i++){   
         Account accRec= new Account();
         accRec.Name = 'Test Account '+i;
         accRec.BillingStreet = null;
         //accRec.ShippingStreet = null;
         accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();    
         listAccountToInsert.add(accRec); 
       }    
       insert listAccountToInsert;    
    /**** End of creation of Account records *****/   
           
    /**** Creation of SalesOrder records *****/   
    for(Integer i=0; i<5; i++){
      Account acc = listAccountToInsert[i];  
         for (Integer j=0;j<5;j++){
              SalesOrder__c So  = new SalesOrder__c();
              So.Name = 'Test SalesOrder '+j;
              So.OrderType__c = 'BO';
              So.Customer__c = acc.id;
              So.SOBilling_City__c = 'Billing City+j'; 
              So.SOBilling_Country__c = 'Billing Country+j';
              So.SOBilling_Zip__c = '0000+j';
              So.SOBilling_State__c = 'Billing State+j';
              So.SOBilling_Address_1__c = 'BillingAddress1+j';
              So.SOBilling_Address_2__c = 'BillingAddress2+j';
              So.SOShipping_City__c = 'Shipping City+j'; 
              So.SOShipping_Country__c = 'Shipping Country+j';
              So.SOShipping_Zip__c = '0000+j';
              So.SOShipping_State__c = 'Shipping State+j';
              So.SOShipping_Address_1__c = 'ShippingAddress1+j';
              So.SOShipping_Address_2__c = 'ShippingAddress2+j';
              listSoToInsert.add(So);
         }
    }
    insert listSoToInsert;
    /**** End of creation of SalesOrder records *****/   
  }
    /**************************************************************************************
    * @Description this method runs the SalesOrderTriggerHandler
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createSalesOrder_Test1(){
        List<SalesOrder__c> listso = [Select id,orderType__c,Customer_Billing_Street__c,Customer_ShippingAddress__c,Customer__c,SOBilling_City__c,SOBilling_Country__c,SOBilling_Zip__c,SOBilling_State__c,SOBilling_Address_1__c, 
                           SOBilling_Address_2__c,SOShipping_City__c,SOShipping_Country__c,SOShipping_Zip__c,SOShipping_State__c,
                           SOShipping_Address_1__c,SOShipping_Address_2__c,Order_Date__c from SalesOrder__c LIMIT 2];
        Test.StartTest();
        SalesOrderTriggerHandler SoTrigger = new SalesOrderTriggerHandler();
        SalesOrderTriggerHandler.handleAfterInsertUpdateCustomer(listso);
        Test.StopTest(); 
         List<Account> listAccountToInsert = [Select id ,BillingCity,BillingCountry,BillingPostalCode,ShippingCity From Account];
         for(Account acc : listAccountToInsert){
             System.assert(acc.BillingCity != null);
             System.assert(acc.BillingCountry != null);
             System.assert(acc.BillingPostalCode != null);
             System.assert(acc.ShippingCity != null);
         }
         
    }
    
   
}