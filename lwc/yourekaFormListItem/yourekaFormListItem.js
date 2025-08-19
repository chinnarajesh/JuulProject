import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class YourekaFormListItem extends NavigationMixin(LightningElement) {
    // Form Template
    @api form;
    @api recordId;
    @api objectName;
    // Field Link Relationship
    @api objectLookup;
    // Lookup field
    @api lookupField;
    // Gets the current UI Theme for the user to help determine LEX and Mobile experience
    @api uiTheme;
    // The Mobile Youreka App URL
    yourekaAppUrl = 'https://yourekaapp.app.link/LseujdfKMK';
    // The VF page for creating a new Youreka Form
    apexUrl = '/apex/disco__NewForm?templateID=';

    handleClick(event) {
        // Represents Salesforce link in Classic/LEX
        let url = '';
        // Represents Salesforce link in Mobile
        let deepUrl = '';
        let lookup;

        // Gets the value on the form for the lookupField or returns undefined
        if(this.lookupField && this.form) {
            lookup = this.lookupField.split('.').reduce((r, val) => { 
                return r ? r[val] : undefined; }, 
                this.form
            );
        }

        if(this.apexUrl) {
            if(lookup) {
                url = this.apexUrl + this.form.Id + '&' + this.objectLookup + '=' + this.recordId +
                    '&' + lookup + '=' + this.recordId;
    
                deepUrl = this.yourekaAppUrl + '?newForm=true&templateId=' + this.form.Id + '&' +
                    '&' + this.objectLookup + '=' + this.recordId + '&' + lookup + '=' +
                    this.recordId;
            } else {
                url = this.apexUrl + this.form.Id + '&' + this.objectLookup + '=' + this.recordId;
                deepUrl = this.yourekaAppUrl + '?newForm=true&templateId=' + this.form.Id + '&' +
                    this.objectLookup + '=' + this.recordId;
            }
        }

        let isSF1 = this.uiTheme === 'Theme4t' ? true : false;
        let isLEX = this.uiTheme === 'Theme4d' ? true : false;
        if(isSF1) {
            this.navigateToUrl(deepUrl);
        } else if(isLEX) {
            this.navigateToUrl(url);
        } else {
            window.location.href = url;
        }
    }

    navigateToUrl(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }
}