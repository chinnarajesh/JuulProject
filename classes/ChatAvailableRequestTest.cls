/*******************************************************************************************
* @Name         ChatAvailableRequestTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         05/11/2020
* @Group        Customer Service
* @Description  This test class tests availability status of a chat button
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         05/11/2020         Initial Creation
*******************************************************************************************/
@IsTest
private class ChatAvailableRequestTest {
    @IsTest
    static void testBehavior() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetAgentAvailability');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        ChatAvailableRequest.checkAvailability('Spain', 'es', 'None');
    }
}