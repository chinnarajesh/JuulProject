/*/*******************************************************************************************
* @Name         LiveAgentServiceTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         03/30/2020
* @Group        Customer Service
* @Description  Test class for the live agent service class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         03/30/2020       Initial Creation
*******************************************************************************************/
@IsTest
private class LiveAgentServiceTest {

    @IsTest
    static void testBehavior() {
        LiveAgentService.getButtonBaseUrl();
        LiveAgentService.getButtonProperties('Spain','es','None');
    }
}