/**
 * Created by Pooja Gite on 11/10/2021.
 */
import { LightningElement, track, api } from 'lwc';
import getSalesOrder from '@salesforce/apex/SalesOrderController.getSalesOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: '', fieldName: ''},
    { label: 'Name', fieldName: 'Name' },
    { label: 'Customer PO Number', fieldName: 'Customer_PO_Number__c', type: 'text' },
    { label: 'Order Date', fieldName: 'Order_Date__c', type: 'date' },
    { label: 'Order Total', fieldName: 'orderTotal__c', type: 'currency' }
];

export default class SalesOrderDatatable extends LightningElement {
    @track data = [];
    @track columns = columns;
    @track Missions;
    @track selectedSO;
    @api SOrecordIds;
    @api accIdFlow;

    async connectedCallback() {
        this.fetchData();
         this.reload = true;

    } 

    fetchData() {
                        getSalesOrder({accId:this.accIdFlow}).then(response => {
                        this.Missions = response;
                        console.log('Mission',this.Missions);
                            })
                            .catch(err => {
                                console.log('error', err)
                              //  this.showToast('ERROR', err.body.message, 'error');
                            });
                    
                }
    handleValuesSelect(event) {
                    //const selectedValue = e.target.value;
                    this.selectedSO = event.target.value;
                    this.SOrecordIds= this.selectedSO;
                    //alert("The selected Accout id is-->" +this.selectedSO);
                }            

}