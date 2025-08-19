/*******************************************************************************************
* @Name         AgentHOOPsTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         03/30/2020
* @Group        Customer Service
* @Description  Test class for AgentHOOPs class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         03/30/2020         Initial Creation
*   2.0              Satabhisa     13/02/2025         Modification
*******************************************************************************************/
@IsTest
private class AgentHOOPsTest {
    

    @isTest(SeeAllData=true)
    static void testBehavior() {
        
        
        AgentHOOPs.checkCallHOOP('United States', 'en_US');
        AgentHOOPs.checkCallHOOP('Austria', 'de_AT');
        AgentHOOPs.checkCallHOOP('Canada', 'en_US');
	    AgentHOOPs.checkCallHOOP('Canada', 'fr_CA');
        AgentHOOPs.checkCallHOOP('United Kingdom', 'en_US');
    }           
}