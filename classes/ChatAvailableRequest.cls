/*******************************************************************************************
* @Name         ChatAvailableRequest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         04/23/2020
* @Group        Customer Service
* @Description  This class checks availability status of a chat button
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/23/2020         Initial Creation
*******************************************************************************************/
public with sharing class ChatAvailableRequest {

    @AuraEnabled(cacheable=true)
    public static String checkAvailability(String market, String language, String issueType) {
        //get button properties
        CS_Chat_Button_Configurations__mdt buttonObj = LiveAgentService.getButtonProperties(market, language, issueType);
        System.debug('result from metadata table query-> ' + buttonObj);
        if (buttonObj != null) {
            String buttonId = buttonObj.Button_ID__c;
            String deploymentId = buttonObj.Deployment_ID__c;
            String orgId = buttonObj.Org_ID__c;
            //get chat availability endpoint
            String chatInitEndpoint = buttonObj.Chat_Init_Endpoint__c;
            System.debug('chatInitEndpoint-> ' + chatInitEndpoint);
            if (chatInitEndpoint != null) {
                String endpoint = chatInitEndpoint + '/rest/Visitor/Settings?Settings.buttonIds=' + buttonId + '&deployment_id=' + deploymentId + '&org_id=' + orgId;
                HttpRequest createReq = new HttpRequest();
                createReq.setEndpoint(endpoint);
                createReq.setHeader('X-LIVEAGENT-API-VERSION', '48');
                createReq.setHeader('Content-Type', 'application/json');
                createReq.setMethod('GET');
                createReq.setTimeout(30000);
                Http h = new Http();
                HttpResponse createRes = h.send(createReq);
                system.debug(createRes.getBody());
                String responseBody = createRes.getBody();
                return responseBody;
            }
        }
        return null;
    }
}