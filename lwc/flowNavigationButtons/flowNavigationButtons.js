import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent  } from 'lightning/flowSupport';

export default class Todos extends LightningElement {

    @api nextButtonVisible;
    @api previousButtonVisible;
    @api submitButtonVisible;

    connectedCallback() {
        //The connectedCallback() lifecycle hook fires when a component is inserted into the DOM. 
        // console.log(this.emailVisible);
        // console.log(this.phoneVisible);
        // console.log(this.chatVisible);
    }

    handleNextSelect(event) {
        //go to the next flow screen
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    handlePreviousSelect(event) {
        //go to the previous flow screen
        const previousNavigationEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(previousNavigationEvent);
    }

    handleSubmitSelect(event) {
        //go to the next flow screen
        const submitNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(submitNavigationEvent);
    }
}