import { LightningElement, api, track } from 'lwc';

export default class KamPaginationNavigator extends LightningElement {
    @api loading = false;
    @api disablePreviousButton = false;
    @api disableNextButton = false;

    handlePrev(_event) {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext(_event) {
        this.dispatchEvent(new CustomEvent('next'));
    }

    get previousButtonDisabled() {
        if (this.loading || this.disablePreviousButton) {
            return true;
        }
        return false;
    }

    get nextButtonDisabled() {
        if (this.loading || this.disableNextButton) {
            return true;
        }
        return false;
    }
}