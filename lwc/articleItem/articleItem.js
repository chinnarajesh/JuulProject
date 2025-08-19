/**
 * Created by sahil.chaudhry on 12/12/19.
 */

import {LightningElement, api} from 'lwc';

export default class ArticleItem extends LightningElement {
    @api article;

    handleSelect(event) {
        // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        // 2. Create a custom event that bubbles.
        const selectEvent = new CustomEvent('articleselect', {
            bubbles: true
        });
        // 3. Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}