import { LightningElement, track, api } from 'lwc';
import createVisitsOnRelatedAccounts from '@salesforce/apex/KAMCreateMissionsatDoor.createVisitsOnRelatedAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KamCreateMissionFromRSG extends LightningElement {
    @api recordId;
    @track saveInProgress = false;
    @track showPopup = false;
    message = 'If there is any existing active InStore Location for same period and category, then it will get deactivated. Do you want to proceed?'
    setAPTRows = [];
    setAPTIRows = [];
    setAPTProductRows = [];
    setAPTCommercialItemRows = []

    setAPTPromotionRows = [];
    setAPTIPromotionRows = [];
    setAPTPromotionProductRows = [];
    setAPTPromotionCommercialItemRows = []

    setAPTResetRows = [];
    setAPTIResetRows = [];
    setAPTResetProductRows = [];
    setAPTResetCommercialItemRows = []


    closeModal() {
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }

    refreshPage() {
        const refreshPage = new CustomEvent('refresh');
        this.dispatchEvent(refreshPage);
    }

    createVisits(e) {
        this.handlePopupCancel();
        const aptListIds = [];
        const aptiListIds = [];
        const aptProductIds = [];
        const aptCommercialItems = [];
        this.saveInProgress = true;
        this.setAPTRows && this.setAPTRows.forEach(aptRows => {
            aptListIds.push({ Id: aptRows.Id, name: aptRows.name })
        })
        this.setAPTIRows && this.setAPTIRows.forEach(aptiRows => {
            aptiListIds.push({ Id: aptiRows.Id, name: aptiRows.name })
        })
        this.setAPTProductRows && this.setAPTProductRows.forEach(aptProducts => {
            aptProductIds.push(aptProducts.Id)
        })
        this.setAPTCommercialItemRows && this.setAPTCommercialItemRows.forEach(commercialItems => {
            aptCommercialItems.push(commercialItems)
        })

        this.setAPTPromotionRows && this.setAPTPromotionRows.forEach(aptRows => {
            aptListIds.push({ Id: aptRows.Id, name: aptRows.name })
        })
        this.setAPTIPromotionRows && this.setAPTIPromotionRows.forEach(aptiRows => {
            aptiListIds.push({ Id: aptiRows.Id, name: aptiRows.name })
        })
        this.setAPTPromotionProductRows && this.setAPTPromotionProductRows.forEach(aptProducts => {
            aptProductIds.push(aptProducts.Id)
        })
        this.setAPTPromotionCommercialItemRows && this.setAPTPromotionCommercialItemRows.forEach(commercialItems => {
            aptCommercialItems.push(commercialItems)
        })

        this.setAPTResetRows && this.setAPTResetRows.forEach(aptRows => {
            aptListIds.push({ Id: aptRows.Id, name: aptRows.name })
        })
        this.setAPTIResetRows && this.setAPTIResetRows.forEach(aptiRows => {
            aptiListIds.push({ Id: aptiRows.Id, name: aptiRows.name })
        })
        this.setAPTResetProductRows && this.setAPTResetProductRows.forEach(aptProducts => {
            aptProductIds.push(aptProducts.Id)
        })
        this.setAPTResetCommercialItemRows && this.setAPTResetCommercialItemRows.forEach(commercialItems => {
            aptCommercialItems.push(commercialItems)
        })

        console.log('aptListIds', aptListIds, aptiListIds, aptProductIds, aptCommercialItems);
        if (aptListIds && aptListIds.length > 0) {
            createVisitsOnRelatedAccounts({ retailStoreId: this.recordId, selectedAPTList: aptListIds, selectedAPTIList: aptiListIds, selectedProducts: aptProductIds, selectedCommercialItems: aptCommercialItems })
                .then(response => {
                    let type = 'success'
                    console.log('response', response)
                    this.saveInProgress = false;
                    this.closeModal();
                    this.refreshPage();
                    const successLabel = response;
                    if (successLabel.startsWith('No associated'))
                        type = 'warning';
                    else
                        type = 'success';

                    this.showToast(type.toUpperCase(), successLabel, type);

                }).catch(error => {
                    console.log('error', error)
                    this.saveInProgress = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        } else {
            this.saveInProgress = false;
            this.showToast('', 'Please select action plan template in order to create missions', 'warning');
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

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    handleChange(event) {
        console.log("You selected an account: " + event.detail.value[0]);
        this.selectedPlanogram = event.detail.value[0];
    }

    handleCascadeToDoorClick() {
        this.showPopup = true;
    }

    handlePopupCancel() {
        this.showPopup = false;
    }


    actionPlanAccountSelectHandler(event) {
        console.log('ActionPlan', event.detail.setAPTRows, event.detail.setAPTIRows, event.detail.setAPTProductRows, event.detail.setAPTCommercialItemRows);

        // For Action Plan 
        if (event.detail.setAPTRows) {
            this.setAPTRows = event.detail.setAPTRows
        }
        if (event.detail.setAPTIRows) {
            this.setAPTIRows = event.detail.setAPTIRows
        }
        if (event.detail.setAPTProductRows) {
            this.setAPTProductRows = event.detail.setAPTProductRows
        }

        if (event.detail.setAPTCommercialItemRows) {
            this.setAPTCommercialItemRows = event.detail.setAPTCommercialItemRows
        }
    }

    actionPlanPromotionSelectHandler(event) {
        console.log('Promotion', event.detail.setAPTPromotionRows, event.detail.setAPTIPromotionRows, event.detail.setAPTPromotionProductRows, event.detail.setAPTPromotionCommercialItemRows);

        // For Promotion 
        if (event.detail.setAPTPromotionRows) {
            this.setAPTPromotionRows = event.detail.setAPTPromotionRows
        }
        if (event.detail.setAPTIPromotionRows) {
            this.setAPTIPromotionRows = event.detail.setAPTIPromotionRows
        }
        if (event.detail.setAPTPromotionProductRows) {
            this.setAPTPromotionProductRows = event.detail.setAPTPromotionProductRows
        }
        if (event.detail.setAPTPromotionCommercialItemRows) {
            this.setAPTPromotionCommercialItemRows = event.detail.setAPTPromotionCommercialItemRows
        }
    }

    actionPlanResetSelectHandler(event) {
        console.log('Reset', event.detail.setAPTResetRows, event.detail.setAPTIResetRows, event.detail.setAPTResetProductRows, event.detail.setAPTResetCommercialItemRows);

        // For Reset 
        if (event.detail.setAPTResetRows) {
            this.setAPTResetRows = event.detail.setAPTResetRows
        }
        if (event.detail.setAPTIResetRows) {
            this.setAPTIResetRows = event.detail.setAPTIResetRows
        }
        if (event.detail.setAPTResetProductRows) {
            this.setAPTResetProductRows = event.detail.setAPTResetProductRows
        }
        if (event.detail.setAPTResetCommercialItemRows) {
            this.setAPTResetCommercialItemRows = event.detail.setAPTResetCommercialItemRows
        }
    }
}