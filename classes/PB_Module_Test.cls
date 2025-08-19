@isTest 
private class PB_Module_Test {
    
     @testSetup
  static void setup() {
      
       ChildAccountShare__c cRec = new ChildAccountShare__c();
        cRec.Name = 'ChidlAccountShare';
        cRec.Shipping_Country_List__c = 'US, United States, USA, CAN, CAD';
        insert cRec;
    Account parentACC = new Account();
    parentACC.Name = 'Parent';
    parentACC.Type ='Independent Retailer';
      parentACC.Ultimate_Parent_Account_Owner__c= UserInfo.getUserId();
     insert parentACC;
    //Create Accounts
    List<Account> accounts = new List<Account>(); 

    for(Integer i = 0; i < 3; i++) {
      
      Account acc = new Account();
          acc.Name = 'Test: ' + i;
        acc.Type = 'Independent Retailer';
        acc.Ultimate_Parent_Account__c = parentACC.Id;
        //acc.Ultimate_Parent_Account_Owner__c = parentACC.Id;
      accounts.add(acc); 
    }

    insert accounts; 

    //Insert Assessment

    Assessment__c assessment = new Assessment__c(
      Name = 'Assess', 
      Country_Code__c = 'CA', 
      Launch_From_Object__c = 'Account'
    );

    Retail_Theater__c RT = new Retail_Theater__c();
     if (!accounts.isEmpty()) {
        RT.Account__c = accounts[1].Id;
        }
       RT.Audit_Date__c = Date.newInstance(2023, 8, 23);
       insert RT;
      
    /*  ContentDocument CD = new ContentDocument();
      CD.Title = 'Pengns';
      CD.FileType = 'JPG';
      CD.FileExtension = 'jpg';
      insert CD; */
 ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
      
      insert contentVersion;
      
     ContentDocument CD = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
     
     
      
      /*RetailStore RS = new RetailStore();
      RS.Name = 'Retail';
      RS.AccountId = accounts[1].Id;
      insert RS;
      
      Visit VS = new Visit();
      VS.cgcloud__Completed_Date__c = Date.newInstance(2023, 8, 23);
      VS.Retail_Theater__c = RT.Id;
      VS.PlaceId = RS.Id;
      //VS.AccountId = accounts[1].Id;
      VS.CreatedDate =  Date.newInstance(2023, 8, 23);
      VS.PlannedVisitStartTime = Datetime.newInstance(2023, 8, 23, 15, 30, 0);
      insert VS;
      
       
      ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = VS.Id;
        cdl.ContentDocumentId = CD.Id;
        cdl.shareType = 'V';
        insert cdl;*/
      
     /* ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = RT.Id;
        
        cd2.ContentDocumentId = CD.Id;
        cd2.shareType = 'V';
        insert cd2;*/
  }
    
    static testMethod void testPhotoUserHierarchy() {
      List<String> resultOfMethod = PhotoUserHierarchy.getUsersList();
    }
    
     static testMethod void testPhotoLibraryHelper() {
         
       List<String> Ids = new List<String>();
         
        Contact con1 = new Contact(
        FirstName='Joe',
        LastName='Smith',
        Phone='415.555.1212');
       insert con1;
         
        Contact con2 = new Contact(
        FirstName='Moe',
        LastName='Mith',
        Phone='415.555.1212');
       insert con2;
         
        for(Contact a : [select id from Contact where Name Like '%Moe%']){
        Ids.add(a.id);
    }
         system.debug('Ids values are::'+Ids);
        PhotoLibraryHelper.getResults('Contact','Ultimate_Parent_Account__c','Lisa Lee',Ids,'Search by Account KAM');
         
          PhotoLibraryHelper.getResults('Contact','Name','Johnson',Ids,'Search by Door Owner');
    }
    
