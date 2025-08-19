/*******************************************************************************************
* @Name         ZendeskSiteUserWrapper
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         07/17/2019
* @Group        Customer Service
* @Description  A wrapper class to deserialize the incoming Zendesk User JSON object
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         07/17/2019          Initial Creation
*******************************************************************************************/
public class ZendeskSiteUserWrapper {

    public Datetime timestamp;
    public String locale;

    public static ZendeskSiteUserWrapper parse(String json) {
        System.debug('incoming json--> ' + json);
        return (ZendeskSiteUserWrapper) System.JSON.deserialize(json, ZendeskSiteUserWrapper.class);
    }
}