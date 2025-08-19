import { LightningElement, track, wire, api } from 'lwc';
import getAccountRecords from '@salesforce/apex/KAMAccountController.getAccountRecords';
import cloneRecords from '@salesforce/apex/KAMAccountController.cloneRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KamAccountListView extends LightningElement {
    @api recordId;
    @track tableLoadingState = true;
    @track accounts;
    @track err;
    @track noAccounts = false;
    @track selectedAccounts = [];
    @track saveInProgress = false;
    @track searchKey;

    // @track page = 1;
    // @track pages = [];
    // @track disablePreviousButton = false;
    // @track disableNextButton = false;
    // perpage = 20;

    connectedCallback() {
        this.fetchData();
    }
    //Updated below method by passing the record ID to show country specific accounts
    fetchData() {
        getAccountRecords({recId: this.recordId})
            .then(response => {
                this.accounts = response;
                this.err = undefined;
                // this.setPages(this.accounts);
                if (!this.accounts || (this.accounts && this.accounts.length === 0)) {
                    this.noAccounts = true;
                }
                this.tableLoadingState = false;
            })
            .catch(err => {
                this.err = err;
                this.accounts = undefined;
                console.log('error', err)
                if (err && err.body) {
                    this.showToast('ERROR', err.body.message, 'error');
                }
            });
    }

    handleSave() {
        if (this.selectedAccounts && this.selectedAccounts.length > 0) {
            this.saveInProgress = true
            cloneRecords({ recId: this.recordId, accId: this.selectedAccounts })
                .then(result => { 

                    console.log('@@Result : '+JSON.stringify(result));
                    if(result.responseType=='Error')
                    {
                        this.showToast('ERROR', result.responseMessage, 'error');
                        this.closeModal();
                        this.saveInProgress = false
                    }
                    else{
                        this.showToast('SUCCESS',result.responseMessage,'success');
                        this.closeModal();
                        this.saveInProgress = false

                    }
                   
                    
                })
                .catch(error => {
                    console.log('error', error)
                    this.showToast('ERROR', 'There was an error in cloning. Please try again!', 'error');
                    this.closeModal();
                    this.saveInProgress = false
                });
        } else {
            this.showToast('WARNING', 'Please select atleast one account in order to clone the template', 'warning');
        }
    }

    handleKeyChange(event) {
        if (this.searchKey !== event.target.value) {
            this.searchKey = event.target.value;
        }
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

    handleAccountsSelect(e) {
        const selectedValue = e.target.value || '';
        const isAccountExists = this.selectedAccounts && this.selectedAccounts.length > 0 ? this.selectedAccounts.includes(selectedValue) : false
        if (isAccountExists) {
            this.selectedAccounts = this.selectedAccounts.filter(val => val !== selectedValue)
        } else {
            this.selectedAccounts.push(selectedValue);
        }
    }

    pageData = () => {
        //Commented Code For pagination, if needed in future, please use this

        // let page = this.page;
        // let perpage = this.perpage;
        // let startIndex = (page * perpage) - perpage;
        // let endIndex = (page * perpage);
        // let result = this.accounts.slice(startIndex, endIndex);

        // if (result.length < this.perpage || result.length === 0) {
        //     this.disableNextButton = true;
        // } else {
        //     this.disableNextButton = false;
        // }
        // if (page === 1) {
        //     this.disablePreviousButton = true;
        // } else {
        //     this.disablePreviousButton = false;
        // }

        let result = [...this.accounts];

        if (this.searchKey) {
            const searchedResults = result && result.filter(data => {
                const lowercaseName = data && data.Name.toLowerCase();
                const lowercaseSearchKey = this.searchKey && this.searchKey.toLowerCase();
                if (lowercaseName.includes(lowercaseSearchKey)) {
                    return data
                }
            });
            result = [...searchedResults];
        }

        const updatedResult = [];
        result && result.forEach(item => {
            if (item.Id && this.selectedAccounts.includes(item.Id)) {
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


    //Code For pagination, if needed in future, please use this ------->

    // setPages = (data) => {
    //     let numberOfPages = Math.ceil(data.length / this.perpage);
    //     for (let index = 1; index <= numberOfPages; index++) {
    //         this.pages.push(index);
    //     }
    // }

    // get hasPrev() {
    //     return this.page > 1;
    // }
    // get hasNext() {
    //     return this.page < this.pages.length
    // }
    // onNext = () => {
    //     ++this.page;
    // }
    // onPrev = () => {
    //     --this.page;
    // }

    // End -------------->


    get currentPageData() {
        return this.pageData();
    }
}