/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * This class deals with Photo Library revamp module which is dynamic in nature.
 * Class methods used directly in LWC components of Photo Library Revamp module.
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Viren Singh   
 * @modifiedBy     Viren Singh  
 * @version        1.0
 * @created        2021-07-28
 * @modified       2021-09-01
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 **/
public class FilterPhotoLibrary {


    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All tab names for KAM Filter Persona
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    NA    
     * @return   List<String>  Account,Campaign,Mission.......
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static List < String > getKAMTabNames() {
        Map < Decimal, String > mapTabs = new Map < Decimal, String > ();
        Map < String, KAM_Photo_Tabs__mdt > mapKAMPhotoTab = KAM_Photo_Tabs__mdt.getAll();
        for (String tabName: mapKAMPhotoTab.keySet()) {
            if (mapKAMPhotoTab.get(tabName).Is_Active__c) {
                mapTabs.put(mapKAMPhotoTab.get(tabName).Serial_Number__c, mapKAMPhotoTab.get(tabName).Label);
            }
        }
        List < String > allAvailableTabNames = new List < String > ();
        List < Decimal > sortTemp = new List < Decimal > ();
        sortTemp.addAll(mapTabs.keySet());
        sortTemp.sort();
        for (Decimal a: sortTemp) {
            allAvailableTabNames.add(mapTabs.get(a));
        }
        return allAvailableTabNames;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All configured filters for KAM Filter Persona.
     * All Filters are coming from KAM_Photo_Filter__mdt metadata Object
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param   objectAPIName  Receive Tab names from LWC and find respective Filter values     
     * @return   String  
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static String getAvailbleKAMFilters() {
         Map < String, String > allTabMap = new Map < String, String > ();
        //Map < String, KAM_Photo_Tabs__mdt> mapFilterPhotoTab = KAM_Photo_Tabs__mdt.getAll();
        Map < String, KAM_Photo_Tabs__mdt> mapFilterPhotoTab = FilterPhotoLibraryUtility.getAvailbleKAMTab();
        system.debug('getAvailbleKAMFilters mapFilterPhotoTab : '+mapFilterPhotoTab);
        for (String tabName: mapFilterPhotoTab.keySet()) {
            if (mapFilterPhotoTab.get(tabName).Is_Active__c) {
                allTabMap.put(mapFilterPhotoTab.get(tabName).DeveloperName, mapFilterPhotoTab.get(tabName).MasterLabel);
            }
        }
        system.debug('getAvailbleKAMFilters allTabMap : '+allTabMap);
        List < String > availableFilters = new List < String > ();
        Map < String, KAM_Photo_Filter__mdt> mapFieldSpecificFilter = FilterPhotoLibraryUtility.getAvailbleKAMFilters();
        system.debug('getAvailbleKAMFilters mapFieldSpecificFilter : '+mapFieldSpecificFilter);
        //Map < String, KAM_Photo_Filter__mdt> mapFieldSpecificFilter = KAM_Photo_Filter__mdt.getAll();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for (String filterName: mapFieldSpecificFilter.keySet()) {
            system.debug('getAvailbleKAMFilters filterName : '+filterName);
            String currentTab = mapFieldSpecificFilter.get(filterName).Object_API_Name__c;
            if ((mapFieldSpecificFilter.get(filterName).Is_Active__c)) {
                gen.writeStartObject();
                Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get(currentTab);
                Map < String, Schema.SObjectField > fieldMap = leadSchema.getDescribe().fields.getMap();
                Schema.DisplayType fielddataType = fieldMap.get(mapFieldSpecificFilter.get(filterName).Field_API_Name__c).getDescribe().getType();
                system.debug('getAvailbleKAMFilters fielddataType : '+fielddataType);
                if (string.valueOf(fielddataType) == 'DATE') {
                    gen.writeStringField('fieldtype', 'date');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isText', true);
                    gen.writeBooleanField('isMultiSelect', false);
                    gen.writeStringField('objectlookupname', '');
                    //gen.writeStringField('helpText', '');
                    gen.writeFieldName('picklistvalues');
                    gen.writeStartArray();
                    gen.writeStartObject();

                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();

                }
                if (string.valueOf(fielddataType) == 'BOOLEAN') {
                    gen.writeStringField('fieldtype', 'boolean');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isText', true);
                    gen.writeBooleanField('isMultiSelect', false);
                    gen.writeStringField('objectlookupname', '');
                    gen.writeFieldName('picklistvalues');
                    //gen.writeStringField('helpText', '');
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();
                }
                if (string.valueOf(fielddataType) == 'REFERENCE') {
                    System.debug('FIELD TYPE IS:::' + 'REFERNECE');
                    System.debug('FIELD APIName IS:::' + mapFieldSpecificFilter.get(filterName).Field_API_Name__c);
                    gen.writeStringField('fieldtype', 'lookup');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', true);
                    gen.writeBooleanField('isText', false);
                    gen.writeBooleanField('isMultiSelect', false);
                    // gen.writeStringField('helpText', mapFieldSpecificFilter.get(filterName).help_Text__c);
                    if(mapFieldSpecificFilter.get(filterName).Lookup_Object_Name__c != null)
                    {
                        gen.writeStringField('objectlookupname', mapFieldSpecificFilter.get(filterName).Lookup_Object_Name__c);
                    }
                    gen.writeFieldName('picklistvalues');
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();
                }

                if (string.valueOf(fielddataType) == 'PICKLIST' || string.valueOf(fielddataType) == 'MULTIPICKLIST') {
                    gen.writeStringField('fieldtype', 'picklist');
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isPicklist', true);
                    gen.writeBooleanField('isText', false);
                    gen.writeBooleanField('isMultiSelect', mapFieldSpecificFilter.get(filterName).Is_Multi_Select__c);
                    gen.writeStringField('objectlookupname', '');
                    //gen.writeStringField('helpText', '');
                    List < String > pickListValuesList = new List < String > ();
                    Schema.DescribeFieldResult fieldResult = fieldMap.get(mapFieldSpecificFilter.get(filterName).Field_API_Name__c).getDescribe();
                    List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
                    gen.writeFieldName('picklistvalues');
                    gen.writeStartArray();

                    Integer i = 0;
                    for (Schema.PicklistEntry pickListVal: ple) {
                        gen.writeStartObject();
                        gen.writeNumberField('key', i++);
                        gen.writeStringField('value', String.valueOf(pickListVal.getLabel()));
                        gen.writeEndObject();
                    }

                    gen.writeEndArray();
                }
                if (string.valueOf(fielddataType) != 'BOOLEAN' &&
                    string.valueOf(fielddataType) != 'DATE' &&
                    string.valueOf(fielddataType) != 'REFERENCE' &&
                    string.valueOf(fielddataType) != 'PICKLIST' &&
                    string.valueOf(fielddataType) != 'MULTIPICKLIST') {
                    gen.writeStringField('fieldtype', 'search');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isText', true);
                    gen.writeBooleanField('isMultiSelect', false);
                    gen.writeStringField('objectlookupname', '');
                    gen.writeFieldName('picklistvalues');
                    //gen.writeStringField('helpText', '');
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();
                }
                if(mapFieldSpecificFilter.get(filterName).Serial_Number__c != null && mapFieldSpecificFilter.get(filterName).Serial_Number__c != 0){
                  gen.writeNumberField('SerialNumber', mapFieldSpecificFilter.get(filterName).Serial_Number__c);
                
                }
                else{
                 gen.writeNumberField('SerialNumber', 0);
                }
                system.debug('getAvailbleKAMFilters mapFieldSpecificFilter.get(filterName) : '+mapFieldSpecificFilter.get(filterName));
                system.debug('getAvailbleKAMFilters allTabMap 2 : '+allTabMap);
                gen.writeStringField('labeltype', mapFieldSpecificFilter.get(filterName).Field_Label__c);
                gen.writeStringField('APIName', mapFieldSpecificFilter.get(filterName).Field_API_Name__c);
                gen.writeStringField('ObjectName', mapFieldSpecificFilter.get(filterName).Object_API_Name__c);
                gen.writeStringField('masterLabel', mapFieldSpecificFilter.get(filterName).MasterLabel);
                String customtabname = allTabMap.get(mapFieldSpecificFilter.get(filterName).KAM_Photo_Tab__r.DeveloperName);
                if(customtabname != NULL)
                {
                    gen.writeStringField('ObjectTabName', customtabname);
                    gen.writeStringField(customtabname, customtabname);
                }
                gen.writeStringField('tempofieldval', '');
                
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        String genString = gen.getAsString();
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"{', '{');
        genString = genString.replace('}"', '}');
        return genString;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All configured filters for Field Filter Persona.
     * All Filters are coming from Field_Photo_Filter__mdt metadata Object
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param  NA   
     * @return  String  
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static String getAvailbleFieldFilters() {

        Map < String, String > allTabMap = new Map < String, String > ();
        //Map < String, Field_Photo_Tab__mdt > mapFilterPhotoTab = Field_Photo_Tab__mdt.getAll();
        Map < String, Field_Photo_Tab__mdt> mapFilterPhotoTab = FilterPhotoLibraryUtility.getAvailbleFieldPhotoTab();
        system.debug('getAvailbleFieldFilters mapFilterPhotoTab : '+mapFilterPhotoTab);
        for (String tabName: mapFilterPhotoTab.keySet()) {
            if (mapFilterPhotoTab.get(tabName).Is_Active__c) {
                allTabMap.put(mapFilterPhotoTab.get(tabName).DeveloperName, mapFilterPhotoTab.get(tabName).MasterLabel);
            }
        }
        system.debug('getAvailbleFieldFilters allTabMap : '+allTabMap);
        List < String > availableFilters = new List < String > ();
        Map < String, Field_Photo_Filter__mdt> mapFieldSpecificFilter = FilterPhotoLibraryUtility.getAvailbleFieldFilters();
        system.debug('getAvailbleFieldFilters mapFieldSpecificFilter : '+mapFieldSpecificFilter);
        //Map < String, Field_Photo_Filter__mdt > mapFieldSpecificFilter = Field_Photo_Filter__mdt.getAll();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for (String filterName: mapFieldSpecificFilter.keySet()) {
            system.debug('getAvailbleFieldFilters filterName : '+filterName);
            String currentTab = mapFieldSpecificFilter.get(filterName).Object_API_Name__c;
            if ((mapFieldSpecificFilter.get(filterName).Is_Active__c)) {
                gen.writeStartObject();
                Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get(currentTab);
                Map < String, Schema.SObjectField > fieldMap = leadSchema.getDescribe().fields.getMap();
                Schema.DisplayType fielddataType = fieldMap.get(mapFieldSpecificFilter.get(filterName).Field_API_Name__c).getDescribe().getType();
                system.debug('getAvailbleFieldFilters fielddataType : '+fielddataType);
                if (string.valueOf(fielddataType) == 'DATE') {
                    gen.writeStringField('fieldtype', 'date');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isText', true);
                    gen.writeBooleanField('isMultiSelect', false);
                    gen.writeStringField('objectlookupname', '');
                    gen.writeFieldName('picklistvalues');
                   // gen.writeStringField('helpText', '');
                    gen.writeStartArray();
                    gen.writeStartObject();

                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();

                }
                if (string.valueOf(fielddataType) == 'BOOLEAN') {
                    gen.writeStringField('fieldtype', 'boolean');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isText', true);
                    gen.writeBooleanField('isMultiSelect', false);
                    gen.writeStringField('objectlookupname', '');
                    gen.writeFieldName('picklistvalues');
                    //gen.writeStringField('helpText', '');
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();
                }
                if (string.valueOf(fielddataType) == 'REFERENCE') {
                    System.debug('FIELD TYPE IS:::' + 'REFERNECE');
                    System.debug('FIELD APIName IS:::' + mapFieldSpecificFilter.get(filterName).Field_API_Name__c);
                    gen.writeStringField('fieldtype', 'lookup');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', true);
                    gen.writeBooleanField('isText', false);
                    gen.writeBooleanField('isMultiSelect', false);
                    // String helptext = String.valueOf(mapFieldSpecificFilter.get(filterName).help_Text__c);
                    // gen.writeStringField('helpText', helptext);
                    if(mapFieldSpecificFilter.get(filterName).Lookup_Object_Name__c != null)
                    {
                        gen.writeStringField('objectlookupname', mapFieldSpecificFilter.get(filterName).Lookup_Object_Name__c);
                    }
                    gen.writeFieldName('picklistvalues');
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();
                }

                if (string.valueOf(fielddataType) == 'PICKLIST' || string.valueOf(fielddataType) == 'MULTIPICKLIST') {
                    gen.writeStringField('fieldtype', 'picklist');
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isPicklist', true);
                    gen.writeBooleanField('isText', false);
                    gen.writeBooleanField('isMultiSelect', mapFieldSpecificFilter.get(filterName).Is_Multi_Select__c);
                    gen.writeStringField('objectlookupname', '');
                    //gen.writeStringField('helpText', '');
                    List < String > pickListValuesList = new List < String > ();
                    Schema.DescribeFieldResult fieldResult = fieldMap.get(mapFieldSpecificFilter.get(filterName).Field_API_Name__c).getDescribe();
                    List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
                    gen.writeFieldName('picklistvalues');
                    gen.writeStartArray();

                    Integer i = 0;
                    for (Schema.PicklistEntry pickListVal: ple) {
                        gen.writeStartObject();
                        gen.writeNumberField('key', i++);
                        gen.writeStringField('value', String.valueOf(pickListVal.getLabel()));
                        gen.writeEndObject();
                    }

                    gen.writeEndArray();
                }
                if (string.valueOf(fielddataType) != 'BOOLEAN' &&
                    string.valueOf(fielddataType) != 'DATE' &&
                    string.valueOf(fielddataType) != 'REFERENCE' &&
                    string.valueOf(fielddataType) != 'PICKLIST' &&
                    string.valueOf(fielddataType) != 'MULTIPICKLIST') {
                    gen.writeStringField('fieldtype', 'search');
                    gen.writeBooleanField('isPicklist', false);
                    gen.writeBooleanField('isLookup', false);
                    gen.writeBooleanField('isText', true);
                    //gen.writeStringField('helpText', '');
                    gen.writeBooleanField('isMultiSelect', false);
                    gen.writeStringField('objectlookupname', '');
                    gen.writeFieldName('picklistvalues');
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeNumberField('key', 0);
                    gen.writeStringField('value', '');
                    gen.writeEndObject();
                    gen.writeEndArray();
                }
                if(mapFieldSpecificFilter.get(filterName).Serial_Number__c != null && mapFieldSpecificFilter.get(filterName).Serial_Number__c != 0){
                  gen.writeNumberField('SerialNumber', mapFieldSpecificFilter.get(filterName).Serial_Number__c);
                
                }
                else{
                 gen.writeNumberField('SerialNumber', 0);
                }
                system.debug('getAvailbleFieldFilters mapFieldSpecificFilter.get(filterName) : '+mapFieldSpecificFilter.get(filterName).help_Text__c);
                system.debug('getAvailbleFieldFilters allTabMap 2 : '+allTabMap);
                gen.writeStringField('labeltype', mapFieldSpecificFilter.get(filterName).Field_Label__c);
                gen.writeStringField('APIName', mapFieldSpecificFilter.get(filterName).Field_API_Name__c);
                gen.writeStringField('ObjectName', mapFieldSpecificFilter.get(filterName).Object_API_Name__c);
                gen.writeStringField('masterLabel', mapFieldSpecificFilter.get(filterName).MasterLabel);
                String customtabname = allTabMap.get(mapFieldSpecificFilter.get(filterName).Field_Photo_Tab__r.DeveloperName);
                if(customtabname != NULL)
                {
                    gen.writeStringField('ObjectTabName', customtabname);
                    gen.writeStringField(customtabname, customtabname);
                }
                gen.writeStringField('tempofieldval', '');
                
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        String genString = gen.getAsString();
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"{', '{');
        genString = genString.replace('}"', '}');
        return genString;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All tab names for Field Filter Persona
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    NA    
     * @return   List<String>  Account,Campaign,Mission.......
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static List < String > getFieldTabNames() {
        Map < Decimal, String > mapTabs = new Map < Decimal, String > ();
        Map < String, Field_Photo_Tab__mdt > mapFieldPhotoTab = Field_Photo_Tab__mdt.getAll();
        for (String tabName: mapFieldPhotoTab.keySet()) {
            if (mapFieldPhotoTab.get(tabName).Is_Active__c) {
                mapTabs.put(mapFieldPhotoTab.get(tabName).Serial_Number__c, mapFieldPhotoTab.get(tabName).Label);
            }
        }
        List < String > allAvailableTabNames = new List < String > ();
        List < Decimal > sortTemp = new List < Decimal > ();
        sortTemp.addAll(mapTabs.keySet());
        sortTemp.sort();
        for (Decimal a: sortTemp) {
            allAvailableTabNames.add(mapTabs.get(a));
        }
        return allAvailableTabNames;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns list of all saved Filter names for current loggedin user 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    Boolean   mypersona For which persona saved filter names should be returned
     * @return   String    Filter Name1,Filter Name2.....
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @AuraEnabled
    public static String getSavedFilterNames(Boolean mypersona) {
        Id currentUserId = UserInfo.getUserId();
        String personaName = '';
        personaName = mypersona ? 'Field Filter' : 'KAM Filter';
        List < Saved_Photo_Filter__c > savedFilters = [Select Filter_Name__c from Saved_Photo_Filter__c
            where Filter_Name__c != ''
            AND Persona__c =: personaName
            AND User__c =: currentUserId and Is_Active__c = true ORDER BY Filter_Name__c ASC
        ];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        Integer i = 0;
        for (Saved_Photo_Filter__c s: savedFilters) {
            gen.writeStartObject();
            gen.writeNumberField('key', i++);
            gen.writeStringField('value', String.valueOf(s.Filter_Name__c));
            gen.writeEndObject();
        }
        gen.writeEndArray();

        String genString = gen.getAsString();
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"{', '{');
        genString = genString.replace('}"', '}');
        return genString;
    }


     @AuraEnabled
    public static String getSavedFilterNamesRefresh(Boolean mypersona) {
        Id currentUserId = UserInfo.getUserId();
        String personaName = '';
        personaName = mypersona ? 'Field Filter' : 'KAM Filter';
        List < Saved_Photo_Filter__c > savedFilters = [Select Filter_Name__c from Saved_Photo_Filter__c
            where Filter_Name__c != ''
            AND Persona__c =: personaName
            AND User__c =: currentUserId and Is_Active__c = true ORDER BY Filter_Name__c ASC
        ];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        Integer i = 0;
        for (Saved_Photo_Filter__c s: savedFilters) {
            gen.writeStartObject();
            gen.writeNumberField('key', i++);
            gen.writeStringField('value', String.valueOf(s.Filter_Name__c));
            gen.writeEndObject();
        }
        gen.writeEndArray();

        String genString = gen.getAsString();
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"{', '{');
        genString = genString.replace('}"', '}');
        return genString;
    }
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All additional saved Filter Values 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    String, Boolean  filterName : Selected Saved Filter Name , mypersona : Selected Persona Name
     * @return   String  Complete JOSN structure of Selected Saved Filter
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static String getSelectedSavedJsonValuesFilter(String filterName, Boolean mypersona) {

        String aftermodi = '';
        aftermodi = filterName.replaceAll('["]', '');
        Id currentUserId = UserInfo.getUserId();
        String personaName = '';
        personaName = mypersona ? 'Field Filter' : 'KAM Filter';
        List < Saved_Photo_Filter__c > savedFilters = [Select Filter_Values__c from Saved_Photo_Filter__c
            where Filter_Name__c =: aftermodi and Persona__c =: personaName
            and User__c =: currentUserId
            AND Is_Active__c = true
        ];
        return savedFilters[0].Filter_Values__c;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All additional saved Filter Values 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    String, Boolean ; filterName : Selected Saved Filter Name , mypersona : Selected Persona Name
     * @return   String  Complete JOSN structure of Saved Question Ids
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static String getSelectedSavedJsonValuesQuestion(String filterName, Boolean mypersona) {

        String aftermodi = '';
        aftermodi = filterName.replaceAll('["]', '');
        Id currentUserId = UserInfo.getUserId();
        String personaName = '';
        personaName = mypersona ? 'Field Filter' : 'KAM Filter';
        List < Saved_Photo_Filter__c > savedFilters = [Select Question_Ids__c from Saved_Photo_Filter__c
            where Filter_Name__c =: aftermodi
            AND Persona__c =: personaName
            AND User__c =: currentUserId
            AND Is_Active__c = true
        ];
        return savedFilters[0].Question_Ids__c;
    }
    
      /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All additional saved Filter Values 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    String, Boolean  filterName : Selected Saved Filter Name , mypersona : Selected Persona Name
     * @return   String  Complete JOSN structure of Selected Saved Filter
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static String getSelectedSavedJsonValuesFromDate(String filterName, Boolean mypersona) {

        String aftermodi = '';
        aftermodi = filterName.replaceAll('["]', '');
        Id currentUserId = UserInfo.getUserId();
        String personaName = '';
        personaName = mypersona ? 'Field Filter' : 'KAM Filter';
        List < Saved_Photo_Filter__c > savedFilters = [Select From_Submitted_Date__c from Saved_Photo_Filter__c
            where Filter_Name__c =: aftermodi and Persona__c =: personaName
            and User__c =: currentUserId
            AND Is_Active__c = true
        ];
        return savedFilters[0].From_Submitted_Date__c;
    }
    
      /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All additional saved Filter Values 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    String, Boolean  filterName : Selected Saved Filter Name , mypersona : Selected Persona Name
     * @return   String  Complete JOSN structure of Selected Saved Filter
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @AuraEnabled
    public static String fetchPhotosForAppliedFilter(List < Map < String, List < String >>> filtervalues, List < String > questionIdValues, Boolean myPersona, Integer myPage, String formSubmittedDate, String formSubmittedDateTo) 
    {
        Integer offset = 20 * (myPage-1); 

        System.debug('filtervalues value is::::'+filtervalues);
        System.debug('questionIdValues value is::::'+questionIdValues);
        System.debug('myPersona value is::::'+myPersona);
        System.debug('myPage value is::::'+myPage);
        System.debug('formSubmittedDate value is::::'+formSubmittedDate);
        System.debug('formSubmittedDateTo value is::::'+formSubmittedDateTo);
        String personaName = '';
        String formDateSubmitted = '';
        if(formSubmittedDate != null){
            formDateSubmitted = formSubmittedDate;
        }
        Date formDate = null;
        if(formDateSubmitted != ''){
           formDate = Date.valueOf(formDateSubmitted);
        }
        
        String formDateSubmittedTo = '';
        if(formSubmittedDateTo != null){
            formDateSubmittedTo = formSubmittedDateTo;
        }
        Date formDateTo = null;
        if(formDateSubmittedTo != ''){
           formDateTo = Date.valueOf(formDateSubmittedTo);
        }
        
        System.debug('Form Submitted Date is::::'+formDate);
        System.debug('Form Submitted Date To is::::'+formDateTo);
        personaName = myPersona ? 'Field_Persona' : 'KAM_Persona';
        List < String > allUserIds = new List<String>();
        Map < String, Field_Photo_Tab__mdt > mapFilterPhotoTab = Field_Photo_Tab__mdt.getAll();
        Map < String, Field_Photo_Filter__mdt > mapFieldSpecificFilter = Field_Photo_Filter__mdt.getAll();
        Map < String, KAM_Photo_Tabs__mdt > mapKAMPhotoTab = KAM_Photo_Tabs__mdt.getAll();
        Map < String, KAM_Photo_Filter__mdt > mapKAMSpecificFilter = KAM_Photo_Filter__mdt.getAll();
        Map<String, PB_Persona_UserRole__mdt> mapPersonaRoleHierarchy = PB_Persona_UserRole__mdt.getAll();
        system.debug('>>>'+PB_Photo_Source__mdt.getAll().get('Photos_Source').Source__c);  
        String PhotoSource=PB_Photo_Source__mdt.getAll().get('Photos_Source').Source__c;  
        Integer QueryLimit=Integer.valueof(PB_Photo_Source__mdt.getAll().get('Photos_Source').QueryLimit__c);    
  
          if(mapPersonaRoleHierarchy.get(personaName).Is_Role_Hierarchy_Active__c){
            allUserIds = PhotoUserHierarchy.getUsersList();
            allUserIds.add(UserInfo.getUserId());
        }
        Set<Id> setIds = new Set<Id>();
        if(personaName == 'Field_Persona'){

        String sQuery = '';
        String finalQueryParam = '';
        for (String filterName: mapFieldSpecificFilter.keySet()) {
              

            if (mapFieldSpecificFilter.get(filterName).Is_Active__c) {

                if (finalQueryParam == '') {
                    finalQueryParam = mapFieldSpecificFilter.get(filterName).Query_Map__c + ',';
                } else {
                    finalQueryParam = finalQueryParam + mapFieldSpecificFilter.get(filterName).Query_Map__c + ',';
                }
            }
        }
        
        
        
         List < Map < String, List < String >>> filterTempValues = new List < Map < String, List < String >>>();
           for (Integer i = 0; i < filtervalues.size(); i++) {
            Map < String, List < String >> filterMap = filtervalues.get(i);
            String tabName = '';
            String fieldName = '';
            tabName = filterMap.get('objectapiname')[0];
            fieldName = filterMap.get('fieldapiname')[0];
            System.debug(' tabName '+tabName);
            System.debug( ' fieldName '+fieldName);
           
              for(String filterName: mapFieldSpecificFilter.keySet()) {
                // System.debug(' mapFieldSpecificFilter '+mapFieldSpecificFilter.get(filterName).Field_API_Name__c);
                // System.debug(' mapFieldSpecificFilter.get(filterName).Tab_Name__c '+mapFieldSpecificFilter.get(filterName).Tab_Name__c);
                // System.debug(' mapFieldSpecificFilter.get(filterName).Is_Active__c  '+mapFieldSpecificFilter.get(filterName).Is_Active__c );
               if(mapFieldSpecificFilter.get(filterName).Field_API_Name__c == fieldName &&
               mapFieldSpecificFilter.get(filterName).Tab_Name__c == tabName &&
               mapFieldSpecificFilter.get(filterName).Is_Active__c  == true){
               filterTempValues.add(filtervalues[i]);
               }
 
            }
 
 
        }
 
        
        System.debug('size '+filterTempValues.size());
        for (Integer i = 0; i < filterTempValues.size(); i++) {
            Map < String, List < String >> filterMap = filterTempValues.get(i);
            String objectName;
            String fieldName;
            List < String > mySelectedValues = new List<String>();
            String fieldType;
            String maila = '';
            String finalvalues = '';

            objectName = filterMap.get('objectapiname')[0];
            fieldName = filterMap.get('fieldapiname')[0];
            fieldType = filterMap.get('fieldType')[0];
            // mySelectedValues = filterMap.get('selectedvalues');
            System.debug('objectapiname: '+objectName);
            System.debug('fieldName '+fieldName);
            System.debug('fieldType '+fieldType);
            if(fieldName == 'Id' || fieldName == 'Ultimate_Parent_Account__c' || fieldName == 'ShippingState' || fieldName == 'ShippingCity' || fieldName == 'Account_Segment__c' || fieldName =='OwnerId' || fieldName == 'Type' || fieldName == 'Name' || fieldName == 'Ultimate_Parent_Account_Owner__c'){
                for(String msv : filterMap.get('selectedvalues')){
                    // System.debug('  msv '+msv);
                    if (msv.contains(',')&& msv != null && msv != ''){
                        List<String> values = msv.split(',');
                        mySelectedValues.addAll(values);
                    }else if(msv != null && msv != ''){
                        mySelectedValues.add(msv);
                    }
                   
                    System.debug('msv '+msv);
                }
                System.debug('mySelectedValues111 '+mySelectedValues);
            }
            if (filterMap.get('objectapiname')[0] == 'Campaign') {
                objectName = 'Account';
               
                
                List<String> accountIds = new List<String>();
                String selectedValue = filterMap.get('selectedvalues')[0];
                
                if (selectedValue != null) {
                    String query = 'SELECT Account__c FROM Account_Campaign_Members__c WHERE Promotion__c = :selectedValue';
                    // List<String> filters = new List<String>();
                    // for (String rtp : filterMap.get('selectedvalues')) {
                    //     System.debug('fffff '+rtp);
                    //     if (fieldName == 'Tier__c') {
                    //         filters.add('Tier__c = :rtp');
                    //     } else if (fieldName == 'Status__c') {
                    //         filters.add('Status__c = :rtp');
                    //     }
                    // }
                    // if (!filters.isEmpty()) {
                    //     query += ' AND ' + String.join(filters, ' AND ');
                    // }
                    // System.debug('Final query: ' + query);
                        // if (!String.isEmpty(tier)) {
                        //     query += ' AND Tier__c = :tier';
                        // }
                        // if (!String.isEmpty(id)) {
                        //     query += ' AND Id = :id';
                        // }
                        // if (!String.isEmpty(status)) {
                        //     query += ' AND Status__c = :status';
                        // }
                    List<Account_Campaign_Members__c> accountMembers = Database.Query(query);
                    
                    for (Account_Campaign_Members__c member : accountMembers) {
                        
                        accountIds.add(member.Account__c);
                    }
                    mySelectedValues = accountIds;
                    
                    System.debug('Form Submitted Date To is::::' + accountIds);
                }
                fieldName = 'Id';

            }
            if(filterMap.get('objectapiname')[0] == 'Account' && fieldName == 'Id' && setIds != NULL){
                setIds = new Set<Id>();
            }
            if (filterMap.get('objectapiname')[0] == 'Retail Theater') {
                objectName = 'Retail_Theater';
                // fieldName = 'Id';
                List<String> rtpValues = new List<String>();
                if(filterMap.get('selectedvalues').size()>0){
                    for (String rtp : filterMap.get('selectedvalues')) {
                        if (rtp.contains(',')&& rtp != null && rtp != ''){
                            List<String> values = rtp.split(',');
                            rtpValues.addAll(values);
                        } else if(rtp != null && rtp != ''){
                            rtpValues.add(rtp);
                        }
                    }
                }
                // String selectedValue = filterMap.get('selectedvalues')[0];
                
                // if (selectedValue != null) {
                //     List<Account_Campaign_Members__c> accountMembers = [SELECT Account__c FROM Account_Campaign_Members__c WHERE Promotion__c = :selectedValue];
                    
                //     for (Account_Campaign_Members__c member : accountMembers) {
                        
                //         accountIds.add(member.Account__c);
                //     }
                    mySelectedValues = rtpValues;
                    
                //     System.debug('Form Submitted Date To is::::' + accountIds);
                // }
                System.debug('Form Retail Theater ::::' + rtpValues);
            }


            
            String currentFieldType = '';
            String currentFieldDateType = '';
            Boolean selectiveSearch = false;
            
            List<String> accIdList = new List<String>();
            for (String filterName: mapFieldSpecificFilter.keySet()) {


                if (mapFieldSpecificFilter.get(filterName).Field_Data_Type__c == 'Picklist (Multi-Select)' &&
                    mapFieldSpecificFilter.get(filterName).Field_API_Name__c == fieldName) {
                    currentFieldType = mapFieldSpecificFilter.get(filterName).Field_Data_Type__c;
                }
                if (mapFieldSpecificFilter.get(filterName).Field_Data_Type__c == 'Date' &&
                    mapFieldSpecificFilter.get(filterName).Field_API_Name__c == fieldName) {
                    currentFieldDateType = mapFieldSpecificFilter.get(filterName).Field_Data_Type__c;
                }
                
                if(mapFieldSpecificFilter.get(filterName).Field_API_Name__c == fieldName && mySelectedValues.size() >0){
                    selectiveSearch = mapFieldSpecificFilter.get(filterName).Selective_Search__c; 
                    // System.debug('fieldType '+fieldType);
                    // System.debug('filterName out '+filterName);
                    // System.debug('mapFieldSpecificFilter.get(filterName).Selective_Search__c '+mapFieldSpecificFilter.get(filterName).Selective_Search__c);
                }
                
            }
            System.debug('Selective search values are::::'+selectiveSearch+' mySelectedValues.size() '+mySelectedValues.size()+ ' mySelectedValues '+mySelectedValues);

            if (fieldName != null && fieldName != '' && mySelectedValues != null && mySelectedValues.size() > 0 && mySelectedValues[0] != '') {

                System.debug(' mySelectedValues '+mySelectedValues);
                if (currentFieldType == 'Picklist (Multi-Select)') {
                    System.debug('entered into this multi picklist condition');
                    maila = '(\'' + String.join(mySelectedValues, '\',\'') + '\')';

                }

                Date currentDate;
                if (currentFieldDateType == 'Date') {
                    currentDate = Date.valueOf(mySelectedValues[0]);

                }

                if (currentFieldType == '' && currentFieldDateType == ''&& fieldName != 'Id' && (mySelectedValues.size() > 1 || fieldType == 'multiple' || fieldType == 'lookup')) {
                    for (String soso: mySelectedValues) {
                        if (maila == '') {
                            maila += '(' + '\'' + soso + '\'';

                        } else {

                            maila += ',' + '\'' + soso + '\'';

                        }
                        System.debug('maila'+soso);
                    }
                    maila += ')';
                    
                } else if (!selectiveSearch && currentFieldType == '' && currentFieldDateType == '' && (mySelectedValues.size() >= 1 && fieldType != 'multiple' && fieldType != 'lookup')|| fieldName == 'Id') {

                    for (String soso: mySelectedValues) {
                        // System.debug(' soso '+soso);
                        if (maila == '') {
                            if(fieldName == 'Id'){
                                setIds.add(soso); 
                            }else{
                                maila += '\'%' + soso + '%\'';
                            }
                            
                        }
                    }
                    System.debug('setIds '+setIds);
                }
                 else if (selectiveSearch && currentFieldType == '' && currentFieldDateType == '' && (mySelectedValues.size() == 1 && fieldType != 'multiple' && fieldType != 'lookup')) {

                    for (String soso: mySelectedValues) {
                        if (maila == '') {
                            maila += soso ;
                        }
                    }
                }
               System.debug('Selective search value is:::'+selectiveSearch);
               System.debug('fieldTypeis:::'+fieldType);
               System.debug('currentFieldDateType is:::'+currentFieldDateType);
               System.debug('fieldName is:::'+fieldName);
               System.debug('currentFieldType is:::'+currentFieldType);
               System.debug(' PhotoSource '+PhotoSource);
               System.debug(' objectName :: '+objectName);
               System.debug(' maila :: '+maila);
                System.debug(' mapFilterPhotoTab.get(objectName) '+mapFilterPhotoTab.get(objectName));
                // if(mapFilterPhotoTab.get(objectName) != null){
                    String soqlMapping = PhotoSource=='Visit'?mapFilterPhotoTab.get(objectName).Visit_Query_Mapping__c:mapFilterPhotoTab.get(objectName).Query_Mapping__c;
                // }
                
                System.debug(' soqlMapping :: '+soqlMapping);
                if ((fieldType == 'single' || fieldType == 'lookup')&& fieldName != 'Ultimate_Parent_Account_Owner__c' && fieldName != 'OwnerId' && fieldName != 'Ultimate_Parent_Account__c' && currentFieldDateType == '' && !selectiveSearch) {
                    if(fieldName == 'Id'){
                        System.debug(' setIds '+setIds);
                        sQuery += ' AND ' + soqlMapping + fieldName + ' IN :  setIds';
                    }else{
                        sQuery += ' AND ' + soqlMapping + fieldName + ' LIKE  '  + maila;
                    }
                    
                }
                 else if (fieldType == 'single' && currentFieldDateType == '' && selectiveSearch) {
                   
                    sQuery += ' AND ' + soqlMapping + fieldName + ' = ' +'\''+ maila + '\'';
                     System.debug('Entered into selective Serach'+sQuery);
                }else if (currentFieldType == '' && currentFieldDateType == '' && (fieldType == 'multiple' || fieldType == 'lookup')) {
                    
                    sQuery += ' AND ' + soqlMapping + fieldName + ' IN ' + maila;
                    System.debug('soqlMapping'+sQuery);
                } else if (currentFieldType == 'Picklist (Multi-Select)' && fieldType == 'multiple') {
                    sQuery += ' AND ' + soqlMapping + fieldName + ' INCLUDES ' + maila;
                } else if (currentFieldDateType == 'Date') {

                    sQuery += ' AND ' + soqlMapping + fieldName + ' = ' + ':currentDate'; // 'WHERE Id = \'' + someId + '\''
                }
            }

            sQuery = sQuery.remove('null');
            System.debug('my custom SOQL string is' + sQuery +' maila '+ setIds);

        }

        List < DocInfo > allDocInfos = new List < DocInfo > ();
        String onlyPhotos = 'Attachment/Photo';
        Date convertedStartDate = null;
        Date convertedEndDate = null;
        /*List < Map < String, String >> tempValo = new List < Map < String, String >> ();
        Map < String, String > tempValoMap = new Map < String, String > ();
        tempValoMap.put('Ultimate Parent Owner','Rajesh Owner');
        tempValoMap.put('Parent Account','Rajesh Parent');
        tempValoMap.put('Name','Rajesh Name');
        tempValoMap.put('Account Owner','Rajesh Owner');
        tempValo.add(tempValoMap);
        */
        try {
           // Date todayDate=system.today();
            Datetime todayDate=System.now();
            String QueryString='';
            String Conditions='';
            set<Id> ContentDocIdset=new set<Id>();
            Map<String,Retail_Theater__c> rtMap=new Map<String,Retail_Theater__c>();
            Map<String,Visit> vtMap=new Map<String,Visit>();
            Integer countPhotos = 0;
           if(PhotoSource=='Visit'){
                QueryString+='Select  Id,cgcloud__Completed_Date__c,Account.Ultimate_Parent_Account_Owner__r.name,Account.Ultimate_Parent_Account__r.name,Account.Name,Account.Owner.Name,(select id,ContentDocumentId,linkedentityId from contentdocumentlinks)  from VISIT WHERE CreatedDate<=:todayDate ';
                if(formDate!=null && formDateTo!=null)
                Conditions+=' AND cgcloud__Completed_Date__c>=: formDate and cgcloud__Completed_Date__c=<: formDateTo';
                if(sQuery!=null && sQuery!='')
                Conditions+=sQuery;
                if(!String.isBlank(Conditions)){
                    QueryString=QueryString+Conditions;
                }
                system.debug('QueryString>>>'+QueryString);
                List<Visit> rtList = database.query(QueryString+' ORDER BY CREATEDDATE DESC DESC LIMIT 20 OFFSET '+offset);
                for(Visit rt:rtList){
                for(ContentDocumentLink cdl:rt.contentdocumentlinks){
                    ContentDocIdset.add(cdl.ContentDocumentId);
                    vtMap.put(cdl.ContentDocumentId,rt);
                }
                }
                system.debug('rtList>>>'+rtList);
            }else{
                QueryString+='Select  Id,Audit_Date__c,Account__r.Ultimate_Parent_Account_Owner__r.name,Account__r.Ultimate_Parent_Account__r.name,Account__r.Name,Account__r.Owner.Name,Account__r.ShippingState,Account__r.ShippingCity,Account__r.Account_Segment__c,Account__r.Type,Virginia_Tobacco_3_2_8ml_4_pack__c,Menthol_3_2_8ml_4_pack__c,Device_Kit_Slate__c,Device_Kit_Silver__c,Menthol_5_1_4ml_2_pack__c,Menthol_5_2_8ml_4_pack__c,USB_Charger__c,Virginia_Tobacco_3_1_4ml_2_pack__c,Virginia_Tobacco_5_1_4ml_2_pack__c,Virginia_Tobacco_5_2_8ml_4_pack__c,(select id,ContentDocumentId,linkedentityId from contentdocumentlinks)  from Retail_Theater__c WHERE CreatedDate<=:todayDate ';
                if(formDate!=null && formDateTo!=null)
                Conditions+=' AND Audit_Date__c>=: formDate and Audit_Date__c<=: formDateTo';
                
                if(sQuery!=null && sQuery!='')
                Conditions+=sQuery;
                if(!String.isBlank(Conditions)){
                    QueryString=QueryString+Conditions;
                }
                system.debug('QueryString>>>'+QueryString);
                
                // system.debug('maila>>>'+maila);
                // if(sQuery == 'AND Account__r.Id IN '){
                   
                //     rtList = database.query(QueryString+' LIMIT :QueryLimit');
                //     System.debug('sQuery '+rtList);
                // }else{
                //     List<Retail_Theater__c> rtList = database.query(QueryString+' ORDER BY CREATEDDATE DESC  LIMIT :QueryLimit');
                // }
                // rtList = database.query(QueryString+' LIMIT :QueryLimit');
                List<Retail_Theater__c> rtList = database.query(QueryString+' ORDER BY CREATEDDATE DESC  LIMIT :QueryLimit');
                for(Retail_Theater__c rt:rtList){
                    for(ContentDocumentLink cdl:rt.contentdocumentlinks){
                        ContentDocIdset.add(cdl.ContentDocumentId);
                        rtMap.put(cdl.ContentDocumentId,rt);
                    }
                }   
                system.debug('rtList>>>'+rtList);
           }
           countPhotos=database.countQuery('select count() from ContentVersion WHERE ContentDocumentId in:ContentDocIdset');
           system.debug('countPhotos>>>'+countPhotos);
           list<ContentVersion> cntList=database.query('SELECT Id,FileExtension,ContentDocumentId,createdDate,ContentSize,ExternalDataSourceId,Title FROM ContentVersion WHERE ContentDocumentId in:ContentDocIdset ORDER BY CREATEDDATE DESC LIMIT 20 OFFSET '+offset);
            System.debug('cntList'+cntList);
            for(ContentVersion cv:cntList){
                DocInfo di=new DocInfo();
                di.versionID=cv.id;
                di.createdDate = cv.createdDate.format();
                di.imageType=cv.FileExtension;
                di.docTitle=cv.Title;
                di.allFieldValues=PhotoSource=='Visit'?mapVisit(vtMap.get(cv.ContentDocumentId)):mapRetailtheater(rtMap.get(cv.ContentDocumentId));
                di.formId=PhotoSource=='Visit'?vtMap.get(cv.ContentDocumentId).id:rtMap.get(cv.ContentDocumentId).id;
                di.allFieldValues2=di.allFieldValues;
                di.docSize=String.valueof(cv.ContentSize);
                di.externalFileID=cv.ExternalDataSourceId;
                di.total=countPhotos;

                di.auditDate=PhotoSource=='Visit'?vtMap.get(cv.ContentDocumentId).cgcloud__Completed_Date__c.format():rtMap.get(cv.ContentDocumentId).Audit_Date__c.format();

                allDocInfos.add(di);
            }
            system.debug('allDocInfos>>>'+allDocInfos);
            // convertedStartDate = Date.valueOf(selectedStartDate);
        } catch (exception e) {
            System.debug('convertedStartDate: ' + e);
        }
             system.debug('allDocInfos>>>'+JSON.serialize(allDocInfos));
             return JSON.serialize(allDocInfos);
        }else{
            System.debug('Entered into KAM Persona');
        String sQuery = '';
        String finalQueryParam = '';
        for (String filterName: mapKAMSpecificFilter.keySet()) {
              

            if (mapKAMSpecificFilter.get(filterName).Is_Active__c) {

                if (finalQueryParam == '') {
                    finalQueryParam = mapKAMSpecificFilter.get(filterName).Query_Map__c + ',';
                } else {
                    finalQueryParam = finalQueryParam + mapKAMSpecificFilter.get(filterName).Query_Map__c + ',';
                }
            }
        }
        
        
        
        List < Map < String, List < String >>> filterTempValues = new List < Map < String, List < String >>>();

 for (Integer i = 0; i < filtervalues.size(); i++) {
            Map < String, List < String >> filterMap = filtervalues.get(i);
            String tabName = '';
            String fieldName = '';
            tabName = filterMap.get('objectapiname')[0];
            fieldName = filterMap.get('fieldapiname')[0];
 
 for(String filterName: mapKAMSpecificFilter.keySet()) {
      System.debug('tabName '+mapKAMSpecificFilter.get(filterName).Tab_Name__c+'tabName '+tabName);
     System.debug('Is_Active__c '+mapKAMSpecificFilter.get(filterName).Is_Active__c);
     System.debug('Field_API_Name__c '+mapKAMSpecificFilter.get(filterName).Field_API_Name__c+'fieldName'+fieldName);
   if(mapKAMSpecificFilter.get(filterName).Field_API_Name__c == fieldName &&
      mapKAMSpecificFilter.get(filterName).Tab_Name__c == tabName &&
      mapKAMSpecificFilter.get(filterName).Is_Active__c  == true){
      
      filterTempValues.add(filtervalues[i]);
             
     }
 
 }
 
 
 }
 
        
        
        for (Integer i = 0; i < filterTempValues.size(); i++) {
            Map < String, List < String >> filterMap = filterTempValues.get(i);
            String objectName;
            String fieldName;
            List < String > mySelectedValues;
            String fieldType;
            String maila = '';
            String finalvalues = '';

            objectName = filterMap.get('objectapiname')[0];
            fieldName = filterMap.get('fieldapiname')[0];
            fieldType = filterMap.get('fieldType')[0];
            mySelectedValues = filterMap.get('selectedvalues');
            
            
            String currentFieldType = '';
            String currentFieldDateType = '';
            Boolean selectiveSearch = false;


            for (String filterName: mapKAMSpecificFilter.keySet()) {


                if (mapKAMSpecificFilter.get(filterName).Field_Data_Type__c == 'Picklist (Multi-Select)' &&
                    mapKAMSpecificFilter.get(filterName).Field_API_Name__c == fieldName) {
                    currentFieldType = mapKAMSpecificFilter.get(filterName).Field_Data_Type__c;
                }
                if (mapKAMSpecificFilter.get(filterName).Field_Data_Type__c == 'Date' &&
                    mapKAMSpecificFilter.get(filterName).Field_API_Name__c == fieldName) {
                    currentFieldDateType = mapKAMSpecificFilter.get(filterName).Field_Data_Type__c;
                }
                
                if(mapKAMSpecificFilter.get(filterName).Field_API_Name__c == fieldName){
                    selectiveSearch = mapKAMSpecificFilter.get(filterName).Selective_Search__c; 
                }
            }
            System.debug('Selective search values are::::'+selectiveSearch);

            if (fieldName != null && fieldName != '' && mySelectedValues != null && mySelectedValues.size() > 0 && mySelectedValues[0] != '') {


                if (currentFieldType == 'Picklist (Multi-Select)') {
                    System.debug('entered into this multi picklist condition');
                    maila = '(\'' + String.join(mySelectedValues, '\',\'') + '\')';

                }

                Date currentDate;
                if (currentFieldDateType == 'Date') {
                    currentDate = Date.valueOf(mySelectedValues[0]);

                }

                if (currentFieldType == '' && currentFieldDateType == '' && (mySelectedValues.size() > 1 || fieldType == 'multiple' || fieldType == 'lookup')) {
                    for (String soso: mySelectedValues) {
                        if (maila == '') {
                            maila += '(' + '\'' + soso + '\'';

                        } else {

                            maila += ',' + '\'' + soso + '\'';

                        }
                    }
                    maila += ')';
                } else if (!selectiveSearch && currentFieldType == '' && currentFieldDateType == '' && (mySelectedValues.size() == 1 && fieldType != 'multiple' && fieldType != 'lookup')) {

                    for (String soso: mySelectedValues) {
                        if (maila == '') {
                            maila += '\'%' + soso + '%\'';
                        }
                    }
                }
                 else if (selectiveSearch && currentFieldType == '' && currentFieldDateType == '' && (mySelectedValues.size() == 1 && fieldType != 'multiple' && fieldType != 'lookup')) {

                    for (String soso: mySelectedValues) {
                        if (maila == '') {
                            maila += soso ;
                        }
                    }
                }
               System.debug('Selective search value is:::'+selectiveSearch);

                String soqlMapping = mapKAMPhotoTab.get(objectName).Query_Mapping__c;

                if (fieldType == 'single' && currentFieldDateType == '' && !selectiveSearch) {
                    sQuery += ' AND ' + soqlMapping + fieldName + ' LIKE  '  + maila;
                }
                 else if (fieldType == 'single' && currentFieldDateType == '' && selectiveSearch) {
                   
                    sQuery += ' AND ' + soqlMapping + fieldName + ' = '  +  ':maila';
                     System.debug('Entered into selective Serach'+sQuery);
                }else if (currentFieldType == '' && currentFieldDateType == '' && (fieldType == 'multiple' || fieldType == 'lookup')) {
                    sQuery += ' AND ' + soqlMapping + fieldName + ' IN ' + maila;
                } else if (currentFieldType == 'Picklist (Multi-Select)' && fieldType == 'multiple') {
                    sQuery += ' AND ' + soqlMapping + fieldName + ' INCLUDES ' + maila;
                } else if (currentFieldDateType == 'Date') {

                    sQuery += ' AND ' + soqlMapping + fieldName + ' = ' + ':currentDate'; // 'WHERE Id = \'' + someId + '\''
                }
            }

            System.debug('my custom SOQL string is' + sQuery +' maila '+maila);

        }

        List < DocInfo > allDocInfos = new List < DocInfo > ();
        String onlyPhotos = 'Attachment/Photo';
        Date convertedStartDate = null;
        Date convertedEndDate = null;
        try {
            // convertedStartDate = Date.valueOf(selectedStartDate);
        } catch (exception e) {
            System.debug('convertedStartDate: ' + e);
        }
        try {
            // convertedEndDate = Date.valueOf(selectedEndDate);
        } catch (exception e) {
            System.debug('convertedEndDate: ' + e);
        }
            
        }
       setIds = new Set<Id>();
        return '';
    }
    public static List < Map < String, String >>  mapRetailtheater(Retail_Theater__c rt){
        List < Map < String, String >> tempValo = new List < Map < String, String >> ();
        Map < String, String > tempValoMap = new Map < String, String > ();
        tempValoMap.put('Audit Date',rt.Audit_Date__c.format());
        tempValoMap.put('Menthol 3% 2.8ml 4pk',rt.Menthol_3_2_8ml_4_pack__c);
        tempValoMap.put('Virginia Tobacco 3% 1.4ml 2-pack',rt.Virginia_Tobacco_3_1_4ml_2_pack__c);
        tempValoMap.put('Virginia Tobacco 3% 2.8ml 4pk',rt.Virginia_Tobacco_3_2_8ml_4_pack__c);
        tempValoMap.put('Virginia Tobacco 5% 1.4ml 2-pack',rt.Virginia_Tobacco_5_1_4ml_2_pack__c);
        tempValoMap.put('Virginia Tobacco 5% 2.8ml 4-pack',rt.Virginia_Tobacco_5_2_8ml_4_pack__c);
        tempValoMap.put('Menthol 3% 2.8ml 4pk',rt.Menthol_3_2_8ml_4_pack__c);
        tempValoMap.put('Menthol 5% 1.4ml 2-pack',rt.Menthol_5_1_4ml_2_pack__c);
        tempValoMap.put('Menthol 5% 2.8ml 4-pack',rt.Menthol_5_2_8ml_4_pack__c);
        tempValoMap.put('USB Charger',rt.USB_Charger__c);
        tempValoMap.put('Device Kit Silver',rt.Device_Kit_Silver__c);
        tempValoMap.put('Device Kit Slate',rt.Device_Kit_Slate__c);
        tempValoMap.put('City',rt.Account__r.ShippingCity);
        tempValoMap.put('State',rt.Account__r.ShippingState);
        tempValoMap.put('Account Segment',rt.Account__r.Account_Segment__c);
        tempValoMap.put('Type',rt.Account__r.Type);
        tempValoMap.put('Account Owner',rt.Account__r.Owner.Name);
        tempValoMap.put('Ultimate Parent Owner',rt.Account__r.Ultimate_Parent_Account_Owner__r.name);
        tempValoMap.put('Parent Account',rt.Account__r.Ultimate_Parent_Account__r.name);
        tempValoMap.put('Name',rt.Account__r.Name);
        tempValo.add(tempValoMap);
        return tempValo;
    }
    public static List < Map < String, String >>  mapVisit(Visit vt){
        List < Map < String, String >> tempValo = new List < Map < String, String >> ();
        Map < String, String > tempValoMap = new Map < String, String > ();
        tempValoMap.put('Audit Date',vt.cgcloud__Completed_Date__c.format());
        //tempValoMap.put('Name22',vt.Account.Name);
        tempValoMap.put('Ultimate Parent Owner',vt.Account.Ultimate_Parent_Account_Owner__r.name);
        tempValoMap.put('Parent Account',vt.Account.Ultimate_Parent_Account__r.name);
        tempValoMap.put('Name',vt.Account.Name);
        tempValoMap.put('Account Owner',vt.Account.Owner.Name);
        
        tempValo.add(tempValoMap);
        return tempValo;
    }
 
    @AuraEnabled(cacheable = true)
    public static String getSelectedSavedJsonValuesToDate(String filterName, Boolean mypersona) {

        String aftermodi = '';
        aftermodi = filterName.replaceAll('["]', '');
        Id currentUserId = UserInfo.getUserId();
        String personaName = '';
        personaName = mypersona ? 'Field Filter' : 'KAM Filter';
        List < Saved_Photo_Filter__c > savedFilters = [Select To_Submitted_Date__c from Saved_Photo_Filter__c
            where Filter_Name__c =: aftermodi and Persona__c =: personaName
            and User__c =: currentUserId
            AND Is_Active__c = true
        ];
        return savedFilters[0].To_Submitted_Date__c;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns All Images for applied/default filter/question ids values
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    List<Map<String,List<String>>>, List<String> ; filtervalues : FilterJSON structure , questionIdValues : Applied Question Ids
     * @return   String  Complete JOSN structure of Images with all values
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */


    private static List < DocInfo > populateFileDataAndFilterDates(List < DocInfo > allDocInfos) {
        Set < Id > allFileIDs = new Set < Id > ();
        List < DocInfo > filteredDocInfos = new List < DocInfo > ();

        for (DocInfo thisDocInfo: allDocInfos) {
            allFileIDs.add(thisDocInfo.versionID);
        }
        
        System.debug('Here is the list of doc Ids:::'+allFileIDs);

        List < ContentVersion > filteredVersions = (List < ContentVersion > ) Database.query('SELECT Id,disco__Image_Type__c,CreatedDate FROM ContentVersion ' +
            'WHERE Id IN:allFileIDs');

        for (ContentVersion thisCV: filteredVersions) {
            for (DocInfo thisDocInfo: allDocInfos) {
                if (thisDocInfo.versionID == thisCV.id) {
                    //thisDocInfo.imageType = thisCV.disco__image_type__c != null ? thisCV.disco__image_type__c : '';
                    thisDocInfo.createdDate = thisCV.createdDate.format();
                    filteredDocInfos.add(thisDocInfo);
                    break;
                }
            }
        }
        System.debug('filteredDocInfos : ' + filteredDocInfos);
        return filteredDocInfos;
    }

    public class DocInfo implements Comparable {

        public List < Map < String, String >> allFieldValues;
        public List < Map < String, String >> allFieldValues2;
        public String versionID;
        public String docTitle;
        public String docSize;
        public String externalFileID;
        public String error;
        public String accountName;
        public String imageType;
        public String createdDate;
        public String auditDate;
        public String formId;
        public Integer total;

        Boolean equals(Object o) {
            if (this === o)
                return true; // i am equal to me
            if (!(o instanceof DocInfo))
                return false; // other classes are not equal to me
            return ((DocInfo) o).versionID == this.versionID;
        }

        public Integer hashCode() {
            return versionID.hashCode();
        }

        public Integer compareTo(Object o) {
            if (!(o instanceof DocInfo))
                return -1;
            return versionID.compareTo(((DocInfo) o).versionID);
        }

    }

    public class FormUser {
        public String Id;
        public String Name;
    }






    @AuraEnabled
    public static string isFilterAlreadyAvailable(String filterName, String personaName) {
        
        String pName = personaName;
        String filName = filterName;
        Id cUser = UserInfo.getUserId();
        List<Saved_Photo_Filter__c> spfTemp = new List<Saved_Photo_Filter__c>();
        
        spfTemp = [Select Filter_Name__c,Filter_Values__c ,Question_Ids__c   from Saved_Photo_Filter__c where Filter_Name__c =:filName AND Persona__c =:pName AND User__c =:cUser AND Is_Active__c = true LIMIT 1];
        
        if(spfTemp.size() > 0){
           return 'Available';
          
        }
        else
        {
          return 'Not Available';
        
        }
     
    }



    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns Success message after save oepration 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    String, String, String, String ; 
     * @return   String  Complete JOSN structure of Images with all values
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */


    @AuraEnabled
    public static string saveNewFilter(String filterName, String personaName, String questionIds,
        String allselectfilterValues, String selectedEditFilter, String fromSubmittedDate, String toSubmittedDate) {
        
        String pName = personaName;
        String filName = filterName;
        Id cUser = UserInfo.getUserId();
        
        List<Saved_Photo_Filter__c> spfTemp = new List<Saved_Photo_Filter__c>();
        Boolean sameSavedFIlter = false;
        if(filterName != selectedEditFilter){
            sameSavedFIlter = true;
        }
        if(selectedEditFilter != '' && !sameSavedFIlter){
        
         spfTemp = [Select Filter_Name__c,Filter_Values__c ,Question_Ids__c   from Saved_Photo_Filter__c where Filter_Name__c =:filName AND Persona__c =:pName AND User__c =:cUser AND Is_Active__c = true LIMIT 1];
        
         if(spfTemp.size() > 0){
          spfTemp[0].Filter_Values__c = allselectfilterValues;
          spfTemp[0].Question_Ids__c = questionIds;
          spfTemp[0].From_Submitted_Date__c = fromSubmittedDate;
          spfTemp[0].To_Submitted_Date__c = toSubmittedDate;
          update spfTemp[0];
         }
         
        }
        
        
        else if(selectedEditFilter == '' || sameSavedFIlter ){

        String dop = filterName;
        List < Saved_Photo_Filter__c > spfoList = new List < Saved_Photo_Filter__c > ();
        Saved_Photo_Filter__c spf = new Saved_Photo_Filter__c();
        spf.Filter_Name__c = dop;
        spf.User__c = UserInfo.getUserId();
        spf.Persona__c = personaName;
        spf.Is_Active__c = true;
        spf.Filter_Values__c = allselectfilterValues;
        spf.Question_Ids__c = questionIds;
        spf.From_Submitted_Date__c = fromSubmittedDate;
        spf.To_Submitted_Date__c = toSubmittedDate;
        spfoList.add(spf);
        Database.SaveResult[] srList = Database.insert(spfoList, false);

        for (Database.SaveResult sr: srList) {
           if (!sr.isSuccess()) {
                for (Database.Error err: sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
      }

        String s = 'success';
        return s;
   }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns Success message after save oepration 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    NA
     * @return   List<disco__Form_Template__c>  
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */


 /*   private static List < cgcloud__Job_Template__c > buildAvailableFormTemplates() {

        Set < cgcloud__Job_Template__c   > availableFormTemplates = new Set < cgcloud__Job_Template__c   > ();

        for (disco__Question__c question: [SELECT disco__Form_Template__c, disco__Form_Template__r.Name, disco__Form_Template__r.Assessment__c
                FROM disco__Question__c
                WHERE disco__Type__c = 'Attachment/Photo'
                AND(disco__Form_Template__r.disco__Status__c = 'In Use'
                    OR disco__Form_Template__r.disco__Status__c = 'Inactive')
                ORDER BY disco__Form_Template__r.Name
            ]) {

            disco__Form_Template__c formTemplate = new disco__Form_Template__c(Id = question.disco__Form_Template__c);

            formTemplate.Name = question.disco__Form_Template__r.Name;
            formTemplate.Assessment__c = question.disco__Form_Template__r.Assessment__c;

            availableFormTemplates.add(formTemplate);

        }
        

        return new List < cgcloud__Job_Template__c > (availableFormTemplates);

    }*/


    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns Success message after save oepration 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    NA
     * @return   String 
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled(cacheable = true)
    public static String getFormValues() {
/*        Set < cgcloud__Job_Template__c > availableFormTemplates = new Set < cgcloud__Job_Template__c > ();

        for (disco__Question__c question: [SELECT disco__Form_Template__c, disco__Form_Template__r.Name, disco__Form_Template__r.Assessment__c
                FROM disco__Question__c
                WHERE disco__Type__c = 'Attachment/Photo'
                AND(disco__Form_Template__r.disco__Status__c = 'In Use'
                    OR disco__Form_Template__r.disco__Status__c = 'Inactive')
                ORDER BY disco__Form_Template__r.Name
            ]) {

            disco__Form_Template__c formTemplate = new disco__Form_Template__c(Id = question.disco__Form_Template__c);

            formTemplate.Name = question.disco__Form_Template__r.Name;
            formTemplate.Assessment__c = question.disco__Form_Template__r.Assessment__c;

            availableFormTemplates.add(formTemplate);

        }
*/
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartArray();
        Integer i = 0;
       /* for (disco__Form_Template__c s: availableFormTemplates) {
            gen.writeStartObject();
            gen.writeNumberField('key', i++);
            gen.writeStringField('value', String.valueOf(s.Name));
            gen.writeStringField('Id', String.valueOf(s.Id));
            if (s.Assessment__c != null) {
                gen.writeStringField('Assessment', String.valueOf(s.Assessment__c));
            } else {
                gen.writeStringField('Assessment', '');
            }
            gen.writeEndObject();
        }
*/


        gen.writeEndArray();

        String genString = gen.getAsString();
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"{', '{');
        genString = genString.replace('}"', '}');
        return genString;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns Success message after save oepration 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    List<String> ; Ids List of all selected forms
     * @return   String  Returns all Questions for applied Forms
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @AuraEnabled(cacheable = true)
    public static String getQuestionValues(List < String > Ids) {

        Set < Id > templateIds = new Set < Id > ();
        for (String ssso: Ids) {
            templateIds.add(ssso);
        }
/*
        Map < Id, List < disco__Question__c >> templateIdPhotoQuestions = new Map < Id, List < disco__Question__c >> ();
        for (disco__Question__c question: [SELECT Id, disco__Label__c, disco__Form_Template__c FROM disco__Question__c WHERE disco__Type__c = 'Attachment/Photo'
                AND disco__Form_Template__c IN: templateIds
            ]) {
            Id templateId = question.disco__Form_Template__c;

            if (templateIdPhotoQuestions.containsKey(templateID)) {
                templateIdPhotoQuestions.get(templateID).add(question);
            } else {
                templateIdPhotoQuestions.put(templateId, new List < disco__Question__c > {
                    question
                });
            }
        }
        */

        // return templateIdPhotoQuestions;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartArray();
        Integer i = 0;

        /*for (Id key: templateIdPhotoQuestions.keySet()) {
            List < disco__Question__c > lsto = templateIdPhotoQuestions.get(key);
            for (disco__Question__c ldqc: lsto) {
                gen.writeStartObject();
                gen.writeNumberField('key', i++);
                gen.writeStringField('Id', String.valueOf(ldqc.Id));
                if (ldqc.disco__Label__c != null && ldqc.disco__Label__c != '') {
                    gen.writeStringField('value', String.valueOf(ldqc.disco__Label__c));
                } else {
                    gen.writeStringField('value', '');
                }
                gen.writeEndObject();
            }
          

        }  */

        gen.writeEndArray();

        String genString = gen.getAsString();
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"{', '{');
        genString = genString.replace('}"', '}');
        return genString;
    }


/*
    private static Map < Id, List < disco__Question__c >> buildTemplateIdPhotoQuestions(List < disco__Form_Template__c > availableFormTemplates) {

        Set < Id > templateIds = new Set < Id > ();

        Map < Id, List < disco__Question__c >> templateIdPhotoQuestions = new Map < Id, List < disco__Question__c >> ();

        for (disco__Form_Template__c template: availableFormTemplates) {
            templateIds.add(template.id);
        }

        for (disco__Question__c question: [SELECT Id, disco__Label__c, disco__Form_Template__c FROM disco__Question__c WHERE disco__Type__c = 'Attachment/Photo'
                AND disco__Form_Template__c IN: templateIds
            ]) {

            Id templateId = question.disco__Form_Template__c;

            if (templateIdPhotoQuestions.containsKey(templateID)) {
                templateIdPhotoQuestions.get(templateID).add(question);
            } else {
                templateIdPhotoQuestions.put(templateId, new List < disco__Question__c > {
                    question
                });
            }
        }

        return templateIdPhotoQuestions;

    }
*/
    @AuraEnabled(cacheable = true)
    public static Map < String, String > builderFormDetails() {

        Map < String, String > options = new Map < String, String > ();
/*
        List < disco__Form_Template__c > availableFormTemplates = buildAvailableFormTemplates();

        Map < Id, List < disco__Question__c >> templateIdPhotoQuestions = buildTemplateIdPhotoQuestions(availableFormTemplates);

        options.put('Templates', JSON.serialize(availableFormTemplates));
        options.put('Questions', JSON.serialize(templateIdPhotoQuestions));
*/
        return options;

    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Returns Success message after save oepration 
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    String, List<String>, String  
     * @return   List<sObject>  Returns all Questions for applied Forms
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */


    @AuraEnabled
    public static List < sObject > search(String objectName, List < String > fields, String searchTerm) {
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName + ' ( Id, ' + String.join(fields, ',') + ')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING ' + returningQuery + ' LIMIT 20';
        System.debug(' query ' + query);
        List < List < sObject >> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }
    
    
     @AuraEnabled(cacheable = true)
    public static List<sObject> getRecordsNames(String objectAPIName, List<String> recordsIds) {
    
       String objectName = objectAPIName;
       String fieldName = 'Name';
       String query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE Id IN :recordsIds';
       system.debug('Here is Object API Name'+objectName);
     //  String dynamicQuery = 'SELECT Id,Name from ' + 'objectName' +' WHERE Id IN :recordsIds';
       List<sObject> listOfResults = Database.Query(query);
       
       if(listOfResults.size() > 0){
               return listOfResults;
      }
      return listOfResults;

    }
    @AuraEnabled(cacheable=true)
    public static Blob getImage(String versionId) {
        // Logic to generate or retrieve the image URL based on versionId
        string imageUrl =  'https://juullabs--fullsb.sandbox.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + versionId;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(imageUrl);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            return res.getBodyAsBlob();
        } else {
            throw new AuraHandledException('Failed to fetch image');
        }
    }

}