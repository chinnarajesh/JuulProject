/*******************************************************************************************
 * @Name         ContactUs
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         01/29/2020
 * @Group        Customer Service
 * @Description  Container LWC to hold email,call and chat button LWCs
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         01/29/2020        Initial Creation
*******************************************************************************************/

import {LightningElement, api, track} from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

export default class ContactUs extends LightningElement {
    @api emailVisible;
    @api phoneVisible;
    @api chatVisible;
    @api callCenterOnline;
    @api actionSelection;
    @api country;
    @api language;
    @api timestamp;
    @api issueType;

    connectedCallback() {
        console.log('ContactUscountry-> ', this.country);
        console.log('ContactUslanguage-> ', this.language);
        console.log('ContactUsissuetype-> ', this.issueType);
    }

    handleEmailSelect(event) {
        this.actionSelection = event.detail;
        console.log(this.actionSelection);
        //Change attribute on Flow
        const attributeChangeEvent = new FlowAttributeChangeEvent('actionSelection', this.actionSelection);
        this.dispatchEvent(attributeChangeEvent);
        //go to the next flow screen
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    handleCallSelect(event) {
        this.actionSelection = event.detail;
        console.log(this.actionSelection);
        //Change attribute on Flow
        const attributeChangeEvent = new FlowAttributeChangeEvent('actionSelection', this.actionSelection);
        this.dispatchEvent(attributeChangeEvent);
        //go to the next flow screen
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    handleChatSelect(event) {
        this.actionSelection = event.detail;
        console.log(this.actionSelection);
        //Change attribute on Flow
        const attributeChangeEvent = new FlowAttributeChangeEvent('actionSelection', this.actionSelection);
        this.dispatchEvent(attributeChangeEvent);
        //go to the next flow screen
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
}