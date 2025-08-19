import { api, LightningElement, track,wire } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getMissionChildData from "@salesforce/apex/OmniScriptFromApexLWC.getMissionChildData"
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

const FIELDS = ['Mission__c.InStoreLocationId__c'];
export default class OmniScriptStoreProductsAssetsDataTransform extends OmniscriptBaseMixin(LightningElement){
//@track storeProductsAssetsData;
    @api storeproductsassetsinfo;
    @track isTrueStoreProduct =true;
//@track storeProductsAssetsDataLWCLoaded = false;
     @track zeroOrNullMSRPProducts = [];
    records = [];
    InstoreData = [];
    @track MissionId;
    @track StoreProductData;
    @track inStoreLocationId ='';
    error;
    
    // getStoreProductsAssetsDataLWC() {
    //     getMissionChildData({ missionId: 'a6F4T000000027JUAQ' })
    //         .then(result => { console.log(result); })
    //         .catch(error => {
    //             this.error = error;
    //         });
    // // }
    // @wire(getRecord, { recordId: '$MissionId', fields: FIELDS })
    // wiredRelatedLists(result) {
    //     const { data, error } = result; // eslint-disable-line  )
    //     console.log(' result ' + JSON.stringify(result));
    //     // console.log(' result22 ' + JSON.stringify(result.data.fields));
    //     if (data) {
    //         this.InstoreData = data;
    //          this.inStoreLocationId = this.InstoreData.fields.InStoreLocationId__c.value;
    //         console.log('inStoreLocationId ' + this.inStoreLocationId);
    //     }
       
