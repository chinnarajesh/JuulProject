import { LightningElement, track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import formFactorPropertyName from '@salesforce/client/formFactor';

const FIELDS = ['Account.JUUL_Serviced_By__r.name']; 


export default class AccountDemoCMP extends LightningElement {

    @track isReadOnly = true;
    @api recordId;
    @track isMobile = false;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    ServiceBy;

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
           
        } else {
          
        }
        
    }

    connectedCallback() {
        this.isMobile = (formFactorPropertyName && formFactorPropertyName.toLowerCase()==='small') ? true: false;


    }

}