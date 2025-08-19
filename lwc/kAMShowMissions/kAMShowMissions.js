import { LightningElement,wire,api,track } from 'lwc';
import getMissionRecords from "@salesforce/apex/KAMAccountMissionsController.getMissionRecords";

export default class KAMShowMissions extends LightningElement {
    
    @api recordId;
    @track relatedMissionData =[];
    @api formFactor='';

    @wire(getMissionRecords,{recordId:"$recordId"}) getMissionRecords({error,data}){
        if(data==null)
        {
            //alert('in null');
            
        }
        if(data!=undefined){  
            var index=1;
            for(var d in data)
            {
                this.relatedMissionData.push({
                    'index':index,
                    'recordId':data[d].Id,
                    'Name':data[d].Name,
                    'CommercialActivity':data[d].Commercial_Activity__c,
                    'Type':data[d].MissionType__c,
                    'Status':data[d].Status__c,
                    'StartDate':data[d].StartDate__c,
                    'EndDate':data[d].EndDate__c,
                    'Description':data[d].InstructionDescription__c

                });
                index++;
            }
            console.log("json"+JSON.stringify(this.relatedMissionData));


        }
        if(error){
            console.log("error"+JSON.stringify(error));
        }
    }
    connectedCallback()
    {
        console.log('recId->'+this.recordId+' '+this.formFactor);
    }
    openMissionRecord(event)
    {
        event.preventDefault();// to stop the default behaviour of href
        //alert('here'+event.target.id);
        var recordId='';
        recordId=this.relatedMissionData[this.getIndex(event.target.id)-1]['recordId'];
        //alert('recordIdtest '+recordId);
        var recordUrl=(this.formFactor=='PHONE')?'/salesforce1://sObject/'+recordId+'/view': '/lightning/r/'+recordId+'/view';
        window.open(recordUrl,'_blank');    
    }
    
    getIndex(str){
        const parts = str.split('-');
        parts.pop();
        return parts.join('-');
    }

    closeModal(evt)
    {
        const redirectToAccount = new CustomEvent('redirectToAccount',{
            detail : {recordId : this.recordId}

        });
        this.dispatchEvent(redirectToAccount);
    }
}