    // }
    @wire(getRelatedListRecords, {
        parentRecordId: '$inStoreLocationId',
        relatedListId: 'Store_Products__r',
        fields: ['StoreProduct__c.Id','StoreProduct__c.ActualMSRP__c']
    })
    wireStoreProductData(result) {
        const { data, error } = result; 
        console.log('this.inStoreLocationId22 ' + this.inStoreLocationId);
        if (data) {
            this.records = data.records;
            this.zeroOrNullMSRPProducts =this.records.reduce((acc, record) => {
                    const id = record.fields.Id.value;
                    acc[`StoreProductdb-${id}`] = {
                        StoreProduct_Actual_PTCNew: record.fields.ActualMSRP__c.value.toString(), 
                        StoreProduct_Actual_Id: id
                    };
                    return acc;
                }, {});
            console.log('data33: '+JSON.stringify(this.zeroOrNullMSRPProducts));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
    renderedCallback(){
        console.log("storeProductsAssetsData--DB111:"+JSON.stringify(this.zeroOrNullMSRPProducts));
    }

    async connectedCallback() {
       
        this.inStoreLocationId = this.omniJsonData.parentObjectY.ISL_Id;
          while (!this.zeroOrNullMSRPProducts || this.zeroOrNullMSRPProducts.length === 0) {
            await new Promise(resolve => setTimeout(resolve, 100));
          }
        const storeProductsAssetsDataDB = this.zeroOrNullMSRPProducts;
        console.log('this.inStoreLocationId ' + JSON.stringify(storeProductsAssetsDataDB));
         console.log(' this.records ' + JSON.stringify(this.records));
       
        //  this.storeProductsAssetsData = this.storeproductsassetsinfo;
       
        console.log("storeProductsAssetsDatasss--"+JSON.stringify(this.omniJsonData.parentObjectY.Mss_Id));
        console.log("storeProductsAssetsData--"+JSON.stringify(this.omniJsonData.StoreProductsAssetsData));
        
        // if(this.storeProductsAssetsDataLWCLoaded == true){
        //     this.omniPrevStep();
        // }


        let storeProductsAssetsData = this.omniJsonData.StoreProductsAssetsData;


        console.log("storeProductsAssetsData--"+JSON.stringify(storeProductsAssetsData));
        console.log("storeProductsAssetsData--DB:"+JSON.stringify(storeProductsAssetsDataDB));
        
        const storeProductsArr = [];
        const assetsArr = [];

        let storeProdValsArr = [];
        //const assetsValsArr = [];

        // Loop through the StoreProductsData and split into two objects

        const storeProductsAssetsDataLength = Object.keys(storeProductsAssetsData).length;

        if(storeProductsAssetsDataLength > 0){ console.log("am here if");
            Object.keys(storeProductsAssetsData).forEach(key => { 
                console.log("key"+key); 
                if (key.startsWith('StoreProduct-')) { 
                    console.log("key-111"+storeProductsAssetsData[key]);
                    console.log("key-222"+storeProductsAssetsData[key].StoreProduct_Actual_PTCNew);
                    console.log("typeof-222"+typeof storeProductsAssetsData[key].StoreProduct_Actual_PTCNew);
    
    
                    const storeProdValLocal = parseInt(storeProductsAssetsData[key].StoreProduct_Actual_PTCNew);
    
                    
                    console.log("fff-val"+ storeProdValLocal);
                    console.log("fff typeof"+typeof storeProdValLocal);
            
                    if(storeProdValLocal > 0){ 
                        storeProdValsArr.push('true'); console.log("123");
                        //storeProductsAssetsData[key].storeProductValidation = "true";
                    }else{
                        storeProdValsArr.push('false'); console.log("234");
                        //storeProductsAssetsData[key].storeProductValidation = "false";
                    }
                    
                    storeProductsArr.push(storeProductsAssetsData[key]);
    
                    //storeProdValsArr.push(storeProductsAssetsData[key].StoreProduct_Actual_PTCNew);
                } else if (key.startsWith('Asset-')) {
                    assetsArr.push(storeProductsAssetsData[key]);
                }
            });
        }else{ console.log("am here else");
            Object.keys(storeProductsAssetsDataDB).forEach(key => { 
                console.log("key"+key); 
                if (key.startsWith('StoreProductdb-')) { 
                    console.log("key-111"+storeProductsAssetsDataDB[key]);
                    console.log("key-222"+storeProductsAssetsDataDB[key].StoreProduct_Actual_PTCNew);
                    console.log("typeof-222"+typeof storeProductsAssetsDataDB[key].StoreProduct_Actual_PTCNew);
    
    
                    const storeProdValLocal = parseInt(storeProductsAssetsDataDB[key].StoreProduct_Actual_PTCNew);
    
                    
                    console.log("fff-val"+ storeProdValLocal);
                    console.log("fff typeof"+typeof storeProdValLocal);
            
                    if(storeProdValLocal > 0){ 
                        storeProdValsArr.push('true'); console.log("123");
                        //storeProductsAssetsData[key].storeProductValidation = "true";
                    }else{
                        storeProdValsArr.push('false'); console.log("234");
                        //storeProductsAssetsData[key].storeProductValidation = "false";
                    }
                    
                    storeProductsArr.push(storeProductsAssetsData[key]);
    
                    //storeProdValsArr.push(storeProductsAssetsData[key].StoreProduct_Actual_PTCNew);
                } else if (key.startsWith('Asset-')) {
                    assetsArr.push(storeProductsAssetsData[key]);
                }
            });
        }
        

    
        console.log("storeProdValsArr--"+storeProdValsArr);
        console.log("StoreProduct-111"+storeProductsArr);
        console.log("StoreProduct-222"+JSON.stringify(storeProductsArr));
        console.log("Asset-111"+assetsArr);
        console.log("Asset-222"+JSON.stringify(assetsArr));

        let storeProductsAssetsDataObj = {};
        storeProductsAssetsDataObj.StoreProducts = storeProductsArr;
        storeProductsAssetsDataObj.Assets = assetsArr;

        console.log("storeProductsAssetsDataObj"+JSON.stringify(storeProductsAssetsDataObj));

        // let storeProductValidationVal = storeProdValsArr => storeProdValsArr.every(v => v === 'true');
        // console.log("storeProductsAssetsDataObj"+storeProductValidationVal);


        // let storeProductValidationVal;
        // if(storeProdValsArr.includes("false")){ 
        //     storeProductValidationVal = "false";
        // }else{
        //     storeProductValidationVal = "true";
        // }

        let data = {};
        data.storeProductsAssetsDataLWC = storeProductsAssetsDataObj;

        if(storeProdValsArr.includes("false")){ 
            data.storeProductValidation = false;
        }else{ 
            data.storeProductValidation = true;
        }
        //data.storeProductValidation = storeProductValidationVal;

        console.log("data-222"+JSON.stringify(data));
        this.isTrueStoreProduct = true ;
        console.log(' this.isTrueStoreProduct ' + this.isTrueStoreProduct);
        // const toastEvent = new ShowToastEvent({
        //     title: 'Test',
        //     message: ' error occured',
        //     variant: 'error'
        // });
        // this.dispatchEvent(toastEvent);

        // var data = {
        //     customer : {
        //         myname : "Santhosh Reddy"
        //     }
        // }
        //this.omniJsonData.Mission_Control = {};
        this.omniApplyCallResp(data);

        if(storeProdValsArr.includes("false")){ 
            console.log("here111");
            this.omniPrevStep();
        }else{ 
            console.log("here222");
            this.omniNextStep();
        }
    
        //this.omniNextStep();
        //this.storeProductsAssetsDataLWCLoaded = true;
        //this.subscribeToEvent();
    }

    // subscribeToEvent(){
    //     pubsub.register('omniscript_action',{
    //         moveStep: this.eventHandler.bind(this),
    //     });
    // }
    // eventHandler(event){
    //     this.subscribeToEvent();
    // }

}