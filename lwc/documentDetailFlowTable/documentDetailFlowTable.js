/**
 * Created by Pooja Gite on 11/10/2021.
 */
import { LightningElement, wire, track, api } from 'lwc';
//import getDocDetails from '@salesforce/apex/DetailDocDatatable.getDocDetails';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
// datatable columns
const columns = [
    
    {
        label: 'Product Name',
        fieldName: 'Product_Name__c',
        type: 'text',
        editable: false,
    }, 
    {
        label: 'SKU',
        fieldName: 'DDSKU__c',
        type: 'text',
    },
    {
        label: 'Product Description',
        fieldName: 'Product_Description__c',
        type: 'text',
    }, 
    {
        label: 'Unit Price',
        fieldName: 'unitPrice__c',
        type: 'Currency',
        editable: false
    },
    {
        label: 'Total Price',
        fieldName: 'Total_Price__c',
        type: 'text',
    },
    {
        label: 'CreatedDate',
        fieldName: 'CreatedDate',
        type: 'text',
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity__c',
        type: 'Number',
        editable: false
    },
    {
        label: 'Return Quantity',
        fieldName: 'Update_Quantity__c',
        type: 'Number',
        editable: true,
        class : "POdataTable",
        cellAttributes: { class: 'slds-theme_error slds-text-title_caps' }
    }

    
];

export default class DocumentDetailFlowTable extends LightningElement {
   
    columns = columns;
    @track docDetailRec;
    @track recordid;
    @track unitPrice;
    @track Product_Name;
    @track Product;
    saveDraftValues = [];
    @api lstDocDetailFlowVar=[];
    @track lstDocDetailFlowVar2=[];
    
    connectedCallback() {
        this.fetchData();
    }
    fetchData(){
        const p =JSON.parse(JSON.stringify(this.lstDocDetailFlowVar));
        this.lstDocDetailFlowVar2= p;
        console.log('p==>',p);
        for(var i=0; i <p.length ; i++) {
            this.recordid=p[i].Id;
            this.unitPrice = p[i].unitPrice__c;
            this.Product= p[i].Product__c;
            this.Product_Name=p[i].Product_Name__c;
        }
        console.log('this.lstDoc', this.recordid);
        console.log('this.lstDoc2'+this.lstDocDetailFlowVar2);
    }
    // from flow to lwc through property in XML
  /* @wire(getDetailDoc)//,{lstDocDetails:JSON.parse(JSON.stringify(this.lstDocDetailFlowVar))})
    const(result) {
        this.docDetailRec = result; 
        console.log('DOc Detail ID-->',result);
         console.log('DOc Detail ID lstDocDetailFlowVar-->',JSON.parse(JSON.stringify(this.lstDocDetailFlowVar)));
        if (result.error) {
            this.docDetailRec = undefined;
        }
    };
*/
    handleSave(event) {
        
        console.log('DOc Detail ID lstDocDetailFlowVar-->',JSON.parse(JSON.stringify(this.lstDocDetailFlowVar)));
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        console.log('recordInputs-->all',recordInputs)
        console.log('recordInputs--->',recordInputs[0].fields.Update_Quantity__c);
        console.log('promises-->',promises);
        /*console.log('lstDocDetailFlowVar',this.lstDocDetailFlowVar2);
        console.log('this.doc'.this.docDetailRec);
         getDetailDoc({lstDocDetails: JSON.parse(JSON.stringify(this.lstDocDetailFlowVar))})
            .then(result => {
                this.docDetailRec = result; 
                console.log('DOc Detail ID-->',result);
            // on success, you can bind to a tracked vars to re-render them
            console.log('getDetailDoc-->', this.docDetailRec);
            })
            .catch(error => {
            console.log(error);
            });*/

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
            for(let i =0;i<recordInputs.length;i++)
            {
                if(this.lstDocDetailFlowVar2[i].Id== recordInputs[i].fields.Id)
                this.lstDocDetailFlowVar2[i].Update_Quantity__c =recordInputs[i].fields.Update_Quantity__c;
            }
            //this.lstDocDetailFlowVar2[0].Update_Quantity__c =recordInputs[0].fields.Update_Quantity__c;
            console.log('this.lstDocDetailFlowVar2[0].Update_Quantity__c',this.lstDocDetailFlowVar2[0].Update_Quantity__c);
            /*getDocDetails({recordid: this.recordid })
            .then(response => {
                     const p2 = response;
                    console.log('p2',p2);
                    this.lstDocDetailFlowVar2= p2;
                    console.log('2__',this.lstDocDetailFlowVar2);
                }).catch(err => {
                    console.log('error', err)
                    this.showToast('ERROR', err.body.message, 'error');
                });*/
            
            return this.refresh();
           

        }).catch(error => {
            console.log('inside 1');
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

    }

    // This function is used to refresh the table once data updated
    async refresh() {
        console.log('refresh****',this.lstDocDetailFlowVar2);
        await refreshApex(this.lstDocDetailFlowVar2);
    }
    showToast(title, message, variant) {
        console.log('showtoast');
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}