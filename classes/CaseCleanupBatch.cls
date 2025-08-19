/*******************************************************************************************
* @Name         CaseCleanupBatch
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         11/01/2018
* @Group        Customer Service
* @Description  A batch which cleans up & update Case records based on requirements
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         11/01/2018          Initial Creation
*******************************************************************************************/
global class CaseCleanupBatch implements Database.Batchable<sObject> {
    /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get the case created date from metadata type
        List<Case_Created_Date__mdt> caseCreatedMdtList = [SELECT CreatedDate__c FROM Case_Created_Date__mdt LIMIT 1];
        if (!caseCreatedMdtList.isEmpty()) Date createdDate = caseCreatedMdtList[0].CreatedDate__c;
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Case_Region__c, Market__c FROM Case WHERE CreatedDate >=: createdDate';
        return Database.getQueryLocator(query);
    }
    /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Case>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext bc, List<Case> records) {
        //emails list for errors
        List<Error_Emails_List__mdt> mdtList = [SELECT Email__c FROM Error_Emails_List__mdt];
        List<String> emailsList = new List<String>();
        for (Error_Emails_List__mdt el : mdtList) {
            emailsList.add((String) el.Email__c);
        }
        try {
            // process each batch of records
            List<Case> caseRecsToUpdate = new List<Case>();
            for (Case c : records) {
                if (String.isBlank(c.Case_Region__c) || String.isBlank(c.Market__c)) {
                    switch on c.Market__c {
                        when 'Israel' {
                            c.Case_Region__c = 'EMEA';
                        }
                        when 'United Kingdom' {
                            c.Case_Region__c = 'EMEA';
                        }
                        when 'United States' {
                            c.Case_Region__c = 'NOAM';
                        }
                        when 'Canada' {
                            c.Case_Region__c = 'NOAM';
                        }
                        when 'Russia' {
                            c.Case_Region__c = 'EMEA';
                        }
                        when 'Switzerland' {
                            c.Case_Region__c = 'EMEA';
                        }
                        when 'Germany' {
                            c.Case_Region__c = 'EMEA';
                        }
                        when 'France' {
                            c.Case_Region__c = 'EMEA';
                        }
                        when else {
                            c.Market__c = 'United States';
                            c.Case_Region__c = 'NOAM';
                        }
                    }
                    caseRecsToUpdate.add(c);
                }
            }
            if (caseRecsToUpdate.size() > 0) {
                //update with partial record saving
                Database.SaveResult[] resultList = Database.update(caseRecsToUpdate, false);
                for (Database.SaveResult re : resultList) {
                    if (re.getErrors().size() > 0) {
                        //loop through database.error
                        for (Database.Error err : re.getErrors()) {
                            throw new CaseCleanupBatchException('Case Update Failed. Error Message: '+err.getMessage()+
                                    '. Fields: ' + err.getFields());
                        }
                    }
                }
            }
        } catch (Exception e) {
            //send email
            SendFailureEmail.sendEmailForCase(e.getMessage(),emailsList);
        }
    }
    /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext bc) {
    // execute any post-processing operations
    }

    public class CaseCleanupBatchException extends Exception {
    }

}