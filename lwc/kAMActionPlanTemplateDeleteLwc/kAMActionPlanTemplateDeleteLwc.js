import { LightningElement,api,track } from 'lwc';
import DeleteactionPlanTemplateRecord from '@salesforce/apex/ActionPlanTemplateDeleteController.DeleteactionPlanTemplateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class KAMActionPlanTemplateDeleteLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showPopup = false;
    @track returnData ;
    @track loading = false;
    @track recordId ;
    @track loading2 = true;
    @track returnData2 ;
    @track AptDelete =true;
    @track NotDeleteApt =false;

    connectedCallback() {
        this.fetchData();
    }

    fetchData(){
      console.log('test method')
      DeleteactionPlanTemplateRecord({ ActionPlanTemplateId: this.recordId,aptDelete:this.NotDeleteApt})
      .then(response => {
          this.returnData2 = response;
          if (this.returnData2 == 'success') {
            this.loading2=false;
            this.showPopup=true;
            
          }else{
            this.closeModal();
            var title ='Action Plan Templates that are past the Planning status cannot be deleted. You may use the Recall function instead.';
            this.showToast('ERROR', title, 'error');
          }

        })
        .catch(err => {
            console.log('error', err)
            this.showToast('ERROR', err.body.message, 'error');
        });
    }

    handleCancel(){
        console.log('test method');
        this.showPopup=false;
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
        
    }
    handleYes(){
        //this.closeModal();
        //this.refreshPage();
        this.showPopup=false;
        this.loading=true;
        // const closeModal = new CustomEvent('close');
        // this.dispatchEvent(closeModal);
       
        DeleteactionPlanTemplateRecord({ ActionPlanTemplateId: this.recordId ,aptDelete:this.AptDelete})
        .then(response => {
            this.returnData = response;
            //this.loading=false;
            this.closeModal();
            console.log('returnData'+this.returnData);
            if (this.returnData == 'success') {
               var title1 ='Action plan template deleted successfully.';
               this.showToast('Success', title1, 'success');
               //eval("$A.get('e.force:refreshView').fire();");
               this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'ActionPlanTemplate__c',
                    actionName: 'home',
                },
            });

            }
            else{
                var title ='Action Plan Templates that are past the Planning status cannot be deleted. You may use the Recall function instead.';
                this.showToast('ERROR', title, 'error');
            }
        })
        .catch(err => {
            console.log('error', err)
            this.showToast('ERROR', err.body.message, 'error');
        });
    }
    closeModal() {
        console.log('close model ');
        this.showPopup=false;
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }
    refreshPage() {
        const refreshPage = new CustomEvent('refresh');
        this.dispatchEvent(refreshPage);
    }
    showToast(title, message, variant) {
        console.log('show tost message');
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}