import { LightningElement,wire } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class OmniScriptAGSGetUrlParams extends OmniscriptBaseMixin(LightningElement){
    currentUrl;
    connectedCallback(){ 
        this.currentUrl = window.location.href;
        let url = String(this.currentUrl);
        let auditCalledFromMission = false;
        if (url.includes('c__SourcePath')) {
            auditCalledFromMission = true;
        } 
        let data = {};
        data.auditCalledFromMissionLWC = auditCalledFromMission;
        this.omniApplyCallResp(data);
        this.omniNextStep();
    }
}