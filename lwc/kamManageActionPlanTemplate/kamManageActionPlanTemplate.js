/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     JUUL Developer       06-19-2020                     */
/*     1.1     Shreya Raut          02-01-2021
/* Class Name: KamAccountPlanning                       */
/* Description: To display KAM Action Plan Template object */
/**********************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import getALLRetailGroups from '@salesforce/apex/KAMAccountPlanning.getALLRetailGroups'
import getPlanogramProducts from '@salesforce/apex/KAMAccountPlanning.getPlanogramProducts'
import saveData from '@salesforce/apex/KAMAccountPlanning.saveData'
import createMissionsProductsAssets from '@salesforce/apex/KAMAccountPlanning.createMissionsProductsAssets'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createProductsAssets from '@salesforce/apex/KAMAccountPlanning.createProductsAssets'
import getBatchJobStatus from '@salesforce/apex/KAMAccountPlanning.getBatchJobStatus'
import CascadeISLMissionChanges from '@salesforce/apex/KAMAccountPlanning.CascadeISLMissionChanges'
import OverrideProducts from '@salesforce/apex/KAMAccountPlanning.OverrideProducts'
import {
    APPLICATION_SCOPE,
    subscribe,
  
    publish,
    MessageContext,
  } from "lightning/messageService";

const columns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Subject', fieldName: 'subject', type: 'text' },
    { label: 'Priority', fieldName: 'priority', type: 'text' }
]

const commercialActivityColumns1 = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Product Type', fieldName: 'productType', type: 'text' },
    //Added by Shreya for SFDC - 0000004228 
    // Commented by Jyoti for Product Bundle changes 
    // start
    // { label: 'Product Bundles', fieldName: 'ProductBundle', type: 'text'},
    // { label: 'Product Bundles Description', fieldName: 'ProductDescription', type: 'text'},
    //end
    //****Price Differentiator, Minimum MSRP, MAX Expected MSRP and Self Funding commented for ticket SFDC - 0000003131
    //{ label: 'Price Differentiator', fieldName: 'differentiator', type: 'number', editable: 'true' },
    { label: 'Facings/ Quantity', fieldName: 'quantity', type: 'number', editable: 'true' },
    //{ label: 'Minimum MSRP', fieldName: 'minimumMSRP', type: 'currency' },
    //{ label: 'Max Expected MSRP', fieldName: 'maximumExpectedMSRP', type: 'currency' },
    { label: 'STD JUUL Funding', fieldName: 'STDFunding', type: 'number', editable: 'true', default: 0.00},
    { label: 'PTC Modifier', fieldName: 'TaxFunding', type: 'number', editable: 'true', default: 0.00},
    
    { label: 'Retailer Funding', fieldName: 'RetailerFunding', type: 'number', editable: 'true', default: 0.00},
    { label: 'State Based Price', fieldName: 'listPrice', type: 'currency'},
    //{ label: 'List Price/Cost', fieldName: 'listPrice', type: 'currency'},// commented for ticket 3613
    //{ label: 'Planned Price/Cost', fieldName: 'plannedPrice', type: 'currency'},
    { label: 'Final PTC', fieldName: 'FinalPTC', type: 'currency'}
        
]

const commercialActivityColumns2 = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Product Type', fieldName: 'productType', type: 'text' },
    //Added by Shreya for SFDC - 0000004228 
    // Commented by Jyoti for Product Bundle changes 
    // start
    // { label: 'Product Bundles', fieldName: 'ProductBundle', type: 'text'},
    // { label: 'Product Bundles Description', fieldName: 'ProductDescription', type: 'text'},
    //end
    //****Price Differentiator, Minimum MSRP, MAX Expected MSRP and Self Funding commented for ticket SFDC - 0000003131
    //{ label: 'Price Differentiator', fieldName: 'differentiator', type: 'number', editable: 'true' },
    { label: 'Facings/ Quantity', fieldName: 'quantity', type: 'number', editable: 'true' },
    //{ label: 'Minimum MSRP', fieldName: 'minimumMSRP', type: 'currency' },
    //{ label: 'Max Expected MSRP', fieldName: 'maximumExpectedMSRP', type: 'currency' },
    { label: 'STD JUUL Funding', fieldName: 'STDFunding', type: 'number', editable: 'true', default: 0.00},
    { label: 'JBP Funding', fieldName: 'TaxFunding', type: 'number', editable: 'true', default: 0.00},
    
    { label: 'Retailer Funding', fieldName: 'RetailerFunding', type: 'number', editable: 'true', default: 0.00},
    { label: 'State Based Price', fieldName: 'listPrice', type: 'currency'},
    //{ label: 'List Price/Cost', fieldName: 'listPrice', type: 'currency'},// commented for ticket 3613
    //{ label: 'Planned Price/Cost', fieldName: 'plannedPrice', type: 'currency'},
    { label: 'Final PTC', fieldName: 'FinalPTC', type: 'currency'}
        
]
const productsColumns1 = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    //***Price Differentiator, Minimum MSRP, MAX Expected MSRP and Self Funding commented for ticket SFDC - 0000003131
    //{ label: 'Price Differentiator', fieldName: 'differentiator', type: 'number', editable: 'true' },
    { label: 'Facings', fieldName: 'quantity', type: 'number', editable: 'true' },
    //{ label: 'Minimum MSRP', fieldName: 'minimumMSRP', type: 'currency' },
    //{ label: 'Max Expected MSRP', fieldName: 'maximumExpectedMSRP', type: 'currency' },
    { label: 'STD JUUL Funding', fieldName: 'STDFunding', type: 'number', editable: 'true' },
    { label: 'PTC Modifier', fieldName: 'TaxFunding', type: 'number', editable: 'true'},
    
    { label: 'Retailer Funding', fieldName: 'RetailerFunding', type: 'number', editable: 'true'},
    { label: 'State Based Price', fieldName: 'listPrice', type: 'currency' },   
    //{ label: 'List Price', fieldName: 'listPrice', type: 'currency' }, // commented for ticket 3613
    //{ label: 'Planned Price', fieldName: 'plannedPrice', type: 'currency' },
    { label: 'Final PTC', fieldName: 'FinalPTC', type: 'currency'}
]

const productsColumns2 = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    //***Price Differentiator, Minimum MSRP, MAX Expected MSRP and Self Funding commented for ticket SFDC - 0000003131
    //{ label: 'Price Differentiator', fieldName: 'differentiator', type: 'number', editable: 'true' },
    { label: 'Facings', fieldName: 'quantity', type: 'number', editable: 'true' },
    //{ label: 'Minimum MSRP', fieldName: 'minimumMSRP', type: 'currency' },
    //{ label: 'Max Expected MSRP', fieldName: 'maximumExpectedMSRP', type: 'currency' },
    { label: 'STD JUUL Funding', fieldName: 'STDFunding', type: 'number', editable: 'true' },
    { label: 'JBP Funding', fieldName: 'TaxFunding', type: 'number', editable: 'true'},
    
    { label: 'Retailer Funding', fieldName: 'RetailerFunding', type: 'number', editable: 'true'},
    { label: 'State Based Price', fieldName: 'listPrice', type: 'currency' },   
    //{ label: 'List Price', fieldName: 'listPrice', type: 'currency' }, // commented for ticket 3613
    //{ label: 'Planned Price', fieldName: 'plannedPrice', type: 'currency' },
    { label: 'Final PTC', fieldName: 'FinalPTC', type: 'currency'}
]
export default class KamManageActionPlanTemplate extends LightningElement {
    @api recordId;
    @track columns = columns;
    @track commercialActivityColumns1 = commercialActivityColumns1;
    @track productsColumns1 = productsColumns1;
    @track commercialActivityColumns2 = commercialActivityColumns2;
    @track productsColumns2 = productsColumns2;
    @track RSGroups = [];
    @track URSGroups = [];
    @track loading = true;
    @track saveInProgress = false;
    @track planogramProductsLoading = false;
    @track blankRsGroups = false
    @track selectedButtonRSGId = ''
    @track CurrencyISOCode;
    // @track disablePreviousButton = false;
    // @track disableNextButton = false;
    @track showPopup = false;
    @track CascadeChangesWarning = false;
    @track showSelectRsgPopup = false;
    @track _isChecked = false;
    @track applyInProgress = false;
    @track CommercialStartegyBase;
    // @track page = 1;
    // @track pages = [];
    @track filteredItems = []
    @track recordTypeName;
    @track APTstatus;
    @track cascadeFlag = false;
    @track CascadeChanges = false;
    @track ISLFlag = false;
    @track MissionsCreated=false;
    @track InstoreLocationsCreated=false;
    @track ProfileSalesOppAdmin=false;
    @track cascadeToDoorDisable = true;
    @track cascadeMissionDisable = true;
    @track PlanButton = true;
    @track storeProductsVisible = true;
    @track planogramVisible = true;
    @track disableSave = true
    @track cascadeProductDisable = true;
    @track firstClick = false;
    @track firstClickDisable = false;
    @track manageApt = false;
    //Added by shreya for SFDC - 0000004197 
    @track batchJobISL;
    @track batchJobMS;
    @track batchMeassageMS;
    @track batchMeassage;
    @track batchRunningISL = false;
    @track batchRunningMS = false;
    @track batchStatus ;
    @track batchStatusBoolean = false;
    @track BatchPercentage;
    //Added for jira ticket JTP-167
    @track OverrideField;
    @track APTChanges;
    @track Executionstatus;
    @wire(MessageContext)
    context;

    // perpage = 5;
    message = 'New InStoreLocation will be created, even if any other InStoreLocation exists. Do you want to proceed?'
    CascadeChangesWarningMsg = 'You are about to modify action plan template data. Proceeding may damage data or create data. Do you Wish to proceed?'
    connectedCallback() {
        this.fetchData();
        console.log('MAPT SUb');
    }

    handleMessage(message){
        console.log('subscription;')
      }
      
    fetchData() {
        getALLRetailGroups({ apt: this.recordId })
            .then(response => {
                const groups = JSON.parse(response);
                console.log('group',groups);
                console.log('test method');
                this.CurrencyISOCode = groups && groups.CurrencyISOCode;
                this.APTstatus = groups ? groups.APTstatus || '' : '';
                this.cascadeFlag = groups && groups.CascadeFlag;
                this.CascadeChanges = groups && groups.CascadeChanges;
                this.ISLFlag = groups && groups.ISLFlag;
                this.InstoreLocationsCreated=groups && groups.InstoreLocationsCreated;
                this.ProfileSalesOppAdmin=groups && groups.ProfileSalesOppAdmin;
                this.MissionsCreated=groups && groups.MissionsCreated;
                this.OverrideField = groups && groups.OverrideField;
                this.APTChanges = groups && groups.APTChanges;
                this.CommercialStartegyBase = groups.CommercialStrategyDate;
                console.log('commercial Date Boolean '+this.CommercialStartegyBase);
                
                //Added for jira ticket JTP-167
                console.log('this.OverrideField'+this.OverrideField);
                this.storeProductsVisible = groups && groups.storeProductsVisible;
                this.planogramVisible = groups && groups.planogramVisible;
                this.RSGroups = groups ? groups.wraperList : []
                const newRecord = this.RSGroups && this.RSGroups.find(detail => !detail.readOnly)
                this.disableSave = !newRecord;
                //Added for JTP 167
                console.log('status values'+this.APTstatus);
                console.log('InstoreLocationsCreated++ '+this.InstoreLocationsCreated);
                console.log('ProfileSalesOppAdmin++'+this.ProfileSalesOppAdmin);
                if(this.APTstatus =='Execution')
                {
                    this.disableSave = true;
                    this.Executionstatus = true;
                }
                //Added by Shreya for ticket SFDC - 0000004197 
                if((this.APTstatus =='Cascade Mission to Doors' || this.APTstatus =='APT Approved & Locked') && this.InstoreLocationsCreated ==true && this.MissionsCreated==false && this.ProfileSalesOppAdmin ==true){
                   this.cascadeToDoorDisable = false;
                }else{
                        this.cascadeToDoorDisable = !newRecord || groups.cascadeToDoorDisable;
                    }
                
                if((this.APTstatus =='Cascade Products to Door' || this.APTstatus =='APT Approved & Locked')&& this.InstoreLocationsCreated ==false && this.ProfileSalesOppAdmin ==true){
                    console.log('status values2');
                   this.PlanButton = true;
                }else{
                        this.PlanButton = false;
                    }
                
                // this.setPages(this.RSGroups);
                if (!this.RSGroups || this.RSGroups && this.RSGroups.length === 0) {
                    this.blankRsGroups = true;
                    this.disableSave = true;
                    // this.disableNextButton = true;
                    // this.disablePreviousButton = true;
                }
                this.loading = false
               
            })
            .catch(err => {
                console.log('error', err)
                this.showToast('ERROR', err.body.message, 'error');
            });
            //Added below function by Shreya for ticket SFDC - 0000004197 
            getBatchJobStatus({apt: this.recordId })
            .then(response => {
                const Batch = JSON.parse(response);
                //console.log('Batch',Batch);
                this.batchStatus =  Batch && Batch.BatchStatus;
                this.BatchProceed = Batch && Batch.BatchJobItemsProcessed;
                this.BatchTotalJobItems =  Batch && Batch.BatchTotalJobItems;
                this.BatchPercentage = Math.round((this.BatchProceed/this.BatchTotalJobItems) * 100);
                //console.log('Batch BatchPercentage',this.BatchPercentage);
                if(this.batchStatus =="Processing")
                {
                    this.batchStatusBoolean = true;
                }else{
                    this.batchStatusBoolean = false;  
                }
                
            })
            .catch(err => {
                console.log('error', err)
                this.showToast('ERROR', err.body.message, 'error');
            });
    }

    async cascadeToDoor() {
        this.handleProductBundle();
        const errors = await this.validateCascadeSave();
        this.handlePopupCancel();
        
        if (errors.length === 0) {
            this.saveInProgress = true;
            //console.log('Mission',this.URSGroups);
            // createMissionsProductsAssets({ aptId: this.recordId, selectedData: this.URSGroups }) coomented by jyoti for product bundle
            createMissionsProductsAssets({ aptId: this.recordId, selectedData: this.URSGroups }) // added by jyoti for product bundle
                .then(response => {
                    let type = 'success'
                    const successLabel = response;
                    this.saveInProgress = false;
                    this.firstClickDisable = true;
                    
                    if (response && successLabel.startsWith('Please do')) {
                        type = 'warning';
                        this.showToast(type.toUpperCase(), successLabel, type);
                        
                    } else {
                        this.closeModal();
                        this.refreshPage();
                        this.showToast(type.toUpperCase(), 'Cascade to Door Successful', type);
                    }
                }).catch(error => {
                    console.log('error', error)
                    this.saveInProgress = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        }
    }
    //Added for JTP 167 
    async handleOverrideProduct()
    {
        this.handleProductBundle();
        const errors = await this.validateCascadeSave();
        this.handlePopupCancel();
        if (errors.length === 0) {
          
        OverrideProducts({aptId: this.recordId,selectedData: this.URSGroups})
        .then(response => {
            let type = 'success' 
            this.showToast(type.toUpperCase(), 'Product override Successful', type);
            this.closeModal();
       })
       .catch(error => {
        console.log('error', error)
        this.saveInProgress = false;
        this.showToast('ERROR', error.body.message, 'error');
        });
    }
    }
    //Added below function by Shreya for ticket SFDC - 0000004197 
    async CascadeProductsToDoor() {
        this.handleProductBundle();
        const errors = await this.validateCascadeSave();
        this.handlePopupCancel();

        if (errors.length === 0) {
            this.saveInProgress = true;
            // console.log('this.URSGroups->'+JSON.stringify(this.URSGroups));
            // createProductsAssets({ aptId: this.recordId, selectedData: this.RSGroups }) Commented by jyoti for product bundle
            createProductsAssets({ aptId: this.recordId, selectedData: this.URSGroups })//Added by jyoti for product bundle
                .then(response => {
                    let type = 'success'
                    const successLabel = response;
                    this.saveInProgress = false;
                    if ( response && successLabel.startsWith('Please do')) {
                        type = 'warning';
                        this.showToast(type.toUpperCase(), successLabel, type);
                    } else {
                        this.closeModal();
                        this.refreshPage();
                        this.cascadeMissionDisable=false;
                        this.showToast(type.toUpperCase(), 'Cascade to Door Successful', type);
                    }
                }).catch(error => {
                    console.log('error', error)
                    this.saveInProgress = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        }
    }

    async handleSave() {
        this.handleProductBundle();
        const aapterror = await this.validateProductdata();
        const finalPtccheck = await this.validateFinalPTCValues();
        const errors = await this.validateCascadeSave();
        if (errors && errors.length === 0 && aapterror && aapterror.length===0 && finalPtccheck && finalPtccheck.length ===0) {
            this.saveData()
        }
    }
    //added the rajesh jututi //JTP-1672
    validateProductdata(){
        let producterror = [];
        const filteredRsgProduct = this.RSGroups && this.RSGroups.filter(detail => !detail.readOnly)
            let AAptcount = filteredRsgProduct ? filteredRsgProduct.length : 0;
            let productcount = 0;
    
            filteredRsgProduct && filteredRsgProduct.map(group => {
                const commercialActivityItemlist = group && group.commercialActivityItems && group.commercialActivityItems.filter(detail => detail.selected)
                if (commercialActivityItemlist !== null && commercialActivityItemlist.length > 0) {
                    productcount++;
                }
            });
            if(AAptcount !==productcount){
                producterror.push('errorFound')
                this.showToast('WARNING', 'You must select a product', 'warning');
            }
        return producterror;
    }
    //ended by rajesh jututi

    //added by rajesh juturi //JTP-1832
    validateFinalPTCValues(){
        let FinalptcError =[];
        let FinalPTCValue =false;
        const filteredRsgFinalPtc = this.RSGroups && this.RSGroups.filter(detail => !detail.readOnly)

        filteredRsgFinalPtc && filteredRsgFinalPtc.map(group => {
            const finalPtcList = group && group.commercialActivityItems && group.commercialActivityItems.filter(detail => detail.selected)
            finalPtcList.forEach(product => {
                if (product.FinalPTC < 0) {
                    //finalPtcErrors.push(`FinalPTC value for ${product.name} should be greater than or equal to 0.`);
                    console.log('the given value is nagitive');
                    FinalPTCValue=true;
                }
            });
        });
        if(FinalPTCValue==true){
            FinalptcError.push('errorFound')
            this.showToast('WARNING', 'Final PTC should not be lessthen 0, Please adjust fundings.', 'warning');
        }


        return FinalptcError;
    }
    // edded by rajesh juturi

    validateCascadeSave() { console.log('ppp');
        let error = [];
        const filteredRsg = this.RSGroups && this.RSGroups.filter(detail => !detail.readOnly)
        const noRsgFound = this.RSGroups && this.RSGroups.find(detail => !detail.selected);
        //console.log('processedData++'+JSON.stringify(this.URSGroups));

        if (noRsgFound) {
            error.push('errorFound')
            this.showToast('WARNING', 'Please select all State group in order to create Missions', 'warning');
        } else {
            let rsgName = [];
            let breakLoop = false;
            let recordTypeError = false;
            filteredRsg && filteredRsg.map(group => {
                const missionTask = group && group.items && group.items.filter(detail => detail.selected);
                const commercialActivityItem = group && group.commercialActivityItems && group.commercialActivityItems.filter(detail => detail.selected)
                const products = group && group.products && group.products.filter(detail => detail.selected)
                if (!breakLoop && error && error.length === 0) {
                    if (this.recordTypeName === 'Account Plan') {
                        if (/*!group.items || */!group.commercialActivityItems || !group.products) {
                            error.push('errorFound');
                            recordTypeError = true;
                            this.showToast('WARNING', 'Please add Commercial Activity Items and Store Products on Action Plan Template in order to proceed further.', 'warning');
                        } else if (/*missionTask && missionTask.length === 0 || */commercialActivityItem && commercialActivityItem.length === 0 || products && products.length === 0) {
                            error.push('errorFound');
                            recordTypeError = true;
                            this.showToast('WARNING', 'Please select Commercial Activity Items and Store Products in order to proceed further.', 'warning');
                        }
                    } else if (this.recordTypeName === 'Promotional Activity Process') {
                        if (/*!group.items ||*/ !group.commercialActivityItems) {
                            error.push('errorFound');
                            recordTypeError = true;
                            this.showToast('WARNING', 'Please add Commercial Activity Items on Action Plan Template in order to proceed further.', 'warning');
                        } else if (/*missionTask && missionTask.length === 0 || */commercialActivityItem && commercialActivityItem.length === 0) {
                            error.push('errorFound');
                            recordTypeError = true;
                            this.showToast('WARNING', 'Please select Commercial Activity Items in order to proceed further.', 'warning');
                        }
                    } else if (this.recordTypeName === 'Reset Activity Process') {
                        const planogram = group.plannedPlanogramId && group.plannedPlanogramId !== ''

                        if (/*missionTask && missionTask.length > 0 && */planogram && (products && products.length > 0 || (group.standardPog && group.planogramProducts && group.planogramProducts.length > 0))) {

                        } else {
                            error.push('errorFound');
                            recordTypeError = true;
                            if (!'group'.items || !group.products) {
                                this.showToast('WARNING', 'Please add Store Products on Action Plan Template in order to proceed further.', 'warning');
                            } else {
                                this.showToast('WARNING', 'Please select a Planogram and Store Products in order to proceed further.', 'warning');
                            }
                        }
                    }
                }

                if (products && products.length > 0 && error && error.length === 0) {
                    const pricingIdNull = products.find(task => task.pricingId === null);
                    if (pricingIdNull) {
                        breakLoop = true;
                        if (!rsgName.includes(group.name)) {
                            rsgName.push(group.name)
                        }
                        error.push('errorFound');
                    }
                    const pricingExpiry = products.find(item => item.PriceMatrixExpiring === true);
                    if(pricingExpiry)
                    this.showToast('WARNING', 'Please reach out to your Price Execution Manager to have your region pricing matrix updated.', 'warning');
                }

                if (commercialActivityItem && commercialActivityItem.length > 0 && error && error.length === 0) {
                    const pricingIdNull = commercialActivityItem.find(item => item.pricingId === null && item.productType === "JUUL Product");
                   
                    if (pricingIdNull) {
                        breakLoop = true;
                        if (!rsgName.includes(group.name)) {
                            rsgName.push(group.name)
                        }
                        error.push('errorFound');
                    }

                    const pricingExpiry = commercialActivityItem.find(item => item.PriceMatrixExpiring === true && item.productType === "JUUL Product");
                    if(pricingExpiry)
                    this.showToast('WARNING', 'Please reach out to your Price Execution Manager to have your region pricing matrix updated.', 'warning');
                }

            })
            console.log(rsgName);
            console.log(rsgName.length);
            console.log(breakLoop);
            console.log(recordTypeError);
            if (rsgName && rsgName.length > 0 && breakLoop && !recordTypeError) {
                const name = rsgName.join(', ');
                this.showToast('WARNING', `Pricing for the Products you have selected for the following Associate Participating States group: ${name} does not exists in their respective Associate Participating States group's.`, 'warning');
            }
        }
        return error;
    }

    saveData() {
        this.saveInProgress = true;
        saveData({ aptId: this.recordId, selectedData: this.URSGroups })
            .then(response => {
                let type = 'success'
                this.saveInProgress = false;
                this.closeModal();
                this.refreshPage();
                this.showToast(type.toUpperCase(), 'Products saved successfully ', type);
            }).catch(error => {
                console.log('error', error)
                this.saveInProgress = false;
                this.showToast('ERROR', error.body.message, 'error');
            });
    }
    async CascadeISLandMissionChanges() {
        this.handleProductBundle();
        const errors = await this.validateCascadeSave();
        this.handlePopupCancel();
        //console.log('Inside Cascade changes');
        //console.log('this.RSGroups',this.RSGroups);
        if ( errors.length === 0) {
        CascadeISLMissionChanges({ aptId: this.recordId, selectedData: this.RSGroups })
            .then(response => {
                let type = 'success'
                this.saveInProgress = false;
                this.closeModal();
                this.refreshPage();
                this.showToast(type.toUpperCase(), 'Products saved successfully ', type);
            }).catch(error => {
                console.log('error', error)
                this.saveInProgress = false;
                this.showToast('ERROR', error.body.message, 'error');
            });
        }
    }

    closeModal() {
        const closeModal = new CustomEvent('close',{detail:this.manageApt});
        this.dispatchEvent(closeModal);
    }

    //Function to refresh the complete page data when case to doors or save is clicked.
    refreshPage() {
        const refreshPage = new CustomEvent('refresh',{detail:this.manageApt});
        this.dispatchEvent(refreshPage);
    }

    //Common function for generating RSG details
    createRSGDetails(key, values, rsgId) {
        //console.log('values=>'+values);
        const updatedValues = [];
        values && values.forEach(element => {
            if (element) {
                //console.log('element=>'+element);
                updatedValues.push({
                    ...element,
                    selected: element.selected === false ? false : true
                })
            }            
        });
        //console.log('updatedValues=>'+updatedValues);
        let filteredRSG = this.RSGroups && this.RSGroups.find(element => element.Id === rsgId)
        const updatedFilteredRSG = { ...filteredRSG, [key]: updatedValues }
        this.RSGroups = this.RSGroups && this.RSGroups.map(detail => {
            if (detail.Id === updatedFilteredRSG.Id) {
                return { ...updatedFilteredRSG }
            }
            return detail;
        });
        
    }

    handleSelectDeselectAll(event) {
        let parentKeyName = event.target.className || ''
        parentKeyName = parentKeyName.split(/(.+)- /)[1]
        if (event.target.id) {
            const RSGId = event.target.id.split(/(.+)-/)[1]
            const filteredRSG = this.RSGroups && this.RSGroups.find(element => element.Id === RSGId)
            const filteredRSGIndex = this.RSGroups ? this.RSGroups.findIndex(element => element.Id === RSGId) : -1
            const items = filteredRSG[parentKeyName];
            const updatedItems = [];
            items && items.forEach(item => {
                updatedItems.push({
                    ...item, selected: event.target.checked || false
                })
            })
            if (filteredRSGIndex > -1) {
                this.RSGroups[filteredRSGIndex][parentKeyName] = updatedItems
            }
        }
    }

    //Function for selecting RSG
    handleRsgSelect(e) {
        const selectedValue = e.target.value || '';
        const checked = e.target.checked
        const updatedRSG = []
        this.RSGroups && this.RSGroups.forEach(item => {
            if (item.Id === selectedValue) {
                updatedRSG.push({
                    ...item,
                    expanded: item.expanded !== null ? !item.expanded : true,
                    selected: item.selected && !item.expanded ? true : !checked ? false : true,
                    disablePOG: true
                })
            } else {
                updatedRSG.push({
                    ...item,
                    disablePOG: true
                })
            }
        })

        this.RSGroups = updatedRSG;
    }

    //Function for Use Standard POG Checkbox
    handlePlanogramCheckboxChange(event) {
        if (event.target.id) {
            const RSGId = event.target.id.split(/(.+)-/)[1]
            const rsgIndex = this.RSGroups && this.RSGroups.findIndex(detail => detail.Id === RSGId);
            if (event.target.checked) {
                let selectedRSG = this.RSGroups && this.RSGroups.find(detail => detail.Id === RSGId);
                const selectedPlanogramValue = selectedRSG && selectedRSG.plannedPlanogramId || ''

                if (!selectedRSG.planogramProducts || selectedRSG.planogramProducts && selectedRSG.planogramProducts.length === 0) {
                    if (!selectedPlanogramValue || selectedPlanogramValue === '') {
                        this.showToast('', 'Please select planogram to use standard POG', 'warning');
                    } else if (selectedPlanogramValue && selectedPlanogramValue !== '') {
                        this.planogramProductsLoading = true
                        getPlanogramProducts({ planogramId: selectedPlanogramValue, rsg: RSGId })
                            .then(response => {
                                const planogramProducts = JSON.parse(response);
                                this.RSGroups[rsgIndex].planogramProducts = planogramProducts;
                                this.RSGroups[rsgIndex].standardPog = true;
                                this.planogramProductsLoading = false;
                            }).catch(error => {
                                console.log('error', error)
                                this.planogramProductsLoading = false;
                                this.showToast('ERROR', error.body.message, 'error');
                            });
                    }
                }
            } else if (!event.target.checked) {
                this.RSGroups[rsgIndex].standardPog = false;
            }
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

    //Function to select planogram
    handleSelectPlanogram(event) {
        const RSGId = event.target.id.split(/(.+)-/)[1]
        const data = event.detail.value;
        const filteredRSGIndex = this.RSGroups && this.RSGroups.findIndex(element => element.Id === RSGId);
        if (this.RSGroups[filteredRSGIndex] && this.RSGroups[filteredRSGIndex].plannedPlanogramId !== data) {
            this.RSGroups[filteredRSGIndex].plannedPlanogramUpdated = true;
            this.RSGroups[filteredRSGIndex].planogramProducts = null;
        } else {
            this.RSGroups[filteredRSGIndex].plannedPlanogramUpdated = false;
        }
        this.RSGroups[filteredRSGIndex].disablePOG = false;
        this.RSGroups[filteredRSGIndex].standardPog = false;
        this.RSGroups[filteredRSGIndex].plannedPlanogramId = data;
    }

    //common function to insert the data of edit fields
    updateEditedFields(parentKeyName, key, rowId, value, rsgId) {
        // Filtering the RSG
        const filteredRSG = this.RSGroups && this.RSGroups.find(element => element.Id === rsgId);
        const rsgIndex = this.RSGroups && this.RSGroups.findIndex(element => element.Id === rsgId);

        //Filter the key values based on recieved parent key like commercial items, products etc
        let filteredRows = filteredRSG ? filteredRSG[parentKeyName] : null;

        if (filteredRows) {
            const filteredRowIndex = filteredRows ? filteredRows.findIndex(row => row.Id === rowId) : -1;
            const filteredItem = filteredRows ? filteredRows.find(row => row.Id === rowId) : null;

            let plannedPrice = filteredItem ? filteredItem.plannedPrice : 0;
            let FinalPTC = filteredItem ? filteredItem.FinalPTC : 0;
            //console.log('Filter Item',filteredItem);
            //if (key === 'differentiator') 
            //console.log('key--->'+key);
           if (key === 'STDFunding'){
               const price = parseFloat(value || '0');
               plannedPrice = (filteredItem.listPrice || 0) + price;
               FinalPTC =  price + (filteredItem.TaxFunding|| 0) + (filteredItem.RetailerFunding|| 0) + (filteredItem.listPrice || 0);
            }
            if (key === 'TaxFunding')
            {
            const price = parseFloat(value || '0');
            FinalPTC =  price + (filteredItem.STDFunding|| 0) + (filteredItem.RetailerFunding|| 0) + (filteredItem.listPrice || 0);
            }
            if(key === 'RetailerFunding')
            {
            const price = parseFloat(value || '0');
            FinalPTC =  price + (filteredItem.STDFunding|| 0) + (filteredItem.TaxFunding|| 0) + (filteredItem.listPrice || 0);
            }
            if (key === 'quantity' && (filteredItem && filteredItem.productType === 'Trade Collateral')) {
                const quantity = parseFloat(value || '0');
                plannedPrice = (filteredItem.listPrice || 0) * quantity;
            }
            if (filteredRowIndex > -1) {
                filteredRows[filteredRowIndex] = { ...filteredItem, [key]: value ? parseFloat(value) : null, plannedPrice: plannedPrice, FinalPTC: FinalPTC  }
            }
        }
        //Checking RSG is found or not.
        if (rsgIndex > -1) {
            //Updating the RSG with the updated Data
            this.RSGroups[rsgIndex][parentKeyName] = filteredRows
        }
    }

    //common function for items, products, tasks checkbox select
    handleValuesSelect(event) {
        const selectedValue = event.target.value || '';
        let parentKeyName = event.target.className || ''
        parentKeyName = parentKeyName.split(/(.+)- /)[1]
        if (event.target.id) {
            const RSGId = event.target.id.split(/(.+)-/)[1]
            const filteredRSG = this.RSGroups && this.RSGroups.find(element => element.Id === RSGId)
            const items = filteredRSG[parentKeyName];
            const updatedItems = [];
            items.forEach(item => {
                if (item.Id === selectedValue && event.target.checked) {
                    updatedItems.push({
                        ...item, selected: true
                    })
                } else if (item.Id === selectedValue && !event.target.checked) {
                    updatedItems.push({
                        ...item, selected: false
                    })
                } else {
                    updatedItems.push({
                        ...item, selected: !item.selected ? false : item.selected
                    })
                }
            })
            
            this.createRSGDetails(parentKeyName, updatedItems, RSGId);
        }
    }

    handleProductBundle()
    {
        
        var newUpdatedItems = [];
        const processedData = [];
        var RSGId='';
        this.RSGroups && this.RSGroups.forEach(uitem => {
            newUpdatedItems = [];
            if(uitem.Id)
            {
                RSGId = uitem.Id;
            if(uitem.commercialActivityItems)
            {
            uitem.commercialActivityItems && uitem.Id && uitem.commercialActivityItems.forEach(ca => {
                if (ca.ProductBundle === 'Combo' || ca.ProductBundle === 'GetxSavex') {
                            var IdArr = ca.Id.split(",");
                            var parentIdArr = ca.parentId.split(",");
                            var pricingIdArr = ca.pricingId.split(",");
                            // console.log('Id-->'+IdArr);
                            // console.log('parentId-->'+parentIdArr);
                            // console.log('pricingId-->'+pricingIdArr);
                                for(var i=0;i<=IdArr.length-1;i++)
                                {
                                     newUpdatedItems.push({
                                        ...ca, Id: IdArr[i], parentId: parentIdArr[i], pricingId: pricingIdArr[i],productType:'JUUL Product'
                                    })
                                }     
                        }
                        else{
                            newUpdatedItems.push({...ca})
                            }              

            }) 
            // console.log('newUpdatedItems='+JSON.stringify(newUpdatedItems));
            if(uitem.Id == RSGId){
                processedData.push({
                    ...uitem, commercialActivityItems : newUpdatedItems
                })
            } 
        }
        }
    })
        this.URSGroups = processedData;
        
        // console.log('processedData='+JSON.stringify( this.URSGroups));
    }


    //common function for edit fields
    handleInputChange(event) {
        const value = event.target.value;
        let parentKeyName = event.target.className || ''
        parentKeyName = parentKeyName.split(/(.+) /)[1]
        const name = event.target.name;
        const itemId = event.target.dataset.id
        const selectedRsgId = event.target.id || null
        if (selectedRsgId) {
            const RSGId = selectedRsgId.split(/(.+)-/)[1]
            this.updateEditedFields(parentKeyName, name, itemId, value, RSGId);
        }
    }

    // showSelectModal(event) { console.log("event.target.id",event.target.id);
    //     const selectedRsgId = event.target.id || ''
    //     this.selectedButtonRSGId = selectedRsgId.split(/(.+)-/)[1]
    //     this.showSelectRsgPopup = true
    // }
    showSelectModal(event) {
        const selectedRsgId = event.target.id || ''
        this.selectedButtonRSGId = selectedRsgId.split(/(.+)-/)[1]
        this.showSelectRsgPopup = true
    }

    handleCascadeToDoorClick() {
        this.showPopup = true;
    }
    handleCascadeChangesClick() {
        //console.log('insode handle click');
        this.CascadeChangesWarning = true;
    }

    handlePopupCancel() {
        this.CascadeChangesWarning = false;
        this.showPopup = false;
        this.showSelectRsgPopup = false
    }

    applyItems(event) {
        const selectedRsgs = event.detail;
        this.applyInProgress = true
        let itemsProcessed = 0;

        const selectedGroup = this.RSGroups.find(group => group.Id === this.selectedButtonRSGId);

        if (selectedGroup) {
            this.RSGroups && this.RSGroups.forEach(group => {
                itemsProcessed++;
                if (selectedRsgs.includes(group.Id)) {
                    group.selected = true;
                    group.plannedPlanogramId = selectedGroup.plannedPlanogramId;
                    group.standardPog = selectedGroup.standardPog;
                    group.planogramProducts = selectedGroup.planogramProducts ? [...selectedGroup.planogramProducts] : null;
                    group.disablePOG = selectedGroup.disablePOG;
                    group.plannedPlanogramURL = selectedGroup.plannedPlanogramURL;

                    if (group.commercialActivityItems && selectedGroup.commercialActivityItems) {
                        group.commercialActivityItems && group.commercialActivityItems.forEach(item => {
                            selectedGroup.commercialActivityItems.forEach(selectedItem => {
                                if (item.Id === selectedItem.Id) {
                                    item.selected = selectedItem.selected
                                    //item.differentiator = selectedItem.differentiator  //Commented for ticket SFDC - 0000003131
                                    item.STDFunding = selectedItem.STDFunding    //Added by shreya-pooja for ticket SFDC - 0000003131
                                    item.TaxFunding = selectedItem.TaxFunding    //Added by shreya-pooja for ticket SFDC - 0000003131
                                    
                                    item.RetailerFunding = selectedItem.RetailerFunding  //Added by shreya-pooja for ticket SFDC - 0000003131
                                    item.quantity = selectedItem.quantity
                                    item.FinalPTC = selectedItem.STDFunding + selectedItem.TaxFunding + selectedItem.RetailerFunding + item.listPrice;
                                    if (item.productType === 'Trade Collateral') {
                                        item.plannedPrice = (item.listPrice || 0) * selectedItem.quantity;
                                    } else {
                                        //item.plannedPrice = item.listPrice + selectedItem.differentiator
                                        item.plannedPrice = item.listPrice + selectedItem.STDFunding
                                    }
                                }
                            })
                        })
                    }

                    if (group.items) {
                        group.items = [...selectedGroup.items]
                    }

                    if (group.products && selectedGroup.products) {
                        group.products && group.products.forEach(product => {
                            selectedGroup.products.forEach(selectedProduct => {
                              
                                if (product.Id === selectedProduct.Id) {
                                    product.selected = selectedProduct.selected
                                    //product.differentiator = selectedProduct.differentiator  //commented for ticket SFDC - 0000003131
                                    product.STDFunding = selectedProduct.STDFunding  //Added by shreya-pooja for ticket SFDC - 0000003131
                                    product.TaxFunding = selectedProduct.TaxFunding  //Added by shreya-pooja for ticket SFDC - 0000003131
                                    
                                    product.RetailerFunding = selectedProduct.RetailerFunding  //Added by shreya-pooja for ticket SFDC - 0000003131
                                    product.quantity = selectedProduct.quantity
                                    //product.plannedPrice = product.listPrice + selectedProduct.differentiator
                                    product.plannedPrice = product.listPrice + selectedProduct.STDFunding
                                    product.FinalPTC = selectedProduct.STDFunding + selectedProduct.TaxFunding + selectedProduct.RetailerFunding + product.listPrice 

                                }
                            })
                        })
                    }

                    if (selectedGroup.planogramProducts) {
                        group.planogramProducts = [...selectedGroup.planogramProducts];
                    }
                }
                if (itemsProcessed === this.RSGroups.length) {
                    this.applyInProgress = false;
                    this.showSelectRsgPopup = false
                }
            })
        }
    }

    //<--------Functions for Pagination Start
    pageData = () => {
        // let page = this.page;
        // let perpage = this.perpage;
        // let startIndex = (page * perpage) - perpage;
        // let endIndex = (page * perpage);

     this.RSGroups =this.RSGroups.map(entry => {
  return {
    ...entry, // Keep other properties of entry
    commercialActivityItems: entry.commercialActivityItems.map(item => ({
      ...item, // Keep other properties of item
        STDFundingDisabledNew: entry.STDFundingDisabled || item.listPrice === 0,// Assign boolean value
        PTCModifierDisabledNew: entry.PTCModifierDisabled || item.listPrice === 0 // Assign boolean value
    }))
  };
});
        
        // console.log('RSGroup ' + JSON.stringify(RSGroup));
        const result = [...this.RSGroups]

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
        return result;
    }

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

    get currentPageData() {
        return this.pageData();
    }
    //Functions for Pagination End------>

    // SubscriptionChannel() {
        
    //   }
     
}