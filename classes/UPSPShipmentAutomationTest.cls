@isTest
private Class UPSPShipmentAutomationTest{
    
    static testMethod void testAll(){
         Profile p = [SELECT Id FROM Profile LIMIT 1];
         String rtId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
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
       ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
           
        List<Account> accList= new List<Account>();
        Account accRec = new Account(Name='TestAccount',
                                    Type = 'HQ',
                                    ShippingState ='AK',
                                    ShippingCountry='US', 
                                    RACS_Status__c='Ready',
                                    National_Account_Manager__c = listUserToInsert[0].id,
                                    Update_via_SelfCert__c  = false,
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId()
         );
       // insert accRec;
        accList.add(accRec);
   
        Case c = new Case(
            Priority='Low',
            status='New',
            Subject='Test',
            Do_Not_Notify__c = true,
            SuppliedEmail = accRec.PersonEmail,
            AccountId = accRec.Id  );
           // OwnerId = u.Id
      
        insert c;
        zkusps__Preference__c pref = new zkusps__Preference__c();
        insert pref;
        
        zkusps__ShippingPreference__c sp = new zkusps__ShippingPreference__c(
            zkusps__companyName__c = 'JUUL',
            zkusps__preference__c = pref.Id,
            zkusps__shippingSenderPhoneDefault__c = '0123456789'
        );
        insert sp;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        
        UPSPShipmentAutomation ctrl = new UPSPShipmentAutomation(stdCon);
        ctrl.generateShipmentLabel();
    }
}