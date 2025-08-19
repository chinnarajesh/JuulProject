import { LightningElement, api } from 'lwc';
import CascadeChanges from '@salesforce/apex/KAMAccountAPTCascadeChanges.CascadeChanges'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class KAMCascadeChanges extends LightningElement {
    @api recordId;
    
    handleISLandMission()
    {
        console.log('this.recordID',this.recordId );
        CascadeChanges({apt: this.recordId })
            .then(response => {
                let type = 'success'
                this.closeModal();
                this.refreshPage();
                this.showToast(type.toUpperCase(), 'InStorelocations and Missions updated successfully ', type);
                
            })
            .catch(err => {
                console.log('error', err)
                this.showToast('ERROR', err.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    closeModal() {
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }

    //Function to refresh the complete page data when case to doors or save is clicked.
    refreshPage() {
        const refreshPage = new CustomEvent('refresh');
        this.dispatchEvent(refreshPage);
    }
}