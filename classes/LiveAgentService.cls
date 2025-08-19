/*/*******************************************************************************************
 * @Name         LiveAgentService
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         03/27/2020
 * @Group        Customer Service
 * @Description  Service for Supporting live agent chats
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         03/27/2020        Initial Creation
*******************************************************************************************/
public with sharing class LiveAgentService {
    /**************************************************************************************
     * @Description this method returns the base url of liveagent from the server
     * @Param  N/A
     * @Return  String URL
     **************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getButtonBaseUrl() {
        return [
                SELECT Site_Base_URL__c
                FROM Liveagent_Configuration__mdt
                LIMIT 1
        ].Site_Base_URL__c;
    }

    /**************************************************************************************
     * @Description this method returns configuration details of a chat button from the server
     * @Param   market, language and issue type
     * @Return  Configurations metadata record
     **************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static CS_Chat_Button_Configurations__mdt getButtonProperties(String market, String language, String issueType) {
        System.debug('market ' + market);
        System.debug('lang ' + language);
        System.debug('issue ' + issueType);
        //if issue type is not 'App', set it to 'None'
        if (issueType != 'App') {
            issueType = 'None';
        }
        List<CS_Chat_Button_Configurations__mdt> chatButtonConfigurationsList = [
                SELECT Button_ID__c, Deployment_ID__c, Org_ID__c, Type__c, Language__c, Market__c, Language_Code__c,
                        Chat_Init_Endpoint__c
                FROM CS_Chat_Button_Configurations__mdt
                WHERE Market__c = :market AND Language_Code__c = :language AND Type__c = :issueType
        ];
        System.debug('chatButtonConfigurationsList-> '+chatButtonConfigurationsList);
        if (!chatButtonConfigurationsList.isEmpty()) {
            return chatButtonConfigurationsList[0];
        } else return null;
    }

}