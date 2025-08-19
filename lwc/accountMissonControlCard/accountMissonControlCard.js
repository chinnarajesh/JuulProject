import { LightningElement,wire,api,track } from 'lwc';
    /*import {fireEvent, registerListener} from 'c/juulPubSub'
    import {CurrentPageReference} from 'lightning/navigation'; */
    import getALLMissions from '@salesforce/apex/AccountMissionController.getALLMissions';
    import getRelatedMissionTasks from '@salesforce/apex/AccountMissionController.getRelatedMissionTasks';
    import getSelMissions from '@salesforce/apex/AccountMissionController.getSelMissions';
    import getRelatedStoreProducts from '@salesforce/apex/AccountMissionController.getRelatedStoreProducts';   
    import getRelatedAsset from '@salesforce/apex/AccountMissionController.getRelatedAsset';
    import saveAssertLwc from '@salesforce/apex/AccountMissionController.saveAssertLwc';
    import saveAccountsLwc from '@salesforce/apex/AccountMissionController.saveAccountsLwc';
    import saveSelMissionStatus from '@salesforce/apex/AccountMissionController.saveSelMissionStatus';
    import { NavigationMixin } from 'lightning/navigation';    

    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import MISSIONSTATUSVALUES from '@salesforce/schema/Mission__c.Status__c';
    import MISSIONSTYPE from '@salesforce/schema/Mission__c.MissionType__c';
    import formFactorPropertyName from '@salesforce/client/formFactor';
    import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
    import CUSTOM_OBJECT from '@salesforce/schema/Mission__c';

    //import { updateRecord } from 'lightning/uiRecordApi';
    //import updateAccount from '@salesforce/apex/ApexControllerClass.updateAccount';
    //import { createRecord  } from 'lightning/uiRecordApi';//commented by pooja
    //import ACCOUNT_OBJECT from '@salesforce/schema/StoreProduct__c';
    //import ACTUALMSRP_FIELD from '@salesforce/schema/StoreProduct__c.ActualMSRP__c';
    //import ID_FIELD from '@salesforce/schema/StoreProduct__c.Id';
    

    const columns = [
        { label: 'View', fieldName: 'A', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Start Date', fieldName: 'StartDate__c', type: 'text' },
        { label: 'End Date', fieldName: 'EndDate__c', type: 'text' },
        { label: 'Commercial Activity', fieldName: 'Commercial_Activity__c', type: 'text' }
    ]
    const columns2 = [
        { label: 'Status', fieldName: 'Status__c', type: 'text' , editable: true},
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
        // { label: 'FinalPTC', fieldName: 'Final_PTC__c', type: 'text' },
        {label: 'Actual PTC', fieldName: 'ActualMSRP__c', type: 'text', editable: true}
    ]
    const Assets = [
        {label: 'Quantity', fieldName: 'Quantity__c', type: 'text'},
        {label: 'Status', fieldName: 'Status__c', type: 'text', editable: true }
       
    ]

    export default class AccountMissionControlFlow extends NavigationMixin(LightningElement) {
    
        @track toggleSaveLabel = 'Save';

        @track StoreProducts = StoreProducts; //Added by SS
        @track StoreProducts1;   //Added by SS
              newMissionTask;   //Added by SS
               error;//Added by SS
        @api MissionID;//Added by SS
        @api accountId;//Added by SS
        @track isMobile = false;//Added by SS
       // @wire(CurrentPageReference) pageRef;


        @track columns = columns;
        @track Missions;
        @track Flag = false;
        @track relatedRecordsDisplay =false;    
        @track Missions1 = [];
        @track columns2 = columns2;    
        @track MissionTask = [];
        @track columns1 = columns1;    
        @track StoreProducts = StoreProducts;
        @track StoreProducts1 = [];    
        @track Assets = Assets;
        @track Asset1 = [];    
        @track isMobile = false;
        @track isReload = false;
        @api AccAuraID;
    
        //Card Data
        newMission;
        newMissionTask;
        error;

        ActualMSRP;

        @track relatedMissiontask =false;

        //--------------------------------
        @track slaOptions;
        @track upsellOptions;
    
        @track ParentType;

        @wire(getObjectInfo, { objectApiName: CUSTOM_OBJECT })
        objectInfo;
    
        @wire(getObjectInfo, {objectApiName: CUSTOM_OBJECT })
        objectInfo;
    
        @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MISSIONSTATUSVALUES })
        slaFieldInfo({ data, error }) {
            if (data) {
                this.slaFieldData = data;
                this.DisplaySelMissions();
        this.DisplayMissionTask();
        this.DisplayStoreProduct();
        this.DisplayAsset();
            };
        }
    
        @wire(getPicklistValues, {recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName: MISSIONSTYPE })
        upsellFieldInfo({ data, error }) {
            if (data) this.upsellOptions = data.values;
        }
    
        // handleUpsellChange(event) {
        //     let key = this.slaFieldData.controllerValues[event.target.value];
        //     this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(key));
        //     //this.ParentType = this.slaFieldData.controllerValues[event.target.value];
        //     this.ParentType = event.detail.value;
        //     console.log('ParentType'+this.ParentType);
        // }
    //------------------------

     /*   @wire(getPicklistValues,
        {   recordTypeId: '$objectInfo.data.defaultRecordTypeId',
            fieldApiName: MISSIONSTATUSVALUES
        })missionStatusValues;*/

       
    connectedCallback() {
        this.isMobile = (formFactorPropertyName && formFactorPropertyName.toLowerCase()==='small') ? true: false;
        
        this.reload = true;
        //registerListener('passAccountToMission',this.getAccountId,this);
       
    }

    getAccountId(param){
        //alert('Id get from flowLwc'+param);
        this.AccAuraID= param;
    }
       /* loadMissions(){
            getRelatedMissionTasks()
			.then(result => {
				this.newMissionTask = result;
            })
			.catch(error => {
				this.error = error;
			});
        }*/

        DisplayMissionTask()
            {
             getRelatedMissionTasks({ mission: this.MissionID })
             .then(response => {
                 
                 this.MissionTask = JSON.parse(response);
             })
             .catch(err => {
                 console.log('error', err)
                 this.showToast('ERROR', err.body.message, 'error');
             });
            
            }


            DisplayStoreProduct()
            {
             //console.log('Hello'+this.MissionID);
             getRelatedStoreProducts({ acc : this.accountId, mission: this.MissionID })
             .then(response => {
                 this.StoreProducts1 = JSON.parse(response);
                 console.log('StoreProducts1',this.StoreProducts1)
                 
             })
             .catch(err => {
                 this.showToast('ERROR', err.body.message, 'error');
                 console.log('error', err)
             });
            
            }


            DisplayAsset()
            {
                //alert('getAsset'+this.accountId+ '--'+this.MissionID);
             getRelatedAsset({ acc : this.accountId, mission: this.MissionID })
             .then(response => {
                 this.Asset1 = JSON.parse(response);
                // alert('this.Asset1 -->'+this.Asset1 );
             })
             .catch(err => {
                 this.showToast('ERROR', err.body.message, 'error');
             });
            }

            DisplaySelMissions()
            {
                getSelMissions({ mission: this.MissionID })
             .then(response => {
                 this.Missions1 = JSON.parse(response);
                 let key = this.Missions1[0]['missiontype'];
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

                 this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(index));
             })
             .catch(err => {
                 console.log('error', err)
                 this.showToast('ERROR', err.body.message, 'error');
             });
            //     getSelMissions({ mission: this.MissionID })
            //  .then(response => {
                 
            //      this.Missions1 = JSON.parse(response);
            //      console.log('Mission Task',this.Missions1)
            //  })
            //  .catch(err => {
            //      console.log('error', err)
            //      this.showToast('ERROR', err.body.message, 'error');
            //  });
            }

            showToast(title, message, variant) {
                const evt = new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant,
                });
                //this.dispatchEvent(evt);
            }

            navigateToComponent(event) { 
                //alert('AccountIdInMissionCard'+this.AccAuraID);
                //fireEvent(this.pageRef,'passAccountId',this.AccAuraID);
                const selectedRecordId = event.target.name;
                this.AccAuraID = selectedRecordId;  
                //alert('navigateToComponent AccAuraID'+this.AccAuraID);     
                
                    let pageReference = {
                        "type": "standard__component",
                        "attributes" :{
                            componentName: "c__NavigateBackComp"
                        },
                        state: {
                            c__recordId:this.AccAuraID,
                            //c__accountId: this.accountId,
                        }
                    };
                    this[NavigationMixin.Navigate](pageReference);

        
            }

            navigateToViewAccountPage() {
                console.log('Inside navigate close');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                       // recordId: this.AccAuraID,
                        recordId: this.accountId,
                        objectApiName: 'Account',
                        actionName: 'view'
                    },
                });
                //this.handleClick();
                //this.refreshComponent();
            }


        refreshComponent(event){
            console.log('Inside refresh');
            eval("$A.get('e.force:refreshView').fire();");
        }

      /* handleNameChange(event) {
               // this.accountId = undefined;
                this.ActualMSRP = event.target.value;
            }*/

            handleNameChange(event) {
                let element = this.StoreProducts1.find(ele  => ele.Id === event.target.dataset.id);
                element.ActualMSRP = event.target.value;
                this.StoreProducts1 = [...this.StoreProducts1];
                console.log('Inside handle name method'+JSON.stringify(this.StoreProducts1));
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

            handleSaveDesktop() {
                this.toggleSaveLabel = 'Saving...'
                let toSaveList = this.Asset1;
                console.log('Inside picklist save method');
                toSaveList.forEach((element, index) => {
                   // if(element.Name === ''){
                       // toSaveList.splice(index, 1);
                  // }
                });
                console.log('Inside save method'+JSON.stringify(this.Asset1));
                //this.StoreProducts1 = toSaveList;
                saveAssertLwc({records : this.Asset1})//PG
                .then(() => {
                    this.toggleSaveLabel = 'Saved';
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : 'Records saved succesfully!',
                            variant : 'success',
                        }),
                    )
                    this.DisplayAsset();
                   // this.isEdited = false;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.record = undefined;
                    console.log("Error in Save call back:", this.error);
                });
               /* .finally(() => {
                    setTimeout(() => {
                        this.toggleSaveLabel = 'Save';
                    }, 3000);
                });*/
            }


            handleSaveStoreProdDesktop() {
                this.toggleSaveLabel = 'Saving...'
                let toSaveList = this.StoreProducts1;
                console.log();
                toSaveList.forEach((element, index) => {
                   // if(element.Name === ''){
                       // toSaveList.splice(index, 1);
                  // }
                });
                console.log('Inside save method'+JSON.stringify(this.StoreProducts1));
                //this.StoreProducts1 = toSaveList;
                saveAccountsLwc({records : this.StoreProducts1})//PG
                .then(() => {
                    this.toggleSaveLabel = 'Saved';
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : 'Records saved succesfully!',
                            variant : 'success',
                        }),
                    )
                
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
                        this.toggleSaveLabel = 'Save';
                    }, 3000);
                });
            }

            // handleChange(event) {
            //     this.valueStatus = event.detail.value;
    
            //     console.log('Inside Handle save',this.valueStatus);
            //  }
    
        //     handleStatusSave() {
        //        //this.toggleSaveLabel = 'Saving...'
        //        //let toSaveList = this.Missions1;
        //        console.log('Inside method handleStatusSave',this.valueStatus);
        //        for(var i=0; i<this.Missions1.length;i++){
        //         this.Missions1[i].missionstatus = this.valueStatus;  
        //        }
              
        //         console.log('line 466',this.Missions1[0].missionstatus);
        //         console.log('line 466',this.Missions1[0].missiontype);
        //        // console.log('Inside 467',this.Missions1);
        //        //toSaveList.forEach((element, index) => {
        //           // if(element.Name === ''){
        //               // toSaveList.splice(index, 1);
        //          // }
        //       // });
        //        console.log('Inside save mission'+JSON.stringify(this.Missions1));
        //        //this.StoreProducts1 = toSaveList;
        //        saveSelMissionStatus({records : this.Missions1})//PG
        //        .then(() => {
        //           // this.toggleSaveLabel = 'Saved';
                   
        //            this.dispatchEvent(
        //                new ShowToastEvent({
        //                    title : 'Success',
        //                    message : 'Records saved succesfully!',
        //                    variant : 'success',
        //                }),
        //            )
               
        //        this.DisplaySelMissions();
        //            //this.isEdited = false;
        //            this.error = undefined;
        //        })
        //        .catch(error => {
        //            this.error = error;
        //            this.record = undefined;
        //            console.log("Error in Save call back:", this.error);
        //        })
        //        .finally(() => {
        //            setTimeout(() => {
        //                this.toggleSaveLabel = 'Save';
        //            }, 3000);
        //        });
        //    }
    

           handleChange(event) {
            this.valueStatus = event.detail.value;

            console.log('Inside Handle save',this.valueStatus);
         }

            handleStatusSave() {
           //this.toggleSaveLabel = 'Saving...'
           //let toSaveList = this.Missions1;
           console.log('Inside method handleStatusSave',this.valueStatus);
           for(var i=0; i<this.Missions1.length;i++){
            this.Missions1[i].missionstatus = this.valueStatus;
            // this.Missions1[i].missiontype = this.ParentType;
           }
           //this.Missions1.missionstatus = this.valueStatus;
           //this.Missions1.missiontype = this.ParentType;
            console.log('line 466',this.Missions1[0].missionstatus);
           // console.log('Inside 467',this.Missions1);
           //toSaveList.forEach((element, index) => {
              // if(element.Name === ''){
                  // toSaveList.splice(index, 1);
             // }
          // });
           console.log('Inside save mission'+JSON.stringify(this.Missions1));
           //this.StoreProducts1 = toSaveList;
           saveSelMissionStatus({records : this.Missions1})//PG
           .then(() => {
              // this.toggleSaveLabel = 'Saved';
               
               this.dispatchEvent(
                   new ShowToastEvent({
                       title : 'Success',
                       message : 'Records saved succesfully!',
                       variant : 'success',
                   }),
               )
           
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
                   this.toggleSaveLabel = 'Save';
               }, 3000);
           });
       }
         
    }