@isTest(SeeAllData=false)
public class ACMShipmentTriggerHandlerTest {
    @isTest
    static void testHandleBeforeInsert() {
        
    Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='SalesOrderTrigger',Enabled__c=true);
        insert(triggerController);
   
    List<Account> listAccountToInsert = new List<Account>();
       ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
    /**** Creation of Account records *****/   
      
         Account accRec= new Account();
         accRec.Name = 'Test Account ';
         accRec.BillingStreet = null;
         //accRec.ShippingStreet = null;
         accRec.ShippingCountry = 'US';
         accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();    
         listAccountToInsert.add(accRec); 
       insert listAccountToInsert;    
    /**** End of creation of Account records *****/   
           
    /**** Creation of SalesOrder records *****/   
     List<SalesOrder__c> listSoToInsert = new List<SalesOrder__c>();
              SalesOrder__c So  = new SalesOrder__c();
              //So.Name = 'Test SalesOrder '+j;
              So.OrderType__c = 'MSA';
              So.Date__c = '2019-02-23';
              So.Customer__c = accRec.id;
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
    
      
    insert listSoToInsert;
      
  
    ACM_Shipment__c shipment = new ACM_Shipment__c();
shipment.State__c = 'TX';
shipment.Country__c = 'United States';
shipment.Zip__c = '12345';
shipment.Sales_Order_Number__c = So.Id;
insert shipment; 
        // call the trigger
        ACMShipmentTriggerHandler.handleBeforeInsert(new List<ACM_Shipment__c>{ shipment });

        // query the updated shipment
        ACM_Shipment__c updatedShipment = [SELECT State__c, Country__c, Zip__c FROM ACM_Shipment__c WHERE Id = :shipment.Id];

        System.assertEquals('TX', updatedShipment.State__c);
        System.assertEquals('United States', updatedShipment.Country__c);
        System.assertEquals('12345', updatedShipment.Zip__c);

        // call the trigger
        ACMShipmentTriggerHandler.handleBeforeUpdate(new List<ACM_Shipment__c>{ shipment }, new List<ACM_Shipment__c>{ shipment });

        // query the updated shipment
        ACM_Shipment__c updatedShipments = [SELECT State__c, Country__c, Zip__c FROM ACM_Shipment__c WHERE Id = :shipment.Id];

}
}