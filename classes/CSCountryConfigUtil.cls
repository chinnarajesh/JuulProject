/*******************************************************************************************
* @Name         CSCountryConfigUtil
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         03/11/2019
* @Group        Customer Service
* @Description  A class having utility methods for CS country configurations
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         03/11/2019          Initial Creation
*******************************************************************************************/
public with sharing class CSCountryConfigUtil {
    public static List<CS_Country_Config__mdt> configsList = [
            SELECT T1_Email_Case_Queue__c, Phone_and_Chat_Case_Queue__c,
                    Zendesk_Language__c, Market__c, Language__c, Region__c,
                    T1_Email_Case_Queue_Name__c, Phone_and_Chat_Case_Queue_Name__c,
                    Market_Outbound_Email__c, T1_App_Email_Case_Queue__c, CC_Weekday_Start_Hour__c,
                    CC_Weekday_End_Hour__c, CC_Weekend_Start_Hour__c, CC_Weekend_End_Hour__c
            FROM CS_Country_Config__mdt
    ];

    /**************************************************************************************
     * @Description This method returns the weekday start hour based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToWeekdayStHr() {
        Map<String, String> localeToWeekdayStHrMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToWeekdayStHrMap.put(mdt.Zendesk_Language__c, mdt.CC_Weekday_Start_Hour__c);
        }
        return localeToWeekdayStHrMap;
    }

    /**************************************************************************************
     * @Description This method returns the weekday end hour based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToWeekdayEndHr() {
        Map<String, String> localeToWeekdayEndHrMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToWeekdayEndHrMap.put(mdt.Zendesk_Language__c, mdt.CC_Weekday_End_Hour__c);
        }
        return localeToWeekdayEndHrMap;
    }

    /**************************************************************************************
     * @Description This method returns the weekend start hour based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToWeekendStHr() {
        Map<String, String> localeToWeekendStHrMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToWeekendStHrMap.put(mdt.Zendesk_Language__c, mdt.CC_Weekend_Start_Hour__c);
        }
        return localeToWeekendStHrMap;
    }

    /**************************************************************************************
     * @Description This method returns the weekend end hour based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToWeekendEndHr() {
        Map<String, String> localeToWeekendEndHrMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToWeekendEndHrMap.put(mdt.Zendesk_Language__c, mdt.CC_Weekend_End_Hour__c);
        }
        return localeToWeekendEndHrMap;
    }
    /**************************************************************************************
     * @Description This method returns the email Queue ID based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToEmailQueueId() {
        Map<String, String> localeToEmailQueueIdMap = new Map<String, String>();
        List<String> emailQueueNamesList = new List<String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            if (String.isNotBlank(mdt.T1_Email_Case_Queue_Name__c)) {
                emailQueueNamesList.add(mdt.T1_Email_Case_Queue_Name__c);
            }
        }
        Map<String, Id> queueNameToQueueIdMap = getGroupIdByName(emailQueueNamesList);
        if (!queueNameToQueueIdMap.isEmpty()) {
            for (CS_Country_Config__mdt mdt : configsList) {
                if (String.isNotBlank(mdt.T1_Email_Case_Queue_Name__c) && String.isNotBlank(mdt.Zendesk_Language__c)) {
                    Id queueId = queueNameToQueueIdMap.get(mdt.T1_Email_Case_Queue_Name__c);
                    localeToEmailQueueIdMap.put(mdt.Zendesk_Language__c, queueId);
                }
            }
        }
        return localeToEmailQueueIdMap;
    }

    /**************************************************************************************
    * @Description This method returns the App email Queue ID based on zendesk locale code
    * @Param   String
    * @Return  String
    **************************************************************************************/
    public static Map<String, String> getLocaleToAppEmailQueueId() {
        Map<String, String> localeToEmailQueueIdMap = new Map<String, String>();
        List<String> emailQueueNamesList = new List<String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            if (String.isNotBlank(mdt.T1_App_Email_Case_Queue__c)) {
                emailQueueNamesList.add(mdt.T1_App_Email_Case_Queue__c);
            }
        }
        Map<String, Id> queueNameToQueueIdMap = getGroupIdByName(emailQueueNamesList);
        if (!queueNameToQueueIdMap.isEmpty()) {
            for (CS_Country_Config__mdt mdt : configsList) {
                if (String.isNotBlank(mdt.T1_App_Email_Case_Queue__c) && String.isNotBlank(mdt.Zendesk_Language__c)) {
                    Id queueId = queueNameToQueueIdMap.get(mdt.T1_App_Email_Case_Queue__c);
                    localeToEmailQueueIdMap.put(mdt.Zendesk_Language__c, queueId);
                }
            }
        }
        return localeToEmailQueueIdMap;
    }

    /**************************************************************************************
     * @Description This method returns the phone & chat Queue ID based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToPhoneChatQueueId() {
        Map<String, String> localeToPhoneChatQueueIdMap = new Map<String, String>();
        List<String> phoneChatQueueNamesList = new List<String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            if (String.isNotBlank(mdt.Phone_and_Chat_Case_Queue_Name__c)) {
                phoneChatQueueNamesList.add(mdt.Phone_and_Chat_Case_Queue_Name__c);
            }
        }
        Map<String, Id> queueNameToQueueIdMap = getGroupIdByName(phoneChatQueueNamesList);
        if (!queueNameToQueueIdMap.isEmpty()) {
            for (CS_Country_Config__mdt mdt : configsList) {
                if (queueNameToQueueIdMap.containsKey(mdt.Phone_and_Chat_Case_Queue_Name__c)) {
                    Id queueId = queueNameToQueueIdMap.get(mdt.Phone_and_Chat_Case_Queue_Name__c);
                    localeToPhoneChatQueueIdMap.put(mdt.Zendesk_Language__c, queueId);
                }
            }
        }
        return localeToPhoneChatQueueIdMap;
    }
    /**************************************************************************************
     * @Description This method returns the market based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToMarket() {
        Map<String, String> localeToMarketMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToMarketMap.put(mdt.Zendesk_Language__c, mdt.Market__c);
        }
        return localeToMarketMap;
    }
    /**************************************************************************************
     * @Description This method returns the language based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToLanguage() {
        Map<String, String> localeToLanguageMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToLanguageMap.put(mdt.Zendesk_Language__c, mdt.Language__c);
        }
        return localeToLanguageMap;
    }
    /**************************************************************************************
     * @Description This method returns the region based on zendesk locale code
     * @Param   String
     * @Return  String
     **************************************************************************************/
    public static Map<String, String> getLocaleToRegion() {
        Map<String, String> localeToRegionMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToRegionMap.put(mdt.Zendesk_Language__c, mdt.Region__c);
        }
        return localeToRegionMap;
    }
    /**************************************************************************************
    * @Description This method returns the market outbound email based on zendesk locale code
    * @Param   String
    * @Return  String
    **************************************************************************************/
    public static Map<String, String> getLocaleToMarketOutboundEmail() {
        Map<String, String> localeToEmailMap = new Map<String, String>();
        for (CS_Country_Config__mdt mdt : configsList) {
            localeToEmailMap.put(mdt.Zendesk_Language__c, mdt.Market_Outbound_Email__c);
        }
        return localeToEmailMap;
    }

    /**************************************************************************************
    * @Description This method returns the queue id based on the queue name
    * @Param   list of queue names
    * @Return  Map of queue names to Ids
    **************************************************************************************/
    public static Map<String, Id> getGroupIdByName(List<String> groupsList) {
        Map<String, Id> queueNameToQueueIdMap = new Map<String, Id>();
        if (!groupsList.isEmpty()) {
            List<Group> queueIdList = [
                    SELECT Id,DeveloperName
                    FROM Group
                    WHERE DeveloperName = :groupsList AND Type = 'Queue'
            ];
            if (!queueIdList.isEmpty()) {
                for (Group g : queueIdList) {
                    queueNameToQueueIdMap.put(g.DeveloperName, g.Id);
                }
            }
        }
        return queueNameToQueueIdMap;
    }
}