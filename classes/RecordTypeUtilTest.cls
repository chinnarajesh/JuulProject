/*******************************************************************************************
* @Name         RecordTypeUtilTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         11/14/2018 
* @Group        Customer Service
* @Description  Test class for RecordTypeUtil class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         11/14/2018          Initial Creation
*******************************************************************************************/
@isTest(seeAllData=false)
private class RecordTypeUtilTest {
    /**************************************************************************************
    * @Description this method creates the test setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @TestSetup static void setup() {
        //create accounts for US market
        List<Account> accountListUS = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438761';
            accountListUS.add(newAccountObj);
        }
       // insert accountListUS;
        //create and link cases with the accounts
        List<Case> caseListUS = new List<Case>();
        Integer accIndexUS = 0;
        for (Integer i = 0; i < 10; i++) {
            Case c = new Case(Description = 'description');
            if (accIndexUS >= accountListUS.size()) accIndexUS = 0;
            c.AccountId = accountListUS.get(accIndexUS).Id;
            accIndexUS++;
            caseListUS.add(c);
        }
       // insert caseListUS;
    }

    static testMethod void testAllMethods() {
        RecordTypeUtil.recordTypeMap('Case');
        RecordTypeUtil.recordTypeId('Case','Master');
    }
}