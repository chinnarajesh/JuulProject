import { LightningElement } from 'lwc';
import submit from '@salesforce/label/c.Submit';

export default class SubmitFlowButton extends LightningElement {
    label = {
        submit
    };

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const selectEvent = new CustomEvent("submitselect", {
        });
        this.dispatchEvent(selectEvent);
    }

}