/*******************************************************************************************
 * @Name         InvocableCustomerSupportCommunities
 * @Author       Rayan Rao <rayan.rao@juul.com>
 * @Date         02/12/2020
 * @Group        Customer Service
 * @Description  This service returns case number based on case ID
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Rayan         02/12/2020         Initial Creation
* 	1.0.1            Sahil         02/13/2020         Code Prettified using IDE
*******************************************************************************************/
global without sharing class InvocableCustomerSupportCommunities {

    global class Requests {
        @InvocableVariable(label='Input - CaseID' description='Input - Case ID' required=true)
        public String inputCaseID;
    }

    global class Results {
        @InvocableVariable(label='Output - CaseNumber' description='Output - Case Number' required=true)
        public String outputCaseNumber;
    }


    @InvocableMethod
    global static List <Results> execute(List<Requests> requestList) {

        //Get CaseID from Request Object
        String caseID = requestList[0].inputCaseID;

        // Get CaseNumber
        List<Case> listCaseNumbers = [SELECT Id, CaseNumber FROM CASE WHERE Id = :caseID];
        String caseNumber = listCaseNumbers[0].CaseNumber;

        //Create a Results object to hold the return values
        Results response = new Results();

        //Add the return value to the Results object
        response.outputCaseNumber = caseNumber;

        //Wrap the Results object in a List container
        List<Results> responseWrapper = new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    }
}