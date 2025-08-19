import { LightningElement, wire, track, api } from 'lwc';
import getALLMissions from '@salesforce/apex/AcctMissioncontrolDesktopcontroller.getALLMissions';
import getselectedMissions from '@salesforce/apex/AcctMissioncontrolDesktopcontroller.getselectedMissions';
import getStoreProducts from '@salesforce/apex/AcctMissioncontrolDesktopcontroller.getStoreProducts';
import getAsset from '@salesforce/apex/AcctMissioncontrolDesktopcontroller.getAsset';
import getMissionTask from '@salesforce/apex/AcctMissioncontrolDesktopcontroller.getMissionTask';
import saveDate from '@salesforce/apex/AcctMissioncontrolDesktopcontroller.saveData';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import MissionStatusPicklist from '@salesforce/schema/Mission__c.Status__c';
import MISSIONSTYPE from '@salesforce/schema/Mission__c.MissionType__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CUSTOM_OBJECT from '@salesforce/schema/Mission__c';
import CUSTOM_OBJECTAsset from '@salesforce/schema/Asset__c';
import AssetStatus from '@salesforce/schema/Asset__c.Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountMissionControlDesktop extends LightningElement {
    
    @api recordId;
    @track MISSIONList; 
    @track MISSIONList2 =[]; 
    @track MISSIONDetails;
    @track STOREProducts;
    @track ASSET;
    @track MISSIONTASK;
    @track MISSIONDetailsView;
    @track MAINTemplate = true;
    @track MISSIONID;
    @track PLANNEDPtc;
    @track map2 =[];
    @track SPLength; 
    @track color;
    @track MISSIONRecordType;
    @track ACCOUNTPlan;
    @track PROMOPlan;
    @track MISSIONStatus;
    @track AssetStatus;
    @track MissionRecordUpdate;
    @wire(getObjectInfo, { objectApiName: CUSTOM_OBJECTAsset })
    AssetStatusInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$AssetStatusInfo.data.defaultRecordTypeId',
            fieldApiName: AssetStatus
        }
    )
    AssetStatusValues;

    @wire(getObjectInfo, { objectApiName: CUSTOM_OBJECT })
    MissionStatusInfo;

    @track slaOptions;
    @track upsellOptions;

    @wire(getPicklistValues, {recordTypeId: '$MissionStatusInfo.data.defaultRecordTypeId', fieldApiName: MissionStatusPicklist })
    slaFieldInfo({ data, error }) {
        if (data) this.slaFieldData = data;
        console.log('data1',data);
    }
    @wire(getPicklistValues, {recordTypeId:'$MissionStatusInfo.data.defaultRecordTypeId', fieldApiName: MISSIONSTYPE })
    upsellFieldInfo({ data, error }) {
        if (data) this.upsellOptions = data.values;
        console.log('data2',data);
    }
    
    handleUpsellChange(event) {
        console.log('$$$123-==>');
        let key = this.slaFieldData.controllerValues[event.target.value];
        console.log('$$$123-==>',key);
        this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(key));
        console.log('sld--==>',this.slaOptions);
    }

    connectedCallback() {
    this.fetchData();
 
    }

    fetchData(){
    getALLMissions({acc: this.recordId})
    .then(response=>{
     console.log('response122',response);
     this.MISSIONList = JSON.parse(response);
     
     
    }).catch(error=> {
        console.log('error',error);
    })
    
    }

    handleRadiobutton(event)
    {
        const selectedValue = event.target.value;
        this.MISSIONID = selectedValue;
        getselectedMissions({MissionID: selectedValue})
        .then(response => {
      
        this.MAINTemplate= false;
        this.MISSIONDetailsView = true;
        this.MISSIONDetails = JSON.parse(response);
        console.log('this.MISSIONDetails.',this.MISSIONDetails);
        this.MISSIONRecordType = this.MISSIONDetails[0].recordtype;
        let key = this.MISSIONDetails[0].missiontype;
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

        if(this.MISSIONRecordType =='Account Plan')
        {
         this.ACCOUNTPlan = true;
      
        }
        if(this.MISSIONRecordType =='Promotional Activity Process')
        {
         this.PROMOPlan = true;
        }
        //console.log('Test'+JSON.stringify(this.slaFieldData.controllerValues));
        //console.log('key'+key);
        //console.log('this.slaFieldData'+JSON.stringify(this.slaFieldData.values));
        this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(index));
        //console.log('this.slaOptions==>',this.slaOptions);
       // let key = this.MISSIONDetails[0]['missiontype'];

        }).catch(error => {
        console.log('error', error)
        });
        this.StoreProductRecords();
        this.AssetRecords();
        this.MissionTaskRecords();
    }
    StoreProductRecords()
    {
        getStoreProducts({MissionID: this.MISSIONID})
        .then(response => {
         //console.log('SP response',response);
         this.STOREProducts = JSON.parse(JSON.stringify(response));
         this.SPLength = response.length;
        // console.log('this.SPLength', this.STOREProducts);
        }).catch(error => {
        //console.log('error', error)
        });

    }
    AssetRecords()
    {
        getAsset({MissionID: this.MISSIONID})
        .then(response => {
        //console.log('response',response);
         this.ASSET = JSON.parse(JSON.stringify(response));
        }).catch(error => {
        console.log('error', error)
        });
    }
    MissionTaskRecords()
    {
        getMissionTask({MissionID: this.MISSIONID})
        .then(response => {
        //console.log('response',response);
         this.MISSIONTASK = JSON.parse(JSON.stringify(response));
        }).catch(error => {
        console.log('error', error)
        });
    }
    GOBack()
    {
        this.MAINTemplate= true;
        this.ACCOUNTPlan = false; 
        this.PROMOPlan = false; 
        this.fetchData();
    }
    GOSave()
    {
       
        saveDate({spList: this.STOREProducts, AssetList: this.ASSET, MissionList: this.MISSIONDetails})
        .then(response =>{
            console.log('Response',response);
            let type = 'success'
         //console.log('response save==>',response);
         this.refreshPage();
         this.showToast(type.toUpperCase(), 'Records are saved successfully', type);
        }).catch(error =>{
            console.log('error ==>',error);
            this.showToast('ERROR', error, 'error');
        });
    }
    AssethandleFieldChange(event)
    {
        let Assetfoundelement = this.ASSET.find(ele => ele.Id == event.target.dataset.id);
        //console.log('foundelement',Assetfoundelement);
        Assetfoundelement.Quantity__c = event.target.value;
        this.ASSET = [...this.ASSET];
        console.log(' ==>Asset ' +  JSON.stringify(this.ASSET));
        
        
    }
    StoreProducthandleFieldChange(event)
    {
        let SPID = event.target.dataset.id;
        console.log('SPID====>',SPID);
        let SPfoundelement = this.STOREProducts.find(ele => ele.Id == event.target.dataset.id);
        //console.log('foundelement',SPfoundelement);
        SPfoundelement.ActualMSRP__c = event.target.value;
        this.STOREProducts = [...this.STOREProducts];
        console.log(' ==> Store product' +  JSON.stringify(this.STOREProducts));
        
    }

    handleChangeMission(event)
    {
      this.MISSIONStatus = event.target.value;
      let Ids = event.target.dataset.id;
      //console.log('Id Mission=>123$$$$$$$',Ids);
      //console.log('MISSIONDetails%^^^^^^^^^^',this.MISSIONDetails);
      let element = this.MISSIONDetails.find(ele  => ele.Id === event.target.dataset.id);
      //console.log('element==>12333',element);
      element.Status__c = event.target.value;
      this.MISSIONDetails = [...this.MISSIONDetails];
    console.log('123 final mission list ',JSON.stringify(this.MISSIONDetails));
    }
    handleChangeAsset(event)
    {
      let element = this.ASSET.find(ele  => ele.Id === event.target.dataset.id);
      //console.log('element==>12333',element);
      element.Status__c = event.target.value;
      this.ASSET = [...this.ASSET];
      //console.log('Inside handle name method'+JSON.stringify(this.ASSET));
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    //Function to refresh the complete page data when case to doors or save is clicked.
    refreshPage() {
        const refreshPage = new CustomEvent('refresh');
        this.dispatchEvent(refreshPage);
    }

}