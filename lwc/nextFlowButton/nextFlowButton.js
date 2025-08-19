import {LightningElement} from 'lwc';
import next from '@salesforce/label/c.Next';

export default class NextFlowButton extends LightningElement {
    label = {
        next
    };

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const selectEvent = new CustomEvent("nextselect", {
        });
        this.dispatchEvent(selectEvent);
    }
}