/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Naveen         10-09-2019                                            */
/* Class Name:     JuulAccountResetBatch                                          */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class JuulGBBatchAccountReset implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    // 
    Date suspensionResetDate;
    BatchConstantValues__c dateCustomsetting;
    
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
    
    global JuulGBBatchAccountReset(){
        dateCustomsetting = BatchConstantValues__c.getValues('BatchBrandProtection');
        Integer numberOfDays = Integer.valueOf(dateCustomsetting.GBSuspensionResetDate__c);
        suspensionResetDate = Date.today().addDays(-numberOfDays );
    }
    
    /*****************************************************************************/
    /* Method Name:    start                                                     /*
    /* Description:    start method of Batchable Interface                       /*
    /*                 Forms SOQL Query for Batch processing                      /*
    /*****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        String SuspendedYear = String.valueOf(suspensionResetDate.year());
        String Suspendedmonth = (String.valueOf(suspensionResetDate.month()).length() == 1)?'0'+String.valueOf(suspensionResetDate.month()):String.valueOf(suspensionResetDate.month());
        String Suspendedday = (String.valueOf(suspensionResetDate.day()).length() == 1)?'0'+String.valueOf(suspensionResetDate.day()):String.valueOf(suspensionResetDate.day());
        string suspensionResetDate = SuspendedYear+'-'+Suspendedmonth+'-'+Suspendedday;
        String query = 'SELECT Id,SS_First_Violation_Date__c,SS_Second_Violation_Date__c,SS_Third_Violation_Date__c,ShippingCountry,Status__c  FROM Account ';
              query += 'WHERE '; 
              query += 'Status__c = \'Suspended\'';
              query += ' AND ';
              query += 'SS_Third_Violation_Date__c < '+suspensionResetDate;
              query +=  ' AND ';
              query += 'ShippingCountry=\'GB\'';

        system.debug('Query####: ' + Query);
        return Database.getQueryLocator(query);
        
    }
        
     /**********************************************************************************/
    /* Method Name:    execute                                                        /*
    /* Description:    execute method of Batchable Interface,                         /*
    /*                                                                                /*
    /**********************************************************************************/
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        List<Account> accUpdateList = new List<Account>();
        for(Account acc : accountList ){
            acc.Status__c ='Customer (Reporting)';
            acc.SS_First_Violation_Date__c = null;
            acc.SS_Second_Violation_Date__c = null; 
            acc.SS_Third_Violation_Date__c = null;          
            accUpdateList.add(acc);
        }       
        Update accUpdateList;  
    }
    
     /*****************************************************************************/
    /* Method Name:    finish                                                    /*
    /* Description:    finish method of Batchable Interface                      /*
    /*****************************************************************************/
    global void finish(Database.BatchableContext BC) {              
        dateCustomsetting = BatchConstantValues__c.getinstance('BatchBrandProtection');
        String adminEmails = dateCustomsetting.X3_Strike_Admin_EmailIds__c;
        if(!String.isEmpty(adminEmails)){
            try{
                String[] toAddresses= adminEmails.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                  TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job JuulUKBatchAccountReset ' + a.Status);
                mail.setPlainTextBody('The batch Apex job JuulUKBatchAccountReset processed ' + a.TotalJobItems +
                                      ' batches with '+ a.NumberOfErrors + ' failures.' + 
                                      '\n Input Paramterers provided for batch job: ' );
                                      
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        }       
               
               
    }
}