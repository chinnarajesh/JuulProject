/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       02-19-2021                    */
/* Class Name: KAMUpdatePricingMatriceControllerTest                       */
/* Description: Test class for coverage KAMUpdatePricingMatriceController  */
 /*Ticket Number: SFDC - 0000003183    */
/**********************************************************************/
@isTest
public class KAMUpdatePricingMatriceControllerTest {
    @testSetup
    public static void setup(){
        List<StateTerritory__c> listSt = new List<StateTerritory__c>();
        StateTerritory__c st = new StateTerritory__c();
        st.Name = 'California';
        st.Country__c = 'US';
        st.StateTerritoryName__c = 'California';
        st.StateTerritoryUniqueName__c = 'California-CA';
        st.StateTax__c = 8.0000;
        st.AdditionalTax__c = 1.0000;
        st.RK4PK__c = 10.00;
        st.RK2PK__c = 0.00;
        st.DK__c = 20.00;
        st.Accessory1__c = 519.99;
        listSt.add(st);        
        insert listSt;
        
        List<Product2> lstPrd = new List<Product2>();
        Product2 p = new Product2();
        p.Name = 'US Basic Device Kit Silver';
        p.ProductCode = 'J1D1846';
        p.ProductPricingFamily__c = 'DK';
        p.Family = 'Devices';    
		p.Product_Country__c = 'US';        
       // p.CurrencyIsoCode = 'USD - U.S. Dollar';
        lstPrd.add(p);
        
         Product2 p1 = new Product2();
        p1.Name = 'US Pods Menthol 5.0% 2.8ml 4pack';
        p1.ProductCode = 'J1T1434';
        p1.ProductPricingFamily__c = 'RK 4PK';
        p1.Family = 'Pods';    
		p1.Product_Country__c = 'US';         
        //p1.CurrencyIsoCode = 'USD - U.S. Dollar';
        lstPrd.add(p1);
        
         Product2 p2 = new Product2();
        p2.Name = 'MKT5523 - JUUL Price Per Pod (4pk) 2020 Header 4’ US	t';
        p2.ProductCode = 'MKT5523';
        p2.ProductPricingFamily__c = 'DK';
        p2.Family = 'Marketing Assets'; 
        p2.Product_Country__c = 'US'; 
        //p2.CurrencyIsoCode = 'USD - U.S. Dollar';
        lstPrd.add(p2);
        
        insert lstPrd;
        
        List<PricingMatrix__c> pricingMat = new List<PricingMatrix__c>();
        PricingMatrix__c pm = new PricingMatrix__c();
        pm.StateTerritory__c = st.Id;
        pm.Country__c = 'US';
        pm.ProductId__c = p.Id;
        pm.ProductPricingFamily__c = 'DK';
        pm.Start_Date__c = Date.Today().addDays(15);
        pm.End_Date__c = Date.Today().addDays(25);
        pricingMat.add(pm);
        
        PricingMatrix__c pm1 = new PricingMatrix__c();
        pm1.StateTerritory__c = st.Id;
        pm1.Country__c = 'US';
        pm1.ProductId__c = p1.Id;
        pm1.ProductPricingFamily__c = 'RK 4PK';
        pm1.Start_Date__c = Date.Today().addDays(15);
        pm1.End_Date__c = Date.Today().addDays(25);
        pricingMat.add(pm1);
        
        PricingMatrix__c pm2 = new PricingMatrix__c();
        pm2.StateTerritory__c = st.Id;
        pm2.Country__c = 'US';
        pm2.ProductId__c = p2.Id;
        pm2.ProductPricingFamily__c = 'DK';
        pm2.Start_Date__c = Date.Today().addDays(15);
        pm2.End_Date__c = Date.Today().addDays(25);
        pricingMat.add(pm2);
        
        insert pricingMat;
        
    }
    
