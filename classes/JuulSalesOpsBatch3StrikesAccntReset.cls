/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Srikanth       09-04-2019 Created for 3 Striker Rule                 */
/* Class Name:     JuulSalesOpsBatch3StrikesAccntReset                                  */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class JuulSalesOpsBatch3StrikesAccntReset implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    Map<String, String> mapInputs =  new Map<String, String>();
    public List<String> civilemailIdList {get;set;}
    public List<String> ageemailIdList {get;set;}
    public List<String> bulkemailIdList {get;set;}
    public BatchConstantValues__c settingsConst {get;set;}
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
    
    global JuulSalesOpsBatch3StrikesAccntReset(){
        this.mapInputs.put('overrideQuery',''); 
    }  
    
    global JuulSalesOpsBatch3StrikesAccntReset(Map<String, String> mapInputs){
        this.mapInputs = mapInputs; 
        civilemailIdList = new List<String>();
        ageemailIdList   = new List<String>();
        bulkemailIdList  = new List<String>();
        
    }
    /*****************************************************************************/
    /* Method Name:    start                                                     /*
    /* Description:    start method of Batchable Interface                       /*
    /*                 Forms SQL Query for Batch processing                      /*
    /*****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String overrideQuery = '';
        if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND ' + mapInputs.get('overrideQuery'); }
        settingsConst    = BatchConstantValues__c.getinstance('BatchBrandProtection');
        Date HardCutoffDate =  settingsConst.X3_Strike_Enforcement_Start_Date__c;  
        Date DtSuspendedReset  = System.today().addMonths(Integer.valueOf(settingsConst.X3_Strike_Account_Suspension_Reset__c));
        Date DtBlacklistReset  = System.today().addMonths(Integer.valueOf(settingsConst.X3_Strike_Account_Blacklist_Reset__c));
        
        String HardCutofYear = String.valueOf(HardCutoffDate.year());
        String HardCutoffmonth = (String.valueOf(HardCutoffDate.month()).length() == 1)?'0'+String.valueOf(HardCutoffDate.month()):String.valueOf(HardCutoffDate.month());
        String HardCutoffday = (String.valueOf(HardCutoffDate.day()).length() == 1)?'0'+String.valueOf(HardCutoffDate.day()):String.valueOf(HardCutoffDate.day());
        string strHardCutoffDate = HardCutofYear+'-'+HardCutoffmonth+'-'+HardCutoffday;
        
        String SuspendedYear = String.valueOf(DtSuspendedReset.year());
        String Suspendedmonth = (String.valueOf(DtSuspendedReset.month()).length() == 1)?'0'+String.valueOf(DtSuspendedReset.month()):String.valueOf(DtSuspendedReset.month());
        String Suspendedday = (String.valueOf(DtSuspendedReset.day()).length() == 1)?'0'+String.valueOf(DtSuspendedReset.day()):String.valueOf(DtSuspendedReset.day());
        string SuspendedResetDate = SuspendedYear+'-'+Suspendedmonth+'-'+Suspendedday;
        String BlacklistYear = String.valueOf(DtBlacklistReset.year());
        String Blacklistmonth = (String.valueOf(DtBlacklistReset.month()).length() == 1)?'0'+String.valueOf(DtBlacklistReset.month()):String.valueOf(DtBlacklistReset.month());
        String Blacklistday = (String.valueOf(DtBlacklistReset.day()).length() == 1)?'0'+String.valueOf(DtBlacklistReset.day()):String.valueOf(DtBlacklistReset.day());
        string BlacklistResetDate = BlacklistYear+'-'+Blacklistmonth+'-'+Blacklistday;

        String query =  ' Select Id, AccountId, Account.Owner.Email,';
               query += ' X1st_Failed_Case_Regulatory_Action__c,X2nd_Failed_Case_Regulatory_Action__c,X3rd_Failed_Case_Regulatory_Action__c,';
               query += ' Date_of_1st_Violation_AV_or_CMP__c, Date_of_2nd_Violation_AV_or_CMP__c,Date_of_3rd_Violation_AV_or_CMP__c'; 
               query += ' from Contact where BP_Suspended_1_Promo_CY_Violation_Date__c = NULL AND BP_Terminated_Blacklisted_Violation_Date__c = NULL AND';
               query += ' Date_of_1st_Violation_AV_or_CMP__c != null AND Date_of_2nd_Violation_AV_or_CMP__c != null AND ';
               query += ' Date_of_1st_Violation_AV_or_CMP__c >= ' + strHardCutoffDate+ ' AND ';
               query += '  ((Account.Status__c = \'Suspended\' AND Date_of_3rd_Violation_AV_or_CMP__c = null AND Date_of_2nd_Violation_AV_or_CMP__c < ' + SuspendedResetDate + ') OR ';
               query += '  (Account.Status__c = \'Blacklisted\' AND Date_of_3rd_Violation_AV_or_CMP__c != null AND Date_of_3rd_Violation_AV_or_CMP__c < ' + BlacklistResetDate + ')) ';
              // query += ' AND AccountId = \'001V000000e8pJLIAY\' ';
               query += overrideQuery;

        system.debug('Query####: ' + Query);
        return Database.getQueryLocator(query);
    }
    
    /**********************************************************************************/
    /* Method Name:    execute                                                        /*
    /* Description:    execute method of Batchable Interface,                         /*
    /*                                                                                /*
    /**********************************************************************************/
    global void execute(Database.BatchableContext BC, List<Contact> contactList)
    {
        Map<Id,Account> contactAccountMap = new Map<Id,Account>();
        system.debug('contactList before update####: ' + contactList);
        
        for(Contact c: contactList){
            c.X1st_Failed_Case_Regulatory_Action__c = null;
            c.X2nd_Failed_Case_Regulatory_Action__c = null;
            c.X3rd_Failed_Case_Regulatory_Action__c = null;
            c.Date_of_1st_Violation_AV_or_CMP__c = null;
            c.Date_of_2nd_Violation_AV_or_CMP__c = null;
            c.Date_of_3rd_Violation_AV_or_CMP__c = null;
            if(!contactAccountMap.containsKey(c.AccountId)){
                contactAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Customer (Reporting)'));
            }
        }
        system.debug('contactList after update####: ' + contactList); 
        system.debug('contactAccountMap####: ' + contactAccountMap);
        
        if(contactList != null && contactList.size() > 0){
            try{
                  Database.SaveResult[] saveResultList1 = Database.update(contactList, false);
                    for (Database.SaveResult sr : saveResultList1) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
            }
            catch(Exception e){
                System.debug('Error :'+e.getMessage());
            }
        } 
        
        if(contactAccountMap != null && contactAccountMap.size() > 0){
            // Update caseAccountMap.values();
            try{
              Database.SaveResult[] saveResultList2 = Database.update(contactAccountMap.values(), false);
                for (Database.SaveResult sr : saveResultList2) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }
            catch(Exception e){
                System.debug('Error :'+e.getMessage());
            }
        }            
        
    }        

    /*****************************************************************************/
    /* Method Name:    executeOrderUpdate                                       /*
    /* Description:    method to run the Batch process from Page                 /*
    /*****************************************************************************/
    public PageReference executeOrderUpdate() {
        ID batchprocessid = Database.executeBatch(this);
        return null;
    }
    
    /*****************************************************************************/
    /* Method Name:    finish                                                    /*
    /* Description:    finish method of Batchable Interface                      /*
    /*****************************************************************************/
    global void finish(Database.BatchableContext BC) {
        settingsConst    = BatchConstantValues__c.getinstance('BatchBrandProtection');
        String adminEmails = settingsConst.X3_Strike_Admin_EmailIds__c;
        if(!String.isEmpty(adminEmails)){
            try{
                String[] toAddresses= adminEmails.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                  TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job JuulSalesOpsBatch3StrikesAccntReset ' + a.Status);
                mail.setPlainTextBody('The batch Apex job JuulSalesOpsBatch3StrikesAccntReset processed ' + a.TotalJobItems +
                                      ' batches with '+ a.NumberOfErrors + ' failures.' + 
                                      '\n Input Paramterers provided for batch job: ' + 
                                      '\n OverrideQuery : ' + mapInputs.get('overrideQuery'));
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        } 
               
    }
}