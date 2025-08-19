import { LightningElement,track,wire } from 'lwc';
import JUUL_IMAGE from '@salesforce/resourceUrl/PB_JUUL_Image';
import fieldFilterOff from '@salesforce/label/c.PB_Field_Filter_Off';
import fieldFilterOn from '@salesforce/label/c.PB_Field_Filter_On';
import KAMFilterOff from '@salesforce/label/c.PB_KAM_Filter_Off';
import KAMFilterOn from '@salesforce/label/c.PB_KAM_Filter_ON';
import { NavigationMixin } from 'lightning/navigation';

export default class MiscStaticResource extends NavigationMixin(LightningElement) {

    juulImage = JUUL_IMAGE;
    isSelected = true;
    notSelected = false
    intermediateValue = true;
    label = {
      fieldFilterOff,
      fieldFilterOn,
      KAMFilterOff,
      KAMFilterOn
  };
  @track changepersonaaction = false;

 handlePersonaChangeFilter(event) {
      this.showModalBox();
  }

  handlePersonaChangeKAM(event) {
    this.showModalBox();
  }

hideModalBox() {
    this.changepersonaaction = false;
}
showModalBox(){
  this.changepersonaaction = true;

}

handelCancel(){
  this.hideModalBox();
   
}

handleProceed(){
   this.hideModalBox();
   this.intermediateValue = !this.intermediateValue;
    this.isSelected = !this.isSelected;
    this.notSelected = !this.notSelected;
    console.log('My Current Filter Persona Value in parent method is::'+this.intermediateValue);
    const objChild = this.template.querySelector('c-photo-library');
    let currentPerosna = this.intermediateValue;
    objChild.callThisMethodFromFilterPersona(currentPerosna);

}

navigateToReport(){
  this[NavigationMixin.GenerateUrl]({
    type: 'standard__objectPage',
    attributes: {
        objectApiName: 'Report',  
        actionName: 'home'
    }
}).then(url => {
    window.open(url, '_blank');
});
}

}