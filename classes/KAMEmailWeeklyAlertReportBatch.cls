/************************************************************************************/
/* VERSION     AUTHOR                  DATE                           				*/
/*  1.0	     Pushkar Gangwar         06-18-2020                     				*/
/* Class Name: KAMEmailWeeklyAlertReportBatch                    					*/
/* Description: Send Weekly email to account team memebers for Alert reports		*/
/************************************************************************************/
global class KAMEmailWeeklyAlertReportBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String addition  = '\'Hierarchy Addition\'';
		String subtraction  = '\'Hierarchy Subtraction\'';
		String Query = 'SELECT Id, AccountId__c FROM AccountOrGroupAlert__c ';
        if(!Test.isRunningTest()){
			Query += ' WHERE (AlertType__c LIKE '+addition+ ' OR AlertType__c LIKE '+ subtraction+ ') AND CreatedDate = THIS_WEEK';            
        }        
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, list<AccountOrGroupAlert__c> thisWeekgroupAlerts){
        set<Id> accountIds = new set<Id>();
        for(AccountOrGroupAlert__c groupAlert : thisWeekgroupAlerts){
            accountIds.add(groupalert.AccountId__c);
        }
        //sending account IDs to get teams memeber emails and send report link
        KAMEmailWeeklyReportHelper.sendAlertReportEmail(accountIds);
    }

	global void finish(Database.BatchableContext BC){
		// Fetching Email Ids from metadata to send the batch ststus
        List<KAMBatchMetaDataSetting__mdt> recipientEmailAddress = [SELECT Email__c FROM KAMBatchMetaDataSetting__mdt];
        List<String> allemails =new List<String>();
        for(KAMBatchMetaDataSetting__mdt mdtEmail : recipientEmailAddress){
        	allemails.add(mdtEmail.Email__c);
        }
        //Sending batch status details to recipient.
		AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed, TotalJobItems, CreatedBy.Email
        	from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(allemails);
        mail.setSubject('Email weekly alert reports for account team batch status: ' + a.Status);
        String bodyText= 'Hi,' +'\n'+ 'Please find the status for Email weekly alert report batch below: '+'\n';
        bodyText +='Total Job Items: ' + a.TotalJobItems +'\n'+ 'Number of Job processed ' + a.JobItemsProcessed + ' with '+ a.NumberOfErrors + ' failures.\n';
        if(a.ExtendedStatus != null){
			bodyText += 'Error Message: ' +a.ExtendedStatus;
        }
        mail.setPlainTextBody(bodyText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    
}