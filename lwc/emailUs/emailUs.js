/*******************************************************************************************
 * @Name         EmailUs
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         01/29/2020
 * @Group        Customer Service
 * @Description  This is a LWC which allows customers to click the email us button
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         01/29/2020        Initial Creation
*******************************************************************************************/
import {LightningElement} from 'lwc';
import emailUs from '@salesforce/label/c.Email_Us';

export default class EmailUs extends LightningElement {
    label = {
        emailUs
    };

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const actionSelection = 'Email';//for email cases
        const selectEvent = new CustomEvent("emailselect", {
            detail: actionSelection
        });
        this.dispatchEvent(selectEvent);
    }
}