     static testMethod void testPhotoLibraryHelper1() {
         
       List<String> Ids = new List<String>();
         
        Contact con1 = new Contact(
        FirstName='Joe',
        LastName='Smith',
        Phone='415.555.1212');
       insert con1;
         
        Contact con2 = new Contact(
        FirstName='Moe',
        LastName='Mith',
        Phone='415.555.1212');
       insert con2;
         
        for(Contact a : [select id from Contact where Name Like '%Moe%']){
        Ids.add(a.id);
    }
         List<Id> listIds = new List<Id>();
         system.debug('Ids values are::'+Ids);
        PhotoLibraryHelper.getResults('Contact','Ultimate_Parent_Account__c','Parent',listIds,'Search by Account KAM');
         
         
           //List<Id> listIds1 = new List<Id>();
        PhotoLibraryHelper.getResults('Contact','Name','Johnson',listIds,'');
    }
     static testMethod void testFilterPhotoLibraryTabNames() {
         
         
         //List<KAM_Photo_Tabs__mdt> kamTabValues = (List<KAM_Photo_Tabs__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account", "DeveloperName":"Account"}]', List<KAM_Photo_Tabs__mdt>.class);  
         //List<Field_Photo_Tab__mdt> fieldTabValues = (List<Field_Photo_Tab__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account","DeveloperName":"Account"}]', List<Field_Photo_Tab__mdt>.class); 
         
         
         //List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "D2R_Start_Date__c"},{"Is_Active__c": "true","Serial_Number__c": "2","Name" : "Test2", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X2D_Bar_Scanner__c"},{"Is_Active__c": "true","Serial_Number__c": "3","Name" : "Test3", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X1st_Preferred_Distributor__c"}]', List<KAM_Photo_Filter__mdt>.class); 
         //List<Field_Photo_Filter__mdt> fieldFilter = (List<Field_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "D2R_Start_Date__c"},{"Is_Active__c": "true","Serial_Number__c": "2","Name" : "Test2", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X2D_Bar_Scanner__c"},{"Is_Active__c": "true","Serial_Number__c": "3","Name" : "Test3", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X1st_Preferred_Distributor__c"},{"Is_Active__c": "true","Serial_Number__c": "4","Name" : "Test4", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Able_To_Sample__c"}]', List<Field_Photo_Filter__mdt>.class);  
         Test.startTest();
         
         //Map < String, KAM_Photo_Filter__mdt> mapFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
         //for (String filterName: mapFieldSpecificFilter.keySet()) {
         // System.debug('My STring Values are:::::'+filterName);
        // }
       
         FilterPhotoLibrary.getKAMTabNames();
         FilterPhotoLibrary.getFieldTabNames();
         FilterPhotoLibrary.getAvailbleKAMFilters();
         FilterPhotoLibrary.getAvailbleFieldFilters();
         Test.stopTest();
    }
    
     /*static testMethod void testFilterPhotoLibraryTabNamesTwo() {
         
         
         //List<KAM_Photo_Tabs__mdt> kamTabValues = (List<KAM_Photo_Tabs__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Demo3"}]', List<KAM_Photo_Tabs__mdt>.class);  
         //List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": true,"Serial_Number__c": "1","Name" : "Demo1", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Converted_Date__c"}]', List<KAM_Photo_Filter__mdt>.class); 
        
         Test.startTest();
         FilterPhotoLibrary.getAvailbleKAMFilters();
         Test.stopTest();
    }*/
    
    
     static testMethod void testFilterPhotoLibrarySavedFilterNames() {
         Id currentUserId = UserInfo.getUserId();
         Saved_Photo_Filter__c spfc = new Saved_Photo_Filter__c();
         spfc.Persona__c = 'Field Filter';
         spfc.Is_Active__c = true;
         spfc.Filter_Name__c = 'Test';
         spfc.User__c = currentUserId;
         
         insert spfc;
         
         FilterPhotoLibrary.getSavedFilterNames(true);
         FilterPhotoLibrary.getSavedFilterNamesRefresh(true);
         FilterPhotoLibrary.getSelectedSavedJsonValuesFilter('Test',true);
         FilterPhotoLibrary.getSelectedSavedJsonValuesQuestion('Test',true);
         FilterPhotoLibrary.getSelectedSavedJsonValuesFromDate('Test',true);
         FilterPhotoLibrary.getSelectedSavedJsonValuesToDate('Test',true);
         FilterPhotoLibrary.isFilterAlreadyAvailable('Test','Field Filter');
         FilterPhotoLibrary.isFilterAlreadyAvailable('Test Test','Field Filter');
         FilterPhotoLibrary.saveNewFilter('Test Test','Field Filter','mtest','test','test','test','test');
         FilterPhotoLibrary.saveNewFilter('Test Test','Field Filter','Test Test','Test Test','Test Test','test','test');
         
    }
    
