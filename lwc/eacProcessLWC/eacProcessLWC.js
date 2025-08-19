/**
 * Created by Pooja Gite.
 */
 import { LightningElement, wire, track, api } from 'lwc';
 import getAccounts from '@salesforce/apex/EACProcessController.getAccounts';
 //import createCase from '@salesforce/apex/fetchDocumentDetails.createCase';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { refreshApex } from '@salesforce/apex';
 import { NavigationMixin } from 'lightning/navigation';
 import {loadStyle} from 'lightning/platformResourceLoader';
 import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
} from 'lightning/flowSupport';
 import updateAccount from '@salesforce/apex/EACProcessController.updateAccount';
 // datatable columns
 const columns = [
     {
        label: 'Account Name',
        fieldName: 'Name',
        type: 'text'
    },
     {
         label: 'Chain Expansion',
         fieldName: 'Chain_Expansion__c',
         type: 'picklist'
     },
     {
         label: 'Last Parent Account Update',
         fieldName: 'Last_Parent_Account_Update__c',
         type: 'date'
     }  
 ];
 
export default class EACProcessLWC extends NavigationMixin(LightningElement) {
    isModalOpen = false;

    @api AccIDs=[];
    @api ListAccIdLWCtoFlow=[];
    @api AccString;
    @track accIDstoApex;
    @track updateButton = true;

    @track checkBool;
    @track preSelectedRows = [];//preselect code
    isCssLoaded = false //table css
    @track isEdited = false;
    @track toggleSaveLabel = 'Save';
    @track myList=[];


    @api recordId;
   
     columns = columns;
     @track docDetailRec;
     //@track recordid;
     @track unitPrice;
     @track Product_Name;
     @track Product;

     saveDraftValues = [];
     @api lstDocDetailFlowVar=[];
     @track lstDocDetailFlowVar2=[];
     @api lstDocDetailFlowVar3;
     
     @track contacts =[];
     @track error;

     @track index;
     @track Values;
     @api SelectedValues = [];

     @api selectedContactIdList=[]; //added for multiselect
     currentSelectedRows = [];
     @track setID;
    @track dummyAccStr;

     @api isSelectedAccountMA=false; //
     @api isSelectedAccountNewConstr=false; //
    @api selectedDoorAccountIdList;
    @api selectedDoorAccountList =new Set();;
  //  ShowBtnNewCon = false;
    //ShowBtnMnA=true;
   @api  selectedAccountIdList=[];
   @api    myRecordId;
     @wire(getAccounts, {SOIds:'$lstDocDetailFlowVar3'})
     wireAccounts({data, error})
     {if(data){ 
        console.log('SOIds-->',this.lstDocDetailFlowVar3); 
        console.log('Success-->',data);
        this.contacts = data;
        this.error = undefined;
        console.log('contatcts-->',this.contacts);
    }
        else if(error) {
            this.error = error;
            this.contacts = undefined;
            console.log('Error msg-->',error);
        
        }
            
        }
     
        connectedCallback() {
           // this.fetchData();
        }

        fetchData(){
            getAccounts()
            .then(response => {
                const groups = JSON.parse(JSON.stringify(response));
                console.log('Success',response);
            }).catch(error => {
                console.log('error', error)
            });
        }
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

