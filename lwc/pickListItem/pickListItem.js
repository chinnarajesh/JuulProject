import Json2 from "@salesforce/resourceUrl/Json2";
import { LightningElement, track, api } from "lwc";
export default class PickListItem extends LightningElement {
  @api item;
  @api fieldpai ="";
  @api objecttabname="";
  constructor() {
    super();
  }
  connectedCallback() {
    this._item = JSON.parse(JSON.stringify(this.item));
    console.log('connected callback '+ JSON.stringify(this.item));
    // console.log('mhari khudki value is '+ JSON.stringify(this.item));
    // console.log('mhari khudki field ki API name value is '+ JSON.stringify(this.fieldpai));
  }
  get itemClass() {
    return (
      "slds-listbox__item ms-list-item" +
      (this.item.selected ? " slds-is-selected" : "")
    );
  }
  onItemSelected(event) {
    const evt = new CustomEvent("items", {
      detail: { item: this.item, fieldAPI: this.fieldpai ,selected: !this.item.selected },
    });
    this.dispatchEvent(evt);
    event.stopPropagation();
  }

  @api
  clearSelection() {
      // Clear the selected state
      console.log('Clearing selection for item:', JSON.stringify(this.item));

      if(this.item.selected == true){
        this.item.selected = false; // Reset the selected state
      }
      // this._item = {};
      // // Update the class if needed (this will trigger reactivity)
      // const listItemElement = this.template.querySelector('.slds-listbox__item');
      // console.log('listItemElement: '+JSON.stringify(listItemElement));
      // if (listItemElement) {
      //     listItemElement.classList.remove('slds-is-selected');
      // }
      this._item = JSON.parse(JSON.stringify(this.item));

    // Use data-id to select the correct list item
    const listItemElement = this.template.querySelector(`li[data-id="${this.item.key}"]`);
    console.log('listItemElement:', listItemElement);
  //   if (listItemElement) {
  //     listItemElement.classList.remove('slds-is-selected');
  // }
  if (listItemElement) {
    listItemElement.className = this.itemClass; // Update the class with the new value
}

console.log('this.itemClass '+JSON.stringify(this.itemClass));
  }
}