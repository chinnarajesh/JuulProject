/*******************************************************************************************
* @Name         SendFailureEmail
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         12/04/2018
* @Group        Customer Service
* @Description  This class is used to send error messages generated from the transactions to
*               specific email addresses configured in custom metadata type
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/04/2018          Initial Creation
*******************************************************************************************/
public with sharing class SendFailureEmail {
    /**************************************************************************************
    * @Description this method sends the email
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    public static void sendEmailForCase(String emailDescription, List<String> emailsList) {
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailsList);
        mail.setSubject('Case Insert/Update Failed');
        mail.setPlainTextBody(emailDescription);
        messages.add(mail);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}