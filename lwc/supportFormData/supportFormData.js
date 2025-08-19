/*******************************************************************************************
 * @Name         SupportFormData
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         12/05/2019
 * @Group        Customer Service
 * @Description  This is a LWC which accepts customer topics from a flow and pass on to an
 *               event
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/05/2019          Initial Creation
*******************************************************************************************/
import {LightningElement, wire, api} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {fireEvent, unregisterAllListeners} from 'c/pubsub';

export default class SupportFormData extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api language = "";
    @api region = "";
    @api csf = "";
    @api topicIds;

    connectedCallback() {
        fireEvent(this.pageRef, 'getArticlesByDCat', {
            language: this.language,
            region: this.region,
            csf: this.csf
        });
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}