import { LightningElement, api, wire, track } from 'lwc';
import getAllRetailStoreGroups from '@salesforce/apex/KAMAssociateRetailStoreGroup.getAllRetailStoreGroups'
import associateRetailStoreGroupsOnApt from '@salesforce/apex/KAMAssociateRetailStoreGroup.associateRetailStoreGroupsOnApt'
import associateStateGroupsOnApt from '@salesforce/apex/GetAccountHierarchyRecordsGroupByState.associateStateGroupsOnApt'
import fetchBatchAssociateStateData from '@salesforce/apex/GetAccountHierarchyRecordsGroupByState.fetchBatchAssociateStateData'

import getStateBasedAccounts from '@salesforce/apex/GetAccountHierarchyRecordsGroupByState.getStateBasedAccounts'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, onError }  from 'lightning/empApi';
// import { NavigationMixin } from 'lightning/navigation';
const columns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Description', fieldName: 'description', type: 'text' },
    { label: 'Store Locations', fieldName: 'storeLocation', type: 'number' },
]
export default class KamAssociateStatesClone extends LightningElement {

    @api recordId;
    @track storeGroupColumns = columns;
    @track loading = true;
    @track saveInProgress = false;
    @track rsGroups = [];
    @track selectedStoreGroups = [];
    @track preSelectedRows = [];
    @track searchKey;
    @track manageAPT = false;

    @track selectedStateGroups=[];
    @track stateAccounts =[];
    @track unSelectedstateGroups =[];
    @track checked = false;
    @track disabledAll = false;
    connectedCallback() {
        this.fetchData();
        this.fetchStateAccountsData();
        this.handleSubscribe();
    }
      //////////// Added by Juturi Rajesh
      subscription = {};
      @api channelName = '/event/Batch_Data__e';
      handleSubscribe() {
          console.log('new subscription')
          //var obj;
          // Callback invoked whenever a new event message is received
          const thisReference = this;
          let messageCallback = function(response) {
              console.log('second subscription')
              console.log('New message received 1: ', JSON.stringify(response));
              console.log('New message received 2: ', response);
              
              let obj= JSON.parse(JSON.stringify(response));
              console.log('New message received 4: ', obj.data.payload.Message__c);
              console.log('New message received 5: ', this.channelName);
              thisReference.BatchStateAccountsData();
              console.log('test console ');
              const evt = new ShowToastEvent({
                  title:obj.data.payload.Message__c ,
                  message:'',
                  variant: 'success',
                  mode: 'dismissable'
              });
              thisReference.dispatchEvent(evt);
              // Response contains the payload of the new message received
          };
  
          // Invoke subscribe method of empApi. Pass reference to messageCallback
          subscribe(this.channelName, -1, messageCallback).then(response => {
              // Response contains the subscription information on subscribe call
              console.log('Subscription request sent to: ', JSON.stringify(response.channel));
              this.subscription = response;
          });
      }
  
      ///////


    fetchData() {
        // getAllRetailStoreGroups({ ActionPlanTemplateId: this.recordId })
        //     .then(response => {
        //         this.rsGroups = JSON.parse(response);
        //         this.loading = false
        //         if (this.rsGroups && this.rsGroups.length === 0) {
        //             this.blankRsGroups = true;
        //         }
        //     })
        //     .catch(err => {
        //         console.log('error', err)
        //         this.showToast('ERROR', err.body.message, 'error');
        //     });
    }

    closeModal() {
        // const value = this.manageAPT;
        const closeModal = new CustomEvent('close',{detail:{childcompdescription:this.manageAPT}});
        this.dispatchEvent(closeModal);
        // this.manageAPT = true;
    }

    // @api childcompdescription='Test Description';

    // handleChildAction(){

    //     const evt= new CustomEvent('myfirstevent', {detail:{childcompdescription:this.manageAPT}});

    //     this.dispatchEvent(evt);

