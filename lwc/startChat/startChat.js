/*******************************************************************************************
 * @Name         StartChat
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         02/10/2020
 * @Group        Customer Service
 * @Description  This is a LWC which starts live agent chat
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         02/10/2020        Initial Creation
*******************************************************************************************/
import {api, wire, LightningElement} from 'lwc';
import startChat from '@salesforce/label/c.Start_Chat';
import buttonBaseUrl from '@salesforce/apex/LiveAgentService.getButtonBaseUrl';

export default class StartChat extends LightningElement {

    @api caseId;
    @api buttonId;
    @api deploymentId;
    @api orgId;
    @api lang;
    @api country;
    label = {
        startChat
    };
    @wire(buttonBaseUrl) baseUrl;

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        console.log('caseId: ', this.caseId);
        console.log('buttonId: ', this.buttonId);
        console.log('deploymentId: ', this.deploymentId);
        console.log('orgId: ', this.orgId);
        console.log('lang: ', this.lang);
        console.log('country: ', this.country);
        console.log('baseurl: ', this.baseUrl.data);
        window.open(this.baseUrl.data + "/chatbutton/?caseId=" + this.caseId + "&buttonId=" + this.buttonId + "&deploymentId=" + this.deploymentId + "&orgId=" + this.orgId + "&lang=" + this.lang + "&country=" + this.country, "_blank", "height=500,width=500");
    }
}