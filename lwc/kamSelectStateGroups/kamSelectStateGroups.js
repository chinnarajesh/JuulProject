import { LightningElement ,api, track} from 'lwc';

export default class KamSelectStateGroups extends LightningElement {
    @api groups;
    @api applyInProgress = false
    @api selectedGroupId = ''
    @track saveInProgress = false;
    @track selectedStoreGroups = [];
    @track disableApplyButton = true;
    @track updatedRsg = [];
  

    connectedCallback() {
        this.updatedRsg = this.groups.filter(group => group.Id !== this.selectedGroupId);
        
        if (this.updatedRsg.length > 0) {
            this.disableApplyButton = false;
        }
        console.log('updated RSG',this.updatedRsg);
        const items = this.updatedRsg;
        console.log('item',items);
        const updatedItems = [];
        items && items.forEach(item => {
            updatedItems.push({
                ...item, selected: false
                
            })
        })
        console.log('updatedItems',updatedItems );
        this.updatedRsg = updatedItems;

        
    }

    handleCheckboxChange(e) {
       
        const selectedValue = e.target.value || '';
        console.log('selectedValue',selectedValue);
        const isRSGExists = this.selectedStoreGroups && this.selectedStoreGroups.length > 0 ? this.selectedStoreGroups.includes(selectedValue) : false
        if (isRSGExists) {
            this.selectedStoreGroups = this.selectedStoreGroups.filter(val => val !== selectedValue)
        } else {
            this.selectedStoreGroups.push(selectedValue);
        }
        console.log('this.selectedStoreGroups',this.selectedStoreGroups);
    }

    closeModal() {
        const cancelModal = new CustomEvent('cancel')
        this.dispatchEvent(cancelModal)
    }

    applyItemsToRsg() {
        const rsgSelectApply = new CustomEvent('applyrsgitems', { detail: this.selectedStoreGroups })
        this.dispatchEvent(rsgSelectApply)
    }
    handleSelectDeselectAll(event)
    {
        console.log('inside RSG');
        const items = this.updatedRsg;
        console.log('item',items);
        const updatedItems = [];
        items && items.forEach(item => {
            updatedItems.push({
                ...item, selected: event.target.checked || false
                
            })
        })
        console.log('updatedItems',updatedItems );
        this.updatedRsg = updatedItems;
        updatedItems && updatedItems.forEach(item => {
            if(item.selected){
              console.log('item.id',item.Id);
              this.selectedStoreGroups.push(item.Id);
            }
        })
        const SelectedRSGIDs =  updatedItems && updatedItems.selected;
        console.log('SelectedRSGIDs',this.selectedStoreGroups);
        //this.selectedStoreGroups.push(selectedValue);
    }
}