    static testMethod void getFormValuesTest(){
        
        FilterPhotoLibrary.getFormValues();
    }
    
     static testMethod void getQuestionValuesTest(){
        List<String> formIds = new List<String>();
         
        /* for(disco__Form_Template__c dft : [Select Id from disco__Form_Template__c]){
             formIds.add(dft.Id);
         }
         List<disco__Form_Template__c> dftList = [Select Id from disco__Form_Template__c];*/
        FilterPhotoLibrary.getQuestionValues(formIds);
        FilterPhotoLibrary.builderFormDetails();
    }
    
     static testMethod void getSearchResultsTest(){
        
        List<String> actList = new List<String>();
         for(Account a : [Select Id from Account]){
             actList.add(a.Id);
         }
        FilterPhotoLibrary.getRecordsNames('Account',actList);
         
        List<String> fieldName = new List<String>();
        fieldName.add('Name');
        FilterPhotoLibrary.search('Account',fieldName,'Test: 1');
    }



  static testMethod void fetchPhotoValuesTest() {
      
      
      List<String> myQuestionIdValues = new List<String>();
      Boolean myPersona = true;
      Integer myPage = 1;
      
       List<KAM_Photo_Tabs__mdt> kamTabValues = (List<KAM_Photo_Tabs__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account"}]', List<KAM_Photo_Tabs__mdt>.class);  
       List<Field_Photo_Tab__mdt> fieldTabValues = (List<Field_Photo_Tab__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account"}]', List<Field_Photo_Tab__mdt>.class); 
       List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test"}]', List<KAM_Photo_Filter__mdt>.class); 
       //List<Field_Photo_Filter__mdt> fieldFilter = (List<Field_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test"}]', List<Field_Photo_Filter__mdt>.class);
       List<Field_Photo_Filter__mdt> fieldFilter = (List<Field_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X1st_Preferred_Distributor__c", "Field_Data_Type__c" :"Picklist (Multi-Select)"}]', List<Field_Photo_Filter__mdt>.class);  
       List<PB_Persona_UserRole__mdt> personaValues = (List<PB_Persona_UserRole__mdt>)Json.deserialize('[{"Is_Role_Hierarchy_Active__c": "true","Name" : "Field Persona"}]', List<PB_Persona_UserRole__mdt>.class);  
       List<PB_Photo_Source__mdt> photoSource = (List<PB_Photo_Source__mdt>)Json.deserialize('[{"Source__c": "Retail_Theater__c","MasterLabel" : "Photos Source"}]', List<PB_Photo_Source__mdt>.class);
     // insert 
     List<String> myTempList = new List<String>();
     Map<String, List<String>> myTempMap = new Map<String, List<String>>();
     List<String> firstList = new List<String>();
     List<String> secondList = new List<String>();
     List<String> thirdList = new List<String>();
     List<String> fourthList = new List<String>();
     firstList.add('Account');
     secondList.add('Name');
     thirdList.add('single');
     fourthList.add('Test: 1');
     myTempMap.put('objectapiname',firstList);
     myTempMap.put('fieldapiname',secondList);
     myTempMap.put('fieldType',thirdList);
     myTempMap.put('selectedvalues',fourthList);
     List<Map<String, List<String>>> myFilterVal  = new List<Map<String, List<String>>>();
     myFilterVal.add(myTempMap);
     myTempList.add('Account');
     myTempList.add('Name');
     myTempList.add('single');
     String mylocalDate = String.valueOf(Date.newInstance(2023, 8, 15));
     String mylocalDateTo = String.valueOf(Date.newInstance(2023, 8, 25));
     //myFilterVal= [{"objectapiname":["Account"],"fieldapiname":["Name"],"fieldType":["single"],"selectedvalues":["7-Eleven"]},{"objectapiname":["Account"],"fieldapiname":["Account_Segment__c"],"fieldType":["multiple"],"selectedvalues":[]},{"objectapiname":["Account"],"fieldapiname":["Ultimate_Parent_Account_Owner__c"],"fieldType":["lookup"],"selectedvalues":["0051O00000D7qyEQAR"]},{"objectapiname":["Account"],"fieldapiname":["OwnerId"],"fieldType":["lookup"],"selectedvalues":[]}];
     FilterPhotoLibrary.fetchPhotosForAppliedFilter(myFilterVal,myQuestionIdValues,myPersona,myPage,mylocalDate,mylocalDateTo);
    
}


 static testMethod void fetchPhotoValuesTestDifferentPersona() {
      
      
      List<String> myQuestionIdValues = new List<String>();
      Boolean myPersona = false;
      Integer myPage = 1;
      
       List<KAM_Photo_Tabs__mdt> kamTabValues = (List<KAM_Photo_Tabs__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account"}]', List<KAM_Photo_Tabs__mdt>.class);  
       List<Field_Photo_Tab__mdt> fieldTabValues = (List<Field_Photo_Tab__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account"}]', List<Field_Photo_Tab__mdt>.class); 
       List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test"}]', List<KAM_Photo_Filter__mdt>.class); 
       List<Field_Photo_Filter__mdt> fieldFilter = (List<Field_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test", "Field_Data_Type__c" :"Date", "Field_API_Name__c" : "ComplianceMechanism__c"}]', List<Field_Photo_Filter__mdt>.class); 
       List<PB_Persona_UserRole__mdt> personaValues = (List<PB_Persona_UserRole__mdt>)Json.deserialize('[{"Is_Role_Hierarchy_Active__c": "true","Name" : "Field Persona"}]', List<PB_Persona_UserRole__mdt>.class);  
       List<PB_Photo_Source__mdt> photoSource = (List<PB_Photo_Source__mdt>)Json.deserialize('[{"Source__c": "Visit","MasterLabel" : "Photos Source"}]', List<PB_Photo_Source__mdt>.class);
     List<String> myTempList = new List<String>();
     Map<String, List<String>> myTempMap = new Map<String, List<String>>();
     List<String> firstList = new List<String>();
     List<String> secondList = new List<String>();
     List<String> thirdList = new List<String>();
     List<String> fourthList = new List<String>();
     firstList.add('Account');
     secondList.add('Name');
     thirdList.add('single');
     fourthList.add('Test: 1');
     myTempMap.put('objectapiname',firstList);
     myTempMap.put('fieldapiname',secondList);
     myTempMap.put('fieldType',thirdList);
     myTempMap.put('selectedvalues',fourthList);
     List<Map<String, List<String>>> myFilterVal  = new List<Map<String, List<String>>>();
     myFilterVal.add(myTempMap);
     myTempList.add('Account');
     myTempList.add('Name');
     myTempList.add('single');
     String mylocalDate = String.valueOf(Date.newInstance(2023, 8, 25));
     String mylocalDateTo = String.valueOf(Date.newInstance(2023, 8, 15));
     //myFilterVal= [{"objectapiname":["Account"],"fieldapiname":["Name"],"fieldType":["single"],"selectedvalues":["7-Eleven"]},{"objectapiname":["Account"],"fieldapiname":["Account_Segment__c"],"fieldType":["multiple"],"selectedvalues":[]},{"objectapiname":["Account"],"fieldapiname":["Ultimate_Parent_Account_Owner__c"],"fieldType":["lookup"],"selectedvalues":["0051O00000D7qyEQAR"]},{"objectapiname":["Account"],"fieldapiname":["OwnerId"],"fieldType":["lookup"],"selectedvalues":[]}];
     FilterPhotoLibrary.fetchPhotosForAppliedFilter(myFilterVal,myQuestionIdValues,myPersona,myPage,mylocalDate,mylocalDateTo);
 } 
}