    // }
    refreshPage() {
        const refreshPage = new CustomEvent('refresh',{detail:{childcompdescription:this.manageAPT}});
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
    handleStateCheckboxChangeAll(e){
        this.checked = e.target.checked; 
        // console.log('checked all ',selectedValue);
        let selectedStates = [];
        const toggleList = this.template.querySelectorAll('.template');
        console.log('togglelist ',JSON.stringify(toggleList));
        // toggleList.forEach((toggle) => {
        //     toggle.addEventListener('change', (e) => this.handleStateCheckboxChange(e));
        // });
        selectedStates =this.stateAccounts.map(item => item.groupedState);
        this.selectedStateGroups = this.stateAccounts.map(item => item.groupedState);
        console.log('data of states ',JSON.stringify(this.stateAccounts.map(item => item.groupedState)));
        console.log(' this.selectedStateGroups', this.selectedStateGroups);
        for (const toggleElement of toggleList) {
            console.log('toggle',JSON.stringify(toggleElement));
            toggleElement.checked = e.target.checked;
            // const selectedValue = toggleElement.target.value || '';
            // const isChecked = toggleElement.target.checked;
            // console.log('selected state ',selectedValue);
            // const isStatexists = this.selectedStateGroups && this.selectedStateGroups.length > 0 ? this.selectedStateGroups.includes(selectedValue) : false
            // if (isStatexists) {
            //     this.selectedStateGroups = this.selectedStateGroups.filter(val => val !== selectedValue)
            // }  else if(isChecked){
            //     this.selectedStateGroups.push(selectedValue);
            // }
            // if (!isChecked) {
            //     this.unSelectedstateGroups.push(selectedValue);
            //     if( this.selectedStateGroups.includes(selectedValue)){
            //     this.selectedStateGroups = this.selectedStateGroups.filter(val => val !== selectedValue)
            //     }
            // } else {
            //     if (this.unSelectedstateGroups.includes(selectedValue)) {
            //         this.unSelectedstateGroups = this.unSelectedstateGroups.filter((val) => val !== selectedValue);
            //     }
            // }
            if( !this.checked){
                this.unSelectedstateGroups = selectedStates;
                this.selectedStateGroups = [];
            //    const selectedValues = this.stateAccounts.filter(elmt=>  !this.unSelectedstateGroups.includes(elmt));
                console.log('unselected value ',this.checked,' ',JSON.stringify(this.unSelectedstateGroups));
            }else  if( this.checked){
                this.unSelectedstateGroups = [];
            }
        }
    }
    handleStateCheckboxChange(e) {
        const dataIdValue = e.target.dataset.id;
        console.log('data-id value:', dataIdValue);

        const selectedValue = e.target.value || '';
        const isChecked = e.target.checked;
        console.log('isChecked '+isChecked);
        const isStatexists = this.selectedStateGroups && this.selectedStateGroups.length > 0 ? this.selectedStateGroups.includes(selectedValue) : false
        if (isStatexists) {
            this.selectedStateGroups = this.selectedStateGroups.filter(val => val !== selectedValue)
        }  else if(isChecked){
            console.log('selected');
            this.selectedStateGroups.push(selectedValue);
            // this.checked = this.stateAccounts.every(item => item.selected === true);
        }
        if (!isChecked ) {
            this.unSelectedstateGroups.push(selectedValue);
            this.checked = false;
            if( this.selectedStateGroups.includes(selectedValue)){
            this.selectedStateGroups = this.selectedStateGroups.filter(val => val !== selectedValue)
            }
        } else {
            if (this.unSelectedstateGroups.includes(selectedValue)) {
                this.checked = false;
                this.unSelectedstateGroups = this.unSelectedstateGroups.filter((val) => val !== selectedValue);
            }
        }
        console.log('selected value '+this.selectedStateGroups);
        console.log('unSelectedstateGroups '+this.unSelectedstateGroups);
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
                        this.manageAPT = true;
                        if (successLabel.startsWith('Please select'))
                            type = 'warning';
                        else
                            type = 'success';
                    }
                    
                    this.showToast(type.toUpperCase(), successLabel, type);
                }).catch(error => {
                    this.manageAPT = false;
                    console.log('error', error)
                    this.saveInProgress = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        } else {
            this.showToast('ERROR', 'Please select retail store groups', 'error');
        }
    }
    createAssociationStates(e) {
        if (this.selectedStateGroups.length !== 0 || this.unSelectedstateGroups.length !== 0) {
            this.saveInProgress = true;

            //let statesWithActIds = {};
            let statesWithActCounts = {};
            let unSelectedStateAccounts ={};

            for(let i=0; i<this.selectedStateGroups.length; i++){
                //let actIdsArr = this.selectedStateGroups[i]
                //statesWithActIds[this.selectedStateGroups[i]] = this.stateAccounts[0].groupedStateWithAccountIds[this.selectedStateGroups[i]];
                statesWithActCounts[this.selectedStateGroups[i]] = this.stateAccounts[0].groupedStateAccountsCount[this.selectedStateGroups[i]];
            }
            for(let i=0; i<this.unSelectedstateGroups.length; i++){
                unSelectedStateAccounts[this.unSelectedstateGroups[i]] = this.stateAccounts[0].groupedStateAccountsCount[this.unSelectedstateGroups[i]];
            }
            associateStateGroupsOnApt({ ActionPlanTemplateId: this.recordId, selectedStatesCount: statesWithActCounts,unSelectedStates: unSelectedStateAccounts})
                .then(response => {
                    let type = 'success'
                    this.saveInProgress = false;
                  
                    
                    const successLabel = response || ' State group associated successfully';
                    if (response) {
                        if (successLabel.startsWith('Please select'))
                            type = 'warning';
                        else
                            type = 'success';
                        this.manageAPT = true;
                    }
                    console.log('manage action'+this.manageAPT);
                    // this.manageAPT = false;
                    this.showToast(type.toUpperCase(), successLabel, type);
                    // this.navigateToAuraComponent();
                    this.closeModal();
                    this.refreshPage();
                }).catch(error => {
                    console.log('error', error)
                    this.saveInProgress = false;
                    this.manageAPT = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        } else {
            this.showToast('ERROR', 'Please select state groups', 'error');
        }
    }

    // navigateToAuraComponent() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__component',
    //         attributes: {
    //             componentName: 'c__KAMManageAPTAura' // Replace with your Aura component name
    //         },
    //         state: {
    //             recordId: this.recordId // Pass the recordId to the Aura component if needed
    //         }
    //     });
    // }

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
    ////////////////////
    fetchStateAccountsData(){
        getStateBasedAccounts({ ActionPlanTemplateId: this.recordId })
        const evt = new ShowToastEvent({
            title:'Please wait preparing the participating states...',
            message:'',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        // .then(response => {
        //     this.stateAccounts = response;
        //     //console.log('2test condition++'+this.blankRsGroups);
        //     //console.log('List '+JSON.stringify(this.stateAccounts[0].groupedStateWithAccountIds));
        //     this.loading = false
        //     if (this.stateAccounts && this.stateAccounts.length === 0) {
        //         this.blankRsGroups = true;
        //         //console.log('test condition++'+this.blankRsGroups);
        //     }
        // })
        // .catch(err => {
        //     console.log('error', err)
        //     this.showToast('ERROR', err.body.message, 'error');
        // });
    }
    BatchStateAccountsData(){
        console.log('test method');
        fetchBatchAssociateStateData({ ActionPlanTemplateId: this.recordId })
        .then(response => {
            this.stateAccounts = response;
            this.checked = this.stateAccounts.every(item => item.selected === true);
            // this.checked ? 'true' : 'false';
            // if(allSelectedTrue){
            //     console.log('true');
            //     this.checked = true;
            // }else{ this.checked = false;
            //     console.log('false');
            // }
            //console.log('2test condition++'+JSON.stringify(this.stateAccounts[0].groupedState));
            //console.log('List '+JSON.stringify(this.stateAccounts[0].groupedStateWithAccountIds));
            this.loading = false
            if (this.stateAccounts && this.stateAccounts.length === 0) {
                this.blankRsGroups = true;
                //console.log('test condition++'+this.blankRsGroups);
            }
        })
        .catch(err => {
            console.log('error', err)
            this.showToast('ERROR', err.body.message, 'error');
        });
    }
}