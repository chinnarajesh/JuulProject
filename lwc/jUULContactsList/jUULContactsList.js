// import module elements
import { LightningElement,
    wire,
    track } from 'lwc';

//import method from the Apex Class
 import fetchJUULContacts from '@salesforce/apex/JUULContactListCtrl.fetchJUULContacts';
 //import getRegions from '@salesforce/apex/JUULContactListCtrl.getRegions';
  


// Declaring the columns in the datatable
const columns = [
    {
        label: 'Name',
        fieldName: 'Name'
    },
    {
        label: 'Title',
        fieldName: 'Title'
    },
    {
        label: 'Region',
        fieldName: 'Region__c'
    },
    {
        label: 'Email',
        fieldName: 'Email'
    },
    {
        label: 'Phone',
        fieldName: 'Phone'
    }
];

//let i=0;

// declare class to expose the component
export default class JUULContactsList extends LightningElement {
    
    @track items = []; //this will hold key, value pair
    @track value = ''; //initialize combo box value

    @track columns = columns;
    @track record = {};
    @track rowOffset = 0;
    @track data = {};
    @track allContacts=[];

    @track chosenValue = '';

    @wire(fetchJUULContacts, {region: ''}) 
    parameters
    ({ error, data }) {
        
        if (data) {
            this.allContacts = data;
            /* eslint-disable no-console */
            // eslint-disable-next-line no-console
            console.log('---data----'+ this.data) ;           
            this.error = undefined;
        } else if (error) {
            this.error = error;
            //this.contacts = undefined;
        }
    }
 
    // Row Action event to show the details of the record
    handleRowAction(event) {
        const row = event.detail.row;
        this.record = row;
        
    }

    

   

    //gettter to return items which is mapped with options attribute
    get regionOptions() {

        return [
            { label: '', value: '' },
            { label: 'Mountain', value: 'Mountain' },
            { label: 'NorCal/Nevada', value: 'NorCal/Nevada' },
            { label: 'So Cal', value: 'So Cal' },
            { label: 'Pac NW', value: 'Pac NW' },
            { label: 'Arizona', value: 'Arizona' },
            { label: 'Pacific (CA & Nevada)', value: 'Pacific (CA & Nevada)' },
            { label: 'LA Metro North', value: 'LA Metro North' },
            { label: 'East LA County', value: 'East LA County' },
            { label: 'Orange County', value: 'Orange County' },
            { label: 'IE/Palm Desert', value: 'IE/Palm Desert' },
            { label: 'San Diego County', value: 'San Diego County' },
            { label: 'Las Vegas', value: 'Las Vegas' },
            { label: 'LA Coastal/South Bay', value: 'LA Coastal/South Bay' },
            { label: 'NorCal', value: 'NorCal' },
            { label: 'SF Metro', value: 'SF Metro' },
            { label: 'Sacramento-North State', value: 'Sacramento-North State' },
            { label: 'East Bay', value: 'East Bay' },
            { label: 'Fresno/Bakersfield/Central Valley', value: 'Fresno/Bakersfield/Central Valley' },
            { label: 'Oregon, Washington, Hawaii, Alaska', value: 'Oregon, Washington, Hawaii, Alaska' },
            { label: 'Washington', value: 'Washington' },
            { label: 'Hawaii', value: 'Hawaii' },
            { label: 'Washington', value: 'Washington' },
            { label: 'Idaho, Montana', value: 'Idaho, Montana' },
            { label: 'Oregon (Portland and North OR)', value: 'Oregon (Portland and North OR)' },
            { label: 'Oregon (South OR)', value: 'Oregon (South OR)' },
            { label: 'Colorado - North/E. Wyoming', value: 'Colorado - North/E. Wyoming' },
            { label: 'Colorado - South', value: 'Colorado - South' },
            { label: 'Utah/W Wyoming', value: 'Utah/W Wyoming' },
            { label: 'Arizona - Northwest', value: 'Arizona - Northwest' },
            { label: 'Arizona - Southeast', value: 'Arizona - Southeast' },
        ];
        /* eslint-disable no-console */
        // eslint-disable-next-line no-console
        //console.log('---Item----'+ this.items) ;
        //return this.items;
    }

    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        const selectedOption = event.detail.value;
        //console.log('selected value=' + selectedOption);
        this.chosenValue = selectedOption;
         /* eslint-disable no-console */
        // eslint-disable-next-line no-console
        console.log('---this.chosenValue----'+ this.chosenValue) ;

        fetchJUULContacts({region: this.chosenValue})
            .then(result => {
                this.allContacts = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.allContacts = undefined;
            });
    }

    //this value will be shown as selected value of combobox item
    get selectedValue(){
        return this.chosenValue;
    }

    get allContacts() {
        return this.allContacts;
    }
    
}