/*******************************************************************************************
 * @Name         ChatWithUs
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         02/03/2020
 * @Group        Customer Service
 * @Description  This is a LWC which allows customers to click the chat with us button
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         02/03/2020        Initial Creation
*******************************************************************************************/
import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import chatWithUs from '@salesforce/label/c.Chat_With_Us';
import MF8to5 from '@salesforce/label/c.MF8to5';
import SM9to5 from '@salesforce/label/c.SM9to5';

import MF9to6 from '@salesforce/label/c.MF9to6';
import MF09to17 from '@salesforce/label/c.MF09to17';
import MF10to18 from '@salesforce/label/c.MF10to18';
import MS6to10 from '@salesforce/label/c.MS6to10';
import MS6to6 from '@salesforce/label/c.MS6to6';
import MS9to17 from '@salesforce/label/c.MS9to17';
import SS10to7 from '@salesforce/label/c.SS10to7';
import MF9to6EST from '@salesforce/label/c.MF9to6EST';
import MF9to5 from '@salesforce/label/c.MF9to5';
import MF10to3 from '@salesforce/label/c.MF10to3';
import MonSat6to6 from '@salesforce/label/c.MonSat6to6';
import MonFri9to6 from '@salesforce/label/c.MonFri9to6';
import checkAvailabilityFromServer from '@salesforce/apex/ChatAvailableRequest.checkAvailability';

export default class ChatWithUs extends NavigationMixin(LightningElement) {

    @track chatDisabled = true;
    @api country;
    @api language;
    @api issueType;
    @track ireland = false;
    @track indonesia = false;
    @track spain = false;
    @track canada = false;
    @track philippines = false;
    @track skorea = false;
    @track usa = false;
    @track uk = false;
    @track switzerland = false;
    @track ukraine = false;
    @track germany = false;
    @track poland = false;
    @track austria = false;
    @track belgium = false;
    @track france = false;
    @track china = false;
    @track czech = false;
    @track portugal = false;
    @track canadaFr = false;

    label = {
        chatWithUs,
        MF8to5,
        SM9to5,
        MF9to6,
        MS6to10,
        SS10to7,
        MF09to17,
        MF10to18,
        MS6to6,
        MS9to17,
        MF9to6EST,
        MF9to5,
        MF10to3,
        MonSat6to6,
        MonFri9to6
    };

    connectedCallback() {
        const countryFromFlow = this.country;
        this.checkAvailability();//check availability
        console.log('ChatWithUslang-> ', this.language);
        console.log('ChatWithUscountry-> ', countryFromFlow);
        console.log('ChatWithUsissueType-> ', this.issueType);
        switch (countryFromFlow) {
            case "Ireland" :
                this.ireland = true;
                break;
            case "Indonesia" :
                this.indonesia = true;
                break;
            case "Spain" :
                this.spain = true;
                break;
            case "Philippines" :
                this.philippines = true;
                break;
            case "South Korea" :
                this.skorea = true;
                break;
            case "United States" :
                this.usa = true;
                break;
            case "United Kingdom" :
                this.uk = true;
                break;
            case "Switzerland" :
                this.switzerland = true;
                break;
            case "Ukraine" :
                this.ukraine = true;
                break;
            case "Germany" :
                this.germany = true;
                break;
            case "Poland" :
                this.poland = true;
                break;
            case "Austria" :
                this.austria = true;
                break;
            case "Belgium" :
                this.belgium = true;
                break;
            case "France" :
                this.france = true;
                break;
            case "China" :
                this.china = true;
                break;
            case "Czech Republic" :
                this.czech = true;
                break;
            case "Portugal" :
                this.portugal = true;
                break;
        }
        if (countryFromFlow === 'Canada') {
            if (this.language === 'fr_CA') {
                this.canadaFr = true;
            } else {
                this.canada = true;
            }
        }
    }

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const actionSelection = 'Chat';//for chat cases
        const selectEvent = new CustomEvent("chatselect", {
            detail: actionSelection
        });
        this.dispatchEvent(selectEvent);
    }

    checkAvailability() {
        //UPDATE : No need to check chat availability based on working hours; Only need to check based on Agent Availability//
        // checkChatWorkingHours({
        //     country: this.country,
        //     language: this.language
        // })
        //     .then(result => {
        //         this.chatDisabled = result;
        //         console.log('chat outside working hours: ' + result);
        //     })
        //     .catch((error) => {
        //         this.message = 'Error received: code' + error.errorCode + ', ' +
        //             'message ' + error.body.message;
        //         console.log(this.message);
        //     });
        //now check based on agent availability in the queue
        checkAvailabilityFromServer({
            market: this.country,
            language: this.language,
            issueType: this.issueType
        })
            .then(result => {
                if (result) {
                    console.log(result);
                    const availabilityObj = JSON.parse(result);
                    //console.log('chatDisabled before-> ', this.chatDisabled);
                    this.chatDisabled = !(availabilityObj.messages[0].message.buttons[0].isAvailable);//NOT operator
                    console.log('available for chat: ' + availabilityObj.messages[0].message.buttons[0].isAvailable);
                    //console.log('chatDisabled after-> ', this.chatDisabled);
                } else {
                    console.log('no response from API');
                }
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
                console.log(this.message);
            });
    }
}