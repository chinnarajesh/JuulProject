/*******************************************************************************************
* @Name         HealthMention
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         10/24/2018
* @Group        Customer Service
* @Description  This is a REST Service to which the external systems post customer records
*               which could have a health mention. Records are then used to create cases
*               and assigned to the right queues.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         10/24/2018          Initial Creation
*******************************************************************************************/
@RestResource(UrlMapping='/customerops/healthmention/*')
global class HealthMention {
    /**************************************************************************************
     * @Description This method receives the payload from the external source & processes it
     * @Param   The JSON payload from the external system
     * @Return  A response with status and message
     **************************************************************************************/
    @HttpPost
    global static responseWrapper processPostReq() {
        responseWrapper responseJSON = new responseWrapper(); //responseWrapper object for API response
        RestRequest req = RestContext.request; //the RestRequest for the Apex REST method
        Blob requestBody = req.requestBody;
        String jsonBody = requestBody.toString(); //the body of the request
        List<CustomerInfoWrapper> wrapperList = new List<CustomerInfoWrapper>();
        wrapperList = CustomerInfoWrapper.parse(jsonBody);
        System.debug('parsed JSON--> ' + wrapperList);
        if (wrapperList.isEmpty()) {
            responseJSON.status = 'failed';
            responseJSON.message = 'No records parsed from this JSON';
        } else {
            System.enqueueJob(new HealthMentionQueueable(wrapperList));
            responseJSON.status = 'success';
            responseJSON.message = 'Job submitted for processing records';
        }
        return responseJSON;
    }

    //wrapper class for the response to an API request
    global class responseWrapper {
        global String status { get; set; } //status string
        global String message { get; set; } //message string
        //constructor
        global responseWrapper() {
            //default all values
            this.status = 'success';
            this.message = 'Default Response - No records processed';
        }
    }
}//end of class