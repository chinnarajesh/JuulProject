/**
 * Created by Pooja Gite on 11/10/2021.
 */
 import { LightningElement, wire, track, api } from 'lwc';
 import getDocDetails from '@salesforce/apex/fetchDocumentDetails.getDocDetails';
 import createCase from '@salesforce/apex/fetchDocumentDetails.createCase';
 //import saveDocDetailsLwc from '@salesforce/apex/fetchDocumentDetails.saveDocDetailsLwc';
 import { updateRecord } from 'lightning/uiRecordApi';
 import UPDATEQTY_FIELD from "@salesforce/schema/Document_Details__c.Update_Quantity__c";
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { refreshApex } from '@salesforce/apex';
 import { NavigationMixin } from 'lightning/navigation';
 import {loadStyle} from 'lightning/platformResourceLoader';
 import { CloseActionScreenEvent } from 'lightning/actions';
 //import COLORS from '@salesforce/resourceUrl/colors';
 // datatable columns
 const columns = [
    /*{    label: 'Checkbox', 
         //fieldName: '',
         type: 'text',
         fixedWidth: 18,
    }, 
     {
         label: 'PRODUCT NAME',
         fieldName: 'Product_Name__c',
         type: 'text',
     },*/
     {
        label: 'PRODUCT DESCRIPTION',
        fieldName: 'Product_Description__c',
        type: 'text',
        fixedWidth: 200,
    },
     {
         label: 'SKU',
         fieldName: 'DDSKU__c',
         type: 'text',
         fixedWidth: 150,
         
     },
     {
         label: 'UNIT PRICE',
         fieldName: 'unitPrice__c',
         type: 'Currency',
        
     },
     {
         label: 'TOTAL PRICE',
         fieldName: 'Total_Price__c',
         type: 'text',
        
     },
     {
         label: 'QUANTITY',
         fieldName: 'Quantity__c',
         type: 'Number',
         defaultContent: '',
         fixedWidth: 150,
         
     },
     {
         label: 'RETURN QUANTITY',
         fieldName: 'Update_Quantity__c',
         type: 'Number',
         editable: true,
         defaultContent: '',
         cellAttributes: { class: 'slds-theme_error slds-text-title_caps' },
       
     }  
 ];
 
export default class DocumentDetailFlowTableLWC extends NavigationMixin(LightningElement) {
    isModalOpen = false;

    @track checkBool;
    @track preSelectedRows = [];//preselect code
    isCssLoaded = false //table css
    @track isEdited = false;
    @track toggleSaveLabel = 'Save';
    @track myList=[];
@track UpdateQuantity;

@track displayScreenYes;
@track displayScreen1 = true; 
@track displayScreenNo;
@track totalBox;
@track totalweight;
@track totalpallet;
@track pickUpHrs;

     @api recordId;
     @track  valuePicklist = '';
     @track valueRadio = '';

     columns = columns;
     @track docDetailRec;
     @track recordid;
     @track unitPrice;
     @track Product_Name;
     @track Product;

     saveDraftValues = [];
     @api lstDocDetailFlowVar=[];
     @track lstDocDetailFlowVar2=[];
     @api lstDocDetailFlowVar3='';
     
     @track contacts =[];
     @track error;

     @track index;
     @track Values;
     @api SelectedValues = [];

     @api selectedContactIdList=[]; //added for multiselect
     currentSelectedRows = [];
     @track setID;
     
     
     //@wire(getDocDetails, {SOIds:'$lstDocDetailFlowVar3'})
    /* @wire(getDocDetails, {SOIds:'$recordId'})
     wiredContacts({data, error})
     {if(data){ 
        console.log('SOIds1-->',this.lstDocDetailFlowVar3); 
        console.log('Success-->',data);
        this.contacts = data;
        this.error = undefined;
        console.log('contatcts-->',this.contacts);
    }
        else if (error) {
            console.log('SOIds2-->',this.lstDocDetailFlowVar3); 
            console.log('error-->',error);
            this.error = error;
            this.contacts = undefined;}
        }
     */
        connectedCallback() {
            this.fetchData();
        }
        fetchData(){
            var updatedValues=[];
            getDocDetails({SOIds: this.recordId})
            .then(response => {
                console.log('response',response);
                const groups = JSON.parse(JSON.stringify(response));
               console.log('group',groups);
               for(let i=0; i<groups.length;i++){
               //console.log('group1',groups[i].Update_Quantity__c);
              
               updatedValues.push({
                ...groups[i],  Update_Quantity__c : '0'
              })
               }
               console.log('updatedValues',updatedValues);

               this.lstDocDetailFlowVar2 = updatedValues;
                //preselect code
            /// let my_ids = [];
            /// for( let i =0;i<lstDocDetailFlowVar2.length;i++ ){
            /// my_ids.push(this.lstDocDetailFlowVar2[i].Id);
                //my_ids.push(this.lstDocDetailFlowVar2[1].Id);
            /// }
             ///  this.preSelectedRows = my_ids;
                //console.log('preSelectedRows:' + this.preSelectedRows);
                //this.error = undefined;
                //preselect code end
            }).catch(error => {
                console.log('error', error)
            });
            console.log('this.lstDoc', this.recordId);
            console.log('this.lstDoc2'+this.lstDocDetailFlowVar2);

        }

