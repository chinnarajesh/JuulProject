/*******************************************************************************************
* @Name         HealthMentionQueueable
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         02/12/2019
* @Group        Customer Service
* @Description  This class processes incoming health mention customer records asynchronously
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         02/12/2019          Initial Creation
*******************************************************************************************/
public with sharing class HealthMentionQueueable implements Queueable {
    List<CustomerInfoWrapper> customerRecsList = new List<CustomerInfoWrapper>();

    /**************************************************************************************
     * @Description This is the constructor of the class
     * @Param   List<CustomerInfoWrapper>
     * @Return  N/A
     **************************************************************************************/
    public HealthMentionQueueable(List<CustomerInfoWrapper> customerRecs) {
        this.customerRecsList = customerRecs;
    }

    /**************************************************************************************
     * @Description This method executes the processes asynchronously
     * @Param   QueueableContext
     * @Return  N/A
     **************************************************************************************/
    public void execute(QueueableContext context) {
        try {
            List<XDSR__c> xdsrObjList = new List<XDSR__c>();
            //process the list to get a set of emails or phones as keys, to create or retrieve person accounts
            Map<String, Account> mapOfKeyToPersAcc = PersonAccountService.upsertPersonAccUsingXDSR(customerRecsList);
            //get the queue which should be the owner of the XDSR record
            Id xdsrReviewQueueId;
            List<Group> groupList = [SELECT Id,Name FROM Group WHERE DeveloperName = 'US_CRT_XDSR_Needs_Review' LIMIT 1];
            if (!groupList.isEmpty()) {
                xdsrReviewQueueId = groupList[0].Id;
            }
            System.debug('final persAcc map before inserting XDSR--> ' + mapOfKeyToPersAcc);
            String emailLowerCase;
            for (CustomerInfoWrapper c : customerRecsList) {
                if (String.isBlank(c.id) && String.isBlank(c.uuid)) {
                    throw new HealthMentionQueueableException('ID is required');
                }
                if (String.isNotBlank(c.email_address)) emailLowerCase = c.email_address.toLowerCase();
                XDSR__c xdsrObj = new XDSR__c();
                //set account id based on email or phone
                if (String.isNotBlank(emailLowerCase)) {
                    xdsrObj.Account__c = mapOfKeyToPersAcc.get(emailLowerCase).Id;
                } else if (String.isNotBlank(c.phone_number)) {
                    xdsrObj.Account__c = mapOfKeyToPersAcc.get(c.phone_number).Id;
                }
                xdsrObj.External_ID__c = c.id;
                if (c.do_not_contact != null) xdsrObj.Do_Not_Contact__c = c.do_not_contact;
                if (String.isNotBlank(emailLowerCase) && DataUtility.checkEmail(emailLowerCase)) {
                    xdsrObj.Email__c = emailLowerCase;
                }
                if (String.isNotBlank(c.first_name)) xdsrObj.First_Name__c = c.first_name;
                if (String.isNotBlank(c.last_name)) xdsrObj.Last_Name__c = c.last_name;
                if (String.isNotBlank(c.health_event_keywords)) xdsrObj.Health_Event_Keyword__c = c.health_event_keywords;
                if (c.health_event_mentioned != null) xdsrObj.Health_Mention__c = c.health_event_mentioned;
                if (String.isNotBlank(c.phone_number)) xdsrObj.Phone__c = c.phone_number;
                if (String.isNotBlank(c.text_content)) xdsrObj.Text_Body__c = c.text_content;
                if (String.isNotBlank(c.submission_channel)) {
                    Id recTypeId = RecordTypeUtil.recordTypeId('XDSR__c', c.submission_channel);
                    if (recTypeId != null) xdsrObj.RecordTypeId = recTypeId;
                    xdsrObj.Submission_Channel__c = c.submission_channel;
                    //for quality survey records, external Id will be from the uuid field instead of id field
                    if (c.submission_channel == 'Quality Survey') {
                        xdsrObj.External_ID__c = c.uuid;
                    }
                }
                if (String.isNotBlank(c.date_received)) {
                    xdsrObj.XDSR_Created_Date__c = Datetime.valueOf(c.date_received);
                }
                if (xdsrReviewQueueId != null) xdsrObj.OwnerId = xdsrReviewQueueId;
                if (String.isNotBlank(c.country)) xdsrObj.Market__c = c.country;
                if (String.isNotBlank(c.language)) {
                    xdsrObj.Language_Preference__c = c.language;
                } else {
                    xdsrObj.Language_Preference__c = 'English';
                }
                xdsrObjList.add(xdsrObj);
            }
            List<Database.UpsertResult> resultList = Database.upsert(xdsrObjList, XDSR__c.fields.External_ID__c, false);
            for (Database.UpsertResult re : resultList) {
                if (re.getErrors().size() > 0) {
                    for (Database.Error er : re.getErrors()) {
                        System.debug('XDSR Upsert Error message--> ' + er.getMessage());
                        throw new HealthMentionQueueableException(er.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception--> ' + e.getMessage());
            EventLogger.log(e);
            if (!Test.isRunningTest()) throw e;
        }
    }

    public class HealthMentionQueueableException extends Exception {
    }
}