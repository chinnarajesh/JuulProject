import { LightningElement, api, wire, track } from 'lwc';

import getPricingDetails from '@salesforce/apex/KAMUpdatePricingMatriceController.getPricingDetails'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getStateDetails from '@salesforce/apex/KAMUpdatePricingMatriceController.getStateDetails'
import saveData from '@salesforce/apex/KAMUpdatePricingMatriceController.saveData'
//import { refreshApex } from '@salesforce/apex';


export default class KamNewPricingMatrix extends LightningElement {
    @api recordId;
    @track data;
    @track updatedData = [];
    @track error;
    @track selectedProducts = [];
    @track showFields;
    @track selId;
    @track stateDetail;
    @track productId;
    @track pricingWrapper;
    @track allSelected;
    @track disableStartEndDate = false;
    @track isAllSelected = false;
    @track allData = [];
    @track sDate;
    @track eDate;
    @track errorMessage;
    @track errorMessageList = [];
    @track allChecked;
    @track showErrorMessage = false;
   
    
    //To close the error message
    closeModel() {
        this.showErrorMessage = false;
	}
    //To get all the details of pricing matrix
    @wire(getPricingDetails, {stateId:'$recordId'})
    if(result){
        this.data = result.data;    //get the wrapper here 
        this.error = undefined;  
        console.log('result1111-->'+JSON.stringify(result.data));
        console.log('result11-->',this.data);
    }
    //console.log('result-->',this.data);
    
    /*
    *CREATED BY : SUBODH SHUKLA
    *DESCRIPTION : Onclick of selectAll checkbox to create the data
    *LAST MODIFIED BY :  
    */ 
    /*magicStartDate(event){
        let selectedDateType = event.target.type;
        this.sDate = event.target.value;
        console.log('sDtae-->',this.sDate);

    }
    magicEndDate(event){
        let selectedDateType = event.target.type;
        this.eDate = event.target.value;
        console.log('eDate-->',this.eDate);
    }*/

   selectAll(event){
       //alert('event.target.'+event.target.type);
       if(event.target.type === 'checkbox'){
           if(event.target.checked){
            this.isAllSelected = true;
           }
           else{
            this.isAllSelected = false;
           }
       }
      
       
       this.disableStartEndDate = false;
       
       console.log('this....disableStartEndDate--------------->', this.disableStartEndDate);
       console.log('isAllSelected--this-=111====>', this.isAllSelected);
       let allRecords = [];
     console.log('inside select all--');
       let allSelected = this.template.querySelectorAll('lightning-input');
       for(let i=0; i< allSelected.length; i++){
           if(allSelected[i].type === 'checkbox'){
               console.log('event.target.checked'+event.target.checked);
               //allSelected[i].checked = event.target.checked;              
               allSelected[i].checked = this.isAllSelected;   
            }
        }
        if(event.target.name === 'startDateAll'){
            let selectedDateType = event.target.type;
            this.sDate = event.target.value;
            console.log('sDtae-->',this.sDate);
        }
        if(event.target.name === 'endDateAll'){
            let selectedDateType = event.target.type;
            this.eDate = event.target.value;
            console.log('eDate-->',this.eDate);
        }
        if(event.target.type === 'checkbox') {
            this.allChecked = this.isAllSelected;
            console.log('allChecked-->',this.allChecked);
        }
        if(this.allChecked == false){
            console.log('allChecked-inside if cond->',this.allChecked);
            this.disableStartEndDate = false;
           }
           else{
            this.disableStartEndDate = true;
           }
           

        if(this.allChecked == true){
            console.log('inside condtn--->');
            this.allData = [];
            //this.disableStartEndDate = true;
            for(let j = 0; j < this.data.length;j++) {
                    if(this.isAllSelected = true){
                        this.allRecords = JSON.parse(JSON.stringify(this.data[j]));
                        console.log('this.allRecords--->'+JSON.stringify(this.allRecords));
                        console.log('sDtae- inside->',this.sDate);
                        console.log('eDate-inside->',this.eDate);
                        console.log('allChecked--inside--->',this.allChecked);                        

                        this.allRecords.allStartDate = this.sDate;
                        this.allRecords.allEndDate = this.eDate;
                        this.allRecords.isAllSelected = true;
                        this.allRecords.isSelected = true;
                        this.allData.push(this.allRecords);     
                        console.log('this.allData--->'+JSON.stringify(this.allData));
                   }
                }   
                //isUpated =true;
                this.updatedData = this.allData;
                console.log('updatedData checked--->'+JSON.stringify(this.updatedData));
            }  
            else{
            this.updatedData = [];
            }
           //console.log('result on select all-->'+JSON.stringify(this.data));             
       // this.allData.push(this.allRecords);
       console.log('allData Json data--->'+JSON.stringify(this.allData));
   }