    /*Datatable CSS
    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }*/

    renderedCallback() {
        console.log(this.isRendered);
        if (this.isRendered) {
            return; 
        }
        this.isRendered = true;
    
        let style = document.createElement('style');
        style.innerText = '.slds-th__action{background-color: #DCDCDC; color: #000000;}';
        this.template.querySelector('lightning-datatable').appendChild(style);
    }

     //for standard datatable handleSave
     handleSave1(event) {
    
       // console.log('DOc Detail ID lstDocDetailFlowVar-->',JSON.parse(JSON.stringify(this.lstDocDetailFlowVar)));
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        
        console.log('draftValue-->all',this.saveDraftValues);
        console.log('recordInputs-->all',recordInputs)////added for error check
       // console.log('recordInputs--->',recordInputs[0].fields.Quantity__c);//added for e
        this.checkBool = true;//added for validation check
        //added for validation check
        console.log('recordInputs Length-->',recordInputs.length);
        console.log('Length-->',this.lstDocDetailFlowVar2.length);
        for ( let i =0;i<this.lstDocDetailFlowVar2.length;i++ ) {
            for(let j =0;j<recordInputs.length;j++){
            //console.log('this.lstDocDetailFlowvar ',this.lstDocDetailFlowVar2[i].Id == recordInputs[i].fields.Id);
            
            console.log('1st condition ', this.lstDocDetailFlowVar2[i].Quantity__c); 
            console.log('2nd condition ', recordInputs[j].fields.Update_Quantity__c);
            console.log('this.lstDocDetailFlowVar2[i]',this.lstDocDetailFlowVar2[i].Id);
            console.log('recordInputs[i].fields.Id',recordInputs[j].fields.Id);
           if (this.lstDocDetailFlowVar2[i].Id == recordInputs[j].fields.Id ){
               console.log('Inside 123');
               //console.log('this.lstDocDetailFlowVar2[i].Quantity__c',this.lstDocDetailFlowVar2[i].Quantity__c);
               //console.log('recordInputs[i].fields.Id.Update_Quantity__c',recordInputs[i].fields.Update_Quantity__c);
           if ((this.lstDocDetailFlowVar2[i].Quantity__c)<(recordInputs[j].fields.Update_Quantity__c))
            {
              console.log('123 ');
                const evt = new ShowToastEvent({
                    message: 'Return Quantity can not be greater than actual Quantity.',
                    variant: 'error',
                });
                this.dispatchEvent( evt );
                this.checkBool = false;
                console.log('checkBool ',this.checkBool);
                break;
            }
        }
        }
        }
        if ( this.checkBool == true ) {
        // Updating the reco   rds using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        console.log('recordInputs-->all',recordInputs)
        console.log('recordInputs--->',recordInputs[0].fields.Update_Quantity__c);
        console.log('promises-->',promises);

        Promise.all(promises).then(res => {
            console.log('inside promise');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'
                })
            );
            this.saveDraftValues = [];
            console.log('this.lstDocDetailFlowVar2',this.lstDocDetailFlowVar2);
           
            for(let i =0;i<recordInputs.length;i++)
            {
                console.log('this.lstDocDetailFlowVar2[i].Update_Quantity__c '+this.lstDocDetailFlowVar2[i].Update_Quantity__c );
                console.log('recordInputs[i];',recordInputs[i].fields);
                if(this.lstDocDetailFlowVar2[i].Id== recordInputs[i].fields.Id){
                this.lstDocDetailFlowVar2[i].Update_Quantity__c= recordInputs[i].fields.Update_Quantity__c;
                }
                //this.contacts[i].Update_Quantity__c =recordInputs[i].fields.Update_Quantity__c;
                
                console.log('this.lstDocDetailFlowVar2',this.lstDocDetailFlowVar2);
            }
            return this.refresh();

        }).catch(error => {
            console.log('inside 1',error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An Error Occured!!',
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }//added for validation check
    }

 // This function is used to refresh the table once data updated
    async refresh() {
    console.log('refresh****',this.lstDocDetailFlowVar2);
    await refreshApex(this.lstDocDetailFlowVar2);
    //  await refreshApex(this.contacts);
    }
  
// back button navigation
navigateToBack() {
    console.log('Inside back');  
    if(this.valueRadio == 'Yes' || this.valueRadio == 'No'){
        this.displayScreen1=true;
        this.displayScreenYes = false;
        this.displayScreenNo = false;
    }             
    //this.reloadPage();
    // this.DisplaySelMissions();
}

navigateToViewSOPage() {
    console.log('Inside navigate back');
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'salesOrder__c',
            actionName: 'view'
        },
    });
}

