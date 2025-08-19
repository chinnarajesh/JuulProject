import { LightningElement, api, track } from "lwc";
export default class MultiPickListFilter extends LightningElement {
  @api label = ""; //Name of the dropDown
  @api maxselected = 1; //Max selected item display
  @api options; // List of items to display
  @api showfilterinput = false; //show filterbutton
  @api showrefreshbutton = false; //show the refresh button
  @api showclearbutton = false; //show the clear button
  @api comboplaceholder = "Select Options..";
  @api multiselect = false;
  @api fieldapiname = "";
  @api objecttabname ='Account';
  @track showvaluesflag = false;
  @api totalselecteditems = 0;
  // @track helpTT='';

  @track _initializationCompleted = false;
  @track _selectedItems = "Select Options..";
  @track _unselectItems = "Select Options..";
  @track _filterValue;
  @track _mOptions;
  @track retailBoolean = false;

  @api selectednamevalues;

  constructor() {
    super();
    this._filterValue = "";
   
  }
  renderedCallback() {
    // this.helpTT = this.label ==='Select Account Segment'? 'Can select multiple values.':
   
    let self = this;
    if (!this._initializationCompleted) {
      this.template.querySelector(".ms-input").addEventListener("click", function (event) {
        
          self.onDropDownClick(event.target);
          event.stopPropagation();
        });
      this.template.addEventListener("click", function (event) {
      
        event.stopPropagation();
      });
      document.addEventListener("click", function (event) {
      
        self.closeAllDropDown();
      });
      this._initializationCompleted = true;
     // this.setPickListName();
    }
    else{
     // this.initArray(self);  // Virender Modified
    }
  //  console.log('VIRENDER value selcetd is:::'+this.selectednamevalues);
   // let mytempar = new Array();
  // this.initArray(this); // Virender Added newly
   let mytempar = [];
   if(this.selectednamevalues !== undefined){
      mytempar=  this.selectednamevalues;
   }
   /* if(this.selectednamevalues !== undefined && this.selectednamevalues.length > 0){
      
      var tepo = '';
      tepo = JSON.stringify(this.selectednamevalues);
      console.log('VIREN VIREN type of string is'+ typeof tepo + tepo);
      var answ = '';
      answ = tepo.split(',');
      console.log('VIREN VIREN type of string after split'+answ);
      mytempar.push(answ);
    
    console.log('MHARO MHARO MHARO'+ mytempar +mytempar.length + typeof mytempar);
    }
    */
   /*if(mytempar !== undefined && mytempar.length >0){
    var tepo = '';
    console.log('VIRENDER VIRENDER VIRENDER:::::'+this.selectednamevalues + typeof this.selectednamevalues);
    tepo = JSON.stringify(this.selectednamevalues);
    console.log('VIREN VIREN type of string is'+ typeof tepo + tepo.length + tepo);
    var answ = '';
    answ = tepo.split(',');
    console.log('THIS IS BHAILO MHARO'+ typeof answ + JSON.stringify(answ));
     console.log('THIS IS BHAILO'+ typeof mytempar + answ[0]);
    for(var m=0; m<mytempar.length; m++){
      console.log('VIRE#NDER IS OUTSIDE'+ mytempar[m]);
      console.log('VIRE#NDER IS OUTSIDE UPDATED'+ typeof mytempar[m]);
      var mypot = JSON.stringify(mytempar[m]);
      console.log('VIRO VIRO VALUE'+mypot + typeof mypot);
      var motto = '';
      var domino = [];
      domino = mytempar[m];
      console.log('LENGTH OF ARRAY IS:::::'+ domino.length);
      for(var mop = 0; mop<domino.length;mop++)
      {
     // motto = mypot.split(',');
     console.log('new variable value is VIRU VIRU'+domino[mop]);
      this._mOptions.forEach(function (eachItem) {
        if (eachItem.value === domino[mop]) {
          eachItem.selected = true;
          console.log('VIRE#NDER IS INSIDE'+ domino[mop]);
         // return;
        }
      });
    }*/
    console.log('selected tab '+this.objecttabname);
    // this.retailBoolean = this.objecttabname !== 'Retail Theater' ? false : true;
    for(var m=0; m<mytempar.length; m++)
    {
   // motto = mypot.split(',');
  // console.log('new variable value is VIRU VIRU'+domino[mop]);
    this._mOptions.forEach(function (eachItem) {
    
      if (eachItem.value === mytempar[m]) {
        eachItem.selected = true;
     
       // return;
      }
    });
  }
   // }
   this.setPickListName();
  }
  
  
  //}
  handleItemSelected(event) {
    let self = this;
  
    let mop2;
   
    if(self.multiselect === true){
      
        mop2 = false;
    }
    else if(self.multiselect === false){
      
        mop2 = true;
    }
    this._mOptions.forEach(function (eachItem) {
   // let mop2 = !!self.multiselect;
  
      //  console.log('THE VALUE OF PICKLIST MULTIPICKLIST API VAR VALUE IS'+self.multiselect);
      //  console.log('NEW OPPOSE BOOLEAN VAL IS'+ mopp);
    if(mop2){
       if(eachItem.selected !== undefined){
           
            eachItem.selected = false;
        }
    }
      if (eachItem.key == event.detail.item.key) {
        eachItem.selected = event.detail.selected;
       // return;
      }
    });
    this.setPickListName();
    // Previous  this.onItemSelected();
    this.onItemSelected(event.detail.fieldAPI);
  }
  filterDropDownValues(event) {
    this._filterValue = event.target.value;
    this.updateListItems(this._filterValue);
  }
  closeAllDropDown() {
    Array.from(this.template.querySelectorAll(".ms-picklist-dropdown")).forEach(
      function (node) {
        node.classList.remove("slds-is-open");
      }
    );
  }

