@isTest
public class TestDataFactory{
    public static List<Campaign> createCampaign(Integer numberOfCampaign){     
        List<Campaign> listCampaign = new List<Campaign>();
          
        for(Integer count = 0; count < numberOfCampaign; count++){
            Campaign camp = new Campaign(Name = 'Test'+count,                           
                            Type='Test');
            listCampaign.add(camp);
        }
        //System.debug(listCampaign);
        return listCampaign;
    }
    
    public static List<Lead> createLead(Integer count) {
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<count;i++) {
            leads.add(new Lead(Company = 'Test', Status = 'Open', Email='test'+count+'@test.com', FirstName = 'Test', LastName = 'Test'+count ));
        }
        return leads;
    }

    public static List<Contact> createContact(Integer numberOfContact){
        List<Contact> listContact = new List<Contact>();
        List<Account> listAccount = createAccount(numberOfContact);
        insert listAccount;
        
        for(Account acc : listAccount){
            for(Integer count = 0; count < numberOfContact; count++){
                Contact con = new Contact(LastName = 'Test'+count, accountId = acc.Id, Email = 'test'+count+'@test.com');
                listContact.add(con);
            }
        }
        return listContact;
    }
    
    public static List<Contact> createContactOnAccount(Integer numberOfContact, List<Account> listAccount){
        //Create a list
        List<Contact> listContact = new List<Contact>();
        for(Account acc : listAccount){
            for(Integer count = 0; count < numberOfContact; count++){
                Contact con = new Contact(LastName = 'Test'+count, accountId = acc.Id, Email = 'test'+count+'@test.com');
                listContact.add(con);
            }
        }
        //Do not insert the list here. Return to calling class.
        return listContact;
    }

    public static List<Account> createAccount(Integer numberOfAccount){
        //Create a list
        List<Account> listAccount = new List<Account>();
        for(Integer count = 0; count < numberOfAccount; count++){
            //Create Instances of Account
            Account acc= new Account(Name='Test'+count);
            //Add the instance to a list
            listAccount.add(acc);
        }
        //Do not insert the list here. Return to calling class.
        return listAccount;
    }

    public static List<Opportunity> createOpportunity(Integer numberOfOpportunity){
        //Create a list
        List<Opportunity> listOpportunity = new List<Opportunity>();
        
        List<Account> listAccount = createAccount(numberOfOpportunity);
        insert listAccount;
        
        for(Account acc : listAccount){
            for(Integer count = 0; count < numberOfOpportunity; count++){
                //Create Instances of Opportunity
                Opportunity opp = new Opportunity(Name='Test'+count, StageName = 'Test', CloseDate = Date.today(), AccountId = acc.Id);
                //Add the instance to a list
                listOpportunity.add(opp);
            }
        }
        //Do not insert the list here. Return to calling class.
        return listOpportunity;
    }
    
    public static List<Opportunity> createOpportunityOnAccount(Integer numberOfOpportunity, List<Account> listAccount){
        //Create a list
        List<Opportunity> listOpportunity = new List<Opportunity>();
        for(Account acc : listAccount){
            for(Integer count = 0; count < numberOfOpportunity; count++){
                //Create Instances of Opportunity
                Opportunity opp = new Opportunity(Name='Test'+count, StageName = 'Test', CloseDate = Date.today(), AccountId = acc.Id);
                //Add the instance to a list
                listOpportunity.add(opp);
            }
        }
        //Do not insert the list here. Return to calling class.
        return listOpportunity;
    }
    
    //Create KAM Photo TAb metadata Record
    public static Map<String,KAM_Photo_Tabs__mdt> createKAMPhotoTabMetadata()
    {   
        Map<String,KAM_Photo_Tabs__mdt> KAMPhotoTab = NEW Map<String,KAM_Photo_Tabs__mdt>();
        //KAMPhotoTab = KAM_Photo_Tabs__mdt.getAll();
        List<KAM_Photo_Tabs__mdt> kamTabValues = (List<KAM_Photo_Tabs__mdt>) Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Account", "MasterLabel":"Account", "DeveloperName":"Account"}]', List<KAM_Photo_Tabs__mdt>.class);  
        for(KAM_Photo_Tabs__mdt fl : kamTabValues)
        {
            KAMPhotoTab.put(fl.DeveloperName,fl);
        }        
        return KAMPhotoTab;
    }
   
    
    //Create KAM Photo Filters metadata Record
    public static Map < String, KAM_Photo_Filter__mdt> createKAMPhotoFilterMetadata(){
        
        Map < String, KAM_Photo_Filter__mdt> mapKAMFieldSpecificFilter = New Map < String, KAM_Photo_Filter__mdt>();
        //mapKAMFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
        List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": true,"MasterLabel": "Converted Date","Serial_Number__c": "1","Name" : "Demo1", "Field_Label__c" : "Converted Date", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Converted_Date__c","KAM_Photo_Tab__c":"Account","KAM_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": true,"MasterLabel": "X2pk Price Location","Serial_Number__c": "2","Name" : "Demo2", "Field_Label__c" : "X2pk Price Location", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X2pk_Price_Location__c","KAM_Photo_Tab__c":"Account","KAM_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": true,"MasterLabel": "X2D Bar Scanner","Serial_Number__c": "3","Name" : "Demo3", "Field_Label__c" : "X2D Bar Scanner", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X2D_Bar_Scanner__c","KAM_Photo_Tab__c":"Account","KAM_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": true,"MasterLabel": "Name","Serial_Number__c": "","Name" : "Demo4", "Field_Label__c" : "Name", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Name","KAM_Photo_Tab__c":"Account","KAM_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": true,"MasterLabel": "X1st Preferred Distributor","Serial_Number__c": "4","Name" : "Demo5", "Field_Label__c" : "X1st Preferred Distributor", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X1st_Preferred_Distributor__c","KAM_Photo_Tab__c":"Account","Lookup_Object_Name__c":"Account","Object_API_Name__c":"Account","KAM_Photo_Tab__r.DeveloperName":"Account"}]', List<KAM_Photo_Filter__mdt>.class); 
        for(KAM_Photo_Filter__mdt fl : kamFilter)
        {
            mapKAMFieldSpecificFilter.put(fl.Field_API_Name__c,fl);
        }
        
        return mapKAMFieldSpecificFilter;
    }
    
    //Create Field Photo TAb metadata Record
    public static Map<String,Field_Photo_Tab__mdt> createFieldPhotoTabMetadata()
    {   
        Map<String,Field_Photo_Tab__mdt> FieldPhotoab = new Map<String,Field_Photo_Tab__mdt>();
        //FieldPhotoab = Field_Photo_Tab__mdt.getAll();
        List<Field_Photo_Tab__mdt> fieldPhotoTabValues = (List<Field_Photo_Tab__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","MasterLabel":"Account", "Name" : "Account","DeveloperName":"Account"}]', List<Field_Photo_Tab__mdt>.class); 
        for(Field_Photo_Tab__mdt fl : fieldPhotoTabValues)
        {
            FieldPhotoab.put(fl.DeveloperName,fl);
        }
        
        return FieldPhotoab;
    }
    
    //Create Field Photo Filters metadata Record
    public static Map < String, Field_Photo_Filter__mdt> createFieldPhotoFilterMetadata(){
        
        Map < String, Field_Photo_Filter__mdt > mapFieldPhotoSpecificFilter = NEW Map < String, Field_Photo_Filter__mdt >();
        //mapFieldPhotoSpecificFilter = Field_Photo_Filter__mdt.getAll();
        List<Field_Photo_Filter__mdt> fieldFilter = (List<Field_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test","MasterLabel": "D2R Start Date","Field_Label__c" : "D2R Start Date", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "D2R_Start_Date__c","Field_Photo_Tab__c":"Account","Field_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": "true","Serial_Number__c": "2","Name" : "Test2", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X2D_Bar_Scanner__c","MasterLabel": "X2D Bar Scanner","Field_Label__c" : "X2D Bar Scanner","Field_Photo_Tab__c":"Account","Field_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": "true","Serial_Number__c": "3","Name" : "Test3", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X1st_Preferred_Distributor__c","MasterLabel": "X1st Preferred Distributor","Field_Label__c" : "X1st Preferred Distributor","Field_Photo_Tab__c":"Account","Field_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": "true","Serial_Number__c": "4","Name" : "Test4", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Able_To_Sample__c","MasterLabel": "Able To Sample","Field_Label__c" : "Able To Sample","Field_Photo_Tab__c":"Account","Field_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": "true","Serial_Number__c": "7","Name" : "Test3","MasterLabel": "Sales Division","Field_Label__c" : "Sales Division", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Sales_Division__c","Field_Photo_Tab__c":"Account","Field_Photo_Tab__r.DeveloperName":"Account"},{"Is_Active__c": "true","Serial_Number__c": "8","Name" : "Test4","MasterLabel": "Account Segment","Field_Label__c" : "Account Segment", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Account_Segment__c","Field_Photo_Tab__c":"Account","Field_Photo_Tab__r.DeveloperName":"Account"}]', List<Field_Photo_Filter__mdt>.class);  
        
        for(Field_Photo_Filter__mdt fl : fieldFilter)
        {
            mapFieldPhotoSpecificFilter.put(fl.Field_API_Name__c,fl);
        }
        mapFieldPhotoSpecificFilter.putAll(fieldFilter);

        return mapFieldPhotoSpecificFilter;
    }

}