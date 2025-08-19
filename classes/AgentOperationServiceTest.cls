/*******************************************************************************************
* @Name         AgentOperationServiceTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         07/22/2019
* @Group        Customer Service
* @Description  Test class for AgentOperationService class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         07/22/2019          Initial Creation
*******************************************************************************************/
@IsTest(seeAllData=false)
private class AgentOperationServiceTest {
    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointWeekdayAll() {
        String payload =
                '{'+
                '"timestamp": "2016-10-27T16:27:02.000Z",'+
                '"locale": "en-ie"'+
                '}';
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/agentoperation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        RestContext.response = res;
        AgentOperationService.getAvailability();
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointWeekdayIsrael() {
        String payload =
                '{'+
                        '"timestamp": "2016-10-27T16:27:02.000Z",'+
                        '"locale": "he"'+
                        '}';
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/agentoperation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        RestContext.response = res;
        AgentOperationService.getAvailability();
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointWeekendAll() {
        String payload =
                '{'+
                        '"timestamp": "2016-10-30T16:27:02.000Z",'+
                        '"locale": "en-ie"'+
                        '}';
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/agentoperation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        RestContext.response = res;
        AgentOperationService.getAvailability();
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointWeekendIsrael() {
        String payload =
                '{'+
                        '"timestamp": "2016-10-29T16:27:02.000Z",'+
                        '"locale": "he"'+
                        '}';
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/agentoperation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        RestContext.response = res;
        AgentOperationService.getAvailability();
        Test.stopTest();
    }
}