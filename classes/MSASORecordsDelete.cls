/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Naveen         05-06-2020                                          */
/* Class Name:     SalesOrderRecordsDelete                                          */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class MSASORecordsDelete implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

   Map<String, String> mapInputs =  new Map<String, String>();
    global MSASORecordsDelete(Map<String, String> mapInputs){
        this.mapInputs = mapInputs;
    }
    
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String overrideQuery = '';
        string strorderType = 'MSA';
        String query = 'Select Id from SalesOrder__c Where Number_of_Doc_Details__c = 0.0 AND orderType__c = \'MSA\' ';
        
        if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND '+mapInputs.get('overrideQuery');
        }
        query += overrideQuery;  
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<salesOrder__c>scope){
        if(scope.size()>0)
        try{
         List<Database.DeleteResult> result = Database.Delete(scope, false);
        }catch(Exception e){
          System.debug('Database.DeleteResult Details'+e.getMessage());
        }
       
    }
    /*****************************************************************************/
    /* Method Name:    finish                                                    /*
    /* Description:    finish method of Batchable Interface                      /*
    /*****************************************************************************/
    global void finish(Database.BatchableContext BC) {              
        BatchConstantValues__c dateCustomsetting = BatchConstantValues__c.getinstance('BatchBrandProtection');
        String adminEmails = dateCustomsetting.X3_Strike_Admin_EmailIds__c;
        if(!String.isEmpty(adminEmails)){
            try{
                String[] toAddresses= adminEmails.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, CreatedDate, 
                  CompletedDate, JobItemsProcessed, 
                                  TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job SalesOrderRecordsDelete ' + a.Status);
                mail.setPlainTextBody('The batch Apex job SalesOrderRecordsDelete processed ' + a.TotalJobItems +
                                      ' batches with '+ a.NumberOfErrors + ' failures.' + 
                                      '\n Input Paramterers provided for batch job: ' + '\n The batch job started '+a.CreatedDate+' and completed '+a.CompletedDate);                                      
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        }         
    }
}