public class TerritoryUtility{
    public static void standardizeField(String fieldType, String fieldName, Map<String,Object> params, List<sObject> objectList){
        try{
             /* Start Custom settings */
            //Map form to custom settings
            Map<String,String> stateMap = new Map<String,String>();            
            Map<String,String> countryMap = new Map<String,String>();
            Map<String,String> countryBasedMap = new Map<String,String>();
            
            //get custom settings data
            List<ISO2_Country__c> isoStateCountryList = [select id,Name,State_Province__c,Country__c,TargetID__c,TargetID__r.State_Province__c,TargetID__r.Country__c,recordType.Name from ISO2_Country__c where TargetID__c != null AND (recordType.Name =: 'Source' OR recordType.Name =: 'Country Based')];            
            System.debug('isoStateCountryList ******************** '+isoStateCountryList.size());
            System.debug('!!!!isoStateCountryList::::'+isoStateCountryList);
            System.debug('!!!!isoStateCountryListSize::::'+isoStateCountryList.size());             
            //State map form
            if(isoStateCountryList != null && isoStateCountryList.size() > 0){
               for(ISO2_Country__c echIso : isoStateCountryList){
                   if(echIso.recordType.Name == 'Source'){
                       stateMap.put(echIso.State_Province__c,echIso.TargetID__r.State_Province__c);
                       countryMap.put(echIso.Country__c,echIso.TargetID__r.Country__c);
                   }else if(echIso.recordType.Name == 'Country Based'){                       
                       countryBasedMap.put(echIso.Country__c,echIso.TargetID__r.Country__c);
                   }
                   
                   
               }
            }
            System.debug('!!!!stateMap::::'+stateMap);                    
            System.debug('!!!!countryMap::::'+countryMap);
           
           
            /* End Custom settings */
            
             String stateCountryLabel = System.Label.StateCountryLabel;
            for(sObject obj: objectList){
                if(obj.get(fieldName) != null){
                    
                    String standardizedBasedCountryVal;
                    String normalizedCountryKey;
                    if(stateCountryLabel == 'New'){
                        if(fieldType=='Country'){
                            if(fieldName == 'BillingCountry'){
                                normalizedCountryKey = ((String)obj.get('BillingCountry')).trim().toLowerCase();
                               
                            }else{
                                normalizedCountryKey = ((String)obj.get('ShippingCountry')).trim().toLowerCase();
                               
                            }
                            
                        }
                    }
                    if(countryBasedMap.containsKey(normalizedCountryKey)){
                        standardizedBasedCountryVal = countryBasedMap.get(normalizedCountryKey);
                        if(standardizedBasedCountryVal!=null)
                        obj.put(fieldName,standardizedBasedCountryVal);
                    }else{
                        System.debug('!!!!country:::::');
                        String normalizedVal = ((String)obj.get(fieldName)).trim().toLowerCase();
                        String standardizedVal;
                        if(stateCountryLabel == 'New'){
                            if(fieldType=='State'){
                                System.debug('!!!!normalizedVal:::::'+normalizedVal);
                                standardizedVal = stateMap.get(normalizedVal);
                            }
                            else if(fieldType=='Country'){
                                if(fieldName == 'BillingCountry'){
                                    String normalizedVal1 = ((String)obj.get('BillingCountry')).trim().toLowerCase();
                                   System.debug('!!!!normalizedVal1:::::'+normalizedVal1);
                                   System.debug('!!!!normalizedVal:::::'+normalizedVal);
                                   System.debug('!!!!countryMap.get(normalizedVal):::::'+countryMap.get(normalizedVal1));
                                   standardizedVal = countryMap.get(normalizedVal1);
                                }else{
                                    String normalizedVal2 = ((String)obj.get('ShippingCountry')).trim().toLowerCase();
                                    System.debug('!!!!normalizedVal2:::::'+normalizedVal2);
                                    System.debug('!!!!normalizedVal:::::'+normalizedVal);
                                   System.debug('!!!!countryMap.get(normalizedVal):::::'+countryMap.get(normalizedVal2));
                                    
                                   standardizedVal = countryMap.get(normalizedVal2);
                                }
                                
                            }
                        }else{
                            if(fieldType=='State'){
                                standardizedVal = TerritoryMappings.STATE_TO_ISO2_MAPPING.get(TerritoryMappings.STATE_MAPPING.get(normalizedVal));
                            }
                            else if(fieldType=='Country'){
                                standardizedVal = TerritoryMappings.COUNTRY_TO_ISO2_MAPPING.get(TerritoryMappings.COUNTRY_MAPPING.get(normalizedVal));
                            }
                        }
                       
                        if(fieldType=='Zip Code'){
                            if(params.containsKey('countryFieldName')){
                                String countryFieldName = (String) params.get('countryFieldName');
                                if(obj.get(countryFieldName)!=null){
                                    String normalizedCountryVal = ((String)obj.get(countryFieldName)).trim().toLowerCase();
                                    String standardizedCountryVal = countryMap.get(normalizedCountryVal);
                                    if((standardizedCountryVal == 'United Kingdom' || standardizedCountryVal == 'GB') && normalizedVal.length() > 7){
                                        standardizedVal = normalizedVal.toUpperCase().subString(0,7);
                                    }
                                    else if((standardizedCountryVal == 'United States' || standardizedCountryVal == null) && normalizedVal.length() > 5){
                                        standardizedVal = normalizedVal.subString(0,5);
                                    }
                                }
                            }
                        }
                        if(standardizedVal!=null)
                        obj.put(fieldName,standardizedVal);
                    }
                    
    
                    
                }
            }
        }catch(exception e){
            System.debug(e);
        }
    }
    
}