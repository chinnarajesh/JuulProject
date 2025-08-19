/**********************************************************************/
/* VERSION     AUTHOR                           DATE                  */
/*     1.0     Pooja Gite                       03-15-2021            */
/* Class Name: AccountMissionControllerPRODTest                           */
/* Description:Test class to cover AccountMissionControllerPROD  
/* Ticket Number: SFDC - 0000003906 :Convert the mission control flow into a LWC.*/
/**********************************************************************/
@isTest
public class AccountMissionControllerPRODTest {
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
        
        List<Mission__c> missionList = new List<Mission__c>();
        Mission__c m = new Mission__c();
        m.StartDate__c = System.today();
        m.EndDate__c = System.today();
        m.AccountId__c=acc.Id;
        m.MissionType__c = 'Strategy';
        m.Status__c = 'Planned';
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
        missionList1.add(m1);
        update m1;
        
        
        
        
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
        storeProductList.add(sp);
        insert sp;
        
        List<StoreProduct__c> storeProductList1 = new List<StoreProduct__c>();
        StoreProduct__c sp1 = new StoreProduct__c();
        sp1.RetailStoreId__c = acc.Id;
        sp1.Id = sp.Id;
        sp1.ActualMSRP__c = 50;
        storeProductList.add(sp1);
        update sp1;
        
        /*StoreProduct__c sp1 = new StoreProduct__c();
        sp1.Id = sp.Id;
        sp1.RetailStoreId__c = acc.Id;
        sp1.ActualMSRP__c = 500;
        update sp1;*/
        
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
            cAssetList.add(a1);
            insert cAssetList;
        //end
        Asset__c a2 = new Asset__c();
        	a2.Id = a1.Id;
            a2.name = 'Test 2';
            a2.Quantity__C = 4;
        	a2.Status__c = 'Unable to install';
            a2.Account__c=acc.id;
            a2.Contact__c=c.id;
            a2.Product__c = pr.id;
            update a2;
        
        List<AccountMissionControllerPROD.selMissions> wrapSelMissionList = new List<AccountMissionControllerPROD.selMissions>();
        AccountMissionControllerPROD.selMissions wrapSelMission = new AccountMissionControllerPROD.selMissions();
        wrapSelMission.Id = m1.Id;
        wrapSelMission.missiontype = 'Strategy';
        wrapSelMission.missionstatus = 'Planned';
        wrapSelMissionList.add(wrapSelMission);
        AccountMissionControllerPROD.saveSelMissionStatus(wrapSelMissionList);
        
        List<AccountMissionControllerPROD.Assets> wrapperAssetList = new List<AccountMissionControllerPROD.Assets>();
        AccountMissionControllerPROD.Assets wrapAsset = new AccountMissionControllerPROD.Assets();
        wrapAsset.Id = a2.Id;
        wrapAsset.Status = 'Unable to install';
        wrapperAssetList.add(wrapAsset);
        AccountMissionControllerPROD.saveAssertLwc(wrapperAssetList );
        
        List<AccountMissionControllerPROD.StoreProduct> wrapperSpList = new List<AccountMissionControllerPROD.StoreProduct>();
        AccountMissionControllerPROD.StoreProduct wrapSp = new AccountMissionControllerPROD.StoreProduct();
        wrapSp.Id =  sp1.Id;
        wrapSp.ActualMSRP= 100;
        wrapperSpList.add(wrapSp);
        //insert wrapperSpList;
        AccountMissionControllerPROD.saveAccountsLwc(wrapperSpList);
      
    }
    static testMethod void missionControl(){
        Test.startTest();
        Account lstAcc=[Select Id,Name From Account Limit 1];
        Mission__c lstMission=[Select id,StartDate__c,EndDate__c,AccountId__c,Status__c FROM Mission__c];
        string url = '<p><a href="" target="_blank" style="">https://login.salesforce.com/</a></p><p><br></p><p><br></p><p><span style="">Test Data</span></p><p><span style="">﻿</span><img src="https://juullabs--developer1--c.documentforce.com/servlet/rtaImage?eid=a6F18000000Au3V&amp;feoid=00N1O00000BiCRx&amp;refid=0EM180000009zyU" alt="VS Code error.PNG" style=""></img></p>';
        AccountMissionControllerPROD.getALLMissions(lstAcc.id);
        AccountMissionControllerPROD.getRelatedMissionTasks(lstMission.id);
        AccountMissionControllerPROD.getSelMissions(lstMission.id);
        AccountMissionControllerPROD.getRelatedStoreProducts(lstAcc.id,lstMission.id);
        //AccountMissionControllerPROD.getRelatedStoreProducts(lstAcc.id);
        AccountMissionControllerPROD.getRelatedAsset(lstAcc.id,lstMission.id);
        
        System.assertEquals('Test', lstAcc.Name);
        
        Test.stopTest();
    }
}