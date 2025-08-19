import { LightningElement,api,track } from 'lwc';
import getResults from '@salesforce/apex/PhotoLibraryHelper.getResults';
import getRecordsNames from '@salesforce/apex/FilterPhotoLibrary.getRecordsNames';

export default class MultiCustomLookupSearch extends LightningElement {
    @api objectName = 'Account';
    @api fieldName = 'Name';
    @api label;
    @api helpText;
    @track searchRecords = [];
    @api selectedMineRecords = [];
    @track selectedRecords = [];
    @api required = false;
    @track ultimateParent = false;
    @api iconName = 'utility:record_lookup'
    @track refreshIcon = 'utility:refresh'
    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @api fieldapiname = "";
    @api selectedvalues;
    @track dropdownList = false;
    @track myselectrec = [];
    @track icon = true;


   /* renderedCallback() {
        let mytempar = [];
    mytempar=  this.selectedvalues;
    console.log('Entered into lookup rerender method'+mytempar.length + mytempar);
    var domino = [];
    if(mytempar !== undefined && mytempar.length > 0){
    domino = mytempar[0];
    console.log('LENGTH OF ARRAY IS in LOOKUP:::::'+ domino.length);
      for(var mop = 0; mop<domino.length;mop++){
     // motto = mypot.split(',');
        console.log('new variable value is VIRU VIRU LOOKUP'+domino[mop]);
        let newsObject = { 'recId' : domino[mop] ,'recName' : '' };
        
      //  myselectrec = [...this.selectedRecords,newsObject];
       // this.myselectrec.push(newsObject);
       // this.selectedRecords = myselectrec;
     }
     //this.myfieldo(myselectrec);

    }
    }*/

    connectedCallback() {
        // console.log('MULTI CUSTOM LOOKUP connectedcall back called Successfully');
        this.modifychildomethod();
        if(this.label === 'Search by Ultimate Parent Account'|| this.label === 'Search by Account KAM' || this.label === 'Search by Door Owner'){
            this.ultimateParent = true;
        }
        if (this.label === 'Campaign Name') {
            this.icon = false;
        }else{
            this.icon = true;
        }

        console.log('this.ultimateParent '+this.ultimateParent+' label '+this.label);
    }
    // _flag =false;
    // handleMouseOut(){
    //     if(this._flag){
    //         this.dropdownList = false;
    //     }
    //     this._flag =false;
    // }
    // handlemouseOver(){
    //     this.dropdownList = true;
    //     this._flag =true;
    // }
    // handledropdown(){
    //     if(this._flag){
    //         this.dropdownList = false;
    //     }
    //     this._flag =false;
    // }
 @track searchVal ='';
    searchField(event) {
       
        const inputElement = event.target;
        console.log(' value '+event.target.value);
        // console.log('searching '+this.fieldName+' ObjectName '+this.objectName+' fieldapiname '+this.fieldapiname);
        let currentText = '';
        if(this.fieldapiname === 'Ultimate_Parent_Account__c'){
            this.fieldName = 'Ultimate_Parent_Account__c';
            // console.log('fieldName '+this.fieldName);
        }
        if(this.label === 'Search by Door Owner' || this.label ==='Search by Ultimate Parent Account' || this.label === 'Search by Account KAM'){
            if(event.target.value.length >= 3){
                this.dropdownList = true;
                currentText = event.target.value;
                this.searchVal = currentText;
                inputElement.setCustomValidity('');
                inputElement.reportValidity();
            }else if(event.target.value.length <= 1){
                inputElement.setCustomValidity('Enter atleast 3 characters.');
                inputElement.reportValidity();
            }
           
        }else{
            currentText = event.target.value;
        }
        var selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            selectRecId.push(this.selectedRecords[i].recId);
        }
    //    console.log('fieldName111 '+this.label);
    //         console.log('this.objectName '+this.objectName);
        this.LoadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId : selectRecId ,label:this.label})
        .then(result => {
            // console.log('fieldName111 '+this.fieldName);
            // console.log('result '+JSON.stringify(result));

            this.searchRecords= result;
            if(this.searchRecords.length >0){
                this.dropdownList = true;
            }else{
                this.dropdownList = false;
            }
            console.log(' this.searchRecords '+JSON.stringify(this.searchRecords));
            this.LoadingText = false;
            
            this.txtclassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.error('-------error-------------'+error);
            console.error(error);
        });
        
    }
   
   setSelectedRecord(event) {
        var recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        let newsObject = { 'recId' : recId ,'recName' : selectName };
        this.selectedRecords.push(newsObject);
        this.txtclassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        let selRecords = this.selectedRecords;
		this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
       // const selectedEvent = new CustomEvent('selected', { detail: {selRecords} });
       const selectedEvent = new CustomEvent('selected', { detail: {selRecords,  fieldAPI: this.fieldapiname}});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.dropdownList = false;
    }

    removeRecord (event){
        let selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            if(event.detail.name !== this.selectedRecords[i].recId)
                selectRecId.push(this.selectedRecords[i]);
        }
        this.selectedRecords = [...selectRecId];
        let selRecords = this.selectedRecords;
       // COMMENTED BY VIREN const selectedEvent = new CustomEvent('selected', { detail: {selRecords}});
      // const selectedEvent = new CustomEvent('selected', { detail: {selRecords}, fieldAPI: this.fieldapiname});
      const selectedEvent = new CustomEvent('selected', { detail: {selRecords,  fieldAPI: this.fieldapiname}});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    modifychildomethod(){
        let mytempar = [];
        this.selectedRecords = [];
        mytempar=  this.selectedvalues;
        console.log('Entered into lookup rerender method'+this.selectedvalues);
        var domino = [];
        if(mytempar !== undefined && mytempar.length > 0){
            // console.log('ENtered inot method here is Object PAI name'+this.objectName);
            // console.log('ENtered inot method here is Records Ids are'+mytempar);

            getRecordsNames({ objectAPIName: this.objectName, recordsIds: mytempar })
            .then(result => {
                let ownResult = result;
                for(let fer=0; fer<ownResult.length;fer++){

                }
                // console.log('FINAL RESULT OF APEX SOQL DYNAMIC'+ ownResult + JSON.stringify(ownResult) + typeof ownResult);
          for(var mop = 0; mop< mytempar.length;mop++){
            // console.log('new variable value is VIRU VIRU LOOKUP'+domino[mop]);
            let myrecName = '';
            myrecName = this.localSearch(mytempar[mop],ownResult);
            // console.log('Final value name of record+++'+ myrecName);
            let newsObject = { 'recId' : mytempar[mop] ,'recName' : myrecName };
          //  myselectrec = [...this.selectedRecords,newsObject];
            this.selectedRecords.push(newsObject);
           // this.selectedRecords = myselectrec;        
            }
        })
        .catch(error => {
                console.error('-------error-------------'+error);
                console.error(error);
            });
        }
    }

     localSearch(nameKey, myArray){
        for (var i=0; i < myArray.length; i++) {
            if (myArray[i].Id === nameKey) {
                return myArray[i].Name;
            }
        }
    }
}