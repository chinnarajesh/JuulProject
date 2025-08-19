import { LightningElement,wire,api,track } from 'lwc';
    import getALLMissions from '@salesforce/apex/AccountMissionController.getALLMissions';
  /*  import {CurrentPageReference} from 'lightning/navigation';
    import {fireEvent, registerListener} from 'c/juulPubSub'*/
    import getRelatedMissionTasks from '@salesforce/apex/AccountMissionController.getRelatedMissionTasks';
    import getSelMissions from '@salesforce/apex/AccountMissionController.getSelMissions';
    import getRelatedStoreProducts from '@salesforce/apex/AccountMissionController.getRelatedStoreProducts';
    import getRelatedAsset from '@salesforce/apex/AccountMissionController.getRelatedAsset';
    import saveAccountsLwc from '@salesforce/apex/AccountMissionController.saveAccountsLwc';
    import saveAssertLwc from '@salesforce/apex/AccountMissionController.saveAssertLwc';
    import saveSelMissionStatus from '@salesforce/apex/AccountMissionController.saveSelMissionStatus';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { NavigationMixin } from 'lightning/navigation'; 
    import CUSTOM_OBJECT from '@salesforce/schema/Mission__c';
    import MISSIONSTATUSVALUES from '@salesforce/schema/Mission__c.Status__c';
    import CUSTOM_OBJECTAsset from '@salesforce/schema/Asset__c';
    import AssetStatus from '@salesforce/schema/Asset__c.Status__c';
    import MISSIONSTYPE from '@salesforce/schema/Mission__c.MissionType__c';
    import formFactorPropertyName from '@salesforce/client/formFactor';
    import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

    

    const columns = [
        { label: 'View', fieldName: 'A', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Start Date', fieldName: 'StartDate__c', type: 'text' },
        { label: 'End Date', fieldName: 'EndDate__c', type: 'text' },
        { label: 'Commercial Activity', fieldName: 'Commercial_Activity__c', type: 'text' },
        { label: 'Record Type', fieldName: 'RecordType.Name', type: 'text' }

    ]
    const columns2 = [
        { label: 'Status', fieldName: 'Status__c', type: 'text'},
        { label: 'Start Date', fieldName: 'StartDate__c', type: 'text' },
        { label: 'End Date', fieldName: 'EndDate__c', type: 'text' },
        { label: 'Commercial Activity', fieldName: 'Commercial_Activity__c', type: 'text' },
        { label: 'KAM Instructions', fieldName: 'InstructionDescription__c', type: 'richText' },
        { label: 'Mission Type', fieldName: 'MissionType__c', type: 'text'}
    ]
    const columns1 = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' }
    ]
    const StoreProducts = [
        {label: 'Product Name', fieldName: 'Product_Name_Formula__c', type: 'text'},
        {label: 'Planned PTC', fieldName: 'Final_PTC__c', type: 'text' },
        {label: 'Actual PTC', fieldName: 'ActualMSRP__c', type: 'text', editable: true}
    ]
    const Assets = [
        { label: 'Asset Name', fieldName: 'Name', type: 'text' },
        {label: 'Quantity', fieldName: 'Quantity__c', type: 'text'},
        { label: 'Status', fieldName: 'Status__c', type: 'text', editable: true }
       
    ]
    const selMissionAccountPlan = [
        { label: 'Sign Vendor Log?', fieldName: 'FillOutVendorLog__c', type: 'text'},
        { label: 'Third Party Allowed?', fieldName: 'ThirdPartyAllowed__c', type: 'text' },
        { label: 'Allowed to Price Scan?', fieldName: 'AllowedtoPriceScan__c', type: 'text' },
        { label: 'If No Pricing, Use JUUL Pricing?', fieldName: 'NoPricingUseJUULPricing__c', type: 'text' },
        { label: 'If Price Does not Scan?', fieldName: 'IfPriceDoesntScan__c', type: 'text' },
        { label: 'How to Fix Out of Stocks?', fieldName: 'ProductHowtoFixOutofStocks__c', type: 'text'},
        { label: 'Can You Label Fixtures?', fieldName: 'CanYouLabelFixtures__c', type: 'text' },
        { label: 'Can You Provide Leave Behinds?', fieldName: 'CanYouProvideLeadBehinds__c', type: 'text'},
        { label: 'KAM Instructions', fieldName: 'InstructionDescription__c', type: 'richText' }

    ]
    const StoreProductsAccountPlan = [
        {label: 'Product Name', fieldName: 'Product_Name_Formula__c', type: 'text'},
        {label: 'Planned PTC', fieldName: 'Final_PTC__c', type: 'text' }
        //{label: 'Actual PTC', fieldName: 'ActualMSRP__c', type: 'text'}
    ]
    const AssetsAcccountPlan = [
        { label: 'Asset Name', fieldName: 'Name', type: 'text' },
        {label: 'Quantity', fieldName: 'Quantity__c', type: 'text'},
        //{ label: 'Status', fieldName: 'Status__c', type: 'text'}
       
    ]
    

    export default class AccountMissionControlFlow extends NavigationMixin(LightningElement) {

    @track saveAss = false;
    @track saveSP = false;    
    @track saveMission = false;

    @track color;
    
    //@track isEditableDesktop = false;   
    @track isViewMission;
    @track selMissionAccountPlan = selMissionAccountPlan;
    @track selMissionsAP;

    @track isViewStoreProductAP;
    @track StoreProductsAccountPlan = StoreProductsAccountPlan;
    @track StoreProductAP;
   
    @track isViewAssetsAP;
    @track AssetsAcccountPlan = AssetsAcccountPlan;
    @track AssetAP;

    @track isEdited = false;
    @track toggleSaveLabelMS = 'Save';
    @track toggleSaveLabelSP = 'Save';
    @track toggleSaveLabelAST = 'Save';
    records;
    wiredRecords;
    saveDraftValues = [];
   @track additionalComment;
   @track commentVal;
    @api recordId;
    @api AccAuraID;
    @track columns = columns;
    @track Missions;
    @track Flag = false;
    @track MissionID;
    @track relatedRecordsDisplay =false;

    @track Missions1;
    @track SDMissions1;
    @track columns2 = columns2;

    @track MissionTask;
    @track columns1 = columns1;

    @track StoreProducts = StoreProducts;
    @track StoreProducts1;
    @track sp = false;

    @track Assets = Assets;
    @track Asset1;
    @track ast=false;
    @track asset1card;

    @track isMobile = false;
    @track isView = false;
    //Card Data
    newMission;
    newMissionTask;
    error;
    @track relatedMissiontask =false;
    @track slaOptions;
    @track upsellOptions;

    @track ParentType;

    @track isAssetchange= false;
    @track isStoreProductchange= false;
    @track isMissionchange = false;
    @track isPOSchange = false;
    @track commentField = false;
    @track additionalField = false;


                @wire(getObjectInfo, { objectApiName: CUSTOM_OBJECTAsset })
                    AssetInfo;
                
                @wire(getPicklistValues, { recordTypeId: '$AssetInfo.data.defaultRecordTypeId',fieldApiName: AssetStatus })
                AssetStatusInfo({ data, error }) {
                    if (data) this.AssetStatusValues = data.values;
                }

                @wire(getObjectInfo, {objectApiName: CUSTOM_OBJECT })
                objectInfo;

                @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MISSIONSTATUSVALUES })
                slaFieldInfo({ data, error }) {
                    if (data) {
                        this.slaFieldData = data;
                    
                    }
                }

                @wire(getPicklistValues, {recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName: MISSIONSTYPE })
                upsellFieldInfo({ data, error }) {
                    if (data) this.upsellOptions = data.values;
                }

                handleUpsellChange(event) {
                    let key = this.slaFieldData.controllerValues[event.target.value];
                    this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(key));
                    //this.ParentType = this.slaFieldData.controllerValues[event.target.value];
                    this.ParentType = event.detail.value;
                    console.log('ParentType'+this.ParentType);
                    
                }

                connectedCallback() {
                console.log('Inside Connected Callback '+this.recordId);
                    
                    this.fetchData();
                    this.isMobile = (formFactorPropertyName && (formFactorPropertyName.toLowerCase()==='small' || formFactorPropertyName.toLowerCase()==='medium')) ? true: false;
                    this.reload = true;
                }

                getAccountId(param){
                    alert('FlowMission'+param);
                    this.recordId= param;
                }

                fetchData() {
                    const acctID = this.AccAuraID;
                    console.log('recordId',this.recordId);
                    this.relatedRecordsDisplay = false;
                    console.log('relatedRecordsDisplay'+this.relatedRecordsDisplay );
            
                    if(this.recordId != null || this.recordId != undefined){
                        getALLMissions({ acc: this.recordId })

                            .then(response => {
                                // this.Missions = JSON.parse(response);
                                let missionData = JSON.parse(response);
                                    this.Missions = missionData.map(item => {
                                    if (item.StartDate && item.EndDate) {
                                        const date1 = new Date(item.StartDate);
                                        const date2 = new Date(item.EndDate);
                                        item.StartDate = `${(date1.getMonth() + 1).toString().padStart(2, '0')}/${date1.getDate().toString().padStart(2, '0')}/${date1.getFullYear()}`;
                                        item.EndDate = `${(date2.getMonth() + 1).toString().padStart(2, '0')}/${date2.getDate().toString().padStart(2, '0')}/${date2.getFullYear()}`;
                                   
                                    }
                                    return item; 
                                });
                                this.color = this.Missions.color;
                                console.log('Mission',this.Missions);
                            })
                            .catch(err => {
                                console.log('error', err)
                                this.showToast('ERROR', err.body.message, 'error');
                            });
                    }
                    const acc = this.AccAuraID;
                    console.log('Line AccAuraID'+this.AccAuraID);
                    console.log('Line recordId'+this.recordId);

                    if(this.recordId == null || this.recordId == undefined){
                            console.log('AccAuraID2',this.AccAuraID);
                            console.log('acctID',acctID);
                            getALLMissions({ acc: acctID })
                            .then(response => {
                                let missionData = JSON.parse(response);
                                    this.Missions = missionData.map(item => {
                                    if (item.StartDate && item.EndDate) {
                                        const date1 = new Date(item.StartDate);
                                        const date2 = new Date(item.EndDate);
                                        item.StartDate = `${(date1.getMonth() + 1).toString().padStart(2, '0')}/${date1.getDate().toString().padStart(2, '0')}/${date1.getFullYear()}`;
                                        item.EndDate = `${(date2.getMonth() + 1).toString().padStart(2, '0')}/${date2.getDate().toString().padStart(2, '0')}/${date2.getFullYear()}`;
                                   
                                    }
                                    return item; 
                                });
                                    console.log('sel Mission ',this.Missions);
                            })
                            .catch(err => {
                                    console.log('error Sel Mission', err)
                                    this.showToast('ERROR', err.body.message, 'error');
                            });

                    }
                }

                handleValuesSelect(e) {
                    const selectedValue = e.target.value;
                    const selectedRecordType = e.target.name;//added for Record type
                    console.log('RecordType value'+selectedRecordType);
                    this.relatedRecordsDisplay = true;
                    this.MissionID = selectedValue;
                    console.log('Selected value1'+selectedValue );
                    console.log('relatedRecordsDisplay'+this.relatedRecordsDisplay );
                    //Added for Record type check
                    if(selectedRecordType == 'Account Plan')
                    {
                        this.isViewMission = true;
                        this.isViewStoreProductAP = true; 
                        this.isViewAssetsAP = true;
                    }else
                    {
                        this.isViewMission = false;
                        this.isViewStoreProductAP = false;
                        this.isViewAssetsAP = false;
                    }
                    this.DisplayMissionTask();
                    this.DisplayStoreProduct();
                    this.DisplayAsset();
                    this.DisplaySelMissions();
                }

                handleValuesSelectMobile(e) {
                    this.isView= true;
                    console.log('on view method'+ this.isView);
                    const selectedValue = e.target.value;
                    const selectedRecordType = e.target.name;//added for Record type
                    this.relatedRecordsDisplay = true;
                    this.MissionID = selectedValue;
                    console.log('Selected value1'+selectedValue );
                    console.log('relatedRecordsDisplay'+this.relatedRecordsDisplay );
                    //added for Record type
                    if(selectedRecordType == 'Account Plan')
                    {
                        this.isViewMission = true;
                        console.log('Account plan on view method'+ this.isViewMission);
                        this.isViewStoreProductAP = true; 
                        this.isViewAssetsAP = true;
                    }else
                    {
                        this.isViewMission = false;
                        console.log('Account plan on view method'+ this.isViewMission);
                        this.isViewStoreProductAP = false;
                        this.isViewAssetsAP = false;
                    }
                    this.DisplayMissionTask();
                    this.DisplayStoreProduct();
                    this.DisplayAsset();
                    this.DisplaySelMissions();
                }

                DisplayMissionTask()
                {
                console.log('MissionID'+this.MissionID);
                getRelatedMissionTasks({ mission: this.MissionID })
                .then(response => {
                    
                    this.MissionTask = JSON.parse(response);
                    console.log('Mission Task',JSON.stringify(this.MissionTask));
                })
                .catch(err => {
                    console.log('error', err)
                    this.showToast('ERROR', err.body.message, 'error');
                });
                }

                DisplaySelMissions()
                {
                getSelMissions({ mission: this.MissionID })
                .then(response => {
                    
                    let missionData = JSON.parse(response);
                    // this.SDMissions1 = missionData;
                    this.SDMissions1 = missionData.map(item => {
                        if (item.additionalComment && /{.*}/.test(item.additionalComment)) {
                            item.additionalComment = '';  // Set to empty string if it contains {}
                        }
                        if (item.missionStartDate && item.missionEndDate) {
                            const date1 = new Date(item.missionStartDate);
                            const date2 = new Date(item.missionEndDate);
                            item.missionStartDate = `${(date1.getMonth() + 1).toString().padStart(2, '0')}/${date1.getDate().toString().padStart(2, '0')}/${date1.getFullYear()}`;
                            item.missionEndDate = `${(date2.getMonth() + 1).toString().padStart(2, '0')}/${date2.getDate().toString().padStart(2, '0')}/${date2.getFullYear()}`;
                        }
                        return item; 
                    });
                    console.log('test '+JSON.stringify(this.SDMissions1 ));
                    this.Missions1 = JSON.parse(response);
                    this.selMissionsAP = JSON.parse(response);
                    let key = this.SDMissions1[0]['missiontype'];
                    const selectedMission = this.SDMissions1.find(mission => mission.Id === this.MissionID);
                    // this.valueStatus = selectedMission['missionstatus'];
                    // this.posvalue = selectedMission['POSRequirement'];
                    // const statusElm = this.template.querySelector('.status-combobox');
                    // statusElm.value = selectedMission['missionstatus'];
                    // this.commentVal = selectedMission['Comments'];
                    this.commentField = selectedMission['missionstatus'] === 'Promo Not Executed' ? true : false;
                    this.posvalue = selectedMission['POSRequirement'];
                    this.additionalField = selectedMission['Comments'] === 'Other' && this.commentField == true  ? true : false;
                    // if(this.commentField){
                    //     const comboboxElement = this.template.querySelector('.comments-combobox');
                    //     comboboxElement.value = selectedMission['Comments'];
                    // }
                    // if(this.additionalField){
                    //     const additionalElement = this.template.querySelector('.additional-combobox');
                    //     additionalElement.value = selectedMission['additionalComment'];
                    // }
                    
                    let index;
                    if(key=='Strategy'){
                        index = 0;
                    }else if(key=='Account Plan'){
                        index= 1;
                    }  else if (key=='Promotion') {
                        index= 2;
                    } else if(key=='Reset'){
                        index= 3;
                    }
                    console.log('Test'+JSON.stringify(this.slaFieldData.controllerValues));
                    console.log('key'+key);
                    console.log('this.slaFieldData'+JSON.stringify(this.slaFieldData.values));
                    this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(index));
                })
                .catch(err => {
                    console.log('error', err)
                    this.showToast('ERROR', err.body.message, 'error');
                });
                }

                DisplayStoreProduct()
                {
                console.log('Hello'+this.MissionID);
                console.log('Inside DisplayStoreProduct-->'+this.recordId);
                console.log('Inside Display-->',JSON.stringify(this.StoreProducts1));
                getRelatedStoreProducts({ acc : this.recordId, mission: this.MissionID })
                
                .then(response => {
                    this.StoreProducts1 = JSON.parse(response);
                    this.StoreProductAP = JSON.parse(response);
                    if(this.StoreProducts1.length>0){                
                        this.sp = true;
                        //console.log('sp ==> '+ this.sp);
                        }
                    console.log('StoreProducts1 method',JSON.stringify(this.StoreProducts1))
                })
                .catch(err => {
                    this.showToast('ERROR', err.body.message, 'error');
                    console.log('error', err)
                });
                }


                DisplayAsset()
                {
                getRelatedAsset({ acc : this.recordId, mission: this.MissionID })
                .then(response => {
                    // this.Assets=json.parse(response);
                    this.Asset1 = JSON.parse(response);
                    this.AssetAP = JSON.parse(response);
                    console.log(' this.Asset1==>'+JSON.stringify( this.Asset1))
                    if(this.Asset1.length>0){                
                    this.ast = true;
                    //console.log('ast ==> '+ this.ast);
                    }
                    //this.asset1card= JSON.parse(response);
                })
                .catch(err => {
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

                Close(){
                console.log('relatedRecordsDisplay'+this.relatedRecordsDisplay );

                    this.closeModal();

                }  
                navigateToComponent() {
                    
                    this.reloadPage();
                    this.isView=false;
                    // this.DisplaySelMissions();
                }

                navigateToViewAccountPage() {
                    console.log('Inside navigate close');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Account',
                            actionName: 'view'
                        },
                    });
                }

                showToast(title, message, variant) {
                    const evt = new ShowToastEvent({
                        title: title,
                        message: message,
                        variant: variant,
                    });
                    //this.dispatchEvent(evt);
                }

                handlSPChange(event) {
                    let element = this.StoreProducts1.find(ele => ele.Id === event.target.dataset.id);
                    if (element) {
                        element.ActualMSRP = event.target.value;
                    this.StoreProducts1 = [...this.StoreProducts1];
                    console.log('Inside handle name method'+JSON.stringify(this.StoreProducts1));
                    this.isStoreProductchange = element.ActualMSRP >0 ;
                    console.log('isStoreProductchange-->' +this.isStoreProductchange);
                    }
                    
                }

                handlePicklistChange(event) {
                    let eventData = event.detail;
                    let pickValue = event.detail.selectedValue;
                    let uniqueKey = event.detail.key;
            
                    let element = this.Asset1.find(ele  => ele.Id === uniqueKey);
                    element.Status = pickValue;
                    this.Asset1 = [...this.Asset1];
                    console.log('Inside handle picklist method'+JSON.stringify(this.Asset1));
                }

                handleSPSave() {
                    this.toggleSaveLabelSP = 'Saving...'
                    let toSaveList = this.StoreProducts1;
                    toSaveList.forEach((element, index) => {
                       // if(element.Name === ''){
                           // toSaveList.splice(index, 1);
                      // }
                    });
                    console.log('Inside save method'+JSON.stringify(this.StoreProducts1));
                    //this.StoreProducts1 = toSaveList;
                    if(this.StoreProducts1.length>0){ //PG 28/07/2020
                    saveAccountsLwc({records : this.StoreProducts1})//PG
                    .then(() => {
                        this.toggleSaveLabelSP = 'Saved';
                        this.saveSP = true;//PG 28/07/2021
                        console.log('Save SP'+this.StoreProducts1);
                     
                        //Commented by PG 28/07/2021
                        /*this.dispatchEvent(
                            new ShowToastEvent({
                                title : 'Success',
                                message : 'Records saved succesfully!',
                                variant : 'success',
                            }),
                        
                        )*/
                    
                        this.DisplayStoreProduct();
                        this.isEdited = false;
                        this.error = undefined;
                    })
                    .catch(error => {
                        this.error = error;
                        this.record = undefined;
                        console.log("Error in Save call back:", this.error);
                    })
                    .finally(() => {
                        setTimeout(() => {
                            this.toggleSaveLabelSP = 'Save';
                        }, 3000);
                    });
                }//PG 28/07/2021
                }

                handleAssetSave() {
                    this.toggleSaveLabelAST = 'Saving...'
                    let toSaveList = this.Asset1;
                    console.log('Inside picklist save method');
                    toSaveList.forEach((element, index) => {
                       // if(element.Name === ''){
                           // toSaveList.splice(index, 1);
                      // }
                    });
                    console.log('Inside save method'+JSON.stringify(this.Asset1));
                    //this.StoreProducts1 = toSaveList;
                    if(this.Asset1.length>0){
                    saveAssertLwc({records : this.Asset1})//PG
                    .then(() => {
                        this.toggleSaveLabelAST = 'Saved';
                        this.saveAss = true;//PG 28/07/2021
                        //Commented by PG 28/07/2021
                        /*this.dispatchEvent(
                            new ShowToastEvent({
                                title : 'Success',
                                message : 'Records saved succesfully!',
                                variant : 'success',
                            }),
                        )*/
                        this.DisplayAsset();
                        this.isEdited = false;
                        this.error = undefined;
                    })
                    .catch(error => {
                        this.error = error;
                        this.record = undefined;
                        console.log("Error in Save call back:", this.error);
                    })
                   .finally(() => {
                        setTimeout(() => {
                            this.toggleSaveLabelAST = 'Save';
                        }, 3000);
                    });
                }//PG 28/07/2021
                }
            
                onDoubleClickEdit() {
                    this.isEdited = true;
                    //console.log('inside onDoubleClickEdit==>'+this.isEdited);
                }
            
                handleCancel() {
                    this.isEdited = false;
                }
                @track posvalue='';
                handleChange(event) {
                    let name = event.target.name;
                    if(name === 'Status'){
                        this.valueStatus = event.detail.value;
                        this.isMissionchange = true;
                        console.log('this.additionalField '+this.additionalField);
                        this.commentField = (this.valueStatus === 'Promo Not Executed');
                        this.additionalField = (this.commentVal === 'Other' && this.valueStatus === 'Promo Not Executed');
                      
                    }else if(name === 'POS'){
                        this.posvalue = event.detail.value;
                    console.log('Inside Handle save POs',this.posvalue);
                    this.isPOSchange = true;
                    }else if(name === 'Comments'){
                        this.commentVal = event.detail.value;
                        this.additionalField = (this.commentVal === 'Other' && this.commentField === true);
                    }else if(name === 'additional comment'){
                        this.additionalComment = event.target.value;
                    }
                        

                        // console.log('Inside Handle save',this.valueStatus);
                       
                        // console.log('isMissionchange-->' +this.isMissionchange);
                }
              
                // handleChangePOS(event){
                //     this.posvalue = event.detail.value;
                //     console.log('Inside Handle save',this.posvalue);
                //     this.isPOSchange = true;
                // }

                handleMissionSave() {
                this.toggleSaveLabelMS = 'Saving...'
                console.log('Inside method handleMissionSave',this.valueStatus+'this.posvalue '+this.posvalue);
                console.log('Inside save mission'+JSON.stringify(this.Missions1));
                for(var i=0; i<this.Missions1.length;i++){
                    if (this.Missions1[i]) {  // Check if the mission object is defined
                        this.Missions1[i].missionstatus = this.valueStatus; 
                        this.Missions1[i].POSRequirement = this.posvalue;
                        this.Missions1[i].Comments =this.commentVal;
                        this.Missions1[i].additionalComment =this.additionalComment;
                    } else {
                        console.warn(`Mission at index ${i} is undefined`);
                    }   
                }
                
                    // console.log('line 466',this.Missions1[0].POSRequirement);
                    // console.log('line 466',this.Missions1[0].missionstatus);
                    // console.log('line 466',this.Missions1[0].missiontype);           
                    console.log('Inside save mission222....'+JSON.stringify(this.Missions1));

                if(this.Missions1.length>0){ // Added by PG 30/06/2021
                saveSelMissionStatus({records : this.Missions1})//PG
                .then((result) => {      
                    this.toggleSaveLabelMS = 'Saved';    
                    this.saveMission = true; // Added by PG 30/06/2021
     
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : 'Records saved succesfully!',
                            variant : 'success',
                        }),
                    )*/
                console.log('result...'+JSON.stringify(result));
                this.DisplaySelMissions();
                    //this.isEdited = false;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.record = undefined;
                    console.log("Error in Save call back:", this.error);
                })
                .finally(() => {
                    setTimeout(() => {
                        this.toggleSaveLabelMS = 'Save';
                    }, 3000);
                });
            }// Added by PG 30/06/2021
                }

                handleChangeAsset(event) {
                    console.log('inside asset handlechangeasset');
                    let element = this.Asset1.find(ele => ele.Id === event.target.dataset.id);
                    if (element) {
                         element.Status = event.target.value;
                    this.Asset1 = [...this.Asset1];
                    console.log('Inside handle name method'+JSON.stringify(this.Asset1));
                    this.isAssetchange= true;
                    }
                   
                }

                reloadPage()
                {
                    setTimeout(function(){ 
                       window.location.reload();
                    }, 1000);
                }

                
        finalSave() {
            let flag = false;
            const comboxReq = this.template.querySelectorAll('.Req-Combo');
                comboxReq.forEach(item => {
                    if (!item.value) {
                        item.setCustomValidity('This field is required'); // Set validation message
                        flag = true;
                    } else {
                        item.setCustomValidity(''); // Clear validation if input is valid
                    }
                    item.reportValidity(); // Trigger validation display
                });
           const PTCValidation = this.template.querySelector('.Final-PTCIP');
            if (!PTCValidation || PTCValidation.value === '' || PTCValidation.value === '0') {
                PTCValidation.setCustomValidity('Value must be greater than 0');
                flag = true;
            } else {
                PTCValidation.setCustomValidity('');
            }
            PTCValidation.reportValidity();

            const InputValidity = this.template.querySelectorAll('.Req-Input');
            InputValidity.forEach(item => {
                if (!item.value || item.value.trim() === '' || item.value === '0') {
                    item.setCustomValidity('This field is required'); // Set validation message
                    flag = true;
                } else {
                    item.setCustomValidity(''); // Clear validation if input is valid
                }
                item.reportValidity(); // Trigger validation display
            });
            
            // console.log('flag2: ' + flag2 + 'flag1:' + flag1);
                if (!flag) {

                        if(this.isStoreProductchange== true){
                        console.log('Inside SP');    
                        this.handleSPSave();
                        this.dispatchEvent(new ShowToastEvent({
                            title : 'Success',
                            message : 'Records saved succesfully!',
                            variant : 'success'})
                            )
                        }
                        if(this.isAssetchange== true){
                        console.log('Inside Asset');
                        this.handleAssetSave();
                        this.dispatchEvent(new ShowToastEvent({
                            title : 'Success',
                            message : 'Records saved succesfully!',
                            variant : 'success'})
                            )
                        }
                        if((this.isMissionchange== true || this.isPOSchange == true || this.commentField == true || this.additionalField == true) && this.posvalue != ''){
                        console.log('Inside Mission');
                        this.handleMissionSave();
                        this.dispatchEvent(new ShowToastEvent({
                            title : 'Success',
                            message : 'Records saved succesfully!',
                            variant : 'success'})
                            )
                        }else{
                            this.dispatchEvent(new ShowToastEvent({
                                title : 'Warning',
                                message : 'No changes detected!',
                                variant : 'warning'})
                            )
                        }
                    }
                }

                get posOptions() {
                    return [
                        { label: 'Yes', value: 'Yes' },
                        { label: 'No', value: 'No' }
                    ];
                }

                get commentOptions() {
                    return [
                        { label: 'POS system not reflecting promo price', value: 'POS system not reflecting promo price' },
                        { label: 'Incorrect Mission loaded', value: 'Incorrect Mission loaded' },
                        { label: 'Incorrect Mission dates', value: 'Incorrect Mission dates' },
                        { label: 'POS unavailable', value: 'POS unavailable' },
                        { label: 'Hardware / backbar configuration issue', value: 'Hardware / backbar configuration issue' },
                        { label: 'Store Manager refusal', value: 'Store Manager refusal' },
                        { label: 'Other', value: 'Other' }
                    ];
                }
//------------------------------------------End-----------------------
   
    }