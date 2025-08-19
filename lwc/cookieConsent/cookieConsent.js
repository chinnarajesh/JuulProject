/*******************************************************************************************
 * @Name         ChatIndependent
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         08/03/2020
 * @Group        Customer Service
 * @Description  This is a LWC which opens cookie consent settings (third party)
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         08/03/2020       Initial Creation
*******************************************************************************************/
import {LightningElement, api} from 'lwc';

export default class CookieConsent extends LightningElement {

    @api cookieSettingLabel;

    handleClick(event) {
        //Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        Cookiebot.renew();
    }
}