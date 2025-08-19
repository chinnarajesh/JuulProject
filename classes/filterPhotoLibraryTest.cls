@isTest
Public class filterPhotoLibraryTest {
    @testSetup static void setup() {
        List< Saved_Photo_Filter__c > testfilter = new List< Saved_Photo_Filter__c >();
        for(Integer i=1;i<5;i++) {
            if(i < 3)
            {
                testfilter.add(new Saved_Photo_Filter__c(Filter_Name__c = 'Test '+i, Is_Active__c=true, Persona__c='Field Filter', User__c =UserInfo.getUserId(),From_Submitted_Date__c = String.valueOf(system.today())));
            }
            else
            {
               testfilter.add(new Saved_Photo_Filter__c(Filter_Name__c = 'Test '+i, Is_Active__c=true, Persona__c='KAM Filter', User__c =UserInfo.getUserId(),From_Submitted_Date__c = String.valueOf(system.today())));
            }
        }
        insert testfilter;
        
         Account ultimateParentAccount = new Account(
            Name = 'Ultimate Parent Account',
            Account_Segment__c = 'TM uncovered',
            Type = 'HQ'
        );
        insert ultimateParentAccount;

        Account testAccount = new Account(
            Name = 'Test Account',
            ShippingCity = 'Tulsa',
            ShippingState = 'OK',
            Account_Segment__c = 'TM Uncovered',
            Type = 'Independent Retailer',
            OwnerId = UserInfo.getUserId(),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Ultimate_Parent_Account_Owner__c = UserInfo.getUserId()
        );
        insert testAccount;
        
        // Create test Retail_Theater__c record
        Retail_Theater__c retailTheater = new Retail_Theater__c(
            Audit_Date__c = Date.today(),
            Account__c = testAccount.Id,
            Menthol_3_2_8ml_4_pack__c = 'In Stock',
            Virginia_Tobacco_3_1_4ml_2_pack__c = 'In Stock',
            Virginia_Tobacco_3_2_8ml_4_pack__c = 'In Stock',
            Virginia_Tobacco_5_1_4ml_2_pack__c = 'In Stock',
            Virginia_Tobacco_5_2_8ml_4_pack__c = 'Out of Stock',
            Menthol_5_1_4ml_2_pack__c = 'In Stock',
            Menthol_5_2_8ml_4_pack__c = 'In Stock',
            USB_Charger__c = 'In Stock',
            Device_Kit_Silver__c = 'In Stock',
            Device_Kit_Slate__c = 'Out of Stock'
        );
        insert retailTheater;

    }
    @isTest static void filterPhotoLibrarymethod1() {
        List <String> listSting = New  List <String>();
        listSting.add('Test 1');
        listSting.add('Test 2');

        Map <String, List <String>>  mapoflist = New Map <String, List <String>>();
        mapoflist.put('Test 1',listSting);

        List <Map<String,List<String>>> ListMapoflist =  NEW List <Map<String,List<String>>>();
        ListMapoflist.add(mapoflist);
        //Saved_Photo_Filter__c spf = [Select Id,Filter_Name__c From Saved_Photo_Filter__c Where Filter_Name__c ='Test 1'];

        String formSubmittedDate  = String.valueOf(system.today());
        String formSubmittedDateTo = String.valueOf(system.today().addDays(3));
        
    	List<Map<String, List<String>>> filterValues = new List<Map<String, List<String>>>();
        Map<String, List<String>> filterMap = new Map<String, List<String>>();
        filterMap.put('objectapiname', new List<String>{'Account'});
        filterMap.put('fieldapiname', new List<String>{'Ultimate_Parent_Account__c'});
        filterMap.put('fieldType', new List<String>{'lookup'});
        filterMap.put('selectedvalues', new List<String>{String.valueof(UserInfo.getUserId())});
        filterValues.add(filterMap);
        List<Map<String, List<String>>> filterValues1 = new List<Map<String, List<String>>>();
        Map<String, List<String>> filterMap1 = new Map<String, List<String>>();
        filterMap1.put('objectapiname', new List<String>{'Account'});
        filterMap1.put('fieldapiname', new List<String>{'Name'});
        filterMap1.put('fieldType', new List<String>{'single'});
        filterMap1.put('selectedvalues', new List<String>{''});
        filterValues1.add(filterMap1);
    	
        List<Map<String, List<String>>> filterValues2 = new List<Map<String, List<String>>>();
        Map<String, List<String>> filterMap2 = new Map<String, List<String>>();
        filterMap2.put('objectapiname', new List<String>{'Account'});
        filterMap2.put('fieldapiname', new List<String>{'Account_Segment__c'});
        filterMap2.put('fieldType', new List<String>{'multiple'});
        filterMap2.put('selectedvalues', new List<String>{'TM Covered'});
        filterValues2.add(filterMap2);
        
        FilterPhotoLibrary.getKAMTabNames();
        FilterPhotoLibrary.getAvailbleKAMFilters();
        FilterPhotoLibrary.getAvailbleFieldFilters();
        FilterPhotoLibrary.getFieldTabNames();
        FilterPhotoLibrary.builderFormDetails();
        FilterPhotoLibrary.getSavedFilterNames(true);
        FilterPhotoLibrary.getSavedFilterNamesRefresh(true);
       
        //Retail_Theater__c retailTH = [Select Id,Name,Account__c,Audit_Date__c FROM Retail_Theater__c Where Account__r.Name = 'Account2'];
        
        Test.startTest();
        String result = FilterPhotoLibrary.getSelectedSavedJsonValuesFromDate('Test 1', true);
        String result1 =FilterPhotoLibrary.getSelectedSavedJsonValuesQuestion('Test 2', true);
        FilterPhotoLibrary.getSelectedSavedJsonValuesFilter('Test 2', true);
        FilterPhotoLibrary.getSelectedSavedJsonValuesToDate('Test 2', true);
        //String result2 = FilterPhotoLibrary.getQuestionValues(testIds);
        FilterPhotoLibrary.isFilterAlreadyAvailable('Test 2', 'Field Filter');
        FilterPhotoLibrary.saveNewFilter('Test 2', 'Field Filter','','','Test 2',formSubmittedDate,formSubmittedDateTo);
        FilterPhotoLibrary.saveNewFilter('Test 2', 'Field Filter','','','Test 4',formSubmittedDate,formSubmittedDateTo);
        FilterPhotoLibrary.getFormValues();
        //List<Map<String, String>> result5 = FilterPhotoLibrary.mapRetailtheater(retailTH);
        FilterPhotoLibrary.fetchPhotosForAppliedFilter(filterValues,listSting,true,1, formSubmittedDate,formSubmittedDateTo);
        FilterPhotoLibrary.fetchPhotosForAppliedFilter(filterValues2,listSting,true,1, formSubmittedDate,formSubmittedDateTo);
        FilterPhotoLibrary.fetchPhotosForAppliedFilter(filterValues1,listSting,true,1, formSubmittedDate,formSubmittedDateTo);
		FilterPhotoLibrary.fetchPhotosForAppliedFilter(filterValues1,listSting,false,1, formSubmittedDate,formSubmittedDateTo);
 		FilterPhotoLibrary.fetchPhotosForAppliedFilter(filterValues,listSting,false,1, formSubmittedDate,formSubmittedDateTo);
        FilterPhotoLibrary.fetchPhotosForAppliedFilter(filterValues2,listSting,false,1, formSubmittedDate,formSubmittedDateTo);
        Test.stopTest();
        
    }
    /*static testMethod void testFilterPhotoLibraryTabNamesTwo() {
         
         
         List<KAM_Photo_Tabs__mdt> kamTabValues = (List<KAM_Photo_Tabs__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Demo3"}]', List<KAM_Photo_Tabs__mdt>.class);  
         List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": true,"Serial_Number__c": "1","Name" : "Demo1", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Converted_Date__c"}]', List<KAM_Photo_Filter__mdt>.class); 
        
         Test.startTest();
         FilterPhotoLibrary.getAvailbleKAMFilters();
         Test.stopTest();
    }*/
    
    @isTest
    static void testMapRetailTheater() {
        // Fetch the test data
        Retail_Theater__c rt = [SELECT Audit_Date__c, 
                                       Menthol_3_2_8ml_4_pack__c, 
                                       Virginia_Tobacco_3_1_4ml_2_pack__c, 
                                       Virginia_Tobacco_3_2_8ml_4_pack__c, 
                                       Virginia_Tobacco_5_1_4ml_2_pack__c, 
                                       Virginia_Tobacco_5_2_8ml_4_pack__c, 
                                       Menthol_5_1_4ml_2_pack__c, 
                                       Menthol_5_2_8ml_4_pack__c, 
                                       USB_Charger__c, 
                                       Device_Kit_Silver__c, 
                                       Device_Kit_Slate__c, 
                                       Account__r.ShippingCity, 
                                       Account__r.ShippingState, 
                                       Account__r.Account_Segment__c, 
                                       Account__r.Type, 
                                       Account__r.Owner.Name, 
                                       Account__r.Ultimate_Parent_Account_Owner__r.Name, 
                                       Account__r.Ultimate_Parent_Account__r.Name, 
                                       Account__r.Name 
                                  FROM Retail_Theater__c 
                                  LIMIT 1];
        
        // Call the method
        List<Map<String, String>> result = FilterPhotoLibrary.mapRetailtheater(rt);

        // Perform assertions
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());

        Map<String, String> resultMap = result[0];
        System.assertEquals(rt.Audit_Date__c.format(), resultMap.get('Audit Date'));
        System.assertEquals(rt.Menthol_3_2_8ml_4_pack__c, resultMap.get('Menthol 3% 2.8ml 4pk'));
        System.assertEquals(rt.Virginia_Tobacco_3_1_4ml_2_pack__c, resultMap.get('Virginia Tobacco 3% 1.4ml 2-pack'));
        System.assertEquals(rt.Account__r.ShippingCity, resultMap.get('City'));
        System.assertEquals(rt.Account__r.Owner.Name, resultMap.get('Account Owner'));
        // Add additional asserts as needed
    }
}