    handleSave(){
        this.selId =[];
        this.pricingWrapper = {};
        this.pricingWrapperList = [];
        var isDateValid = false;
        var isStartDate = false;
        var isDatesBlank = false;
        var isEndDate = false;
        var isAllDataBlank = false;
        console.log('this.data- on saveee->'+JSON.stringify(this.data));
        console.log('this.updatedData- on saveee->'+JSON.stringify(this.updatedData));
        
        if(this.updatedData !== null && this.updatedData !== undefined && this.updatedData.length > 0){
            for(var i = 0; i< this.updatedData.length; i++ ){
                console.log('this.updatedData[i]--->'+JSON.stringify(this.updatedData[i]));
                if((this.updatedData[i].startDate > this.updatedData[i].endDate) || (this.updatedData[i].allStartDate > this.updatedData[i].allEndDate)){ 
                    console.log('inside if--');
                    isDateValid = true;
                    break;
                }
            }
        }
    
        isStartDate = false;
        isDatesBlank = false;
        isEndDate = false;
        if(this.updatedData !== null && this.updatedData !== undefined && this.updatedData.length > 0){
            for(var i = 0; i< this.updatedData.length; i++ ){
                console.log('this.updatedData[i].allStartDate '+this.updatedData[i].allStartDate );
                if((this.updatedData[i].allStartDate === null || this.updatedData[i].allStartDate === undefined) && (this.updatedData[i].allEndDate === null || this.updatedData[i].allEndDate === undefined) && this.updatedData[i].isAllSelected){
                    isDatesBlank = true;
                    break;
                }
                if((this.updatedData[i].allStartDate === null || this.updatedData[i].allStartDate === undefined) && this.updatedData[i].isAllSelected ){
                    isStartDate = true;
                    break;
                }
                console.log('this.updatedData[i].allEndDate '+this.updatedData[i].allEndDate );
                if((this.updatedData[i].allEndDate === null || this.updatedData[i].allEndDate === undefined) && this.updatedData[i].isAllSelected){
                    isEndDate = true;
                    break;
                }   

                if(this.updatedData[i].isSelected === true && (this.updatedData[i].startDate === null || this.updatedData[i].startDate === undefined ) && (this.updatedData[i].endDate === null || this.updatedData[i].endDate === undefined) && (this.updatedData[i].isAllSelected == null)){
                    isDatesBlank = true;
                    break;
                }
                if(this.updatedData[i].isSelected === true && (this.updatedData[i].startDate === null || this.updatedData[i].startDate === undefined ) && (this.updatedData[i].isAllSelected == null)){
                    isStartDate = true;
                    break;
                }   
                if(this.updatedData[i].isSelected === true && (this.updatedData[i].endDate === null || this.updatedData[i].endDate === undefined ) && (this.updatedData[i].isAllSelected == null)){
                    isEndDate = true;
                    break;
                }         
            }
        }else{           
                isAllDataBlank = true;
                this.showToast("Error!", 'Please select products' , "error");
        }

        if(isDatesBlank){
            this.showToast("Error!", 'Start Date & End Date cannot be blank' , "error");
        }
        
        if(isStartDate){
            this.showToast("Error!", 'Start Date cannot be blank' , "error");
        }

        if(isEndDate){
            this.showToast("Error!", 'End Date cannot be blank' , "error");
        }

        if(isDateValid){
            this.showErrorMessage = false;
            this.showToast("Error!", 'Start date should be less than end date' , "error");
        }

        if(!isDateValid &&  !isEndDate && !isStartDate && !isDatesBlank && !isAllDataBlank){ 
           // if(this.updatedData[i].startDate != null && this.updatedData[i].endDate != null && this.updatedData[i].isSelected ==true){

               //  console.log('inside if save..');     
                //Added by subodh for saving procing matrix data
                saveData({wrapperList : this.updatedData})         
                    .then(response => {
                        let errmessage='';
                        this.errorMessageList = [];
                        if(response.length>0){
                            let errorId = '';
                            
                            this.showErrorMessage = true;
                            errmessage='Pricing Matrix with that Start And End Date already exist OR Pricing Matrix records already exist within this Start And End Date For:;                        ';
                            for(var index=0;index < response.length ; index++){
                                //errorId =errorId + ', ' + response[index].productName;
                                this.errorMessageList.push({
                                    'key':response[index],
                                    'value': response[index].productName
                                });
                            }
                            this.errorMessage = errmessage;
                        }else{
                            this.showErrorMessage = false;
                            this.showToast("Success", 'Pricing matrices record created successfully.','success');
                            this.closeModal();
                        }
                    
                    }) 
                .catch(error => {
                    this.showErrorMessage = false;
                    console.log('error.body-->'+JSON.stringify(error));
                this.showToast("Error!", error.body.message , "error");
                });
           // }
           // else{
               // this.showToast("Error!", 'Fill Start Date and End Date' , "error");
           // }
        }
    /*else{
        this.showErrorMessage = false;
        this.showToast("Error!", 'Start date should be less than end date' , "error");
    } */       
    }

