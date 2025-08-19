@isTest(SeeAllData = False)
public class Batch_MSASalesOrderExternalIDUpdateTest {
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
       ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
    /**** Creation of Account records *****/   
       for(Integer i=0; i<5; i++){   
         Account accRec= new Account();
         accRec.Name = 'Test Account '+i;
         accRec.BillingStreet = null;
         //accRec.ShippingStreet = null;
         accRec.ShippingCountry = 'US';
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
              So.OrderType__c = 'MSA';
              So.Date__c = '2019-02-23';
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
      
      // Insert SalesData 
      Sales_Data__c sd =new Sales_Data__c(Name='TestSalesName',
                                       Date__c  =  String.ValueOf(Date.Today()),
                                       Product__c = 'ProductTest',
                                       Distributor_External_Id__c ='Ext',
                                       Retailer_External_Id__c ='Ret');
      Insert sd;
      
      List<Document_Details__c> docList = new List<Document_Details__c>();
      Integer k = 0;
      for(SalesOrder__c so : listSoToInsert) {
          docList.add(new Document_Details__c(Name='TestDocumentDetails'+k,
                                       salesOrderNumber__c = so.id,
                                       CurrencyIsoCode = 'CAD',MSA_Shipment_Line_External_ID__c='ttwerwrwresdfsdfs32'+k,Sales_Data__c=sd.id));
          k++;
      }
      
      Insert docList;
      
      
    /**** End of creation of SalesOrder records *****/   
  }
    /**************************************************************************************
    * @Description this method runs the SalesOrderTriggerHandler
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
     private static testMethod void UpdateMSAExternalIDOnDocDetail_Test1(){       
         Test.StartTest();
         Map<String, String> mapInputs =  new Map<String, String>();
         Database.executeBatch(new Batch_MSASalesOrderExternalIDUpdate(mapInputs));
         Test.StopTest(); 
         salesOrder__c ord =  [Select id,MSA_Sales_Order_External_ID__c,OrderType__c,Order_Date__c From salesOrder__c limit 1 ];
         system.assertEquals(ord.MSA_Sales_Order_External_ID__c, 'ExtRet20190223');
         
    }
    
    @isTest static void testMSASalesOrderExternalIDUpdate() {       
        Test.startTest();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Batch_MSASalesOrderExternalIDUpdate Check', sch, new Batch_MSASalesOrderExternalIDUpdate());
        Test.stopTest();
    }
}