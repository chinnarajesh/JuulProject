/*******************************************************************************************
* @Name         CaseByEmailTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         03/05/2019
* @Group        Customer Service
* @Description  Test class for CaseByEmail class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         03/05/2019          Initial Creation
*******************************************************************************************/
@IsTest(seeAllData=false)
private class CaseByEmailTest {
    /**************************************************************************************
     * @Description this method creates setup records
     * @Param   --none--
     * @Return  --none--
     **************************************************************************************/
    @testSetup static void setup() {
        //create accounts for US market
        List<Account> accountListUS = new List<Account>();
        List<Contact> contactListUS = new List<Contact>();
        for (Integer i = 0; i < 1; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438761';
            accountListUS.add(newAccountObj);
        }
            for(Account a :accountListUS){
                Integer i=0;  
            Contact con = new Contact();
        	con.LastName = 'Test' + i;
        	con.AccountId = a.id;
        	con.Type__c = 'Buyer';
       	    con.email='testing'+i+'@abc.com';
            contactListUS.add(con);
                i++;
        }
        system.debug(contactListUS.size());
            
       // insert accountListUS;
        //create cases
        List<Case> caseListUS = new List<Case>();
        for (Integer i = 0; i < 1; i++) {
            Case c = new Case(Description = 'description' + i, Case_Region__c = null, SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway0@mailinator.com');
            caseListUS.add(c);
        }
       insert caseListUS;
    }

    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointPositive() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String email = 'jamesconway0@mailinator.com';
        req.requestURI = '/services/apexrest/customerops/casebyemail?email='+email;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        CaseByEmail.getCaseId();
        Test.stopTest();
    }
}