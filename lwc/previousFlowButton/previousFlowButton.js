import { LightningElement } from 'lwc';
import previous from '@salesforce/label/c.Previous';

export default class PreviousFlowButton extends LightningElement {
    label = {
        previous
    };

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const selectEvent = new CustomEvent("previousselect", {
        });
        this.dispatchEvent(selectEvent);
    }



}