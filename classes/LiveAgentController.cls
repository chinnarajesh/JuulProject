/*/*******************************************************************************************
 * @Name         LiveAgentController
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         02/17/2020
 * @Group        Customer Service
 * @Description  This is the controller for the liveagent visualforce page
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         02/17/2020        Initial Creation
*******************************************************************************************/
public without sharing class LiveAgentController {

    public CS_Chat_Button_Configurations__mdt liveagentConfig { get; set; }
    public String lang { get; set; }
    public String caseId { get; set; }
    public String buttonId { get; set; }
    public String deploymentId { get; set; }
    public String orgId { get; set; }
    public String country { get; set; }

    public LiveAgentController() {
        //get url param values
        lang = ApexPages.currentPage().getParameters().get('lang');
        //Code added by Shreya for Ticket SFDC - 0000003218
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        caseId = ESAPI.encoder().SFDC_HTMLENCODE(caseId);  //sr01
        buttonId = ApexPages.currentPage().getParameters().get('buttonId');
        buttonId = ESAPI.encoder().SFDC_HTMLENCODE(buttonId);  //sr02
        deploymentId = ApexPages.currentPage().getParameters().get('deploymentId');
        deploymentId = ESAPI.encoder().SFDC_HTMLENCODE(deploymentId); //sr03
        orgId = ApexPages.currentPage().getParameters().get('orgId');
        orgId = ESAPI.encoder().SFDC_HTMLENCODE(orgId); //sr04
        country = ApexPages.currentPage().getParameters().get('country');

        if (String.isNotBlank(country) && String.isNotBlank(lang)) {
            liveagentConfig = [
                    SELECT Chat_Init_Endpoint__c, Deployment_Endpoint__c
                    FROM CS_Chat_Button_Configurations__mdt
                    WHERE Market__c = :country AND Language_Code__c = :lang
                    LIMIT 1
            ];
            System.debug('liveagentConfig-> ' + liveagentConfig);
        }
    }
}