    static testMethod void getKAMUpdatePricingMatriceControllerTest(){
        StateTerritory__c sterr = new StateTerritory__c();
        sterr.Name = 'Alaska';
        sterr.Country__c = 'US';
        sterr.StateTerritoryName__c = 'Alaska';
        //sterr.StateTerritoryUniqueName__c = 'California-CA';
        sterr.StateTax__c = 8.0000;
        sterr.AdditionalTax__c = 1.0000;
        sterr.RK4PK__c = 10.00;
        sterr.RK2PK__c = 0.00;
        sterr.DK__c = 20.00;
        sterr.Accessory1__c = 519.99;
        insert sterr;
        
        Product2 pr = new Product2();
        pr.Name = 'MKT5523 - JUUL Price Per Pod (4pk) 2020 Header 4’ US	t';
        pr.ProductCode = 'MKT5523';
        pr.ProductPricingFamily__c = 'DK';
        pr.Family = 'Marketing Assets';       
        pr.Product_Country__c = 'US'; 
        insert pr;
        
        List<PricingMatrix__c> pricingMatrix = new List<PricingMatrix__c>();
         PricingMatrix__c price = new PricingMatrix__c();
        price.StateTerritory__c = sterr.Id;
        price.Country__c = 'US';
        price.ProductId__c = pr.Id;
        price.ProductPricingFamily__c = 'DK';
        price.Start_Date__c = Date.Today().addDays(15);
        price.End_Date__c = Date.Today().addDays(25);
        //pricingMatrix.add(price);
        insert price;
        List<KAMUpdatePricingMatriceController.pricingMatrixWrapper> wrapText = new List<KAMUpdatePricingMatriceController.pricingMatrixWrapper>();
        KAMUpdatePricingMatriceController.pricingMatrixWrapper wrapObj = new KAMUpdatePricingMatriceController.pricingMatrixWrapper();
       wrapObj.productId = pr.Id;
        wrapObj.country = 'US';
        wrapObj.stateTerritoryId = sterr.Id;
        wrapObj.productPricingFamily = pr.ProductPricingFamily__c;
        wrapObj.isSelected = true;
        wrapObj.allStartDate = Date.today();
        wrapObj.allEndDate = Date.today().addDays(10);
     //   wrapObj.isAllSelected = false;
        wrapText.add(wrapObj);  
        
        KAMUpdatePricingMatriceController.pricingMatrixWrapper wrapObj1 = new KAMUpdatePricingMatriceController.pricingMatrixWrapper();
       wrapObj1.productId = pr.Id;
        wrapObj1.country = 'US';
        wrapObj1.stateTerritoryId = sterr.Id;
        wrapObj1.productPricingFamily = pr.ProductPricingFamily__c;
		wrapObj1.isSelected = false;
       wrapObj1.isAllSelected = true;
         wrapObj1.allStartDate = Date.today();
        wrapObj1.allEndDate = Date.today().addDays(10);
        wrapText.add(wrapObj1);
        
        KAMUpdatePricingMatriceController.pricingMatrixWrapper wrapObj2 = new KAMUpdatePricingMatriceController.pricingMatrixWrapper();
       wrapObj2.productId = pr.Id;
        wrapObj2.country = 'US';
        wrapObj2.stateTerritoryId = sterr.Id;
        wrapObj2.productPricingFamily = pr.ProductPricingFamily__c;
		wrapObj2.isSelected = false;
       wrapObj2.isAllSelected = true;
         wrapObj2.startDate = Date.today();
        wrapObj2.endDate = Date.today().addDays(10);
        wrapText.add(wrapObj2);
        
        KAMUpdatePricingMatriceController.pricingMatrixWrapper wrapObj3 = new KAMUpdatePricingMatriceController.pricingMatrixWrapper();
       wrapObj3.productId = pr.Id;
        wrapObj3.country = 'US';
        wrapObj3.stateTerritoryId = sterr.Id;
        wrapObj3.productPricingFamily = pr.ProductPricingFamily__c;
        wrapObj3.isSelected = true;
        wrapObj3.startDate = Date.today();
        wrapObj3.endDate = Date.today().addDays(10);
     //   wrapObj.isAllSelected = false;
        wrapText.add(wrapObj3);  
        
        //List<KAMUpdatePricingMatriceController.pricingMatrixWrapper> wrapText1 = new List<KAMUpdatePricingMatriceController.pricingMatrixWrapper>();
           
         test.startTest();        
        //List<StateTerritory__c> sterr =[SELECT Id FROM StateTerritory__c];
        List<Product2> prod = [Select Id from Product2];
        
        List<StateTerritory__c> listState = [SELECT Id FROM StateTerritory__c];
        List<KAMUpdatePricingMatriceController.pricingMatrixWrapper> wrapText1 = new List<KAMUpdatePricingMatriceController.pricingMatrixWrapper>();
        wrapText1 =  KAMUpdatePricingMatriceController.getPricingDetails(listState[0].Id);  
        System.assertEquals(wrapText1[0].productPricingFamily, 'DK');
        
        KAMUpdatePricingMatriceController.getStateDetails();
        //KAMUpdatePricingMatriceController.pricingMatrixWrapper wr = new KAMUpdatePricingMatriceController.saveData(wrapText);
        //KAMUpdatePricingMatriceController kpr = new KAMUpdatePricingMatriceController();
        KAMUpdatePricingMatriceController.saveData(wrapText);
        KAMUpdatePricingMatriceController.handleErrorProduct();
        
        //KAMUpdatePricingMatriceController.validateStartDateEndDate(wrapText);        
        List<KAMUpdatePricingMatriceController.pricingMatrixWrapper> wrapText2 = new List<KAMUpdatePricingMatriceController.pricingMatrixWrapper>();
        wrapText2 = KAMUpdatePricingMatriceController.validateStartDateEndDate(wrapText);
        System.assertEquals(wrapText2[0].productPricingFamily, 'DK');
         
         test.stopTest();
        
    }
}