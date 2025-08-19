import { LightningElement, api, wire, track } from 'lwc';
import getAllRetailStoreGroups from '@salesforce/apex/KAMAssociateRetailStoreGroup.getAllRetailStoreGroups'
import associateRetailStoreGroupsOnApt from '@salesforce/apex/KAMAssociateRetailStoreGroup.associateRetailStoreGroupsOnApt'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Description', fieldName: 'description', type: 'text' },
    { label: 'Store Locations', fieldName: 'storeLocation', type: 'number' },
]

export default class KAMAssociateRSG extends LightningElement {
    @api recordId;
    @track storeGroupColumns = columns;
    @track loading = true;
    @track saveInProgress = false;
    @track rsGroups = [];
    @track selectedStoreGroups = [];
    @track preSelectedRows = [];
    @track searchKey;


    connectedCallback() {
        this.fetchData();
    }

    fetchData() {
        getAllRetailStoreGroups({ ActionPlanTemplateId: this.recordId })
            .then(response => {
                this.rsGroups = JSON.parse(response);
                this.loading = false
                if (this.rsGroups && this.rsGroups.length === 0) {
                    this.blankRsGroups = true;
                }
            })
            .catch(err => {
                console.log('error', err)
                this.showToast('ERROR', err.body.message, 'error');
            });
    }

    closeModal() {
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }

    refreshPage() {
        const refreshPage = new CustomEvent('refresh');
        this.dispatchEvent(refreshPage);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleCheckboxChange(e) {
        const selectedValue = e.target.value || '';
        const isRSGExists = this.selectedStoreGroups && this.selectedStoreGroups.length > 0 ? this.selectedStoreGroups.includes(selectedValue) : false
        if (isRSGExists) {
            this.selectedStoreGroups = this.selectedStoreGroups.filter(val => val !== selectedValue)
        } else {
            this.selectedStoreGroups.push(selectedValue);
        }
    }

    createAssociation(e) {
        if (this.selectedStoreGroups.length !== 0) {
            this.saveInProgress = true;
            associateRetailStoreGroupsOnApt({ ActionPlanTemplateId: this.recordId, selectedRSGList: this.selectedStoreGroups })
                .then(response => {
                    let type = 'success'
                    this.saveInProgress = false;
                    this.closeModal();
                    this.refreshPage();
                    const successLabel = response || 'Retail Store group associated successfully';
                    if (response) {
                        if (successLabel.startsWith('Please select'))
                            type = 'warning';
                        else
                            type = 'success';
                    }
                    this.showToast(type.toUpperCase(), successLabel, type);
                }).catch(error => {
                    console.log('error', error)
                    this.saveInProgress = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        } else {
            this.showToast('ERROR', 'Please select retail store groups', 'error');
        }
    }

    handleKeyChange(event) {
        if (this.searchKey !== event.target.value) {
            this.searchKey = event.target.value;
        }
    }

    pageData = () => {
        let result = [...this.rsGroups];

        if (this.searchKey) {
            const searchedResults = result && result.filter(data => {
                const lowercaseName = data && data.name && data.name.toLowerCase();
                const lowercaseSearchKey = this.searchKey && this.searchKey.toLowerCase();
                if (lowercaseName.includes(lowercaseSearchKey)) {
                    return data
                }
            });
            result = [...searchedResults];
        }


        const updatedResult = [];
        result && result.forEach(item => {
            if (item.Id && this.selectedStoreGroups.includes(item.Id)) {
                updatedResult.push({
                    ...item, selected: true
                })
            } else {
                updatedResult.push({
                    ...item
                })
            }
        })
        return updatedResult;
    }

    get currentPageData() {
        return this.pageData();
    }
}