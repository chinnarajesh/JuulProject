/*******************************************************************************************
* @Name         HealthMentionTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         12/10/2018
* @Group        Customer Service
* @Description  A test class for the HealthMention REST API
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/10/2018          Initial Creation
*******************************************************************************************/
@IsTest(SeeAllData = false)
private class HealthMentionTest {
    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointPositive() {
        //create accounts for US market
        ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
        List<Account> accountListUS = new List<Account>();
        for (Integer i = 0; i < 1; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.Phone = '1233438761';
            newAccountObj.PersonEmail = 'jamesconway111@mailinator.com';
            newAccountObj.Email_UID__c = 'jamesconway111@mailinator.com';
            accountListUS.add(newAccountObj);
        }
        insert accountListUS;
        CustomerInfoWrapper wrapperObj = new CustomerInfoWrapper();
        wrapperObj.phone_number = '1233438761';
        wrapperObj.first_name = 'James';
        wrapperObj.last_name = 'Conway0';
        wrapperObj.email_address = 'jamesconway111@mailinator.com';
        //wrapperObj.date_received = String.valueOf(Date.newInstance(2018,12,10));
        wrapperObj.submission_channel = 'Focus Group';
        wrapperObj.health_event_mentioned = true;
        wrapperObj.id = '123';
        wrapperObj.country = 'United States';
        //wrapperObj.language = 'English';
        List<CustomerInfoWrapper> custList = new List<CustomerInfoWrapper>();
        custList.add(wrapperObj);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/healthmention';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(custList));
        RestContext.request = req;
        RestContext.response = res;
        HealthMention.processPostReq();
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointNegative() {
        Test.startTest();
              ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        try {
            //create accounts for US market
            List<Account> accountListUS = new List<Account>();
            for (Integer i = 0; i < 1; i++) {
                Account newAccountObj = new Account();
                newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
                newAccountObj.FirstName = 'James';
                newAccountObj.LastName = 'Conway' + i;
                newAccountObj.Phone = '1233438761';
                accountListUS.add(newAccountObj);
            }
            insert accountListUS;
            CustomerInfoWrapper wrapperObj = new CustomerInfoWrapper();
            List<CustomerInfoWrapper> custList = new List<CustomerInfoWrapper>();
            custList.add(wrapperObj);

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/customerops/healthmention';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(custList));
            RestContext.request = req;
            RestContext.response = res;
            HealthMention.processPostReq();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description this method tests the HTTP POST endpoint
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testEndpointNoAccountWithPhone() {
        CustomerInfoWrapper wrapperObj = new CustomerInfoWrapper();
        wrapperObj.phone_number = '1233438761';
        wrapperObj.first_name = 'James';
        wrapperObj.last_name = 'Conway0';
        //wrapperObj.email_address = 'jamesconway@mailinator.com';
        //wrapperObj.date_received = String.valueOf(Date.newInstance(2018,12,10));
        wrapperObj.submission_channel = 'Focus Group';
        wrapperObj.health_event_mentioned = true;
        wrapperObj.id = '123';
        wrapperObj.country = 'United States';
        //wrapperObj.language = 'English';
        List<CustomerInfoWrapper> custList = new List<CustomerInfoWrapper>();
        custList.add(wrapperObj);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/healthmention';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(custList));
        RestContext.request = req;
        RestContext.response = res;
        HealthMention.processPostReq();
        Test.stopTest();
    }

    /**************************************************************************************
   * @Description this method tests the HTTP POST endpoint
   * @Param   --none--
   * @Return  --none--
   **************************************************************************************/
    static testMethod void testEndpointNoAccountWithEmail() {
        CustomerInfoWrapper wrapperObj = new CustomerInfoWrapper();
        //wrapperObj.phone_number = '1233438761';
        wrapperObj.first_name = 'James';
        wrapperObj.last_name = 'Conway0';
        wrapperObj.email_address = 'jamesconway1232@mailinator.com';
        //wrapperObj.date_received = String.valueOf(Date.newInstance(2018,12,10));
        wrapperObj.submission_channel = 'Focus Group';
        wrapperObj.health_event_mentioned = true;
        wrapperObj.id = '123';
        wrapperObj.country = 'United States';
        //wrapperObj.language = 'English';
        List<CustomerInfoWrapper> custList = new List<CustomerInfoWrapper>();
        custList.add(wrapperObj);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customerops/healthmention';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(custList));
        RestContext.request = req;
        RestContext.response = res;
        HealthMention.processPostReq();
        Test.stopTest();
    }
}