    closeModal() {
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }

    /*
    *CREATED BY : SUBODH SHUKLA
    *DESCRIPTION :
    *LAST MODIFIED BY :  
    */
    handleChange(event){
        debugger;
        //this.disableStartEndDate = false;
        //refreshApex(this.seletedPricingValue);

        console.log('disableStartEndDate-->', this.disableStartEndDate);        
        this.isAllSelected = false;
        var newObjData;
        var selectedpricingID = event.target.dataset.id; //here getting the selected pricing matrix id
        var seletedPricingType = event.target.type;      //here getting the selected pricing matrix type
        var seletedPricingValue = event.target.value;    //here getting the selected pricing matrix start date or end date

        if(seletedPricingType === 'date' || seletedPricingType === 'checkbox') {
            for(let index = 0; index < this.data.length;index++) {
                console.log('seletedPricingValue**'+seletedPricingValue);
                console.log('event.target.checked**'+event.target.checked);
                //here getting the data for selected row
                if(this.data[index].pricingMatrixId === selectedpricingID && ((seletedPricingValue !== '' && seletedPricingValue !== null && seletedPricingValue !== undefined) || (event.target.checked !== '' && event.target.checked !== null && event.target.checked !== undefined) )){
                    newObjData = {};
                    let isDataUpdated = false;
                    if(this.updatedData !== undefined && this.updatedData.length > 0){
                        for(var updateDataIndex = 0; updateDataIndex < this.updatedData.length ; updateDataIndex++){
                            if(this.updatedData[updateDataIndex].pricingMatrixId === selectedpricingID){
                                let isUpdate = false;
                                newObjData =JSON.parse(JSON.stringify(this.updatedData[updateDataIndex]))
                                console.log('newObjData-->',this.newObjData);
                                console.log('newObjData json-->',JSON.stringify(this.newObjData));
                                if(event.target.name === 'startdate'){
                                    newObjData.startDate = seletedPricingValue;
                                    isUpdate = true;
                                }
                                if(event.target.name === 'enddate') {
                                    newObjData.endDate = seletedPricingValue;
                                    isUpdate = true;
                                }
                                if(event.target.type === 'checkbox') {
                                    newObjData.isSelected = event.target.checked;
                                    isUpdate = true;
                                }
                                if(isUpdate){
                                    this.updatedData[updateDataIndex] = newObjData;
                                    console.log('this.updatedData[updateDataIndex].startDate '+this.updatedData[updateDataIndex].startDate );
                                    console.log('this.updatedData[updateDataIndex].endDate '+this.updatedData[updateDataIndex].endDate );
                                    console.log('this.updatedData[updateDataIndex].isSelected '+this.updatedData[updateDataIndex].isSelected );
                                    if((this.updatedData[updateDataIndex].startDate === null || this.updatedData[updateDataIndex].startDate === undefined) && (this.updatedData[updateDataIndex].endDate === null || this.updatedData[updateDataIndex].endDate === undefined) && this.updatedData[updateDataIndex].isSelected === false && 
                                        (this.updatedData[updateDataIndex].allEndDate === null || this.updatedData[updateDataIndex].allEndDate === undefined) && (this.updatedData[updateDataIndex].allStartDate === null || this.updatedData[updateDataIndex].allStartDate === undefined)){
                                           this.updatedData.splice(updateDataIndex, 1);
                                    }
                                    break;
                                }
                                console.log('remove000'+this.updatedData);
                            }
                            else {
                                let isNewRow = true;
                                
                                if(this.updatedData.find(ele=>ele.pricingMatrixId==selectedpricingID) !== undefined){
                                    isNewRow = false;
                                }
                                if(isNewRow){
                                    newObjData =JSON.parse(JSON.stringify(this.data[index]));
                                    if(event.target.name === 'startdate'){
                                        newObjData.startDate = seletedPricingValue;
                                        isDataUpdated = true;
                                        break;
                                    }
                                    if(event.target.name === 'enddate') {
                                        newObjData.endDate = seletedPricingValue;
                                        isDataUpdated = true;
                                        break;
                                    }
                                    if(event.target.type === 'checkbox') {
                                        newObjData.isSelected = event.target.checked;
                                        isDataUpdated = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }else{
                        //When Update data is blank push the new updated matrix
                        newObjData =JSON.parse(JSON.stringify(this.data[index]))
                        if(event.target.name === 'startdate'){
                            newObjData.startDate = seletedPricingValue;
                        }
                        if(event.target.name === 'enddate') {
                            newObjData.endDate = seletedPricingValue;
                        }
                        if(event.target.type === 'checkbox') {
                            newObjData.isSelected = event.target.checked;
                        }
                        this.updatedData.push(newObjData);
                        break;
                    }
                    if(isDataUpdated){
                        this.updatedData.push(newObjData);
                        console.log('this.updatedData[updateDataIndex].startDate '+this.updatedData[updateDataIndex].startDate );
                        console.log('this.updatedData[updateDataIndex].endDate '+this.updatedData[updateDataIndex].endDate );
                        console.log('this.updatedData[updateDataIndex].isSelected '+this.updatedData[updateDataIndex].isSelected );
                        
                        if((this.updatedData[updateDataIndex].startDate === null || this.updatedData[updateDataIndex].startDate === undefined) && (this.updatedData[updateDataIndex].endDate === null || this.updatedData[updateDataIndex].endDate === undefined) && this.updatedData[updateDataIndex].isSelected === false && 
                                        (this.updatedData[updateDataIndex].allEndDate === null || this.updatedData[updateDataIndex].allEndDate === undefined) && (this.updatedData[updateDataIndex].allStartDate === null || this.updatedData[updateDataIndex].allStartDate === undefined)){
                            this.updatedData.splice(updateDataIndex, 1);
                        }
                    }
                    console.log('testzzzzzzzzzzzzzzzz'+this.updatedData);
                }
            }
        }
        console.log('this.updatedData-->'+JSON.stringify(this.updatedData));
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }

}