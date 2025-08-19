/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Mahesh         02-05-2019                                            */
/* Class Name:     BatchBrandProtection1                                                 */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class BatchBrandProtection1 implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

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
    
    
    global BatchBrandProtection1() {
        civilemailIdList = new List<String>();
        ageemailIdList = new List<String>();
        bulkemailIdList = new List<String>();
        settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');
    }
    /*****************************************************************************/
    /* Method Name:    start                                                     /*
    /* Description:    start method of Batchable Interface                       /*
    /*                 Forms SQL Query for Batch processing                      /*
    /*****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//For JTP-112
        String query = ' Select Id,AccountId,Account.Owner.Email,Sub_Type__c,Secret_Shop_Date__c,Next_Secret_Shop_Date__c,Regulatory_Action__c,Secret_Shop_Status__c,CreatedDate,ClosedDate from Case ';
               query += ' where RecordTypeId =: B2BSupportCaseRecordTypeId AND status = \'Retail Case Closed\' AND ';
               query += '((Sub_Type__c = \'Civil Money Penalty (CMP)\' AND Regulatory_Action__c = NULL) OR ';
               query += '((Sub_Type__c = \'Age Verification\' OR Sub_Type__c = \'Bulk Purchasing\')  AND Next_Secret_Shop_Date__c = NULL )) ';
               //query += 'AND Regulatory_Action__c = NULL';
              

        
        system.debug('Query####: ' + Query);
        return Database.getQueryLocator(query);
    }
    
    /**********************************************************************************/
    /* Method Name:    execute                                                        /*
    /* Description:    execute method of Batchable Interface,                         /*
    /*                                                                                /*
    /**********************************************************************************/
    global void execute(Database.BatchableContext BC, List<Case> caseList)
    {
        String strAccountId, strSubType, strSecretShopStatus, strMapId, strCaseMapId, strCaseMapIdPass, strCaseMapIdFail, strCaseEmail;
        String strCaseAccntId, strCaseSubType, strCaseSSStatus, strCaseSSStatusPass, strCaseSSStatusFail;
        String strPassRecExists, strFailRecExists, strLatestExisting, strExceptionCase;
        Datetime MaxClosedDate, MaxClosedDatePass, MaxClosedDateFail;
        Integer CaseCount, CaseCountPass, CaseCountFail;
        Set<Id> AccountIdSet = new Set<Id>();
        Set<Id> ExecptionCaseAccountIdSet = new Set<Id>();
        Case CaseUpdate;  
        Set<Case> caseUpdateSet = new Set<Case>();
        List<Case> caseUpdateList = new List<Case>();
        List<Case> caseExceptionList = new List<Case>();
        List<Account> lstAccntStatusTerminated = new List<Account>();
        Set<Account> setAccntStatusTerminated = new Set<Account>();		
        Map<String,Object[]> accountCaseTypeAggregateMap = new Map<String,Object[]>();
        Object[] AggregareResultRec, AggregareResultRecPass, AggregareResultRecFail;
        Map<Id,List<Case>> accountExcpCaseListMap = new Map<Id,List<Case>>();
        Map<Id,Id> accountExcpSrcCaseListMap = new Map<Id,Id>();
        Date Dt1year  = System.today().addMonths(Integer.valueOf(settingsConst.Between_Months_of_CreatedStartDT_1__c));
        Date Dt2years = System.today().addMonths(Integer.valueOf(settingsConst.Between_Months_of_CreatedStartDT_2__c)); 
        String ExcpCaseMapCount;
        list<Case> ExceptionExistingCase;
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//For JTP-112
        
        for(Case c: caseList){
            AccountIdSet.add(c.AccountId);
        }

        system.debug('AccountIdSet####: ' + AccountIdSet);
        
        AggregateResult[] results = [select AccountId, Sub_Type__c, Secret_Shop_Status__c, max(ClosedDate) Max_ClosedDate, count(Id) CaseCount
                                       from case      
                                      where RecordTypeId =: B2BSupportCaseRecordTypeId AND status = 'Retail Case Closed' AND AccountId in :AccountIdSet AND
                                            ((Sub_Type__c = 'Civil Money Penalty (CMP)' AND Regulatory_Action__c != NULL AND ClosedDate >=:Dt2years) OR 
                                             (Sub_Type__c IN ('Age Verification','Bulk Purchasing') AND (Next_Secret_Shop_Date__c != NULL 
                                                                                                         //OR Regulatory_Action__c != NULL
                                                                                                          )))
                                      group by AccountId, Sub_Type__c,Secret_Shop_Status__c];
        
        /// Exeception if there is no existing data for any of the case
        
        system.debug('results####: ' + results);
      
        for(Integer index = 0, size = results.size(); index < size; index++) {
                AggregareResultRec = new List<Object>();            
                   strAccountId        = (String)results[index].get('AccountId');
                   strSubType          = (String)results[index].get('Sub_Type__c'); 
                   strSecretShopStatus = (String)results[index].get('Secret_Shop_Status__c');
                   strMapId            = strAccountId + strSubType + strSecretShopStatus;
                   System.debug('!!!!strMapId::::'+strMapId);
                   System.debug('!!!!AggregareResultRec[0]::::'+(DateTime)results[index].get('Max_ClosedDate'));
                   AggregareResultRec.add((DateTime)results[index].get('Max_ClosedDate'));
                   
                   AggregareResultRec.add((Integer)results[index].get('CaseCount'));
                   
                   accountCaseTypeAggregateMap.put(strMapId,AggregareResultRec);
        }
        
        system.debug('accountCaseTypeAggregateMap####: ' + accountCaseTypeAggregateMap);
        
        for(Case c: caseList){
             strCaseAccntId  = c.AccountId;
             strCaseSubType  = c.Sub_Type__c;
             strCaseSSStatus = c.Secret_Shop_Status__c;
             strCaseEmail    = c.Account.Owner.Email;
             CaseUpdate = new Case();
             strExceptionCase = 'No';
             system.debug('c.Id####: ' + c.Id);
             CaseUpdate.Id = c.Id;
            system.debug('CaseUpdate.Id####: ' + CaseUpdate.Id);
            system.debug('strCaseSubType####: ' + strCaseSubType);
            system.debug('c.Account.Owner.Email####: ' + c.Account.Owner.Email);
            
             /*if (strCaseSubType == 'Civil Money Penalty (CMP)') {
                    civilemailIdList.add(strCaseEmail);
                    strCaseMapId    = strCaseAccntId + strCaseSubType + strCaseSSStatus;
                    if(accountCaseTypeAggregateMap.containsKey(strCaseMapId)){
                        AggregareResultRec = accountCaseTypeAggregateMap.get(strCaseMapId);
                        MaxClosedDate = (Datetime)AggregareResultRec[0];
                        CaseCount     = (Integer)AggregareResultRec[1];  
                        system.debug('AggregareResultRec####: ' + AggregareResultRec);
                        system.debug('civilemailIdList####: ' + civilemailIdList);
                        system.debug('MaxClosedDate####: ' + MaxClosedDate);
                        system.debug('CaseCount####: ' + CaseCount);
                        if (CaseCount == 1){
                            if (MaxClosedDate >= Dt1year ){   // Within 12 months so this is second case
                                CaseUpdate.Regulatory_Action__c = 'CMP - Suspended - 1 Promo Cycle';
                            }
                            else                              // beyond 12 months so this is first case
                            {
                                CaseUpdate.Regulatory_Action__c = 'CMP - First Warning';
                            }
                        }
                        else if (CaseCount == 2) {
                            CaseUpdate.Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle';
                        } 
                        else if (CaseCount == 3) {
                            CaseUpdate.Regulatory_Action__c = 'CMP - Terminated';
                            setAccntStatusTerminated.add(new Account (Id = c.AccountId, Status__c= 'Blacklisted'));
                        }                      
                    }
                    else  {           // this is first case as there is no existing data 
                        CaseUpdate.Regulatory_Action__c = 'CMP - First Warning';
                        system.debug('CaseUpdate####:   NoExisting CMP Data');
                    }
                   system.debug('CaseUpdate####: ' + CaseUpdate);
            }
             
            else {
                strCaseMapIdPass  = strCaseAccntId + strCaseSubType + 'Pass';
                strCaseMapIdFail  = strCaseAccntId + strCaseSubType + 'Fail';
                strPassRecExists  = '';
                strFailRecExists  = '';
                strLatestExisting = '';
                
                system.debug('strCaseMapIdPass####: ' + strCaseMapIdPass);
                system.debug('strCaseMapIdFail####: ' + strCaseMapIdFail);
                system.debug('strCaseMapIdFail####: ' + strCaseMapIdFail);
                system.debug('civilemailIdList####: ' + civilemailIdList);
                
                if(accountCaseTypeAggregateMap.containsKey(strCaseMapIdPass)){
                    AggregareResultRecPass = accountCaseTypeAggregateMap.get(strCaseMapIdPass);
                    
                    MaxClosedDatePass = (Datetime)AggregareResultRecPass[0];
                    CaseCountPass     = (Integer)AggregareResultRecPass[1]; 
                    strPassRecExists = 'Yes';
                }
                if(accountCaseTypeAggregateMap.containsKey(strCaseMapIdFail)){
                    AggregareResultRecFail = accountCaseTypeAggregateMap.get(strCaseMapIdFail);
                    MaxClosedDateFail = (Datetime)AggregareResultRecFail[0];
                    CaseCountFail     = (Integer)AggregareResultRecFail[1]; 
                    strFailRecExists = 'Yes';
                }
                system.debug('AggregareResultRecPass####: ' + AggregareResultRecPass);
                system.debug('AggregareResultRecFail####: ' + AggregareResultRecFail); 
                system.debug('strPassRecExists####: ' + strPassRecExists);
                system.debug('strFailRecExists####: ' + strFailRecExists);
                system.debug('MaxClosedDatePass####: ' + MaxClosedDatePass);
                system.debug('MaxClosedDateFail####: ' + MaxClosedDateFail);
                system.debug('CaseCount####: ' + CaseCount);
                if(strPassRecExists == 'Yes' && strFailRecExists == 'Yes') {
                    if (MaxClosedDatePass > MaxClosedDateFail) {
                        strLatestExisting = 'Pass';
                    }
                    else {
                        strLatestExisting = 'Fail';
                    }
                }
                else if(strPassRecExists == 'Yes' && strFailRecExists == '') {
                    strLatestExisting = 'Pass';
                }
                else if(strPassRecExists == '' && strFailRecExists == 'Yes') {
                    strLatestExisting = 'Fail';
                }
                else {
                    strLatestExisting = '';
                }
                
                system.debug('strLatestExisting####: ' + strLatestExisting);
                
                if (strCaseSubType == 'Age Verification') {
                    
                    if (strCaseSSStatus == 'Pass' && (strLatestExisting == '' || strLatestExisting == 'Fail')) {   // First Case --> No existing data or Fail Reset
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_4__c));
                    }
                    else if (strCaseSSStatus == 'Pass' && strLatestExisting == 'Pass') {   // Second Case, Third Case .....
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_3__c));
                    }
                    else if (strCaseSSStatus == 'Fail' && (strLatestExisting == '' || strLatestExisting == 'Pass')) {   // // First Case --> No existing data or Pass 
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addDays(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_1__c));
                        CaseUpdate.Regulatory_Action__c = 'AV - First Warning'; 
                        ageemailIdList.add(strCaseEmail);
                    }
                    else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail') {      // 2 consequetive fails
                        CaseUpdate.Regulatory_Action__c = 'AV - Report to FDA';
                        setAccntStatusTerminated.add(new Account (Id = c.AccountId, Status__c= 'Blacklisted'));
                        ageemailIdList.add(strCaseEmail);
                    }
                }
                else if (strCaseSubType == 'Bulk Purchasing') {   
                    
                    if (strCaseSSStatus == 'Pass' && (strLatestExisting == '' || strLatestExisting == 'Fail')) {   // First Case --> No existing data or Fail Reset
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_5__c));
                    }
                    else if (strCaseSSStatus == 'Pass' && strLatestExisting == 'Pass') {   // Second Case, Third Case .....
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_4__c));
                    }
                    else if (strCaseSSStatus == 'Fail' && (strLatestExisting == '' || strLatestExisting == 'Pass')) {   // // First Case --> No existing data or Pass 
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_2__c));
                        CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - First Warning'; 
                        bulkemailIdList.add(strCaseEmail);
                    }
                    else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail' && CaseCountFail == 1) {   // // Second Consequetive Case  
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_4__c));
                        CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - Suspended - 1 Promo Cycle'; 
                        bulkemailIdList.add(strCaseEmail);
                    }
                    else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail' && CaseCountPass == 0 && CaseCountFail >= 2) {   // // Second Consequetive Case  
                        CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - Terminated / Blacklisted';
                        setAccntStatusTerminated.add(new Account (Id = c.AccountId, Status__c= 'Blacklisted'));
                        bulkemailIdList.add(strCaseEmail);
                    }
                    else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail' && CaseCountPass >= 1 && CaseCountFail >= 2) {   //  
                        strExceptionCase = 'Yes';
                        CaseExceptionList.add(c); 
                        ExecptionCaseAccountIdSet.add(c.AccountId);
                        accountExcpSrcCaseListMap.put(c.AccountId,c.Id);
                    }
                }

            } */
            //system.debug('CaseUpdate####: ' + CaseUpdate);
            //system.debug('strExceptionCase####: ' + strExceptionCase);
            //system.debug('caseUpdateListBEfore ####: ' + caseUpdateList);
            /*if (strExceptionCase == 'No') { 
                system.debug('Entered Loop ####: ');
                caseUpdateList.add(CaseUpdate);  
                system.debug('caseUpdateListAfter####: ' + caseUpdateList);
            }*/
            
        }

        //System.debug('!!!!civilemailIdList::::'+civilemailIdList);
        //System.debug('!!!!ageemailIdList::::'+ageemailIdList);
        //System.debug('!!!!bulkemailIdList::::'+bulkemailIdList);
        //System.debug('!!!!CaseExceptionList::::'+CaseExceptionList);  
        System.debug('!!!!ExecptionCaseAccountIdSet::::'+ExecptionCaseAccountIdSet);
        system.debug('caseUpdateList####: ' + caseUpdateList);
        
 
        if(CaseExceptionList != null && CaseExceptionList.size() > 0){
        ExceptionExistingCase = [select Id, AccountId, Secret_Shop_Status__c, Account.Owner.Email, Secret_Shop_Date__c
                                   from case      
                                  where RecordTypeId =: B2BSupportCaseRecordTypeId AND status = 'Retail Case Closed' AND AccountId in :ExecptionCaseAccountIdSet AND
                                        Sub_Type__c = 'Bulk Purchasing'  AND (Next_Secret_Shop_Date__c != NULL OR Regulatory_Action__c != NULL)
                                  Order by AccountId, ClosedDate DESC];
 
        for(Case ec: ExceptionExistingCase){
            CaseUpdate = new Case();
            if(accountExcpCaseListMap.containsKey(ec.AccountId)){
                if (ExcpCaseMapCount == 'FirstCaseRec') {
                    accountExcpCaseListMap.get(ec.AccountId).add(ec);
                    ExcpCaseMapCount = 'SecondCaseRec';
                    CaseUpdate.Id    = accountExcpSrcCaseListMap.get(ec.AccountId);   //get exeception source case id
    
                    if (ec.Secret_Shop_Status__c == 'Fail'){      //Second latest case is Fail
                         CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - Terminated / Blacklisted';
                         setAccntStatusTerminated.add(new Account (Id = ec.AccountId, Status__c= 'Blacklisted'));
                    }
                    else {                                       //Second latest case is Pass
                        CaseUpdate.Next_Secret_Shop_Date__c = ec.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_4__c));
                        CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - Suspended - 1 Promo Cycle'; 
                    }
                    caseUpdateList.add(CaseUpdate);
                    bulkemailIdList.add(ec.Account.Owner.Email);
                }
            }
            else {
                accountExcpCaseListMap.put(ec.AccountId,new List<Case>{ec}); //First latest case is always Fail
                ExcpCaseMapCount = 'FirstCaseRec';
            }
         }
            System.debug('!!!!Excdeption CaseUpdate::::'+CaseUpdate);
        }
        
        System.debug('!!!!civilemailIdList::::'+civilemailIdList);
        System.debug('!!!!ageemailIdList::::'+ageemailIdList);
        System.debug('!!!!bulkemailIdList::::'+bulkemailIdList);
        System.debug('!!!!CaseExceptionList::::'+CaseExceptionList);
        
        System.debug('!!!!setAccntStatusTerminated::::'+setAccntStatusTerminated);
        System.debug('!!!!CaseUpdateList1::::'+CaseUpdateList);
        System.debug('!!!!CaseUpdateSet::::'+CaseUpdateSet);
        CaseUpdateList.addAll(CaseUpdateSet);
        System.debug('!!!!CaseUpdateList2::::'+CaseUpdateList);
        Update CaseUpdateList;
		lstAccntStatusTerminated.addAll(setAccntStatusTerminated);
        if(lstAccntStatusTerminated != null && lstAccntStatusTerminated.size() > 0){
             Update lstAccntStatusTerminated;
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
                if((civilemailIdList != null && civilemailIdList.size() > 0) || 
                   (ageemailIdList != null && ageemailIdList.size() > 0) ||
                   (bulkemailIdList != null && bulkemailIdList.size() > 0)) {
 
                /* Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
                 if(civilemailIdList != null && civilemailIdList.size() > 0){
                      
                      //EmailTemplate civiltemp=[Select id from EmailTemplate where name = 'EmailTemplatename' limit 1];                      
                      mail.setToAddresses(civilemailIdList);
                      //mail.setTemplateId(civiltemp.id);
                 }
                 if(ageemailIdList != null && ageemailIdList.size() > 0){                     
                    // EmailTemplate agetemp=[Select id from EmailTemplate where name = 'EmailTemplatename' limit 1];                      
                      mail.setToAddresses(ageemailIdList);
                      //mail.setTemplateId(agetemp.id);
                     
                 }
                 if(bulkemailIdList != null && bulkemailIdList.size() > 0){                     
                    // EmailTemplate bulktemp=[Select id from EmailTemplate where name = 'EmailTemplatename' limit 1];                      
                      mail.setToAddresses(bulkemailIdList);
                     // mail.setTemplateId(bulktemp.id);
                      
                 }
                 
                 mail.setSenderDisplayName('System Admin');
                 mail.setSubject('Batch Completed');
                 
                 Messaging.sendEmail(new Messaging.SingleEmailMessage [] { mail });*/
            }
               
    }
}