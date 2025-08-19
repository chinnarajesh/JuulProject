import { LightningElement, track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Account.JUUL_Serviced_By__r.name']; 


export default class AccountDemoCMP extends LightningElement {

    @track isReadOnly = true;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    ServiceBy;

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
           
        } else {
          
        }
    }

}