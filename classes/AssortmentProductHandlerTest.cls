@isTest(SeeAllData=false)
public class AssortmentProductHandlerTest {

      @testSetup static void setup(){
            ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        accList.add(acc);
          insert accList;
        
        List<Product2> prodList = new List<Product2>();
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        prodList.add(p);
        
        Product2 p1= new Product2();
        p1.name= 'Test Items2';
        p1.Family='Accessories';
        p1.IsActive = true;
        p1.Product_Country__c = 'US';
        p1.ProductPricingFamily__c='DK';
        p1.US_E_Order_Enabled__c = true;
        prodList.add(p1);
        insert prodList;
         
          
        StateTerritory__c st = new StateTerritory__c();
        st.Country__c = 'US';
        st.StateTerritoryName__c = 'Hawaii';
        st.Name = 'Hawaii';
        st.StateISO2__c='HI';
        insert st;
               
        List<PricingMatrix__c> pmList = new List<PricingMatrix__c>();
        PricingMatrix__c pm = new PricingMatrix__c();
        pm.Active__c = true;
        pm.ProductId__c= p1.id;
        pm.Country__c = 'US';
        pm.StateTerritory__c =st.id;
        pm.ProductPricingFamily__c ='DK';
        pm.Start_Date__c = Date.Today().addDays(-5);
        pm.End_Date__c = Date.Today().addDays(25);
        pm.Start_Date__c = system.today();
        pmList.add(pm);
          
        insert pmList;
        Assortment__c ap= new Assortment__c();
          ap.Country__c ='US';
          ap.Name= 'Test Assortment';
          insert ap;
          
          
      }
      static testMethod void testMethod1(){
          test.startTest();
          product2 p3 =[select id from product2 where name='Test Items2'];
          Assortment__c a3 =  [select id from Assortment__c where name='Test Assortment'];
          AssortmentProduct__c asp = new 	AssortmentProduct__c();
          asp.ProductId__c = p3.id;
          asp.AssortmentId__c = a3.id;
          asp.Country__c= 'US';
          insert asp;
              
         test.stopTest();
      }
    
}