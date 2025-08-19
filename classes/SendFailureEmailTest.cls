/*******************************************************************************************
* @Name         SendFailureEmailTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         12/04/2018
* @Group        Customer Service
* @Description  Test class for SendFailureEmail class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/04/2018          Initial Creation
*******************************************************************************************/
@IsTest(seeAllData=false)
private class SendFailureEmailTest {
    /**************************************************************************************
    * @Description this method tests sending the email
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    private static testMethod void testSendEmail() {
        List<String> emailsList = new List<String>();
        emailsList.add('sahil.chaudhry@juul.com');
        SendFailureEmail.sendEmailForCase('description',emailsList);
    }
}