  onDropDownClick(dropDownDiv) {
    let classList = Array.from(
      this.template.querySelectorAll(".ms-picklist-dropdown")
    );
    if (!classList.includes("slds-is-open")) {
      this.closeAllDropDown();
      Array.from(
        this.template.querySelectorAll(".ms-picklist-dropdown")
      ).forEach(function (node) {
        node.classList.add("slds-is-open");
      });
    } else {
      this.closeAllDropDown();
    }
  }

  onRefreshClick() {
    this.setPickListName();
    this.showvaluesflag = true;
    this._filterValue = "";
    this.initArray(this);
    this.updateListItems("");
   // this.setPickListName();
     this.onItemSelected(); //VIREN COMMENTED IN ORDER TO PASS TEST TEST WILL UNCOMMENT AGAIN
  }
  onClearClick() {
    this._filterValue = "";
    this.updateListItems("");
  }
  connectedCallback() {
      this.initArray(this);
      this.accHP =   this.objecttabname === 'Account'? true :false;
      
  }
  initArray(context) {
    context._mOptions = new Array();
    context.options.forEach(function (eachItem) {
      context._mOptions.push(JSON.parse(JSON.stringify(eachItem)));
    });
    //Added by Viren
    for(var m=0; m<this.selectednamevalues; m++){
     
      context._mOptions.forEach(function (eachItem) {

        if (eachItem.value === selectednamevalues[m]) {
          eachItem.selected = true;
         
         // return;
        }
      });
    }
     //Added by Viren
  }
  updateListItems(inputText) {
    Array.from(this.template.querySelectorAll("c-pick-list-item")).forEach(
      function (node) {
        if (!inputText) {
          node.style.display = "block";
        } else if (
          node.item.value
            .toString()
            .toLowerCase()
            .indexOf(inputText.toString().trim().toLowerCase()) != -1
        ) {
          node.style.display = "block";
        } else {
          node.style.display = "none";
        }
      }
    );
    this.setPickListName();
  }
  setPickListName() {
    console.log('this._selectedItems  :: '+this._selectedItems );
    let selecedItems = this.getSelectedItems();
    let selections = "";
    if (selecedItems.length < 1) {
      selections = this.comboplaceholder;
    } else if (selecedItems.length > this.maxselected) {
      selections = selecedItems.length + " Options Selected";
    } else {
      selecedItems.forEach((option) => {
       // selections += option.value + ","; // RECENT COMMENTED
       selections += option.value;
      });
    }
    this._selectedItems = selections;
    console.log('this._selectedItems end  :: '+this._selectedItems );
  }
  @api
  getSelectedItems() {
    let resArray = new Array();
    this._mOptions.forEach(function (eachItem) {
      if (eachItem.selected) {
        resArray.push(eachItem);
      }
    });
    console.log(' this._mOptions '+ JSON.stringify( this._mOptions));
   console.log(' resArray '+ JSON.stringify(resArray));
    return resArray;
  }

