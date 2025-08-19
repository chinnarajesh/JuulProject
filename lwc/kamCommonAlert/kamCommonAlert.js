import { LightningElement, api } from 'lwc';

export default class KamCommonAlert extends LightningElement {
    @api message = '';

    handleYes(_event) {
        this.dispatchEvent(new CustomEvent('yes'));
    }

    handleCancel(_event) {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}