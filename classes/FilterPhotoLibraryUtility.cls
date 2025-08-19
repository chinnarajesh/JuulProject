/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * This class deals with Photo Library revamp module which is dynamic in nature.
 * Class methods used directly in LWC components of Photo Library Revamp module.
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Sudip   
 * @modifiedBy     Sudip 
 * @version        1.0
 * @created        2023-08-25
 * @modified       2023-08-25
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 **/
public class FilterPhotoLibraryUtility {

    public static Map<String,KAM_Photo_Tabs__mdt> getAvailbleKAMTab()
    {
        Map<String, KAM_Photo_Tabs__mdt > KAMPhotoTab = NEW Map<String, KAM_Photo_Tabs__mdt >();
        if(!Test.isRunningTest())
        {
            KAMPhotoTab = KAM_Photo_Tabs__mdt.getAll();
        }
        else
        {
            KAMPhotoTab = TestDataFactory.createKAMPhotoTabMetadata();
            /*mapFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
            List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": true,"Serial_Number__c": "1","Name" : "Demo1", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Converted_Date__c"}]', List<KAM_Photo_Filter__mdt>.class); 
            mapFieldSpecificFilter.putAll(kamFilter);*/
        }
        return KAMPhotoTab;
    }

    public static Map<String,KAM_Photo_Filter__mdt> getAvailbleKAMFilters()
    {
        Map<String, KAM_Photo_Filter__mdt> mapKAMFieldSpecificFilter = NEW Map <String,KAM_Photo_Filter__mdt>();
        if(!Test.isRunningTest())
        {
            mapKAMFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
        }
        else
        {
            mapKAMFieldSpecificFilter = TestDataFactory.createKAMPhotoFilterMetadata();
            /*mapFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
            List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": true,"Serial_Number__c": "1","Name" : "Demo1", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Converted_Date__c"}]', List<KAM_Photo_Filter__mdt>.class); 
            mapFieldSpecificFilter.putAll(kamFilter);*/
        }
        return mapKAMFieldSpecificFilter;
    }
    
    public static Map<String,Field_Photo_Tab__mdt> getAvailbleFieldPhotoTab()
    {
        Map<String, Field_Photo_Tab__mdt > FieldPhotoab = NEW Map<String, Field_Photo_Tab__mdt >();
        if(!Test.isRunningTest())
        {
            FieldPhotoab = Field_Photo_Tab__mdt.getAll();
        }
        else
        {
            FieldPhotoab = TestDataFactory.createFieldPhotoTabMetadata();
            /*mapFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
            List<KAM_Photo_Filter__mdt> kamFilter = (List<KAM_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": true,"Serial_Number__c": "1","Name" : "Demo1", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Converted_Date__c"}]', List<KAM_Photo_Filter__mdt>.class); 
            mapFieldSpecificFilter.putAll(kamFilter);*/
        }
        return FieldPhotoab;
    }
    
    public static Map <String,Field_Photo_Filter__mdt> getAvailbleFieldFilters()
    {
        Map < String, Field_Photo_Filter__mdt > mapFieldPhotoSpecificFilter = NEW Map < String, Field_Photo_Filter__mdt >();
        if(!Test.isRunningTest())
        {
             mapFieldPhotoSpecificFilter = Field_Photo_Filter__mdt.getAll();
        }
        else
        {
            mapFieldPhotoSpecificFilter = TestDataFactory.createFieldPhotoFilterMetadata();
            /*mapFieldSpecificFilter = Field_Photo_Filter__mdt.getAll();
            List<Field_Photo_Filter__mdt> fieldFilter = (List<Field_Photo_Filter__mdt>)Json.deserialize('[{"Is_Active__c": "true","Serial_Number__c": "1","Name" : "Test", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "D2R_Start_Date__c"},{"Is_Active__c": "true","Serial_Number__c": "2","Name" : "Test2", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X2D_Bar_Scanner__c"},{"Is_Active__c": "true","Serial_Number__c": "3","Name" : "Test3", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "X1st_Preferred_Distributor__c"},{"Is_Active__c": "true","Serial_Number__c": "4","Name" : "Test4", "Object_API_Name__c" : "Account", "Field_API_Name__c" : "Able_To_Sample__c"}]', List<Field_Photo_Filter__mdt>.class);  
            mapFieldSpecificFilter.putAll(fieldFilter);*/
        }
        return mapFieldPhotoSpecificFilter;
    }


}