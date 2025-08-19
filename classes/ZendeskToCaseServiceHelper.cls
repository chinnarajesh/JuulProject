/*******************************************************************************************
* @Name         ZendeskToCaseServiceHelper
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         05/16/2019
* @Group        Customer Service
* @Description  Helper class for handling Zendesk to Case Service class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         05/16/2019        Initial Creation
*******************************************************************************************/
public with sharing class ZendeskToCaseServiceHelper {
    public static Map<String, String> localeToMarketMap = CSCountryConfigUtil.getLocaleToMarket();
    public static Map<String, String> localeToRegionMap = CSCountryConfigUtil.getLocaleToRegion();
    public static Map<String, String> localeToLanguageMap = CSCountryConfigUtil.getLocaleToLanguage();
    public static Map<String, String> localeToEmailQueueMap = CSCountryConfigUtil.getLocaleToEmailQueueId();
    public static Map<String, String> localeToAppEmailQueueMap = CSCountryConfigUtil.getLocaleToAppEmailQueueId();
    public static Map<String, String> localeToPhoneChatQueueMap = CSCountryConfigUtil.getLocaleToPhoneChatQueueId();
    public static Map<String, String> localeToOutboundEmailMap = CSCountryConfigUtil.getLocaleToMarketOutboundEmail();

    /*******************************************************************************************************************
     * @Description This method creates a case object with all fields and returns it back for addition to the list
     * @Param   Id, String, String, Id
     * @Return  Case
    ******************************************************************************************************************/
    public static Case returnCase(Id recTypeId, String lang, String subject, String description, String ticketType,
            String priority, String orderNumb, Boolean noOrderNumb, String promoCode, String retPromoCode, String topic,
            String issue, String action, Id zdTicketId, Boolean agreeToPP, String custFirstName,
            String custLastName, String custEmail, String custPhone) {
        System.debug('start creating a case object');
        Case c = new Case();
        c.RecordTypeId = recTypeId;
        c.Origin = 'Support Form';
        //values dependent on locale code. Fetched from custom metadata types.
        if (String.isNotBlank(lang)) {
            c.Language_Preference__c = getLanguage(lang);
            c.Market__c = getMarket(lang);
            c.Case_Region__c = getRegion(lang);
            c.Market_Outbound_Email1__c = getOutboundEmail(lang);
            //assign owner id based on subject for phone&chat, or directly for email
            if (subject == 'Incoming Call' || subject == 'Incoming Chat') {
                Id queueId = getPhoneChatQueueId(lang);
                System.debug('queueId--> ' + queueId);
                if (queueId != null) c.OwnerId = queueId;
                //assign case origin as phone or chat
                if (subject == 'Incoming Call') {
                    c.Origin = 'Phone';
                } else if (subject == 'Incoming Chat') {
                    c.Origin = 'Chat';
                }
            } else {
                Id queueId = getEmailQueueId(lang);
                //special queue assignment for app troubleshooting record type
                if (recTypeId == RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting')) {
                    queueId = getAppEmailQueueId(lang);
                }
                System.debug('queueId--> ' + queueId);
                if (queueId != null) c.OwnerId = queueId;
            }
        }
        if (String.isNotBlank(subject)) c.Subject = subject;
        if (String.isNotBlank(description)) c.Description = description;
        if (String.isNotBlank(ticketType)) c.Type = ticketType;
        if (String.isNotBlank(priority)) c.Priority = priority;
        if (String.isNotBlank(orderNumb)) c.Order__c = orderNumb;
        if (noOrderNumb != null) c.No_Order_Number__c = noOrderNumb;
        if (String.isNotBlank(promoCode)) c.JUUL_coupon_code__c = promoCode;
        if (String.isNotBlank(retPromoCode)) c.JUUL_coupon_code__c = retPromoCode;
        if (String.isNotBlank(topic)) c.Topic__c = topic;
        if (String.isNotBlank(issue)) c.Issue__c = issue;
        if (String.isNotBlank(action)) c.Action__c = action;
        c.DO_NOT_NOTIFY__c = false;
        c.Send_Auto_Reply_Email__c = true;
        c.Web_Form__c = 'Zendesk';
        c.Do_Not_Assign__c = true; //do not run case assignment rules. configured as a node in case assignment rules.
        c.Related_Zendesk_Ticket__c = zdTicketId;
        c.Agree_to_Privacy_Policy__c = agreeToPP;
        c.Web_First_Name__c = custFirstName;
        c.Web_Last_Name__c = custLastName;
        c.SuppliedEmail = custEmail;
        c.SuppliedPhone = custPhone;
        System.debug('about to return back case --> ' + c);
        return c;
    }
    /*******************************************************************************************************************
     * @Description This method returns the market to be set based on the incoming brand from zendesk
     * @Param   String
     * @Return  String
    ******************************************************************************************************************/
    public static String getMarket(String locale) {
        if (localeToMarketMap.containsKey(locale)) return localeToMarketMap.get(locale);
        return null;
    }
    /*******************************************************************************************************************
     * @Description This method returns the region to be set based on the zendesk brand
     * @Param   String
     * @Return  String
    ******************************************************************************************************************/
    public static String getRegion(String locale) {
        if (localeToRegionMap.containsKey(locale)) return localeToRegionMap.get(locale);
        return null;
    }
    /*******************************************************************************************************************
     * @Description This method returns the language to be set based on the locale from zendesk
     * @Param   String
     * @Return  String
    ******************************************************************************************************************/
    public static String getLanguage(String locale) {
        if (localeToLanguageMap.containsKey(locale)) return localeToLanguageMap.get(locale);
        return null;
    }
    /*******************************************************************************************************************
     * @Description This method returns the email queue id to be set based on the locale from zendesk
     * @Param   String
     * @Return  Id
    ******************************************************************************************************************/
    public static Id getEmailQueueId(String locale) {
        if (localeToEmailQueueMap.containsKey(locale)) return (Id) localeToEmailQueueMap.get(locale);
        return null;
    }
    /*******************************************************************************************************************
     * @Description This method returns the app email queue id to be set based on the locale from zendesk
     * @Param   String
     * @Return  Id
    ******************************************************************************************************************/
    public static Id getAppEmailQueueId(String locale) {
        if (localeToAppEmailQueueMap.containsKey(locale)) return (Id) localeToAppEmailQueueMap.get(locale);
        return null;
    }
    /*******************************************************************************************************************
     * @Description This method returns the outbound email address to be set based on the locale from zendesk
     * @Param   String
     * @Return  String
    ******************************************************************************************************************/
    public static String getOutboundEmail(String locale) {
        if (localeToOutboundEmailMap.containsKey(locale)) return localeToOutboundEmailMap.get(locale);
        return null;
    }
    /*******************************************************************************************************************
     * @Description This method returns the phone and chat queue id to be set based on the locale from zendesk
     * @Param   String
     * @Return  Id
    ******************************************************************************************************************/
    public static Id getPhoneChatQueueId(String locale) {
        if (localeToPhoneChatQueueMap.containsKey(locale)) return (Id) localeToPhoneChatQueueMap.get(locale);
        return null;
    }
}