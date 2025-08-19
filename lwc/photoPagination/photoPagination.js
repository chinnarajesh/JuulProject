import { LightningElement, api, track } from "lwc";
const DELAY = 300;

export default class PhotoPagination extends LightningElement {

    @api records;
    @api recordsperpage = 20;
    @api columns;
    recordsToDisplay;

    @api totalRecords;
     pageNo;
    totalPages;
    startRecord;
    endRecord;
    end = false;
    @track pagelinks = [];
    isLoading = false;
    _initializationCompleted = false;
    @api selectedpagenumber;
    

    renderedCallback(){
      
      //  this.isLoading = true;
      // this.setRecordsToDisplay();
     // if(this._initializationCompleted){
     //   console.log('Entered into pagination renreder method its needed');
      //  this.pagelinks = [];
      //  this.setRecordsToDisplay();

    //  }
      //  console.log('Entered into pagination renreder method update' + this._initializationCompleted);
      //  this._initializationCompleted = true;
      //  console.log('Entered into pagination renreder method update after update' + this._initializationCompleted);
    }

    connectedCallback() {
       // this.isLoading = true;
       console.log('Enteredinto connected call back method of Photo Pagination');
       this.setRecordsToDisplay();
    }

 @api setRecordsToDisplay(myValueNew, lenofval) {
     let totalLen= 0;
      
    if(myValueNew !== undefined && lenofval !== undefined){
       this.records = myValueNew;
       this.totalRecords = lenofval;
    }
      console.log('Call to Set Records TO Display Method'+ this.totalRecords);
        this.pagelinks = [];
       // this.totalRecords = this.records.length;
        this.pageNo = 1;
        this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
        this.preparePaginationList();

        for (let i=1; i<=this.totalPages; i++) {
            //this.pagelinks.push(i);
            this.pagelinks = [...this.pagelinks ,{value: i , label: i}]; 
        }
        console.log('Ye mera page number hain:::'+this.pageNo);
        this.isLoading = false;
    }
    handleClick(event) {
        let label = event.target.label;
        if (label === "First") {
            this.handleFirst();
        } else if (label === "Previous") {
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } else if (label === "Last") {
            this.handleLast();
        }
    }

    handleNext() {
        this.pageNo += 1;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    handleFirst() {
        this.pageNo = 1;
        this.preparePaginationList();
    }

    handleLast() {
        this.pageNo = this.totalPages;
        this.preparePaginationList();
    }
    preparePaginationList() {
       // this.isLoading = true;
        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.records.slice(begin, end);

        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;

        const event = new CustomEvent('pagination', {
            detail: { 
                records : this.recordsToDisplay,
                pnum : this.pageNo
            }
        });
        this.dispatchEvent(event);

        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.disableEnableActions();
        }, DELAY);
        this.isLoading = false;
    }

    disableEnableActions() {
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach(bun => {
            if (bun.label === this.pageNo) {
                bun.disabled = true;
            } else {
                bun.disabled = false;
            }

            if (bun.label === "First") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            }
        });
    }

    handlePage(event) {
        this.selectedpagenumber = event.target.value;
        this.pageNo = parseInt(event.target.value);
        console.log('Selected Page number is::'+ typeof this.pageNo + this.pageNo+ event.target.value);
        this.preparePaginationList();
    }

}