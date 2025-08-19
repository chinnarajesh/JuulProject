/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       05-17-2021                    */
/* Class Name: UndeleteContactBatch                       */
/* Description: Restrict user to delete Contact records  */
 /*Ticket Number:    */
/**********************************************************************/
public class UndeleteContactBatch implements Database.Batchable<sobject>, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id recTypeAccPerson;
        Map<String,Schema.RecordTypeInfo> rtMapAcc = Schema.SObjectType.Account.getRecordTypeInfosByName();
        recTypeAccPerson = rtMapAcc.get('Person Account').getRecordTypeId(); 
        System.debug('recTypeAccPerson-->' +recTypeAccPerson);
        String userName = 'Ownbackup User';
        String contactLst = 'SELECT Id, Name, IsDeleted, LastModifiedBy.Name FROM Contact WHERE LastModifiedBy.Name =:userName AND Account.RecordTypeId !=:recTypeAccPerson AND IsDeleted=True ALL ROWS'; //       LastModifiedBy.Name =:userName  AND
       return Database.getQueryLocator(contactLst);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> undeletedList = scope;
        undelete undeletedList;
       
    }
    
    public void finish(Database.BatchableContext BC){
        List<String> allemails =new List<String>();
            allemails.addAll((Label.OwnBackup_Email).split(';'));
            
            //Sending batch status details to recipient.
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed, TotalJobItems, CreatedBy.Email
                              from AsyncApexJob where Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(allemails);
            mail.setSubject('OwnBackup records batch status: ' + a.Status);
            String bodyText= 'Hi,' +'\n'+ 'Please find the status for Undeleted Contact Records batch below: '+'\n';
            bodyText +='Total Job Items: ' + a.TotalJobItems +'\n'+ 'Number of Job processed ' + a.JobItemsProcessed + ' with '+ a.NumberOfErrors + ' failures.\n';
            /*if(a.ExtendedStatus != null){
                bodyText += 'Error Message: ' +a.ExtendedStatus;
            }*/
            
            mail.setPlainTextBody(bodyText);
            //mail.setPlainTextBody('records processed ' + a.TotalJobItems + ' with '+ a.NumberOfErrors + ' failures. '+a.ExtendedStatus);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        UndeleteAssetBatch asstBatch = new UndeleteAssetBatch();
        Database.executeBatch(asstBatch);
    }


}