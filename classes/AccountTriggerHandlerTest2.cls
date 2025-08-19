@isTest(SEEALLDATA = FALSE)
public class AccountTriggerHandlerTest2 {
    
    @TestSetup
    public static void makeData(){        
       //Boolean isactive=true;  
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA';
      insert sett;        
      ChildAccountShare__c sett2 = new ChildAccountShare__c();
      sett2.Name = 'ChidlAccountShare';
      sett2.Shipping_Country_List__c = 'CAN,CAD,CA';
      insert sett2;        
        
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);  
      Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='AccountOrGroupAlertTrigger',Enabled__c=true);
      insert(triggerController2); 
        
    /*---------------Insert User Record------------------*/     
     List<User> listUserToInsert = new List<User>();
      for(Integer i=0; i<2; i++){
          
          If(i==0||i==1){  
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
       If(i==2){  
        User u = new User(
            ProfileId = [Select Id from Profile Where Name='System Administrator'].id,
            LastName = 'mulesoftapi'+i,
            Email = 'mulesoftapi+'+i+'@g.com',
            Username = 'mulesoftapi'+i+'@gJuul123.com',            
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'mulesoftapi'+i,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
      listUserToInsert.add(u);
          }
        
      }
        
        
      insert listUserToInsert;
       /*-------------End User Insert-----------------*/
      /*-----------Insert Parent Account Data ----------------------*/
    
        List<Account>Acclst= new List<Account>(); 
        
        
    Account ParAcc= new Account();
    ParAcc.Name= 'Alert Parent Account'; 
        ParAcc.Type='HQ';
        ParAcc.ShippingState='AK';
        ParAcc.ShippingCountry ='US';
        ParAcc.Update_via_SelfCert__c  = true;
        ParAcc.Last_Youreka_Survey_Date__c = System.Today();
		ParAcc.Update_via_SelfCert__c = false;
        ParAcc.NSL_Published_Date__c=system.today();
        ParAcc.National_Account_Manager__c=listUserToInsert[0].id;
        ParAcc.Activated_On_Locator__c=true;
        ParAcc.shippingCountry = 'US';  
        ParAcc.ShippingStreet='Test Account';            
        ParAcc.ShippingCity='Lyonn'; 
        ParAcc.ShippingState='TestShipping State';
        ParAcc.ShippingPostalCode ='001';    
        ParAcc.MAVerifiedLatitude__c=5.7;
        ParAcc.MAVerifiedLongitude__c=9.0; 
        ParAcc.Update_via_SelfCert__c=False;    
        ParAcc.ComplianceMechanism__c='Potency Ban - 0.77%';	
        ParAcc.ResultCode__c='Test Result Code';                                        
        ParAcc.Update_via_SelfCert__c  = false;  
        Acclst.add(ParAcc);  
    /*-----------End Parent account Data---------------------*/
   /*/----------------------Insert 2nd Parent Account----------------------/*/
        
        
Account ParAcc2= new Account();
    ParAcc2.Name= 'Alert Parent Account2'; 
        ParAcc2.Type='HQ';
        ParAcc2.ShippingState='AK';
        ParAcc2.ShippingCountry ='US';
        ParAcc2.Update_via_SelfCert__c  = true;
        ParAcc2.Last_Youreka_Survey_Date__c = System.Today();
		ParAcc2.Update_via_SelfCert__c = false;
        ParAcc2.NSL_Published_Date__c=system.today();
        ParAcc2.National_Account_Manager__c=listUserToInsert[0].id;
        ParAcc2.Activated_On_Locator__c=true;
        ParAcc2.shippingCountry = 'US';  
        ParAcc2.ShippingStreet='Test Account';            
        ParAcc2.ShippingCity='Lyonn'; 
        ParAcc2.ShippingState='TestShipping State';
        ParAcc2.ShippingPostalCode ='001';    
        ParAcc2.MAVerifiedLatitude__c=5.7;
        ParAcc2.MAVerifiedLongitude__c=9.0; 
        ParAcc2.Update_via_SelfCert__c=False;    
        ParAcc2.ComplianceMechanism__c='Potency Ban - 0.77%';	
        ParAcc2.ResultCode__c='Test Result Code';                                        
        ParAcc2.Update_via_SelfCert__c  = false;  
        Acclst.add(ParAcc2);  
           
       
        //----------------------End Insert 2nd parent Account-------------------//
       
        
        
        
        
        
     /*---------Insert Person Account----------------*/
         Account Personacc = new Account();
             Personacc.LastName='AlertTest3';
                       Personacc.Type = 'HQ';
                       Personacc.ShippingCountry ='US';
                       Personacc.ShippingCity ='CA';
                       Personacc.ShippingPostalCode='002';
                       Personacc.BillingCountry='US';
                       Personacc.BillingState='ca';
                       Personacc.BillingPostalCode='95000-1234';
                       Personacc.Update_via_SelfCert__c  = false;
                       Personacc.BirthdateText__c='11/30/1963 00:00:00';           
                       Personacc.National_Account_Manager__c = listUserToInsert[0].id;
                       Personacc.Update_via_SelfCert__c  = false;
                       Personacc.Pathway_Status__c='Declined EAC';
                       Personacc.ComplianceMechanism__c='Potency Ban - 0.77%';
                       Personacc.ShippingState='USA';
                       Personacc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                       Acclst.add(Personacc);    
  /*------------------*-----------End Insert person Account-------------------------------------*/   
     
  /*---------------Insert New Independent RetailerAccount Record---------------*/ 
        
       Account accIndRec = new Account();
        accIndRec.Name='AlertTest';
        //accIndRec.LastName='Ban';
        accIndRec.Type = 'HQ';
        accIndRec.ParentId=ParAcc.Id;
         accIndRec.Ultimate_Parent_Account__c= ParAcc.ID;
        accIndRec.shippingCountry = 'US';  
        accIndRec.ShippingStreet='Test Account1';            
        accIndRec.ShippingCity='Test Shipping City1'; 
        accIndRec.ShippingState='TestShipping State1';
        accIndRec.ShippingPostalCode ='002';
        accIndRec.ComplianceMechanism__c='';
        accIndRec.Does_Business_As_DBA__c='Test Done business';
        //accIndRec.National_Account_Manager__c = ListUserToInsert[0].id,
        accIndRec.MapAnythingComplianceMechanism__c=ListUserToInsert[1].id;
        accIndRec.Locator_Request_Receipt__c=9.77;
        accIndRec.Pathway_Status__c ='Declined EAC';
        accIndRec.Request_for_account_to_be_on_locator__c=false;
        accIndRec.Deactivate_on_Locator__c=true;
        accIndRec.Update_via_SelfCert__c  = false;
        accIndRec.MALongitude__c=3.33;
        accIndRec.MALatitude__c=2.22;
        accIndRec.MAVerifiedLatitude__c=2.34;
        accIndRec.Resync_to_Locator__c=True;
        accIndRec.Status__c = 'Blacklisted';                                    
        accIndRec.Activated_On_Locator__c=true;   
        accIndRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        //insert accIndRec;
        Acclst.add(accIndRec);
  //-------------------------------End Insert Independent retailer Account---------------------//
  
  
  
//-------------------------------Insert new account with different status-----------------------//
  
       Account accIndRec2 = new Account();
        accIndRec2.Name='AlertTest2';
       // accIndRec.LastName='Ban';
        accIndRec2.Type = 'HQ';
        accIndRec2.ParentId=accIndRec.id;
        accIndRec2.Ultimate_Parent_Account__c=ParAcc.id;
        accIndRec2.shippingCountry = 'US';                   
        accIndRec2.ShippingStreet='Test Account1';                    
        accIndRec2.ShippingCity='Test Shipping City2';    
        accIndRec2.ShippingState='TestShipping State2';  
        accIndRec2.ShippingPostalCode ='002';
        accIndRec2.ComplianceMechanism__c='';
        accIndRec2.National_Account_Manager__c = ListUserToInsert[0].id;
        accIndRec2.MapAnythingComplianceMechanism__c=ListUserToInsert[1].id;
        accIndRec2.Locator_Request_Receipt__c=9.77;
        accIndRec2.Pathway_Status__c ='Committed - Not EAC Ready';
        accIndRec2.Request_for_account_to_be_on_locator__c=true;
        accIndRec2.Deactivate_on_Locator__c=false;
        accIndRec2.Update_via_SelfCert__c  = false;
        accIndRec2.MAVerifiedLatitude__c=2.34;
        accIndRec2.Resync_to_Locator__c=true;
        accIndRec2.Does_Business_As_DBA__c='Test 1 DBA Business';
        accIndRec2.Status__c = 'Blacklisted';                                    
        accIndRec2.Activated_On_Locator__c=true; 
        accIndRec2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        acclst.add(accIndRec2);  
        
        //-------------------------------Insert New Account with different Status-------------------------------//
        
         Account accIndRec3 = new Account();
        accIndRec3.Name='AlertTest3';
       // accIndRec.LastName='Ban';
        accIndRec3.Type = 'HQ';
        boolean isupdate;
        isupdate = false;
        //accIndRec3.MDM_RecordType__c='Independent Retailer';
        accIndRec3.ParentId=accIndRec.id;
        accIndRec3.Ultimate_Parent_Account__c=ParAcc.id;
        accIndRec3.shippingCountry = 'US';                  
        accIndRec3.ShippingStreet='Test Account1';                    
        accIndRec3.ShippingCity='Test Shipping City2';    
        accIndRec3.ShippingState='TestShipping State2';  
        accIndRec3.ShippingPostalCode ='002';
        //accIndRec3.ComplianceMechanism__c='';
        accIndRec3.National_Account_Manager__c = ListUserToInsert[0].id;
        accIndRec3.MapAnythingComplianceMechanism__c=ListUserToInsert[1].id;
        accIndRec3.Locator_Request_Receipt__c=9.77;
        accIndRec3.Pathway_Status__c ='Committed - Not EAC Ready';
        accIndRec3.Request_for_account_to_be_on_locator__c=true;
        accIndRec3.Deactivate_on_Locator__c=false;
        accIndRec3.Update_via_SelfCert__c  = false;
        accIndRec3.MAVerifiedLatitude__c=2.34;
        accIndRec3.Resync_to_Locator__c=true;
        accIndRec3.Does_Business_As_DBA__c='Test 1 DBA Business';
        accIndRec3.Status__c = 'Customer (Reporting)';                                    
        accIndRec3.Activated_On_Locator__c=true;             
        accIndRec3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
        
        acclst.add(accIndRec3);
        
        
        
        
        
        Insert acclst;
        

        
     /*------Insert Reatils Store Group---------*/ 
        RetailLocationGroup__c rsg = new RetailLocationGroup__c();
        rsg.AccountId__c = accIndRec.id;
        rsg.Country__c = 'US';
        rsg.Pricing_State__c='AK';
        insert rsg; 
     /*----------------End Insert ReatailLocationGroup----------------------*/   
       
        RetailLocationGroup__c rsg1 = new RetailLocationGroup__c();
        rsg1.AccountId__c = accIndRec.id;
        rsg1.Country__c = 'US';
        rsg1.Pricing_State__c='CA';
        insert rsg1;    
     /*----------------End Insert ReatailLocationGroup----------------------*/   
   
    /*----------------Insert Sales Order Data--------------*/
       salesOrder__c sodr1 = new salesOrder__c();
        sodr1.Name = '1010';
        sodr1.Customer__c = accIndRec.Id;
        sodr1.Date__c = '2021-04-20';
        insert sodr1; 
/*------------------------------End insert Sales Order data-----------------------------*/    

        //-----------------Insert Contact Record ------------------------------//
    Contact cnt= new Contact();
        Cnt.Lastname='Test Contact';
        Cnt.AccountId=accIndRec.id;
        Insert Cnt;
        
        ISO2_Country__c ICS= New ISO2_Country__c();
        ICS.Name='Test';
        ICS.State_Province__c='AK';
        ICS.Country__c='US';
        ICS.RecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Target').getRecordTypeId();
        Insert ICS;
        
        ISO2_Country__c ICS2= New ISO2_Country__c();
        ICS2.Name='Test2';
        ICS2.State_Province__c='AK';
        ICS2.Country__c='US';
        ICS2.TargetID__c=ICS.id;
        ICS2.RecordTypeId = Schema.SObjectType.ISO2_Country__c.getRecordTypeInfosByName().get('Country Based').getRecordTypeId();
        Insert ICS2;
        
        
        
    }
        
   //------------------Test Method 1-----------------------//     
   public static testMethod void accMasterCreateTest(){ 
       Test.startTest();
        AccountTriggerHandler ac123 = new AccountTriggerHandler(); 
        Account accRec2 =[Select Id, Name, EAC_Certification_Status__c, X2D_Bar_Scanner__c, AV_Capable__c, QPL_Capable__c,
                            					Pathway_Status__c, Last_Youreka_Survey_Date__c FROM Account WHERE Name = 'Alert Parent Account' LIMIT 1];          
        List<Account>acc12 = New List<Account>();
        acc12  =[select id from account where Name ='AlertTest'];
                 
        User U = New User();        
        U=[Select id from user where Username ='abc0@gJuul123.com'];
        for (account ac:acc12){         
        ac.Name = 'Test Case';      
        ac.EAC_Certification_Status__c = 'Certification Pending';
        ac.Ultimate_Parent_Account__c= accRec2.id;   
        ac.Status__c='Blacklisted';    
        ac.X2D_Bar_Scanner__c = True;
        ac.AV_Capable__c = True;
        ac.QPL_Capable__c = True;
        ac.ParentId=accRec2.id;            
        ac.Pathway_Status__c = 'EAC Ready';
        ac.Last_Youreka_Survey_Date__c = System.Today();
        ac.Locator_Request_Receipt__c=9.77;    
		ac.Update_via_SelfCert__c = false;
        ac.NSL_Published_Date__c=system.today();
        ac.National_Account_Manager__c=U.id;
        ac.MALongitude__c=4.44;    
        ac.Activated_On_Locator__c=true;
        ac.Does_Business_As_DBA__c='1111222222222244444444';   
        ac.shippingCountry = 'CA';  
        ac.ShippingStreet='Test Account Street';            
        ac.ShippingCity='Lyonn'; 
        ac.ShippingState='Test State';
        //ac.Resync_to_Locator__c=True;
        ac.Resync_to_Locator__c=false;     
        ac.ShippingPostalCode ='001';
        ac.Request_for_account_to_be_on_locator__c=true;    
        ac.MAVerifiedLatitude__c=5.7;
        ac.MAVerifiedLongitude__c=9.0; 
        ac.MALatitude__c=1.2;    
        ac.Update_via_SelfCert__c=False;    
        ac.ComplianceMechanism__c='Category Ban';	
        ac.ResultCode__c='Test Result Code';
        ac.OwnerId= U.id;
        ac.Update_via_SelfCert__c  = false; 
        Update ac;
       } 
       Account accRecID =[Select Id from Account WHERE Name='Alert Parent Account' LIMIT 1];
       Account toUppdate =[Select Id from Account WHERE Name='Test Case' LIMIT 1];
        toUppdate.ParentId = accRec2.ID;
         accRecID.ShippingPostalCode='004';
         
        update toUppdate;
       
       Test.stopTest();
    }
    
   //------------------------End Test Method1-----------------------------------// 
   public static testMethod void accMasterCreateTest2(){ 
            User Um= new User();
            Um = [Select id from user where Username ='abc1@gJuul123.com'];
            System.runAs(Um){
   Test.startTest(); 
        AccountTriggerHandler ac1 = new AccountTriggerHandler(); 
        Account accRec1 =[Select Id from Account WHERE Name='Alert Parent Account' LIMIT 1];          
        List<Account>acc2 = New List<Account>();
        acc2  =[select id from account where Name ='AlertTest2'];        
        User U1 = New User();        
        U1=[Select id from user where Username ='abc1@gJuul123.com'];
        for (account ac:acc2){         
        ac.Name = 'Test Case';      
        ac.EAC_Certification_Status__c = 'Certification Pending';
        ac.X2D_Bar_Scanner__c = True;
        ac.AV_Capable__c = True;
        ac.MALatitude__c=1.1;
        ac.MALongitude__c=1.2;
            
        ac.Ultimate_Parent_Account__c=accRec1.id;    
        ac.QPL_Capable__c = True;
        ac.ParentId=accRec1.id;
        ac.Pathway_Status__c = 'Declined EAC';
        ac.Last_Youreka_Survey_Date__c = System.Today();
        ac.Deactivate_on_Locator__c=false; 
        ac.Activated_On_Locator__c=true;
        ac.Locator_Request_Receipt__c=5.77; //547-Locator_Request_Receipt__c   
		ac.Update_via_SelfCert__c = false;
        ac.Does_Business_As_DBA__c='DBA1';  //547-Does_Business_As_DBA__c 
        ac.NSL_Published_Date__c=system.today();
        ac.National_Account_Manager__c=U1.id;
        ac.Activated_On_Locator__c=true;               
        ac.shippingCountry = 'CA';  
        ac.ShippingStreet='Test Account Street';               
        ac.ShippingCity='Lyonn';                   
        ac.ShippingState='Test';                   
        ac.Resync_to_Locator__c=false;            
        ac.ShippingPostalCode ='002';
        ac.MAVerifiedLatitude__c=5.7;
        ac.MAVerifiedLongitude__c=9.0; 
        ac.Update_via_SelfCert__c=False;    
        ac.ComplianceMechanism__c='Category Ban';	
        ac.MapAnythingComplianceMechanism__c=Um.id; 
        ac.ResultCode__c='Test Result Code';
        ac.OwnerId= U1.id;
        ac.Request_for_account_to_be_on_locator__c=true;    
        ac.Update_via_SelfCert__c  = false;
        ac.Status__c='Blacklisted';
        ac.MDM_RecordType__c='Independent Retailer';         
        Upsert ac;
            
        //-------------update to other status-------------------//
            
            
         Account accRec2 =[Select Id from Account WHERE Name='Alert Parent Account2' LIMIT 1];          
        List<Account>acc3 = New List<Account>();
        acc3  =[select id from account where Name ='AlertTest3'];        
        User U2 = New User();        
        U2=[Select id from user where Username ='abc1@gJuul123.com'];
        for (account ac2:acc3){         
       // ac2.Name = 'Test acc';      
        ac2.EAC_Certification_Status__c = 'Certification Passed';
        ac2.X2D_Bar_Scanner__c = True;
        ac2.AV_Capable__c = True;
        ac2.MALatitude__c=1.1;
        ac2.MALongitude__c=1.2;    
        //ac.Ultimate_Parent_Account__c=accRec1.id;    
        ac2.Locator_Request_Receipt__c=9.0808;   
        ac2.QPL_Capable__c = True;
        //ac2.ParentId=accRec1.id;
        ac2.Pathway_Status__c = 'Committed - Not EAC Ready';
        ac2.Last_Youreka_Survey_Date__c = System.Today();
        ac2.Deactivate_on_Locator__c=false; 
        ac2.Activated_On_Locator__c=false;
        ac2.Locator_Request_Receipt__c=5.77;    
		ac2.Update_via_SelfCert__c = false;
        ac2.Does_Business_As_DBA__c='DBA1';   
        ac2.NSL_Published_Date__c=system.today();
        ac2.National_Account_Manager__c=U1.id;
        ac2.Activated_On_Locator__c=true;               
        ac2.shippingCountry = 'CA';  
        ac2.ShippingStreet='Test Account Street';               
        ac2.ShippingCity='Lyonn';                    
        ac2.ShippingState='Test';                    
        ac2.Resync_to_Locator__c=false;            
        ac2.ShippingPostalCode ='002';               
        ac2.MAVerifiedLatitude__c=5.7;
        ac2.MAVerifiedLongitude__c=9.0; 
        ac2.Update_via_SelfCert__c=False;
        ac2.ResultCode__c='Pass'; 
        ac2.ResultCode__c='Test Result Code';
        ac2.OwnerId= U2.id;
        ac2.Request_for_account_to_be_on_locator__c=true;    
        ac2.Update_via_SelfCert__c  = false;
        ac2.Status__c='Business Closed';
        ac2.MDM_RecordType__c='Chain Retailer';         
        Update ac2; 
           }
            Test.stopTest();
       } 
                
                
     }
    }
      
    }