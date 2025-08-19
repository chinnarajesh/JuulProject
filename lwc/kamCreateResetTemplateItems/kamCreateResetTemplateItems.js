import { LightningElement, api, wire, track } from 'lwc';
import getAllAPTWithItemsProducts from '@salesforce/apex/KAMCreateMissionsatDoor.getAllAPTWithItemsProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Subject', fieldName: 'subject', type: 'text' },
    { label: 'Priority', fieldName: 'priority', type: 'text' }
]
const storeProductColumns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
]

const commercialActivityColumns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Product Type', fieldName: 'productType', type: 'text' },
]

export default class KamCreateResetTemplateItems extends LightningElement {
    @api recordId;
    @track columns = columns;
    @track storeProductColumns = storeProductColumns;
    @track commercialActivityColumns = commercialActivityColumns;
    @track aptItems;
    @track loading = true;
    @track value = [];
    @track selectedAptResetItems = [];
    @track disablePreviousButton = false;
    @track disableNextButton = false;
    @track showPopup = false;
    @track page = 1;
    @track pages = [];
    perpage = 5;

    @wire(getAllAPTWithItemsProducts, { RetailStoreGrpID: '$recordId', SelectedRecordType: 'ResetActivityProcess' })
    wiredAptItems({ data, error }) {
        if (data) {
            const tempjson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
            this.aptItems = JSON.parse(tempjson);
            this.loading = false
        } else if (error) {
            console.log('error', error)
            this.showToast('ERROR', error.body.message, 'error');
        }
    }

    pageData = () => {
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);
        const result = this.aptItems.slice(startIndex, endIndex);

        if (result.length < this.perpage || result.length === 0) {
            this.disableNextButton = true;
        } else {
            this.disableNextButton = false;
        }
        if (page === 1) {
            this.disablePreviousButton = true;
        } else {
            this.disablePreviousButton = false;
        }
        return result;
    }

    handleCheckboxChange(e) {
        const selectedValue = e.target.value || '';

        const updatedAptItems = []
        this.aptItems && this.aptItems.forEach(item => {
            if (item.Id === selectedValue) {
                updatedAptItems.push({
                    ...item,
                    expanded: item.expanded !== null ? !item.expanded : true
                })
            } else {
                updatedAptItems.push({
                    ...item,
                })
            }
        })
        this.aptItems = updatedAptItems;

        const isAptExists = this.value && this.value.length > 0 ? this.value.includes(selectedValue) : false
        if (isAptExists) {
            this.value = this.value.filter(val => val !== selectedValue)
            this.selectedAptResetItems = this.selectedAptResetItems.filter(item => item.Id !== selectedValue)
        } else {
            this.value.push(selectedValue);
            this.selectedAptResetItems.push({ Id: selectedValue, name: '' })
        }
        const setAPTResetRows = [];
        if (this.selectedAptResetItems && this.selectedAptResetItems.length > 0) {
            setAPTResetRows.push(...this.selectedAptResetItems);
        }
        const actionPlanSelectionChangeEvent = new CustomEvent('actionplanresetselect', { detail: { setAPTResetRows: setAPTResetRows } });
        this.dispatchEvent(actionPlanSelectionChangeEvent);

    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleSelect(event) {
        const selectedRows = this.template.querySelectorAll('lightning-tree-grid');
        const selectedItems = [];
        selectedRows && selectedRows.forEach(row => {
            selectedItems.push(...row.getSelectedRows())
        })
        const setAPTIResetRows = [];
        for (var i = 0; i < selectedItems.length; i++) {
            setAPTIResetRows.push(selectedItems[i]);
        }
        console.log(setAPTIResetRows)
        const actionPlanSelectionChangeEvent = new CustomEvent('actionplanresetselect', { detail: { setAPTIResetRows: setAPTIResetRows } });
        this.dispatchEvent(actionPlanSelectionChangeEvent);
    }

    handleStoreProductsSelect(event) {
        const selectedRows = this.template.querySelectorAll(".store_products_reset");
        const selectedProducts = [];
        selectedRows && selectedRows.forEach(row => {
            selectedProducts.push(...row.getSelectedRows())
        })
        const actionPlanSelectionChangeEvent = new CustomEvent('actionplanresetselect', { detail: { setAPTResetProductRows: selectedProducts } });
        this.dispatchEvent(actionPlanSelectionChangeEvent);
    }

    handleCommercialItemsSelect(event) {
        const selectedRows = this.template.querySelectorAll(".commercial_products_reset");
        const selectedCommercialItems = [];
        selectedRows && selectedRows.forEach(row => {
            selectedCommercialItems.push(...row.getSelectedRows())
        })
        const actionPlanSelectionChangeEvent = new CustomEvent('actionplanresetselect', { detail: { setAPTResetCommercialItemRows: selectedCommercialItems } });
        this.dispatchEvent(actionPlanSelectionChangeEvent);
    }
    setPages = (data) => {
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }
    get hasPrev() {
        return this.page > 1;
    }
    get hasNext() {
        return this.page < this.pages.length
    }
    onNext = () => {
        ++this.page;
    }
    onPrev = () => {
        --this.page;
    }

    get currentPageData() {
        return this.pageData();
    }
}