    getSelectedIdAction(event){
        console.log('inside event');
        const letters = new Set();
        const cexp= new Set();
       
        let currentRows = event.detail.selectedRows;

       
        console.log('currentRows.length'+currentRows.length);
        this.isSelectedAccountMA = false;
        this.isSelectedAccountNewConstr = false;
        for(let i=0;i<currentRows.length;i++){
            this.currentSelectedRows = currentRows;

            this.selectedDoorAccountList.add(this.currentSelectedRows[i]);
           // console.log(' this.currentSelectedRows ', this.currentSelectedRows[i] );
            letters.add( this.currentSelectedRows[i].Id);
            if(i==0)
            this.dummyAccStr=this.currentSelectedRows[i].Id;
            else
            this.dummyAccStr=this.dummyAccStr+'XXX'+this.currentSelectedRows[i].Id;

            cexp.add( this.currentSelectedRows[i].Chain_Expansion__c);
            //console.log(' this.currentSelectedRows Chain expension',this.currentSelectedRows[i].Chain_Expansion__c  );
        
            if(this.currentSelectedRows[i].Chain_Expansion__c=='M&A')
            {
            this.isSelectedAccountMA=true;

            console.log('isSelectedAccountMA->-',this.isSelectedAccountMA);
        }
        else
         {
            if(this.currentSelectedRows[i].Chain_Expansion__c=='New Construction')
            this.isSelectedAccountNewConstr=true;
          //  this.ShowBtnNewCon = true;
            //this.ShowBtnMnA=false
            console.log('isSelectedAccountNewConstr-->',this.isSelectedAccountNewConstr);
        
         }
        }
     //   console.log('selectedAccountIdList',cexp);
       //  console.log('letters',letters);
       //  console.log('isSelectedAccountMA',this.isSelectedAccountMA);

        this.setID =  [...letters]   
        this.ListAccIdLWCtoFlow = this.setID;
        this.AccString = JSON.parse(JSON.stringify(this.setID));
        this.accIDstoApex = this.setID;
console.log('ListAccIdLWCtoFlow :'+this.dummyAccStr);

//console.log('selectedDoorAccountList obj::'+this.selectedDoorAccountList);
        this.updateButton = false;


        if(letters.size> 0   &&  (            
            
            ( this.isSelectedAccountMA==true  &&  this.isSelectedAccountNewConstr==true ) )
            ){
        this.updateButton = true;
        console.log('updateButton-->',this.updateButton);
        }
        else if (

            letters.size> 0   &&  (
            
                ( this.isSelectedAccountMA==true  &&  this.isSelectedAccountNewConstr==false )  ||
    
                ( this.isSelectedAccountMA==false  &&  this.isSelectedAccountNewConstr==true )
            )  
        )
        {
            this.updateButton = false;
        }
        if(letters.size<= 0){
            this.updateButton = true;
            console.log('updateButton 1-->',this.updateButton);
        }
        

        const attributeChangeEvent = new FlowAttributeChangeEvent('isSelectedAccountMA', this.isSelectedAccountMA);
             this.dispatchEvent(attributeChangeEvent); 

             const attributeChangeEvent2 = new FlowAttributeChangeEvent('isSelectedAccountNewConstr', this.isSelectedAccountNewConstr);
             this.dispatchEvent(attributeChangeEvent2); 

           const attributeChangeEvent3 = new FlowAttributeChangeEvent('selectedDoorAccountIdList', this.dummyAccStr   );
             this.dispatchEvent(attributeChangeEvent3); 

            // const attributeChangeEvent4 = new FlowAttributeChangeEvent('selectedAccountIdList', this.letters   );
            // this.dispatchEvent(attributeChangeEvent4); 

          

             console.log('AccString-->',this.AccString);
        console.log('AccIDs-->',this.AccIDs);
        console.log('set',this.setID);
    }
    handleSave(event)
    {
        console.log('inside HandleSave');
        updateAccount({SetIDs:this.accIDstoApex})
        .then(response => {
          console.log('Success',response);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'

                
                })
            );
            this.handleNext();
        }).catch(error => {
            console.log('error', error);
        });
        
    }
    handleCaseCreation(){
    createCase({SelectedValues: this.setID,recordId: this.recordId, PLvalue: this.valuePivaluePicklistcklist, radioVal: this.valueRadio,totalBox: this.totalBox, totalweight: this.totalweight, totalpallet: this.totalpallet, pickUpHrs: this.pickUpHrs })
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


       if(this.isSelectedAccountNewConstr)
       {
        updateAccount({SetIDs:this.accIDstoApex})
        .then(response => {
          console.log('Success',response);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'

                
                })
            );
           
        }).catch(error => {
            console.log('error', error);
        });

        const navigateNext= new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNext);
        
      }
       else{
        const navigateNext= new FlowNavigationNextEvent();
       this.dispatchEvent(navigateNext);
       }
      //  this.showUploadComponent=true;

    }
   
}