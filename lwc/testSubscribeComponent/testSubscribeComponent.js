import { LightningElement ,wire,api, track} from 'lwc';

  import { subscribe, onError }  from 'lightning/empApi';
  import UserId from "@salesforce/user/Id";
export default class TestSubscribeComponent extends LightningElement {
   @track popmodel = false;
    @api channelName = '/event/Call_LWC_From_Platfromevent__e';
    @api recordId;
    @track manageAPT = false;



    connectedCallback() {
        this.handleSubscribe();
    }
    handleSubscribe() {
        console.log('new subscription')
        const thisReference = this;
        let messageCallback = function(response) {
            console.log('second subscription')
            
            console.log('New message received 1: ', JSON.stringify(response));
            console.log('New message received 2: ', response);
            console.log('selected Id '+thisReference.recordId);
            
            let obj= JSON.parse(JSON.stringify(response));
            // console.log('New message received 4: ', obj.data.payload.Event_user__c);
            // console.log('New message received 5: ', this.channelName);
              console.log('test console ');
              if(obj.data.payload.Event_user__c === UserId && obj.data.payload.Selected_AptId__c === thisReference.recordId){
                console.log('apex user ',obj.data.payload.Event_user__c,' User ',UserId,' reocrd ',obj.data.payload.Selected_AptId__c);
                thisReference.popmodel = true;
                console.log('popup model ',thisReference.popmodel);
              }
            //   const evt = new ShowToastEvent({
            //       title:obj.data.payload.Message__c ,
            //       message:'',
            //       variant: 'success',
            //       mode: 'dismissable'
            //   });
            //   thisReference.dispatchEvent(evt);
            // thisReference.downloadCSV(obj.data.payload.csv_Link__c);
            // thisReference.loading =false;
            // thisReference.closeModal();
            // console.log('test console ');
            //   let toastMode;
            // //   thisReference.closeModal();
            //   thisReference.downloadCSV(obj.data.payload.csv_Link__c);
            // if(!obj.data.payload.csv_Link__c){
            //     thisReference.loading =true;
                
            //     toastMode = 'dismissable';
                
            // }else if(obj.data.payload.csv_Link__c){
              
            //     toastMode = ' pester';
               

            // }
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
    closeAssociate(event){
        this.popmodel = false;
        this.manageAPT = event.detail.childcompdescription;
        console.log('final close of apt', this.manageAPT);
        eval("$A.get('e.force:refreshView').fire();");
    }

    closeManageAPt(){
        this.manageAPT = false;
        eval("$A.get('e.force:refreshView').fire();");
    }
}