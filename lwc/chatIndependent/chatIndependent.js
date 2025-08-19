/*******************************************************************************************
 * @Name         ChatIndependent
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         04/24/2020
 * @Group        Customer Service
 * @Description  This is a LWC which starts live agent chat
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/24/2020        Initial Creation
*******************************************************************************************/
import {LightningElement, api, wire, track} from 'lwc';
import chatWithUs from '@salesforce/label/c.Chat_With_Us';
import buttonBaseUrl from '@salesforce/apex/LiveAgentService.getButtonBaseUrl';
import checkAvailabilityFromServer from '@salesforce/apex/ChatAvailableRequest.checkAvailability';

export default class ChatIndependent extends LightningElement {

    @api buttonId;
    @api deploymentId;
    @api orgId;
    @api country;
    @api lang;
    @wire(buttonBaseUrl) baseUrl;
    @track chatDisabled = true;

    label = {
        chatWithUs
    };

    connectedCallback() {
        this.checkAvailability();
    }

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        console.log('buttonId: ', this.buttonId);
        console.log('deploymentId: ', this.deploymentId);
        console.log('orgId: ', this.orgId);
        console.log('baseurl: ', this.baseUrl.data);
        console.log('country: ', this.country);
        console.log('language: ', this.lang);
        window.open(this.baseUrl.data + "/chatbutton/?buttonId=" + this.buttonId + "&deploymentId=" + this.deploymentId + "&orgId=" + this.orgId + "&lang=" + this.lang + "&country=" + this.country, "_blank", "height=500,width=500");
    }

    checkAvailability() {
        //check based on agent availability in the queue
        checkAvailabilityFromServer({
            market: this.country,
            language: this.lang,
            issueType: undefined
        })
            .then(result => {
                if (result) {
                    const availabilityObj = JSON.parse(result);
                    this.chatDisabled = !(availabilityObj.messages[0].message.buttons[0].isAvailable);//NOT operator
                    console.log('available for chat: ' + availabilityObj.messages[0].message.buttons[0].isAvailable);
                }
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
                console.log(this.message);
            });
    }
}