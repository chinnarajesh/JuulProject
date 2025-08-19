import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class OmniScriptMissionSaveAction extends OmniscriptBaseMixin(LightningElement){
    handleClick() {
        // Your custom logic goes here
       
        const urlParams = new URLSearchParams(window.location.search);
        console.log('urlParams1-'+urlParams);

        // Example: Dispatch a custom event
        //this.dispatchEvent(new CustomEvent('custombuttonclick'));
        //auditCalledFromMission = true;
        let data = {};
        data.missionSaveButtonPressed = true;
 
    
        console.log("data-"+JSON.stringify(data));
 
 
        this.omniApplyCallResp(data);

        this.omniNextStep();

    }

 

}