  onItemSelected(str) {
    let myvalo = str;
    if(myvalo !== undefined){
    const evt = new CustomEvent("itemselected", {
     // detail: this.getSelectedItems(),
     // aponame: myvalo,
     detail: { item: this.getSelectedItems(), aponame: myvalo }
    });
    this.dispatchEvent(evt);
  }
}

/*@api myNewMethodValuePopulate(){

  this._mOptions = new Array();
    this.options.forEach(function (eachItem) {
      console.log('Virender INSIDE options'+ JSON.stringify(eachItem));
      this._mOptions.push(JSON.parse(JSON.stringify(eachItem)));
    });
    //Added by Viren
    for(var m=0; m<this.selectednamevalues; m++){
      console.log('VIRE#NDER IS OUTSIDE'+ selectednamevalues[m]);
     
      context._mOptions.forEach(function (eachItem) {
        console.log('DEMO DEMO DEMO NEWWWWWWWW');
        console.log('NEWWWWWWWWWWWWWW'+eachItem.value + typeof eachItem.value  + 'POPOPOP'+ typeof selectednamevalues[m] + selectednamevalues[m]);
        if (eachItem.value === selectednamevalues[m]) {
          eachItem.selected = true;
          console.log('VIRE#NDER IS INSIDE'+ selectednamevalues[m]);
         // return;
        }
      });
    }


}*/
@api
clearReatilData(){
   if (this.objecttabname === 'Retail Theater') {
    if (Array.isArray(this._mOptions)) {
      // Reset selected states in _mOptions array
      this._mOptions.forEach(slt => {
          slt.selected = false; // Clear the selected state
      });

      // Important: Trigger reactivity by reassigning the array
      this._mOptions = [...this._mOptions]; // This ensures the data is refreshed in the UI
  }

  this._selectedItems = "Select Options..";
  this._filterValue = "";
  this.filterDropDownValues({ target: { value: '' } });
  this.updateListItems(this._filterValue);
  console.log('showvaluesflag '+this.showvaluesflag);
  if(this.showvaluesflag){
    let pickitem =  this.template.querySelector('c-pick-list-item');
    if(pickitem){
      pickitem.clearSelection();
      console.log('pickitem ::: '+JSON.stringify(pickitem));
      this.setPickListName();
    }
  }
  this.onRefreshClick();
 this.selectednamevalues=[];
//  console.log('pickitem ::: '+JSON.stringify(pickitem));
  console.log('this._mOptions ::: '+JSON.stringify(this._mOptions));
        // Refresh the UI to reflect the changes
       
        const element = this.template.querySelectorAll('.slds-listbox__item');
        element.forEach(elmt=>{
          console.log('elmt.id  '+elmt);
          elmt.classList.remove('slds-is-selected');
        });   //slds-listbox__item ms-list-item slds-is-selected   
        // this.template.querySelector('.slds-listbox__item').classList.remove('slds-is-selected');  
        // Find elements based on the data-label and clear them
        const elements = this.template.querySelectorAll(`[data-label="${this.label}"]`);
        elements.forEach(elmt => {
            if (elmt.dataset.label === this.label) {
              elmt.value = "Select Options..";
                // Clear the selection of child components (c-pick-list-item)
              // const pickListItems = this.template.querySelectorAll('c-pick-list-item');
              // pickListItems.forEach(item => {
              //   console.log(' item111 :: '+JSON.stringify(item));
              //   const listItem = item.querySelector('.slds-listbox__item'); // Get the list item within the child component
              //   console.log(' listItem :: '+JSON.stringify(listItem));
              //   if (listItem) {
              //     listItem.classList.remove('slds-is-selected'); // Clear selection in the child component
              //   }
              // });

              //   // const listItemElement = this.template.querySelector('.slds-listbox__item');
              //   // if (listItemElement) {
              //   //     listItemElement.classList.remove('slds-is-selected');
              //   // }

              //   console.log('elmt.dataset.label ::: '+elmt.dataset.label);
              //   // Reset the input element value
              //   const inputElmt = this.template.querySelector(`[data-key="${this.label}"]`);
              //   if (inputElmt) {
              //       inputElmt.value = ''; // Clear input field
              //   }
            }
        });
        // this.retailBoolean = true;
        // Reset selected items display
        // this._selectedItems = ''; // This ensures the UI reflects the cleared state
        // this.setPickListName(); // Update picklist display name
    }
  }
  


}