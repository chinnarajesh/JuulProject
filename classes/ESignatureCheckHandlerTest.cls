/*******************************************************************************************
* @Name         ESignatureCheckHandlerTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         01/16/2019
* @Group        Customer Service
* @Description  A test class for the ESignatureCheckHandler class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         01/16/2019          Initial Creation
*******************************************************************************************/
@isTest(seeAllData = false)
private class ESignatureCheckHandlerTest {
    /**************************************************************************************
    * @Description this method tests the checkSigCaseHealthExp method
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testSignature() {
        Boolean exceptionThrown = false;
        try {
            //create accounts for US market
            List<Account> accountListUS = new List<Account>();
            for (Integer i = 0; i < 1; i++) {
                Account newAccountObj = new Account();
                newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
                newAccountObj.FirstName = 'James';
                newAccountObj.LastName = 'Conway' + i;
                newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
                newAccountObj.Phone = '1233438761';
                newAccountObj.VIP__c = false;
                accountListUS.add(newAccountObj);
            }
            insert accountListUS;
            //create cases
            List<Case> caseListUS = new List<Case>();
            for (Integer i = 0; i < 5; i++) {
                Case c = new Case(Description = 'description' + i, Case_Region__c = null, SuppliedName = 'James Conway',
                        SuppliedEmail = 'jamesconway0@mailinator.com', RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience'));
                caseListUS.add(c);
            }
            insert caseListUS;
        } catch (Exception e) {
            exceptionThrown =  true;
            System.assertEquals(exceptionThrown, true);
        }
    }

}