@isTest
public class AcctMissionControllerDesktopTest {
    
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
        
         List<InStoreLocation__c> ISLList = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
       // sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c = acc.id;
        sl.Active__c = True;
        sl.Category__c='Account Plan';
        sl.StartDate__c = date.newInstance(2020, 07, 02);        
        sl.EndDate__c =date.newInstance(2020, 09, 10);
        //sl.PlanogramId__c=plano.id;
        sl.InStoreLocationType__c = 'Planogram Specific';
        sl.Status__c ='Planned'; 
        ISLList.add(sl);
         
        insert ISLList;
         
        List<Mission__c> missionList = new List<Mission__c>();
        Mission__c m = new Mission__c();
        m.StartDate__c = System.today();
        m.EndDate__c = System.today();
        m.AccountId__c=acc.Id;
        m.MissionType__c = 'Strategy';
        m.Status__c = 'Planned';
      //  m.RecordType.Name = 'Promotional Activity Process';
        
        m.InStoreLocationId__c = ISLList[0].id;
        missionList.add(m);
       insert m;
 
      
       
        //Pooja--------------
        List<Mission__c> missionList1 = new List<Mission__c>();
        Mission__c m1 = new Mission__c();
        m1.Id = m.Id;
        m1.StartDate__c = System.today();
        m1.EndDate__c = System.today();
        m1.AccountId__c=acc.Id;
        m1.MissionType__c = 'Reset';
        m1.Status__c = 'Not Visited';
       //m1.RecordType.Name ='Account Plan';
        missionList1.add(m1);
        update m1;
        
         Mission__c m2 = new Mission__c();
m2.StartDate__c = Date.today();
m2.EndDate__c = Date.today().addDays(7);
m2.Status__c = 'In Progress';
m2.InstructionDescription__c = 'Test Description';
m2.MissionType__c = 'Test Type';
//m2.RecordTypeId = 'Test Record Type';
m2.FillOutVendorLog__c = 'true';
m2.ThirdPartyAllowed__c = true;
m2.AllowedtoPriceScan__c = 'true';
m2.NoPricingUseJUULPricing__c = 'true';
m2.IfPriceDoesntScan__c = 'Test Fix';
m2.ProductHowtoFixOutofStocks__c = 'Test Fix';
m2.CanYouLabelFixtures__c = 'true';
m2.CanYouProvideLeadBehinds__c = 'true';
         missionList1.add(m2);
         //insert missionList1;
                  
         
   ID missionId = m2.Id;
AcctMissioncontrolDesktopcontroller.getselectedMissions(missionId);
    
       Map<Id,Mission__c> missionMap1 = new Map<Id,Mission__c>([SELECT id,StartDate__c,EndDate__c,Status__c,InstructionDescription__c,Commercial_Activity__c,MissionType__c,RecordType.Name,
                                                                 FillOutVendorLog__c,ThirdPartyAllowed__c,AllowedtoPriceScan__c,NoPricingUseJUULPricing__c,IfPriceDoesntScan__c,
                                                                 ProductHowtoFixOutofStocks__c,CanYouLabelFixtures__c,CanYouProvideLeadBehinds__c,RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.ExecutionNotes__c	
                                                                 FROM Mission__c WHERE Id =:MissionID]);         
         
         
         
        List<MissionTask__c> mtList = new List<MissionTask__c>();
        MissionTask__c mt = new MissionTask__c();
        mt.Status__c = 'Planned';
        mt.ParentId__c=m.Id;
        mt.Subject__c='PM dev APTI';
        mtList.add(mt);
        insert mt;
        
        List<Product2> prList = new List<Product2>();
        Product2 pr = new   Product2();
        pr.Name = 'CA Basic Device Kit Slate';
        prList.add(pr);
        insert prList;
        
        List<StoreProduct__c> storeProductList = new List<StoreProduct__c>();
        StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = acc.Id;
        sp.ActualMSRP__c = 50;
        //sp.InStoreLocationId__c = ISLList[0].id;
        storeProductList.add(sp);
       insert sp;
         
        
        List<StoreProduct__c> storeProductList1 = new List<StoreProduct__c>();
        StoreProduct__c sp1 = new StoreProduct__c();
        sp1.RetailStoreId__c = acc.Id;
        sp1.Id = sp.Id;
        sp1.ActualMSRP__c = 50;
        //sp1.InStoreLocationId__c = ISLList[0].id;
        storeProductList.add(sp1);
        update sp1;
        
        
        Contact cList= new Contact();
        contact c=new Contact();
        c.LastName='Test';
        c.AccountId=acc.Id;
        //cList.add(c);
        insert c;
        
        
         
        List<Asset> assetList = new List<Asset>();
            Asset a = new Asset();
            a.name = 'test';
            a.Quantity = 2;
            a.AccountId=acc.id;
            a.ContactId=c.id;
            a.Product2Id = pr.id;
            a.InStoreLocation__c = ISLList[0].id;
            assetList.add(a);
            insert assetList;
        
        //added by Jyoti for SFDC - 0000004342
        //start
        List<Asset__c> cAssetList = new List<Asset__c>();
            Asset__c a1 = new Asset__c();
            a1.name = 'test';
            a1.Quantity__C = 2;
            a1.Account__c=acc.id;
            a1.Contact__c=c.id;
            a1.Product__c = pr.id;
        	a1.Status__c = 'Unable to install';
            a1.InStoreLocation__c = ISLList[0].id;
            cAssetList.add(a1);
           
        //end
        Asset__c a2 = new Asset__c();
        	a2.Id = a1.Id;
            a2.name = 'Test 2';
            a2.Quantity__C = 4;
        	a2.Status__c = 'Unable to install';
            a2.Account__c=acc.id;
            a2.Contact__c=c.id;
            a2.Product__c = pr.id;
            a2.InStoreLocation__c = ISLList[0].id;
        	 cAssetList.add(a2);
         	 insert cAssetList;
         
           update a2;
     }
    
   
     static testMethod void missionControl(){
         
        Test.startTest();
        Account lstAcc=[Select Id,Name From Account WHERE Name='Test' Limit 1];
        List<Mission__c> lstMission= new List<Mission__c>([Select id,StartDate__c,EndDate__c,AccountId__c,Status__c FROM Mission__c]);
        List<Asset__c> accList = new List<Asset__c>([select id,Status__c from Asset__c]);
        List<StoreProduct__c> spList = new List<StoreProduct__c>([select id,ActualMSRP__c,Final_PTC__c from StoreProduct__c]);
        string url = '<p><a href="" target="_blank" style="">https://login.salesforce.com/</a></p><p><br></p><p><br></p><p><span style="">Test Data</span></p><p><span style="">﻿</span><img src="https://juullabs--developer1--c.documentforce.com/servlet/rtaImage?eid=a6F18000000Au3V&amp;feoid=00N1O00000BiCRx&amp;refid=0EM180000009zyU" alt="VS Code error.PNG" style=""></img></p>';
        AcctMissioncontrolDesktopcontroller.getALLMissions(lstAcc.id);
         
       
       AcctMissioncontrolDesktopcontroller.getselectedMissions(lstMission[0].id);
        AcctMissioncontrolDesktopcontroller.getMissionTask(lstMission[0].id);
        AcctMissioncontrolDesktopcontroller.getAsset(lstMission[0].id);
         lstMission[0].status__c = 'Planned';
        AcctMissioncontrolDesktopcontroller.saveData(spList,accList,lstMission);
        System.assertEquals('Test', lstAcc.Name);
        
        //System.debug('missionMap1'+missionMap1); 
        Test.stopTest();
    }
    

}