/*******************************************************************************************
* @Name         CaseByEmail
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         01/09/2019
* @Group        Customer Service
* @Description  This is a REST Service which returns a recently created case based on
*               the customer's email
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         01/09/2019          Initial Creation
*******************************************************************************************/
@RestResource(UrlMapping='/customerops/casebyemail/*')
global class CaseByEmail {
    /**************************************************************************************
     * @Description This method receives an email from the external system & returns CaseID
     * @Param   Customer's email as string
     * @Return  Case ID or error message
     **************************************************************************************/
    @HttpGet
    global static String getCaseId() {
        //SOQL for the case created in the last 1 minute for the customer
        List<Case> caseList = [
                SELECT Id, Contact.Email
                FROM Case
                WHERE CreatedDate >= :Datetime.now().addMinutes(-1)
                        AND Contact.Email = :RestContext.request.params.get('email')
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        //if case found,return it; otherwise return no record
        if (!caseList.isEmpty()) {
            return (String) caseList[0].Id;
        } else {
            return 'No record';
        }
    }
}