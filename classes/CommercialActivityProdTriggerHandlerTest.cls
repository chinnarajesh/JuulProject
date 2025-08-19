/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Shreya Raut             26-03-2021                     */
/* Class Name: CommunityActivityPrdTest                               */
/* Description:Test Class for CommercialActivityProdTriggerHandlerTest             */
/**********************************************************************/
@isTest(SeeAllData=false)
public class CommercialActivityProdTriggerHandlerTest {


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
         
        CommercialActivity__c ca = new CommercialActivity__c();
        ca.Name='Test Commercial Activity';
        ca.Country__c='US';
        insert ca;
        List<CommercialActivityProduct__c> capList = new List<CommercialActivityProduct__c>();
        CommercialActivityProduct__c cai = new CommercialActivityProduct__c();
        cai.ProductId__c = p.id;
        cai.ProductType__c ='JUUL Product';
        cai.CommercialActivityId__c = ca.id;
        cai.HideItemWhilePlanning__c = true;
        cai.Product_Bundle__c='Combo';
        cai.Product_bundle_Description__c='P1';
        cai.Country__c='US';
        capList.add(cai);
        
        CommercialActivityProduct__c cai1 = new CommercialActivityProduct__c();
        cai1.ProductId__c =p1.id;
        cai1.ProductType__c ='Trade Collateral';
        cai1.HideItemWhilePlanning__c = true;
        cai1.CommercialActivityId__c = ca.id;
        cai1.Product_Bundle__c='Combo';
        cai1.Product_bundle_Description__c='P1';
        cai1.Country__c='US';
        capList.add(cai1);
        
        CommercialActivityProduct__c cai2 = new CommercialActivityProduct__c();
        cai2.ProductId__c =p1.id;
        cai2.ProductType__c ='Trade Collateral';
        cai2.CommercialActivityId__c = ca.id;
        cai2.HideItemWhilePlanning__c = true;
        cai2.Product_Bundle__c='Getxsavex';
        cai2.Product_bundle_Description__c='G1';
        cai2.Country__c='US';
        capList.add(cai2);
        insert capList;
    }

    static testMethod void testResetPlanning(){
        test.startTest();
        CommercialActivity__c c = [select id,Product_Bundle_Error__c,Commercial_Activity_Status__c from CommercialActivity__c where name='Test Commercial Activity'];
        System.debug('CommercialActivity__c'+c);
        List<CommercialActivityProduct__c> capList1 = new List<CommercialActivityProduct__c>();
        
        system.assertEquals(false, c.Commercial_Activity_Status__c);
        CommercialActivityProduct__c p = [select id,Product_bundle_Description__c from CommercialActivityProduct__c where Product_bundle_Description__c='G1' ];
        p.Product_bundle_Description__c='P1';
        p.Product_Bundle__c='Combo';
        update p;
        delete p;
        product2 p3 =[select id from product2 where name='Test Items2'];
        CommercialActivityProduct__c cai3 = new CommercialActivityProduct__c();
        cai3.ProductId__c =p3.id;
        cai3.ProductType__c ='Trade Collateral';
        cai3.CommercialActivityId__c = c.id;
        cai3.HideItemWhilePlanning__c = true;
        cai3.Product_Bundle__c='Getxsavex';
        cai3.Product_bundle_Description__c='G1';
        cai3.Country__c='US';
        insert cai3;
         CommercialActivityProduct__c cai4 = new CommercialActivityProduct__c();
        cai4.ProductId__c =p3.id;
        cai4.ProductType__c ='Trade Collateral';
        cai4.CommercialActivityId__c = c.id;
        cai4.HideItemWhilePlanning__c = true;
        cai4.Product_Bundle__c='Getxsavex';
        cai4.Product_bundle_Description__c='G1';
        cai4.Country__c='US';
        insert cai4;
        delete cai4;
        test.stopTest();
    }
    

}