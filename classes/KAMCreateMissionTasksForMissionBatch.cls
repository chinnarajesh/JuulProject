/************************************************************************/
/* VERSION     AUTHOR                  DATE                           	*/
/*  1.0	     Pushkar Gangwar         05-20-2020                     	*/
/* Class Name: KAMCreateMissionTaskForVisitBatch                    	*/
/* Description: To process Daily Mission Tasks and Action Plan Item for Visit Created In Last 24 Hours  							 	  	*/
/************************************************************************/
global class KAMCreateMissionTasksForMissionBatch implements Database.Batchable<sObject> {
    global String overrideQuery = '';
    global KAMCreateMissionTasksForMissionBatch(String overrideQuery){
        this.overrideQuery  = overrideQuery;
    }
    global KAMCreateMissionTasksForMissionBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, ActionPlanTemplateId__c, Mission__c FROM ActionPlan__c '; 
       	query += 'WHERE '; 
       	query += 'isProcessed__c = false'; 
        if(overrideQuery != null &&  overrideQuery != ''){
            query += ' AND '+overrideQuery;
        }
        system.debug('query-- '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ActionPlan__c> actionPlanRecords){
        if(actionPlanRecords.size() > 0){
            //calling helper class to process the batch execution
          	KAMCreateMissionTaskHelper.getMissionAndActionPlanTemplateItems(actionPlanRecords);
        }
    }     
    global void finish(Database.BatchableContext bc){
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
            mail.setSubject('Mission Task record creation batch status: ' + a.Status);
        	String bodyText= 'Hi,' +'\n'+ 'Please find the status for Mission Task and Action Plan Item Record Creation batch below: '+'\n';
        	bodyText +='Total Job Items: ' + a.TotalJobItems +'\n'+ 'Number of Job processed ' + a.JobItemsProcessed + ' with '+ a.NumberOfErrors + ' failures.\n';
        	if(a.ExtendedStatus != null){
				bodyText += 'Error Message: ' +a.ExtendedStatus;
        	}

        	mail.setPlainTextBody(bodyText);
            //mail.setPlainTextBody('records processed ' + a.TotalJobItems + ' with '+ a.NumberOfErrors + ' failures. '+a.ExtendedStatus);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }    
}