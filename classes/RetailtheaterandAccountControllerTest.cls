@istest
public class RetailtheaterandAccountControllerTest {

    @istest
    public static void test(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
         Account acc = new Account();
        acc.Name='Test';
        acc.Type='National Chain Retailer';
        acc.ShippingCountry = 'US';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        acc.RACS_Status__c = 'Not Committed	';
        acc.X2D_Bar_Scanner__c = true;
        insert acc;
        
        cgcloud__Product_Template__c  Pt = new cgcloud__Product_Template__c ();
        Pt.cgcloud__Active__c = true;
        Pt.cgcloud__Sales_Org__c = '0001';
        Pt.Name = 'test Product Template';
        Pt.cgcloud__Description_Language_1__c = 'test';
        insert Pt;
        
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        p.cgcloud__Product_Template__c = Pt.Id;
        p.cgcloud__Description_1_Language_1__c = 'test';
        insert p;
        Product2 p1= new Product2();
        p1.name= 'Test Items2';
        p1.Family='Accessories';
        p1.IsActive = true;
        p1.Product_Country__c = 'US';
        p1.ProductPricingFamily__c='DK';
        p1.US_E_Order_Enabled__c = true;
        p1.cgcloud__Product_Template__c = Pt.Id;
        p1.cgcloud__Description_1_Language_1__c = 'test';
        insert p1;
        
        Retail_Theater__c testRetailTheater = new Retail_Theater__c();
        //testRetailTheater.Accessory_Audit_Facings__c = 500;
        testRetailTheater.Account__c = acc.id;
        testRetailTheater.Audit_Date__c = system.today();
        testRetailTheater.Shelf_Talker_Count__c  = 800.00;
        testRetailTheater.X2pk_Price_Location__c = 'Scroller';
        insert testRetailTheater;
        
       /* Address  address = new Address();
        address.Address = '46 Napanoch, New York 12458 US';
        address.AddressType = 'Mailing ';
        address.LocationType = 'Warehouse ';
        insert address;
		*/
        cgcloud__Data_Type__c  DT = new cgcloud__Data_Type__c ();
        DT.cgcloud__Sales_Org__c = '0001';
        DT.cgcloud__Data_Type__c = 'Toggle';
        DT.Name = 'testdatatype';
        DT.cgcloud__Long_Name__c = 'long test';
        DT.cgcloud__Manual__c = true;
        DT.cgcloud__Customizable__c = true;
        insert DT;
        
        cgcloud__Job_Template__c  jobTemp = new cgcloud__Job_Template__c ();
        jobTemp.cgcloud__Sales_Org__c = '0001';
        jobTemp.cgcloud__Description_Language_4__c = 'test';
        jobTemp.cgcloud__Product_Reference__c = true;
        jobTemp.Name = 'test';
		insert jobTemp;
        
        cgcloud__Job_Definition_Template__c  jobDefTemp = new cgcloud__Job_Definition_Template__c ();
        jobDefTemp.Mapping_object__c = 'Account';
        jobDefTemp.Mapping_field__c = 'X2D_Bar_Scanner__c';
        jobDefTemp.cgcloud__Active__c = true;
        jobDefTemp.cgcloud__Description_Language_1__c = 'test';
        jobDefTemp.cgcloud__Max_Value__c = 700;
        jobDefTemp.cgcloud__Min_Value__c = 300;
        jobDefTemp.cgcloud__Job_Template__c = jobTemp.Id;
        jobDefTemp.cgcloud__Data_Type__c = DT.Id;
        insert jobDefTemp;
        cgcloud__Job_Definition_Template__c  jobDefTemp1 = new cgcloud__Job_Definition_Template__c ();
        jobDefTemp1.Mapping_object__c = 'Account';
        jobDefTemp1.Mapping_field__c = 'RACS_Status__c';
        jobDefTemp1.cgcloud__Active__c = true;
        jobDefTemp1.cgcloud__Description_Language_1__c = 'test';
        jobDefTemp1.cgcloud__Max_Value__c = 700;
        jobDefTemp1.cgcloud__Min_Value__c = 300;
        jobDefTemp1.cgcloud__Job_Template__c = jobTemp.Id;
        jobDefTemp1.cgcloud__Data_Type__c = DT.Id;
        insert jobDefTemp1;
        
        cgcloud__Job_Definition_Template__c  jobDefTemp2 = new cgcloud__Job_Definition_Template__c ();
        jobDefTemp2.Mapping_object__c = 'Retail_Theater__c';
        jobDefTemp2.Mapping_field__c = 'Shelf_Talker_Count__c';
        jobDefTemp2.cgcloud__Active__c = true;
        jobDefTemp2.cgcloud__Description_Language_1__c = 'test';
        jobDefTemp2.cgcloud__Max_Value__c = 700;
        jobDefTemp2.cgcloud__Min_Value__c = 300;
        jobDefTemp2.cgcloud__Job_Template__c = jobTemp.Id;
        jobDefTemp2.cgcloud__Data_Type__c = DT.Id;
        insert jobDefTemp2;
        cgcloud__Job_Definition_Template__c  jobDefTemp3 = new cgcloud__Job_Definition_Template__c ();
        jobDefTemp3.Mapping_object__c = 'Retail_Theater__c';
        jobDefTemp3.Mapping_field__c = 'X2pk_Price_Location__c ';
        jobDefTemp3.cgcloud__Active__c = true;
        jobDefTemp3.cgcloud__Description_Language_1__c = 'test';
        jobDefTemp3.cgcloud__Max_Value__c = 700;
        jobDefTemp3.cgcloud__Min_Value__c = 300;
        jobDefTemp3.cgcloud__Job_Template__c = jobTemp.Id;
        jobDefTemp3.cgcloud__Data_Type__c = DT.Id;
        insert jobDefTemp3;
        RetailStore RS = new RetailStore();
        RS.Name = 'Retail';
        RS.AccountId = acc.Id;
        insert RS;
        
        Visit  visit = new Visit ();
        visit.AccountId = acc.Id;
        //visit.VisitPriority = 'High';
        visit.PlaceId = RS.Id;
        visit.Retail_Theater__c = testRetailTheater.Id;
        visit.PlannedVisitStartTime = system.today();
        insert visit;
        
      /*  cgcloud__Visit_Job__c vj = new cgcloud__Visit_Job__c();
        vj.cgcloud__Visit__c  = visit.Id;
        vj.cgcloud__Visit_Date__c = system.today();
        vj.cgcloud__Job_Definition_Template__c = jobDefTemp.Id;
        vj.cgcloud__Product__c = p1.Id;
        //vj.cgcloud__Display_Value__c = 'yes';
        insert vj;
		*/
        cgcloud__Visit_Job__c vj1 = new cgcloud__Visit_Job__c();
        vj1.cgcloud__Visit__c  = visit.Id;
        vj1.cgcloud__Visit_Date__c = system.today();
        vj1.cgcloud__Job_Definition_Template__c = jobDefTemp1.Id;
        vj1.cgcloud__Product__c = p1.Id;
        //vj.cgcloud__Display_Value__c = 'yes';
        insert vj1;	
		/*cgcloud__Visit_Job__c vj2 = new cgcloud__Visit_Job__c();
        vj2.cgcloud__Visit__c  = visit.Id;
        vj2.cgcloud__Visit_Date__c = system.today();
        vj2.cgcloud__Job_Definition_Template__c = jobDefTemp2.Id;
        vj2.cgcloud__Product__c = p1.Id;
        //vj.cgcloud__Display_Value__c = 'yes';
        insert vj2;		
		*/
        cgcloud__Visit_Job__c vj3 = new cgcloud__Visit_Job__c();
        vj3.cgcloud__Visit__c  = visit.Id;
        vj3.cgcloud__Visit_Date__c = system.today();
        vj3.cgcloud__Job_Definition_Template__c = jobDefTemp3.Id;
        vj3.cgcloud__Product__c = p1.Id;
        //vj.cgcloud__Display_Value__c = 'yes';
        insert vj3;	
      
        // Call the method
        Test.startTest();
        List<RetailtheaterandAccountController.FlowInput> inputs = new List<RetailtheaterandAccountController.FlowInput>();
        RetailtheaterandAccountController.FlowInput wrapp = new RetailtheaterandAccountController.FlowInput();
        wrapp.accountdId = acc.Id;
        wrapp.retailtheaterId = testRetailTheater.Id;
        wrapp.visitId = visit.Id;
        inputs.add(wrapp);
        RetailtheaterandAccountController.updateRetailtheaterandAccount(inputs);
        Test.stopTest();        
    }
}