closeModal() {
    // to close modal set isModalOpen tarck value as false
    console.log('Inside close');
    //this.isModalOpen = false;
    this.dispatchEvent(new CloseActionScreenEvent());
}

/*for HTML custom Table code
        handleUpdateQtyChange(event) {
            let element = this.contacts.find(ele  => ele.Id === event.target.dataset.id);
            element.Update_Quantity__c = event.target.value;
            this.contacts = [...this.contacts];
        }

        handleSave() {
            this.toggleSaveLabel = 'Saving...'
            let toSaveList = this.contacts;
            toSaveList.forEach((element, index) => {
                if(element.Update_Quantity__c === ''){
                    toSaveList.splice(index, 1);
                }
            });
    
            this.contacts = toSaveList;
            saveDocDetailsLwc({records : toSaveList})
            .then(() => {
                this.toggleSaveLabel = 'Saved';
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success',
                        message : `Records saved succesfully!`,
                        variant : 'success',
                    }),
                )
                this.fetchData();
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

        onDoubleClickEdit() {
            this.isEdited = true;
        }
    
        handleCancel() {
            this.isEdited = false;
        }*/
  

     showToast(title, message, variant) {
         console.log('showtoast');
         const evt = new ShowToastEvent({
             title: title,
             message: message,
             variant: variant,
         });
         this.dispatchEvent(evt);
     }

    getSelectedIdAction(event){
        console.log('inside event');
        const letters = new Set();
        let currentRows = event.detail.selectedRows;
        console.log('currentRows.length'+currentRows.length);
        for(let i=0;i<currentRows.length;i++){
            this.currentSelectedRows = currentRows;
            console.log(' this.currentSelectedRows ', this.currentSelectedRows[i].Id );
            letters.add( this.currentSelectedRows[i].Id);

        }
        console.log('letters',letters);
        this.setID =  [...letters]
        /*for(let i=0;i<currentRows.length;i++){
           // const first = [...set][0];
         this.setID =  [...letters][i];
        }*/
       
        console.log('set',this.setID);
        
        
       
       /* this.Values =  event.detail.selectedRow;

    if (event.target.checked) {
        this.SelectedValues.push( this.Values);
    } else {
        try {
            this.index = this.SelectedValues.indexOf( this.Values);
            this.SelectedValues.splice(this.index, 1);
        } catch (err) {
            //error message
        }
    }*/
    //alert('selected checkbox are : '+JSON.stringify(this.SelectedValues));
}

//For Picklist value
get options() {
    return [
        { label: 'DamagedProduct', value: 'DamagedProduct' },
        { label: 'Overage', value: 'Overage' },
        { label: 'Shortage', value: 'Shortage' },
    ];
}
handleChangePicklist(event) {
    this.valuePicklist = event.detail.value;
    console.log('Picklist ',this.valuePicklist);
}

//for radio button
get optionsRadio() {
    return [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
}

handleRadio(event) {
    this.valueRadio = event.detail.value;
    console.log('Radio ', this.valueRadio);
   /* this.displayScreen1= false;
    if(this.valueRadio == 'Yes'){
    this.displayScreenYes = true;
    console.log('Inside if');
    }
    else if(this.valueRadio == 'No'){
    this.displayScreenNo = true;
    console.log('Inside else');
    */
   // }
   // console.log('displayScreen ',displayScreen);
}

inputValueChange(event) {
    if(event.target.label=='Total Boxes for Return'){
        this.totalBox= event.target.value;
        console.log('totalBox',this.totalBox);
    }
    if(event.target.label=='Total Weight for boxes'){
        this.totalweight= event.target.value;
        console.log('totalweight',this.totalweight);
    }
    if(event.target.label=='Total Pallets'){
        this.totalpallet= event.target.value;
        console.log('totalpallet',this.totalpallet);
    }
    if(event.target.label=='Please provide pick-up hours'){
        this.pickUpHrs= event.target.value;
        console.log('pickUpHrs',this.pickUpHrs);
    }
}

handleCaseCreation(){
    createCase({SelectedValues: this.setID,recordId: this.recordId, PLvalue: this.valuePicklist, radioVal: this.valueRadio,totalBox: this.totalBox, totalweight: this.totalweight, totalpallet: this.totalpallet, pickUpHrs: this.pickUpHrs })
        .then(response => {
        console.log('Success ',response);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully!!',
                variant: 'success'
            })
        );
       // this.isModalOpen= false;//added for JTP-219
        this.navigateToViewSOPage();
        })
        .catch(error=>{
            console.log('Error ',error);
        })
    }
    
    handleNext(){
    this.displayScreen1= false;
    if(this.valueRadio == 'Yes'){
    this.displayScreenYes = true;
    console.log('Inside if');
    }
    else if(this.valueRadio == 'No'){
    this.displayScreenNo = true;
    console.log('Inside else');
    }
    }

}