/*******************************************************************************************
* @Name         CustomerInfoWrapper
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         12/10/2018
* @Group        Customer Service
* @Description  A wrapper class to deserialize the incoming XDSR JSON object
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/10/2018          Initial Creation
*******************************************************************************************/
//wrapper class to deserialize incoming JSON payload into a salesforce object
/* Sample incoming JSON
        [
          {
            "email_address": "someone@example.com",
            "phone_number": "1234567890",
            "first_name": "first",
            "last_name": "last",
            "text_content": "content",
            "date_received": "2012-04-23T18:25:43.511Z",
            "submission_channel": "channel",
            "health_event_mentioned": true,
            "health_event_keywords": "keywords",
            "do_not_contact": true
          },
          {
            "email_address": "someone@example.com",
            "phone_number": "1234567890",
            "first_name": "first",
            "last_name": "last",
            "text_content": "content",
            "date_received": "2012-04-23T18:25:43.511Z",
            "submission_channel": "channel",
            "health_event_mentioned": true,
            "health_event_keywords": "keywords",
            "do_not_contact": true,
            "id" : "123abc",
            "market" : "united states",
            "language" : "english"
          }
        ]
 */
public class CustomerInfoWrapper {

    public String email_address;
    public String phone_number;
    public String first_name;
    public String last_name;
    public String text_content;
    public String date_received;
    public String submission_channel;
    public Boolean health_event_mentioned;
    public String health_event_keywords;
    public Boolean do_not_contact;
    public String id;
    public String country;
    public String language;
    public String uuid;

    public static List<CustomerInfoWrapper> parse(String json) {
        System.debug('incoming json--> ' + json);
        return (List<CustomerInfoWrapper>) System.JSON.deserialize(json, List<CustomerInfoWrapper>.class);
    }
}