@isTest
public class MSASORecordsDeleteTest {
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
      
      // Create Custom setting        
      BatchConstantValues__c dateCustomsetting = new BatchConstantValues__c(Name ='BatchBrandProtection', GBSuspensionResetDate__c= 90,X3_Strike_Account_Blacklist_Reset__c = 1, X3_Strike_Account_Suspension_Reset__c= 1, X3_Strike_Enforcement_Start_Date__c = System.Today(),X3_Strike_Admin_EmailIds__c='test.test12@juul.com' );
      Insert dateCustomsetting;
      
    /**** Creation of Account records *****/   
       for(Integer i=0; i<10; i++){   
         Account accRec= new Account();
         accRec.Name = 'Test Account '+i;
         accRec.BillingStreet = null;
         accRec.ShippingStreet = null;  
         accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();    
         listAccountToInsert.add(accRec); 
       }    
       insert listAccountToInsert;    
    /**** End of creation of Account records *****/   
           
    /**** Creation of SalesOrder records *****/   
    for(Integer i=0; i<10; i++){
      Account acc = listAccountToInsert[i];  
         for (Integer j=0;j<10;j++){
              SalesOrder__c So  = new SalesOrder__c();
              So.Name = 'Test SalesOrder '+j;
              So.OrderType__c = 'MSA';
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
    * @Description this method runs the  batch 
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void createSalesOrder_Test1(){        
        Test.StartTest();
         Map<String, String> mapInputs =  new Map<String, String>();
         Datetime dt = Datetime.now().addMinutes(1);
         String cronExp = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
         System.schedule('MSASORecordsDelete', cronExp, new MSASORecordsDelete(mapInputs));
         Database.executeBatch(new MSASORecordsDelete(mapInputs));
        Test.StopTest(); 
         List<SalesOrder__c> listOfSo = [Select Id from SalesOrder__c Where Number_of_Doc_Details__c = 0.0 AND orderType__c = 'MSA'];
         system.assertEquals(listOfSo.size(), 0, 'All Record Deleted Successfully');
    }
   
}