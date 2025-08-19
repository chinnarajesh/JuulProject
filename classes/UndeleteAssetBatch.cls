/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       05-17-2021                    */
/* Class Name: UndeleteAssetBatch                       */
/* Description: Restrict user to delete Asset records  */
/*Ticket Number:     */
/**********************************************************************/
public class UndeleteAssetBatch implements Database.Batchable<sobject>, Database.Stateful{
     //public List<SObject> passRecord;
    public integer i=0;
         public integer j=0;
    public List<Id> passRecord = new List<Id>() ;
    public List<Id> failRecord = new List<Id>() ;
    public Database.QueryLocator start(Database.BatchableContext BC){
        String userName = 'Ownbackup User';
        String assetLst = 'SELECT Id, Name, IsDeleted, LastModifiedBy.Name FROM Asset WHERE LastModifiedBy.Name =:userName AND IsDeleted=True ALL ROWS'; //LastModifiedBy.Name =:userName  AND
        return Database.getQueryLocator(assetLst);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope){
        List<Asset> undeletedAssetList = scope;
        undelete undeletedAssetList;
        
      /*  Database.UndeleteResult[] myRecords = Database.undelete(undeletedAssetList, false);
        for (Database.UndeleteResult sr : myRecords) {
            if (sr.isSuccess()) {
                i++;
                // Operation was successful, so get the ID of the record that was processed
				//passRecord.add(sr.)                
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    j++;
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        } */
            
        }
        
        public void finish(Database.BatchableContext Bc){
            List<String> allemails =new List<String>();
            allemails.addAll((Label.OwnBackup_Email).split(';'));
            
            //Sending batch status details to recipient.
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed, TotalJobItems, CreatedBy.Email
                              from AsyncApexJob where Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(allemails);
            mail.setSubject('OwnBackup records batch status: ' + a.Status);
            String bodyText= 'Hi,' +'\n'+ 'Please find the status for Undeleted Asset Records batch below: '+'\n';
            bodyText +='Total Job Items: ' + a.TotalJobItems +'\n'+ 'Number of Job processed ' + a.JobItemsProcessed + ' with '+ a.NumberOfErrors + ' failures.\n';
            /*if(a.ExtendedStatus != null){
                bodyText += 'Error Message: ' +a.ExtendedStatus;
            }*/
            
            mail.setPlainTextBody(bodyText);
            //mail.setPlainTextBody('records processed ' + a.TotalJobItems + ' with '+ a.NumberOfErrors + ' failures. '+a.ExtendedStatus);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }