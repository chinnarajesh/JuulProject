@isTest(SEEALLDATA = FALSE)
public class AccountTriggerHandlerTest {
  
  /****** Old Code : Commented by Anil
     static testmethod void TestTerritoryPopulation(){         
        Account a = new Account(LastName='Test',BillingCountry='US',BillingState='California',BillingPostalCode='95000-1234',RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Account' AND Name ='Person Account' LIMIT 1].Id,BirthdateText__c='11/30/1963 00:00:00');
        insert(a);    
    }
   End of Old Code ***********/

    @TestSetup
    public static void makeData(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
        
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);  
      Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='AccountOrGroupAlertTrigger',Enabled__c=true);
      insert(triggerController2);  
        
      List<User> listUserToInsert = new List<User>();
      for(Integer i=0; i<2; i++){
        User u = new User(
            ProfileId = [Select Id from Profile Where Name='System Administrator'].id,
            LastName = 'last'+i,
            Email = 'abc+'+i+'@g.com',
            Username = 'abc'+i+'@gJuul123.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias'+i,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
      listUserToInsert.add(u);
        
      }
      insert listUserToInsert;
        
        cgcloud__Account_Template__c  accTemp = new cgcloud__Account_Template__c();
        accTemp.cgcloud__Active__c = true;
        accTemp.cgcloud__Sales_Org__c = '0001';
        accTemp.cgcloud__Description_Language_1__c = 'Customer';
        accTemp.Name = 'Customer';
        insert accTemp;
        
        List<Account> accList= new List<Account>();
        Account accRec = new Account(Name='TestAccount',
                                    Type = 'HQ',
                                    ShippingState ='AK',
                                    ShippingCountry='US', 
                                    RACS_Status__c='Ready',
                                    ShippingPostalCode='002',
                                    cgcloud__Account_Template__c  = accTemp.Id,
                                    Deactivate_on_Locator__c = true,
                                    Activated_On_Locator__c = true,
                                     Request_for_account_to_be_on_locator__c = false,
                                    Phone = '9809809909',
                                    Status__c = 'Blacklisted',
                                      MAVerifiedLatitude__c = 52.265850170081336 ,
                                    //ComplianceMechanism__c = 'Menthol Ban',
                                     X2D_Bar_Scanner__c = true,
                                     //RACS_Status__c = 'Ready',
                                     MapAnythingComplianceMechanism__c = listUserToInsert[0].id,
                                    EAC_Certification_Pathway_Status__c  = 'Door Level',
                                    //Date_of_Newest_Sales_Order__c = date.newInstance(2022, 07, 02),
                                    National_Account_Manager__c = listUserToInsert[0].id,
                                    Update_via_SelfCert__c  = false,
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId()
         );
       // insert accRec;
        accList.add(accRec);
        Account accRec3 = new Account(Name='AlertTest3',
                                    Type = 'Chain Retail',
                                    ShippingCountry ='US',
                                    ShippingCity ='CA',
                                    ShippingState ='AK',
                                    ShippingPostalCode='002',
                                    cgcloud__Account_Template__c  = accTemp.Id,
                                      Deactivate_on_Locator__c = true,
                                    Activated_On_Locator__c = true,
                                      ComplianceMechanism__c = 'Menthol Ban',
                                     Request_for_account_to_be_on_locator__c = false,
                                      X2D_Bar_Scanner__c = true,
                                      RACS_Status__c = 'Ready',
                                      Status__c = 'Blacklisted',
                                      MapAnythingComplianceMechanism__c = listUserToInsert[0].id,
                                      MAVerifiedLatitude__c = 52.265850170081336 ,
                                      EAC_Certification_Pathway_Status__c  = 'Door Level',
                                    //cgcloud__Sales_Org__c = '0001',
                                    National_Account_Manager__c = listUserToInsert[0].id,
                                    Update_via_SelfCert__c  = false,
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId()
         );
       // insert accRec3;   
        accList.add(accRec3);
         Account accRec2 = new Account(Name='AlertTest',
                                       Type = 'HQ',
                                       ShippingCountry ='CA',
                                       ShippingCity ='Lyon',
                                       ShippingPostalCode='002',
                                       ShippingState ='AK',
                                       Deactivate_on_Locator__c = true,
                                       Activated_On_Locator__c = true,
                                       ComplianceMechanism__c = 'Menthol Ban',
                                       Request_for_account_to_be_on_locator__c = false,
                                       cgcloud__Account_Template__c  = accTemp.Id,
                                       X2D_Bar_Scanner__c = true,
                                       RACS_Status__c = 'Ready',
                                       Status__c = 'Blacklisted',
                                       MapAnythingComplianceMechanism__c = listUserToInsert[0].id,
                                        MAVerifiedLatitude__c = 52.265850170081336 ,
                                       EAC_Certification_Pathway_Status__c  = 'Door Level',
                                       //cgcloud__Sales_Org__c = '0001',
                                       National_Account_Manager__c = listUserToInsert[0].id,
                                       Update_via_SelfCert__c  = false,
                                       RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId()
         );
       // insert accRec2;        
        accList.add(accRec2);
        
        insert accList;
        
        test.startTest();
        List<RetailLocationGroup__c> retailsLocList=new List<RetailLocationGroup__c>();
        RetailLocationGroup__c rsg = new RetailLocationGroup__c();
        rsg.AccountId__c = accRec.id;
        rsg.Country__c = 'US';
        rsg.Pricing_State__c='AK';
      //  insert rsg; 
        retailsLocList.add(rsg);
        
        RetailLocationGroup__c rsg1 = new RetailLocationGroup__c();
        rsg1.AccountId__c = accRec3.id;
        rsg1.Country__c = 'US';
        rsg1.Pricing_State__c='CA';
       // insert rsg1; 
        retailsLocList.add(rsg1);
        
      insert  retailsLocList;
        
        //Assortment sortment = new Assortment();
        
      
         List<Account> accLst1 = new List<Account>();
        
        
        Account pAccount = new Account(); 
        pAccount.Name = 'Alert Partent Accunt';
        pAccount.ParentId = accRec.ID;
        pAccount.ShippingState='AK';
        //pAccount.Ultimate_Parent_Account__c= accRec.ID;
        pAccount.Update_via_SelfCert__c  = true;
         pAccount.ShippingCity = 'Aden';
        pAccount.ShippingPostalCode = '004';
        pAccount.MapAnythingComplianceMechanism__c = listUserToInsert[1].id;
        pAccount.cgcloud__Account_Template__c = accTemp.Id;
        pAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
       // insert pAccount;    
        System.debug('accRec.id ++++++++++++++++ '+accRec);
        
        accLst1.add(pAccount);
        
       
        
       
        Account account = new Account();
        account.Name = 'Test acc case'; 
        account.ParentId = accRec.id;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        account.EAC_Certification_Status__c = 'Certification Passed';
        account.X2D_Bar_Scanner__c = False;
        account.AV_Capable__c = False;
        account.QPL_Capable__c = False;
        account.ShippingState = 'AK';
        account.ShippingCity = 'Aden';
        account.ShippingPostalCode = '004';
        account.cgcloud__Account_Template__c = accTemp.Id; 
        account.Update_via_SelfCert__c  = false;
        account.Pathway_Status__c = 'Committed - Not EAC Ready';
        account.Request_for_account_to_be_on_locator__c = true;
        account.Deactivate_on_Locator__c = false;
        account.ShippingCountry = 'CA';
        accLst1.add(account);
        
        Account account1 = new Account();
        account1.Name = 'Test acc case 1';     
        account1.ParentId = accRec.id;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        account1.EAC_Certification_Status__c = 'Certification Passed';
        account1.X2D_Bar_Scanner__c = False;
        account1.AV_Capable__c = False;
        account1.QPL_Capable__c = False;
        account1.ShippingState='AK';
        account1.ShippingCity = 'Aden';
        account1.ShippingPostalCode = '004';
        account1.Update_via_SelfCert__c  =false;
        account1.Pathway_Status__c = 'Committed - Not EAC Ready';
        account1.Chain_Expansion__c = 'New Construction';
		account1.cgcloud__Account_Template__c = accTemp.Id;

        accLst1.add(account1);
        
         insert accLst1; 
        Product2 p= new Product2();
        p.name= 'Test Items';
        p.Family='Devices';
        p.IsActive = true;
        p.Product_Country__c = 'US';
        p.ProductPricingFamily__c='DK';
        p.US_E_Order_Enabled__c = true;
        insert p;
        
        Assortment__c assort = new Assortment__c();
        assort.Description__c ='Testing';
        assort.Country__c = 'US';
        insert assort;
        
        AssortmentProduct__c assortProduct = new AssortmentProduct__c();
        assortProduct.AssortmentId__c= assort.id;
        assortProduct.ProductId__c = p.id;
        assortProduct.Country__c = 'US';
        insert assortProduct;
        
        StoreAssortment__c storeAssort = new StoreAssortment__c();
        storeAssort.AccountId__c = accRec.ID;
        storeAssort.Active__c= true;
        storeAssort.AssortmentId__c = assort.id;
        storeAssort.Country__c = 'US';
        insert storeAssort;
        
        cgcloud__Org_Unit__c orgunit = new cgcloud__Org_Unit__c();
        orgunit.cgcloud__Sales_Org__c = '0001';
        orgunit.Zip_Code__c = '002';
        insert orgunit;
       /* List<salesOrder__c> salesList = new List<salesOrder__c>();
        salesOrder__c  sOrder = new salesOrder__c ();
        //sOrder.Order_Date__c = date.newInstance(2021, 09, 10);
        sOrder.Name = 'test1';
        sOrder.Distributor__c = accRec.id; 
        salesList.add(sOrder);
        
        salesOrder__c  sOrder2 = new salesOrder__c ();
        //sOrder2.Order_Date__c = date.newInstance(2022, 09, 10);
        sOrder2.Name = 'test2';
        sOrder2.Distributor__c = accRec.id; 
        salesList.add(sOrder2);
        insert salesList;
        */
        /*cgcloud__Account_Org_Unit__c accorg = new cgcloud__Account_Org_Unit__c();
        accorg.cgcloud__Account__c = accRec.ID;
        accorg.cgcloud__Active__c = true;
        accorg.cgcloud__Org_Unit__c = orgunit.Id;
        //accorg.
        insert accorg;
        */
            test.stopTest();
        
        }
   public static testMethod void testTerritoryLogic(){
       
         Test.startTest();
        AccountTriggerHandler accountHandler = new AccountTriggerHandler();
         String stateCountryLabel = System.Label.StateCountryLabel;
        stateCountryLabel = 'New';
        
        Id targetRecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Target').getRecordTypeId();
        Id sourceRecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Country Based').getRecordTypeId();
        Id sourceRecordTypeId1 = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Source').getRecordTypeId();
       
            
        ISO2_Country__c usaTarget = new ISO2_Country__c();
        usaTarget.Name__c = 'US-CA';
        usaTarget.Country__c = 'US';
        usaTarget.State_Province__c = 'CA';
        usaTarget.recordtypeid = targetRecordTypeId;
        Insert usaTarget;
        
        ISO2_Country__c usaSource = new ISO2_Country__c();      
        usaSource.Country__c = 'usa';
        usaSource.State_Province__c = 'ca';
        usaSource.TargetID__c = usaTarget.id;
        usaSource.recordtypeid = sourceRecordTypeId;
        Insert usaSource;
       
        ISO2_Country__c usaSource1 = new ISO2_Country__c(); 
        usaSource1.recordtypeid = sourceRecordTypeId1;
        usaSource1.TargetID__c = usaTarget.id;
        usaSource1.Country__c = 'United States';
        Insert usaSource1;
       
       
       
      /*  Account a = new Account(LastName='Test',
                                BillingCountry='US',
                                BillingState='ca',
                                BillingPostalCode='95000-1234',
                                ShippingState='CA',
                                ShippingCountry='US',
                                Update_via_SelfCert__c  = false,
                                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
                                BirthdateText__c='11/30/1963 00:00:00');
        insert(a);
        
        a.BillingCountry = 'USA';
        a.BirthdateText__c='1963-01-01 00:00:00';
        update(a);
        */
        
       Account a2 = new Account(Name='Test',
                                 BillingCountry='usa',
                                 BillingState='ca',
                                 BillingPostalCode='95000-1234',
                                 Type = 'HQ',
                                Status__c = 'Suspended',
                                Activated_On_Locator__c = true,
                                ShippingCountry = 'US',
                                 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId()
        );
        insert(a2);

        a2.BillingCountry = 'USA';
        update(a2);
       
       Test.stopTest();
    }
     public static testMethod void updateResultCodeOnAccountTest(){
          //Batch_CreateOrgUnit createOrg = new Batch_CreateOrgUnit();
        Test.startTest();
         Account accRec1 =[Select Id, National_Account_Manager__c from Account LIMIT 1];
        Bypass_NAM_Update_Logic__mdt bypassNAM = [SELECT BypassLogic__c from Bypass_NAM_Update_Logic__mdt LIMIT 1];
        User uRec = [Select Id, Name from User Where LastName = 'last1'];
        System.debug('uRecuRec ******************* '+uRec.id);
        accRec1.National_Account_Manager__c = uRec.id;
        accRec1.ShippingCity = 'Aden';
        accRec1.ShippingPostalCode = '004';
        accRec1.MAVerifiedLatitude__c = 52.265850170081336 ;
        update accRec1;
         //Database.executeBatch(createOrg, 100);
        Test.stopTest();
     }    
    
  /*   public static testMethod void createGroupAlertandAlertTest(){
        Test.startTest();
         Account accRec2 =[Select Id from Account WHERE Name='AlertTest' LIMIT 1];
         Account toUppdate =[Select Id from Account WHERE Name='Alert Partent Accunt' LIMIT 1];
        toUppdate.ParentId = accRec2.ID;
         accRec2.ShippingPostalCode='004';
         
        update toUppdate;
          
         test.stopTest();
     }
        */
    public static testMethod void updateTerritoryAssigner(){
        test.startTest();
         Account accRec2 =[Select Id from Account WHERE Name='AlertTest' LIMIT 1];
        User u = [select id from user where Lastname = 'last1' Limit 1];
        System.debug('User Details'+UserInfo.getUserId());
        ID  RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
        accRec2.RecordTypeId  = RecordTypeId;
         accRec2.shippingCountry = 'US';
        accRec2.ShippingPostalCode='001';
        accRec2.ShippingCity='Lyonn';
        accRec2.ResultCode__c='Test';
        accRec2.OwnerId= u.id;
        //accRec2.cgcloud__Account_Template__c  = accTemp.Id;
        accRec2.CurrentPOSProvider__c = 'Smart Trade Fixture';
        accRec2.MDM_RecordType__c='Test';
        accRec2.Update_via_SelfCert__c  = false;
        update accRec2; 
        test.stopTest();
    }
    //Added by Shreya for RSG Automation SFDC - 0000005443 
    public static testMethod void CreateORupdateARSG(){
     test.startTest();
        cgcloud__Account_Template__c  accTemp = new cgcloud__Account_Template__c();
        accTemp.cgcloud__Active__c = true;
        accTemp.cgcloud__Sales_Org__c = '0001';
        accTemp.cgcloud__Description_Language_1__c = 'Customer';
        accTemp.Name = 'Customer3';
        insert accTemp;
    /* Account doorAcct =[Select Id from Account WHERE Name='Test acc case 1' LIMIT 1];    
     Account HQAcct =[Select Id,ShippingState from Account WHERE Name='TestAccount' LIMIT 1];  
     
     doorAcct.ParentId = HQAcct.id;
     //doorAcct.Ultimate_Parent_Account__c = HQAcct.id;
     RetailLocationGroup__c a =[select id,Pricing_State__c,AccountID__c from RetailLocationGroup__c where AccountId__c =: HQAcct.id Limit 1];
     
        System.system.assertEquals(a.Pricing_State__c,HQAcct.ShippingState);
     update doorAcct;*/
        
        Account accRec2 =[Select Id from Account WHERE Name='TestAccount' LIMIT 1];
        Account accRec22 =[Select Id from Account WHERE Name='AlertTest3' LIMIT 1];
        Account a = new account();
        a.name='test rsg';
        a.ParentId = accRec2.id;
        a.ShippingCountry = 'US';
        a.ShippingState ='AK';
        a.ShippingPostalCode = '003';
        a.Type = 'HQ';
        a.ShippingCity = 'Aden';
        a.cgcloud__Account_Template__c  = accTemp.Id;
        insert a;
        a.ParentId = accRec22.id;
        a.ShippingState ='CA';
        a.ShippingCity = 'Aden';
        a.ShippingPostalCode = '004';
        update a;
         
       test.stopTest();
    }
   //Added by Ramya - SFDC - 0000004010     
    /*public static testMethod void accMasterCreateTest(){
        
        Test.startTest();
         Account accRec2 =[Select Id from Account WHERE Name='AlertTest' LIMIT 1];
        //Account acUpdate = [Select Id, Name, EAC_Certification_Status__c, X2D_Bar_Scanner__c, AV_Capable__c, QPL_Capable__c,
                                                //Pathway_Status__c, Last_Youreka_Survey_Date__c FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Account> accLst = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Test acctt';
       acc.ParentId = accRec2.ID;
        acc.ShippingCountry = 'US';
        acc.ShippingState='AK';
        acc.NSL_Published_Date__c=system.today();
        acc.Resync_to_Locator__c = true;
        acc.Locator_Request_Receipt__c = 1212;
        acc.Deactivate_on_Locator__c = true;
        acc.Activated_On_Locator__c = true;
        acc.Request_for_account_to_be_on_locator__c = false;
        acc.Update_via_SelfCert__c  = false;
        acc.Pathway_Status__c='Certification Pending';
        //insert acc;
        accLst.add(acc);
        
        Account ac = new Account();
        ac.Name = 'Test acc';
        ac.Locator_Request_Receipt__c = 888;
        ac.ParentId = accRec2.ID;
        ac.Does_Business_As_DBA__c = 'Store loc';
        ac.Request_for_account_to_be_on_locator__c = false;
        ac.Activated_On_Locator__c = true;
        ac.Deactivate_on_Locator__c = true;        
        ac.Update_via_SelfCert__c  = false;
        //insert ac;
        accLst.add(ac);
        
        Account a4 = new Account();
        a4.Name = 'Test Store Loc';
        a4.Deactivate_on_Locator__c = false;
        a4.Request_for_account_to_be_on_locator__c = true;
        a4.Status__c = 'Blacklisted';
        a4.Activated_On_Locator__c = true;
        a4.ShippingCountry = 'US';
        a4.Update_via_SelfCert__c  = false;
        //insert a4; 
        accLst.add(a4);
        
        Account a8 = new Account();
        a8.Name = 'Test store loc';
        a8.Request_for_account_to_be_on_locator__c = true;
        a8.Activated_On_Locator__c = true;
        a8.Resync_to_Locator__c = false;
        a8.Does_Business_As_DBA__c = 'Store loc';
        a8.Pathway_Status__c='Certification Pending';
        a8.MALatitude__c = 12.99;
        a8.MALongitude__c = 13.88;
        a8.Locator_Request_Receipt__c = 1234;
        a8.Update_via_SelfCert__c  = false;
        //insert a8;
        accLst.add(a8);
        
           Account accSale = new Account();
        accSale.Name = 'test add str';
        accSale.Status__c = 'Customer (Reporting)';
        accSale.Does_Business_As_DBA__c = 'test';
        accSale.ShippingCountry = 'CA';
        accSale.Pathway_Status__c='Certification Pending';
        accSale.Update_via_SelfCert__c  = false;
        //insert accSale;
        accLst.add(accSale);
        
        insert accLst;
        
        List<Account> acListUpdate=new List<Account>();
        Account acc1 = new Account();
        acc1.Id = acc.Id;
        acc1.Name = 'Test acc';
        acc1.Resync_to_Locator__c = true;
        acc1.Locator_Request_Receipt__c = 999;
        acc1.Activated_On_Locator__c = false;
        acc1.Deactivate_on_Locator__c = true;
        acc1.Does_Business_As_DBA__c = 'xyz';
        acc1.Request_for_account_to_be_on_locator__c = true;
        acc1.Update_via_SelfCert__c  = false;
         acc1.Pathway_Status__c = 'KDM Not Contacted';
        acc1.ParentId =  accRec2.id;
        acc1.Ultimate_Parent_Account__c = accRec2.id;
      //  update acc1;    
      acListUpdate.add(acc1);   
        
        Account ac1 = new Account();
        ac1.Id = ac.Id;
        ac1.Name = 'Test acc 1';
        ac1.Locator_Request_Receipt__c = 121 ;
         acc1.Does_Business_As_DBA__c = 'rrr';
        ac1.Request_for_account_to_be_on_locator__c = true;
        ac1.Activated_On_Locator__c = false;
        ac1.Deactivate_on_Locator__c = true;   
        ac1.Update_via_SelfCert__c  = false;
      //  Update ac1;      
        acListUpdate.add(ac1);
        
       Account a9 = new Account();
        a9.Id = a8.Id;
        a9.Name = 'Test store loc';
        a9.Request_for_account_to_be_on_locator__c = true;
        a9.Activated_On_Locator__c = false;
        a9.Resync_to_Locator__c = true;
        a9.Does_Business_As_DBA__c = 'Store loc';
        a9.MALatitude__c = 122.99;
        a9.MALongitude__c = 133.88;
        a9.Pathway_Status__c = 'Committed - Not EAC Ready';
        a9.Update_via_SelfCert__c  = false;
      //  update a9; 
          
          acListUpdate.add(a9);
                       
        Account a5 = new Account();
        a5.Id = a4.Id;
        a5.Name = 'Test Store Loc';
        a5.Status__c = 'Blacklisted';
        a5.Activated_On_Locator__c = true;
        a5.Deactivate_on_Locator__c = true;
        a5.ShippingCountry = 'US';
        a5.Resync_to_Locator__c = true;
        a5.RACS_Status__c='Ready';
        a5.Pathway_Status__c = 'Declined EAC';
        a5.Update_via_SelfCert__c  = false;
       // Update a5; 
        
    acListUpdate.add(a5);
    update acListUpdate;
        
        salesOrder__c sodr = new salesOrder__c();
        sodr.Name = '1010';
        sodr.Customer__c = accSale.Id;
        sodr.Date__c = '2021-04-20';
        insert sodr; 
        
        Date d1 = Date.today().addDays(-120);
        
        Test.stopTest();
    } */
    
    public static testMethod void automaticCaseCreationTest(){
        cgcloud__Account_Template__c  accTemp = new cgcloud__Account_Template__c();
        accTemp.cgcloud__Active__c = true;
        accTemp.cgcloud__Sales_Org__c = '0001';
        //accTemp.cgcloud__Description_Language_1__c = 'Customer';
        accTemp.Name = 'Customer4';
        //accTemp.
        insert accTemp;
        
        User u = [SELECT Id, Name FROM User WHERE Id=: UserInfo.getUserId()];
         System.runAs(u){
             Test.startTest();
        Account acUpdate = [Select Id, Name, EAC_Certification_Status__c, X2D_Bar_Scanner__c, AV_Capable__c, QPL_Capable__c,
                                                Pathway_Status__c, Last_Youreka_Survey_Date__c FROM Account WHERE Name = 'Test acc case' LIMIT 1];
             
             
        Account acnt = new Account();
        acnt.Id = acUpdate.Id;
        acnt.Name = 'Test Case';
        acnt.EAC_Certification_Status__c = 'Certification Passed';
        acnt.X2D_Bar_Scanner__c = True;
        acnt.AV_Capable__c = True;
        acnt.QPL_Capable__c = True;
        acnt.CurrentPOSProvider__c = 'Smart Trade Fixture';
        //acnt.cgcloud__Account_Template__c  = accTemp.Id;
        acnt.Pathway_Status__c = 'EAC Ready';
        acnt.Last_Youreka_Survey_Date__c = System.Today();
        //acnt.Date_of_Newest_Sales_Order__c= System.Today();
        acnt.Update_via_SelfCert__c = false;
        acnt.NSL_Published_Date__c=system.today();
       // acnt.Update_via_SelfCert__c  =true;
        //acnt.Pathway_Status__c = 'Committed - Not EAC Ready';
        //acnt.Chain_Expansion__c = 'New Construction';
             
        Update acnt;
    /* SA Update
         Account accRec2 =[Select Id from Account WHERE Name='AlertTest' LIMIT 1];
         accRec2.EAC_Certification_Status__c = 'Certification Passed';
         accRec2.X2D_Bar_Scanner__c = True;
         */
             
          Account act = new Account();
             act.Id = acnt.Id;
            act.EAC_Certification_Status__c = 'Certification Pending';
            act.Pathway_Status__c = 'EAC Ready';
             update act;
             
            act.Pathway_Status__c = 'Committed - Not EAC Ready';
            update act;
             
        Group grpId = new Group();
        grpId.Name = 'EAC Certification';
        grpId.Type = 'Queue';
        insert grpId;
        
       QueuesObject obj = new QueuesObject();
       obj.QueueId = grpId.Id;
       obj.SobjectType = 'Case';
            insert obj;
        
         Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EAC Certification').getRecordTypeId();
        List<Case> lstCase = new List<Case>();
        Case c = new Case();
        c.AccountId = acUpdate.Id;
        c.RecordTypeId = caseRecordType;
        c.OwnerId = grpId.Id;
        c.Status = 'New';
        insert c;
        
         Test.stopTest(); 
         }
        
    }
    
        
}