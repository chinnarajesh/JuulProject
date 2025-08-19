/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Mahesh         02-05-2019                                            */
/*     2.0         Srikanth       09-04-2019 Modified for 3 Striker Rule                */
/* Class Name:     JuulSalesOpsBatchBrandProtection                                     */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class JuulSalesOpsBatchBrandProtection implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

    Map<String, String> mapInputs =  new Map<String, String>();
    public List<String> civilemailIdList {get;set;}
    public List<String> ageemailIdList {get;set;}
    public List<String> bulkemailIdList {get;set;}
    public BatchConstantValues__c settingsConst {get;set;}
    List<String> shippingCountryList {get;set;}
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
    
    global JuulSalesOpsBatchBrandProtection(){
        this.mapInputs.put('overrideQuery','');
        civilemailIdList = new List<String>();
        ageemailIdList = new List<String>();
        bulkemailIdList = new List<String>();
        settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');
        shippingCountryList = String.valueOf(settingsConst.ShippingCountryList__c).split(',');
        
    }  
    
    global JuulSalesOpsBatchBrandProtection(Map<String, String> mapInputs){
        this.mapInputs = mapInputs; 
        civilemailIdList = new List<String>();
        ageemailIdList = new List<String>();
        bulkemailIdList = new List<String>();
        settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');
        shippingCountryList = String.valueOf(settingsConst.ShippingCountryList__c).split(',');
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
        Date HardCutoffDate1 =  settingsConst.X3_Strike_Enforcement_Start_Date__c;
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
        
        String query = ' Select Id,AccountId,Account.Owner.Email,Account.Violation_Type__c,Sub_Type__c,Secret_Shop_Date__c,Next_Secret_Shop_Date__c,Regulatory_Action__c,Secret_Shop_Status__c,CreatedDate,ClosedDate, ContactId ';
               query += ', Contact.X1st_Failed_Case_Regulatory_Action__c, Contact.X2nd_Failed_Case_Regulatory_Action__c, Contact.X3rd_Failed_Case_Regulatory_Action__c ';
               query += ', Contact.Date_of_1st_Violation_AV_or_CMP__c, Contact.Date_of_2nd_Violation_AV_or_CMP__c, Contact.Date_of_3rd_Violation_AV_or_CMP__c ';
             //  query += ',Contact.BP_First_Warning_Violation_Date__c, Contact.BP_Suspended_1_Promo_CY_Violation_Date__c, Contact.BP_Terminated_Blacklisted_Violation_Date__c ';
               query += '  from Case where RecordTypeId =: B2BSupportCaseRecordTypeId  AND status = \'Retail Case Closed\' AND ';
               query += '((Sub_Type__c = \'Sale Involving a Minor\' OR Sub_Type__c = \'Product Quantity Limits\') OR ';
               query += '((Sub_Type__c = \'Age Verification\' )  AND Next_Secret_Shop_Date__c = NULL ';
                   //AND Regulatory_Action__c = NULL ';
               query += ' AND (Secret_Shop_Status__c IN ( \'Pass\' ,\'Fail\') ';
               query += ' AND Secret_Shop_Date__c >= :HardCutoffDate1)))';
               query += ' AND RMA_Country__c IN : shippingCountryList ';
               query += overrideQuery;
               query += ' Order BY Secret_Shop_Date__c';

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
        String strCaseAccntId, strCaseContactId, strCaseSubType, strCaseSSStatus, strCaseSSStatusPass, strCaseSSStatusFail;
        String strPassRecExists, strFailRecExists, strLatestExisting, strExceptionCase;
        Datetime MaxClosedDate, MaxClosedDatePass, MaxClosedDateFail;
        Integer CaseCount, CaseCountPass, CaseCountFail, CMPCount, AVCount, TotalCount;
        Set<Id> AccountIdSet = new Set<Id>();
        Set<Id> ExecptionCaseAccountIdSet = new Set<Id>();
        Case CaseUpdate;  
        Set<Case> caseUpdateSet = new Set<Case>();
        List<Case> caseUpdateList = new List<Case>();
        List<Case> caseExceptionList = new List<Case>();        
        Map<String,Object[]> accountCaseTypeAggregateMap = new Map<String,Object[]>();
        Object[] AggregareResultRec, AggregareResultRecPass, AggregareResultRecFail;
        Map<Id,List<Case>> accountExcpCaseListMap = new Map<Id,List<Case>>();
        Map<Id,Id> accountExcpSrcCaseListMap = new Map<Id,Id>();
        String ExcpCaseMapCount;
        list<Case> ExceptionExistingCase;
        Map<Id,Contact> caseContactMap = new Map<Id,Contact>();
        Map<Id,Account> caseAccountMap = new Map<Id,Account>();
        Set<Id> CMPReset = new Set<Id>();
        Set<Id> AVReset  = new Set<Id>();
        Date SecretShopDate;
        // Date HardCutoffDate = Date.newInstance(2019, 2, 1);
        Date HardCutoffDate =  settingsConst.X3_Strike_Enforcement_Start_Date__c; 
        Date Dt1year  = System.today().addMonths(Integer.valueOf(settingsConst.Between_Months_of_CreatedStartDT_1__c));
        Date Dt2years = System.today().addMonths(Integer.valueOf(settingsConst.Between_Months_of_CreatedStartDT_2__c));
        String X1stFailedCaseRegulatoryAction, X2ndFailedCaseRegulatoryAction, X3rdFailedCaseRegulatoryAction;
        Date Date1stViolation, Date2ndViolation, Date3rdViolation;
      //  Date BP_1stCaseDate, BP_2ndCaseDate, BP_3rdCaseDate;
        Date CutoffDate_1YR, CutoffDate_2YR;
 		Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
        
        if (HardCutoffDate >= Dt1year){
            system.debug('@@test1@@@');
            CutoffDate_1YR = HardCutoffDate; }
        else {   system.debug('@@test2@@@');
            CutoffDate_1YR = Dt1year; }
        
        if (HardCutoffDate >= Dt2years){
            CutoffDate_2YR = HardCutoffDate; }
        else {  
            CutoffDate_2YR = Dt2years; }
        

        
        for(Case c: caseList){
            AccountIdSet.add(c.AccountId);
        }

        system.debug('AccountIdSet####: ' + AccountIdSet);
        system.debug('CutoffDate_1YR####: ' + CutoffDate_1YR);
        //system.debug('Case @@@ ' + [Select Id, RecordType.Name,status,AccountId,Secret_Shop_Date__c,RMA_Country__c,Sub_Type__c,Regulatory_Action__c From Case]);
        
        AggregateResult[] results = [select AccountId, Sub_Type__c, Secret_Shop_Status__c, max(Secret_Shop_Date__c) Max_ClosedDate, count(Id) CaseCount
                                       from case      
                                      where RecordTypeId =: B2BSupportCaseRecordTypeId AND status = 'Retail Case Closed' AND AccountId in :AccountIdSet AND
                                            ((
                                                //Sub_Type__c = 'Civil Money Penalty (CMP)' AND //JTP-112
                                                Regulatory_Action__c != NULL AND Secret_Shop_Date__c >=:CutoffDate_1YR) OR 
                                             (
                                                // Sub_Type__c IN ('Bulk Purchasing') AND //JTP-112
                                                 (Next_Secret_Shop_Date__c != NULL OR Regulatory_Action__c != NULL ) AND Secret_Shop_Status__c IN ('Pass','Fail')))AND
                                             RMA_Country__c IN : shippingCountryList
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
             strCaseAccntId   = c.AccountId;
             strCaseContactId = c.ContactId;
             strCaseSubType   = c.Sub_Type__c;
             strCaseSSStatus  = c.Secret_Shop_Status__c;
             SecretShopDate   = c.Secret_Shop_Date__c;
             strCaseEmail     = c.Account.Owner.Email;
             X1stFailedCaseRegulatoryAction = c.Contact.X1st_Failed_Case_Regulatory_Action__c;
             X2ndFailedCaseRegulatoryAction = c.Contact.X2nd_Failed_Case_Regulatory_Action__c;
             X3rdFailedCaseRegulatoryAction = c.Contact.X3rd_Failed_Case_Regulatory_Action__c;
             Date1stViolation = c.Contact.Date_of_1st_Violation_AV_or_CMP__c;
             Date2ndViolation = c.Contact.Date_of_2nd_Violation_AV_or_CMP__c;
             Date3rdViolation = c.Contact.Date_of_3rd_Violation_AV_or_CMP__c;
           //  BP_1stCaseDate   = c.Contact.BP_First_Warning_Violation_Date__c; 
           //  BP_2ndCaseDate   = c.Contact.BP_Suspended_1_Promo_CY_Violation_Date__c; 
           //  BP_3rdCaseDate   = c.Contact.BP_Terminated_Blacklisted_Violation_Date__c;
             CaseUpdate = new Case();
             strExceptionCase = 'No';
             system.debug('c.Id####: ' + c.Id);
             CaseUpdate.Id = c.Id;
            system.debug('CaseUpdate.Id####: ' + CaseUpdate.Id);
            system.debug('strCaseSubType####: ' + strCaseSubType);
            //system.debug('c.Account.Owner.Email####: ' + c.Account.Owner.Email);
            if(!caseContactMap.containsKey(strCaseContactId)){
                caseContactMap.put(strCaseContactId,new Contact(Id = strCaseContactId));
            }
            else {
                if (caseContactMap.get(strCaseContactId).Date_of_1st_Violation_AV_or_CMP__c != null || CMPReset.contains(strCaseContactId) || AVReset.contains(strCaseContactId)) {
                    X1stFailedCaseRegulatoryAction = caseContactMap.get(strCaseContactId).X1st_Failed_Case_Regulatory_Action__c;
                    Date1stViolation = caseContactMap.get(strCaseContactId).Date_of_1st_Violation_AV_or_CMP__c;
                }
                if (caseContactMap.get(strCaseContactId).Date_of_2nd_Violation_AV_or_CMP__c != null || CMPReset.contains(strCaseContactId) || AVReset.contains(strCaseContactId)) {
                    X2ndFailedCaseRegulatoryAction = caseContactMap.get(strCaseContactId).X2nd_Failed_Case_Regulatory_Action__c;
                    Date2ndViolation = caseContactMap.get(strCaseContactId).Date_of_2nd_Violation_AV_or_CMP__c;
                }
                if (caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c != null || CMPReset.contains(strCaseContactId) || AVReset.contains(strCaseContactId)) {
                    X3rdFailedCaseRegulatoryAction = caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c;
                    Date3rdViolation = caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c;
                }
            }
            
            if (strCaseSubType == 'Sale Involving a Minor' || strCaseSubType == 'Other - Not Involving a Minor' || strCaseSubType == 'No Violations Observed') {
                    AVCount   = 0;
                    CaseCount = 0;
                    TotalCount = 0;
                    if (Date1stViolation != null && X1stFailedCaseRegulatoryAction =='AV - First Warning' && Date1stViolation >= HardCutoffDate && Date1stViolation >= Dt1year) {
                        AVCount = 1;
                    }
                    if (Date2ndViolation != null && (X2ndFailedCaseRegulatoryAction =='AV - First Warning' || X2ndFailedCaseRegulatoryAction == 'AV - Report to FDA')
                        && Date2ndViolation >= HardCutoffDate && Date2ndViolation >= Dt1year) {
                        AVCount += 1;
                    }

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
                        
                        if (CaseCount == 1) {
                            if (MaxClosedDate >= HardCutoffDate && MaxClosedDate >= Dt1year){   // Within 12 months so this is second case
                                CaseCount = 1;
                            }
                            else 
                            {   
                                 CaseCount = 0;
                                 if (AVCount == 0) {        // First Case Reset 
                                   CMPReset.add(strCaseContactId);  
                                 }
                            }   
                        }
                    }
                        
                        TotalCount     = CaseCount + AVCount;
                        if (CaseCount == 0) {
                            CaseUpdate.Regulatory_Action__c = 'CMP - First Warning';
                            system.debug('CaseUpdate####:   NoExisting CMP Data');
                        }
                        else if (CaseCount == 1){
                            CaseUpdate.Regulatory_Action__c = 'CMP - Suspended - 2 Promo Cycle';
                        }
                        else if (CaseCount >= 2) {
                            CaseUpdate.Regulatory_Action__c = 'CMP - Terminated';
                        }
                
                        if (TotalCount == 0) {
                            caseContactMap.get(strCaseContactId).X1st_Failed_Case_Regulatory_Action__c = CaseUpdate.Regulatory_Action__c;
                            caseContactMap.get(strCaseContactId).Date_of_1st_Violation_AV_or_CMP__c = SecretShopDate;
                            caseContactMap.get(strCaseContactId).X2nd_Failed_Case_Regulatory_Action__c = null;
                            caseContactMap.get(strCaseContactId).Date_of_2nd_Violation_AV_or_CMP__c = null;
                            caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = null;
                            caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c = null;
                            system.debug('CaseUpdate####:   NoExisting CMP Data');
                        }
                        else if (TotalCount == 1){
                            caseContactMap.get(strCaseContactId).X2nd_Failed_Case_Regulatory_Action__c = CaseUpdate.Regulatory_Action__c;
                            caseContactMap.get(strCaseContactId).Date_of_2nd_Violation_AV_or_CMP__c    = SecretShopDate;
                            if(!caseAccountMap.containsKey(c.AccountId)){
                                caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Suspended'));
                                caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = null;
                                caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c    = null;
                            }
                            else if (caseAccountMap.get(c.AccountId).Status__c != 'Blacklisted') {
                                caseAccountMap.get(c.AccountId).Status__c = 'Suspended';
                                caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = null;
                                caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c    = null;
                            }
                        }
                        else if (TotalCount >= 2) {
                            caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = CaseUpdate.Regulatory_Action__c;
                            caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c    = SecretShopDate;
                            // check if Account Violation Type is null or not 
                            
                          
                            
                            if(!caseAccountMap.containsKey(c.AccountId)){
                                if(c.Account.Violation_Type__c == null){
                                    caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Blacklisted',Violation_Type__c = 'Secret Shop 3rd Strike Policy'));}
                                                    else{
                                                        caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Blacklisted'));
                                                    }
                                
                               
                            }
                            else if (caseAccountMap.get(c.AccountId).Status__c != 'Blacklisted') {
                                caseAccountMap.get(c.AccountId).Status__c = 'Blacklisted'; 
                                if(c.Account.Violation_Type__c == null){
                                    caseAccountMap.get(c.AccountId).Violation_Type__c = 'Secret Shop 3rd Strike Policy';
                                }
                               
                            }
                        }
                
                   system.debug('CaseUpdate####: ' + CaseUpdate);
            } 
            else if (strCaseSubType == 'Age Verification') {

                 CMPCount  = 0;
                 CaseCount = 0;
                 TotalCount = 0;
                 if (strCaseSSStatus == 'Pass') {   // First Case --> No existing data or Fail Reset
                        CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_5__c));
                 }
                 else if (strCaseSSStatus == 'Fail') {
                     
                     if (Date1stViolation != null && X1stFailedCaseRegulatoryAction =='CMP - First Warning' && Date1stViolation >= HardCutoffDate && Date1stViolation >= Dt1year) {
                         CMPCount += 1;
                     }
                     if (Date2ndViolation != null && (X2ndFailedCaseRegulatoryAction =='CMP - First Warning' || X2ndFailedCaseRegulatoryAction == 'CMP - Suspended - 2 Promo Cycle') 
                         && Date2ndViolation >= HardCutoffDate && Date2ndViolation >= Dt1year) {
                         CMPCount += 1;
                     }
                     
                     if (Date1stViolation == null && Date2ndViolation == null && Date3rdViolation == null){
                         CaseCount = 0;
                     }
                     else if (Date1stViolation != null && X1stFailedCaseRegulatoryAction =='AV - First Warning' && Date2ndViolation == null && Date3rdViolation == null) {     // one previous case
                         if (Date1stViolation < CutoffDate_1YR && CMPCount == 0) {
                             CaseCount = 0;  // One Level Reset
                             AVReset.add(strCaseContactId);
                         }
                         else{
                             CaseCount = CaseCount + 1;
                         }
                     }
                     else if (Date1stViolation != null && X1stFailedCaseRegulatoryAction =='AV - First Warning' && Date2ndViolation != null && X2ndFailedCaseRegulatoryAction == 'AV - Report to FDA' && Date3rdViolation == null) {     // two previous cases
                         if (Date1stViolation < CutoffDate_1YR && CMPCount == 0) {
                             CaseCount = 0;  //Complete reset 
                            // CaseCount = CMPCount + 1;
                             AVReset.add(strCaseContactId);
                         }
                         else{
                             CaseCount = CaseCount + 2;
                         }
                     }
                     else if (Date1stViolation != null && X1stFailedCaseRegulatoryAction =='AV - First Warning' && Date2ndViolation != null && X2ndFailedCaseRegulatoryAction != 'AV - Report to FDA' && Date3rdViolation == null) {     // two previous cases
                         if (Date1stViolation < CutoffDate_1YR && CMPCount == 0) {
                             CaseCount = 0;  //Complete reset 
                            // CaseCount = CMPCount + 1;
                             AVReset.add(strCaseContactId);
                         }
                         else{
                             CaseCount = CaseCount + 1;
                         }
                     }
                     
                     TotalCount = CaseCount + CMPCount;
                     if (CaseCount == 0) {     // no previous cases
                         CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addDays(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_1__c));
                         CaseUpdate.Regulatory_Action__c = 'AV - First Warning';
                         ageemailIdList.add(strCaseEmail); 
                     }
                     else if (CaseCount == 1) {
                         CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addDays(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_1__c));
                         CaseUpdate.Regulatory_Action__c = 'AV - Report to FDA';   
                         ageemailIdList.add(strCaseEmail);
                     }
                     else if (CaseCount >= 2) {
                         CaseUpdate.Regulatory_Action__c = 'AV - 3rd Audit Failure';           // first & second cases are valid
                         bulkemailIdList.add(strCaseEmail);
                     }
                     
                     if (TotalCount == 0) {     // no previous cases
                         caseContactMap.get(strCaseContactId).X1st_Failed_Case_Regulatory_Action__c = CaseUpdate.Regulatory_Action__c;
                         caseContactMap.get(strCaseContactId).Date_of_1st_Violation_AV_or_CMP__c = SecretShopDate;
                         caseContactMap.get(strCaseContactId).X2nd_Failed_Case_Regulatory_Action__c = null;
                         caseContactMap.get(strCaseContactId).Date_of_2nd_Violation_AV_or_CMP__c = null;
                         caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = null;
                         caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c = null;
                         ageemailIdList.add(strCaseEmail); 
                     }
                     else if (TotalCount == 1) {
                         caseContactMap.get(strCaseContactId).X2nd_Failed_Case_Regulatory_Action__c = CaseUpdate.Regulatory_Action__c;
                         caseContactMap.get(strCaseContactId).Date_of_2nd_Violation_AV_or_CMP__c    = SecretShopDate;
                         ageemailIdList.add(strCaseEmail);
                         if(!caseAccountMap.containsKey(c.AccountId)){
                             caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Suspended'));
                             caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = null;
                             caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c = null;
                         }
                         else if (caseAccountMap.get(c.AccountId).Status__c != 'Blacklisted') {
                             caseAccountMap.get(c.AccountId).Status__c = 'Suspended';
                             caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = null;
                             caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c = null;
                         }
                     }
                     else if (TotalCount >= 2) {
                         caseContactMap.get(strCaseContactId).X3rd_Failed_Case_Regulatory_Action__c = CaseUpdate.Regulatory_Action__c; // first & second cases are valid
                         caseContactMap.get(strCaseContactId).Date_of_3rd_Violation_AV_or_CMP__c    = SecretShopDate;
                         bulkemailIdList.add(strCaseEmail);
                         
                         // check if Account Violation Type is null or not 
                            
                            
                         
                         if(!caseAccountMap.containsKey(c.AccountId)){
                             if(c.Account.Violation_Type__c == null){
                                 caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Blacklisted',Violation_Type__c = 'Secret Shop 3rd Strike Policy'));}
                             else{
                                 caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Blacklisted'));
                             }
                         }
                         else if (caseAccountMap.get(c.AccountId).Status__c != 'Blacklisted') {
                             caseAccountMap.get(c.AccountId).Status__c = 'Blacklisted'; 
                             if( caseAccountMap.get(c.AccountId).Violation_Type__c == null){
                                caseAccountMap.get(c.AccountId).Violation_Type__c = 'Secret Shop 3rd Strike Policy'; 
                             }
                         }
                     }
                 }
            }
            else if (strCaseSubType == 'Product Quantity Limits'){
                strCaseMapIdPass  = strCaseAccntId + strCaseSubType + 'Pass';
                strCaseMapIdFail  = strCaseAccntId + strCaseSubType + 'Fail';
                strPassRecExists  = '';
                strFailRecExists  = '';
                strLatestExisting = '';
                CaseCountPass = 0;
                CaseCountFail = 0;
                
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
                    
                if (strCaseSSStatus == 'Pass' && (strLatestExisting == '' || strLatestExisting == 'Fail')) {   // First Case --> No existing data or Fail Reset
                    CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_5__c));
                }
                else if (strCaseSSStatus == 'Pass' && strLatestExisting == 'Pass') {   // Second Case, Third Case .....
                    CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_5__c));
                }
                else if (strCaseSSStatus == 'Fail' && (strLatestExisting == '' || strLatestExisting == 'Pass')) {   // // First Case --> No existing data or Pass 
                    CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_2__c));
                    CaseUpdate.Regulatory_Action__c = 'Warning'; 
                    caseContactMap.get(strCaseContactId).BP_First_Warning_Violation_Date__c = SecretShopDate;
                    caseContactMap.get(strCaseContactId).BP_Suspended_1_Promo_CY_Violation_Date__c = null;
                    bulkemailIdList.add(strCaseEmail);
                }
                else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail' && CaseCountFail == 1) {   // // Second Consequetive Case  
                    CaseUpdate.Next_Secret_Shop_Date__c = c.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_4__c));
                    CaseUpdate.Regulatory_Action__c = 'Product Quantity Limits'; 
                    caseContactMap.get(strCaseContactId).BP_Suspended_1_Promo_CY_Violation_Date__c = SecretShopDate;
                    bulkemailIdList.add(strCaseEmail);
                }
                else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail' && CaseCountPass == 0 && CaseCountFail >= 2) {   // // Second Consequetive Case  
                    CaseUpdate.Regulatory_Action__c = 'Product Quantity Limits';
                    // check if Account Violation Type is null or not
                    String Violation_Type;
                    
                    
                    if(!caseAccountMap.containsKey(c.AccountId)){
                        if(c.Account.Violation_Type__c == null){
                            caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Blacklisted',Violation_Type__c = 'Secret Shop 3rd Strike Policy'));}
                        else{
                            caseAccountMap.put(c.AccountId,new Account(Id = c.AccountId, Status__c = 'Blacklisted'));
                        }
                    }
                    else if (caseAccountMap.get(c.AccountId).Status__c != 'Blacklisted') {
                        caseAccountMap.get(c.AccountId).Status__c = 'Blacklisted'; 
                        if(caseAccountMap.get(c.AccountId).Violation_Type__c == null){
                            caseAccountMap.get(c.AccountId).Violation_Type__c = 'Secret Shop 3rd Strike Policy';
                        }
                    }
                    caseContactMap.get(strCaseContactId).BP_Terminated_Blacklisted_Violation_Date__c = SecretShopDate;
                    bulkemailIdList.add(strCaseEmail);
                }
                else if (strCaseSSStatus == 'Fail' && strLatestExisting == 'Fail' && CaseCountPass >= 1 && CaseCountFail >= 2) {   //  
                    strExceptionCase = 'Yes';
                    CaseExceptionList.add(c); 
                    ExecptionCaseAccountIdSet.add(c.AccountId);
                    accountExcpSrcCaseListMap.put(c.AccountId,c.Id);
                }
            }
            system.debug('CaseUpdate####: ' + CaseUpdate);
            system.debug('strExceptionCase####: ' + strExceptionCase);
            system.debug('caseUpdateListBEfore ####: ' + caseUpdateList);
            if (strExceptionCase == 'No') { 
                system.debug('Entered Loop ####: ');
                caseUpdateList.add(CaseUpdate);  
                system.debug('caseUpdateListAfter####: ' + caseUpdateList);
            }
            
        }

        System.debug('!!!!civilemailIdList::::'+civilemailIdList);
        System.debug('!!!!ageemailIdList::::'+ageemailIdList);
        System.debug('!!!!bulkemailIdList::::'+bulkemailIdList);
        System.debug('!!!!CaseExceptionList::::'+CaseExceptionList);  
        System.debug('!!!!ExecptionCaseAccountIdSet::::'+ExecptionCaseAccountIdSet);
        system.debug('caseUpdateList####: ' + caseUpdateList);
        
 
        if(CaseExceptionList != null && CaseExceptionList.size() > 0){
        ExceptionExistingCase = [select Id, AccountId, Secret_Shop_Status__c, Account.Owner.Email, Account.Violation_Type__c, Secret_Shop_Date__c, ContactId
                                   from case      
                                  where RecordTypeId =: B2BSupportCaseRecordTypeId AND status = 'Retail Case Closed' AND AccountId in :ExecptionCaseAccountIdSet AND
                                        Sub_Type__c = 'Bulk Purchasing'  AND (Next_Secret_Shop_Date__c != NULL OR Regulatory_Action__c != NULL)
                                  Order by AccountId, Secret_Shop_Date__c DESC];
 
        for(Case ec: ExceptionExistingCase){
            CaseUpdate = new Case();
            if(accountExcpCaseListMap.containsKey(ec.AccountId)){
                if (ExcpCaseMapCount == 'FirstCaseRec') {
                    accountExcpCaseListMap.get(ec.AccountId).add(ec);
                    ExcpCaseMapCount = 'SecondCaseRec';
                    CaseUpdate.Id    = accountExcpSrcCaseListMap.get(ec.AccountId);   //get exeception source case id
    
                    if (ec.Secret_Shop_Status__c == 'Fail'){      //Second latest case is Fail
                         CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - Terminated / Blacklisted';
                         //setAccntStatusTerminated.add(new Account (Id = ec.AccountId, Status__c= 'Blacklisted'));
                         String Violation_Type;
                         if(ec.Account.Violation_Type__c == null){
                            Violation_Type = 'Secret Shop 3rd Strike Policy';
                         }else{
                            Violation_Type = ec.Account.Violation_Type__c;
                         }
                         
                         if(!caseAccountMap.containsKey(ec.AccountId)){
                            caseAccountMap.put(ec.AccountId,new Account(Id = ec.AccountId, Status__c = 'Blacklisted',Violation_Type__c = Violation_Type));
                         }
                         else if (caseAccountMap.get(ec.AccountId).Status__c != 'Blacklisted') {
                                caseAccountMap.get(ec.AccountId).Status__c = 'Blacklisted'; 
                                caseAccountMap.get(ec.AccountId).Violation_Type__c = Violation_Type;
                         }
                         caseContactMap.get(strCaseContactId).BP_Terminated_Blacklisted_Violation_Date__c = ec.Secret_Shop_Date__c;
                    }
                    else {                                       //Second latest case is Pass
                        CaseUpdate.Next_Secret_Shop_Date__c = ec.Secret_Shop_Date__c.addMonths(Integer.valueOf(settingsConst.Next_Secret_Shop_Date_of_4__c));
                        CaseUpdate.Regulatory_Action__c = 'Bulk Purchasing - Suspended - 1 Promo Cycle'; 
                        caseContactMap.get(strCaseContactId).BP_Suspended_1_Promo_CY_Violation_Date__c = ec.Secret_Shop_Date__c;
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
        
        System.debug('!!!!CaseUpdateSet::::'+CaseUpdateSet);
        System.debug('!!!!caseContactMap::::'+caseContactMap);
        System.debug('!!!!caseAccountMap::::'+caseAccountMap);
        
        CaseUpdateList.addAll(CaseUpdateSet); 
        
        if(CaseUpdateList != null && CaseUpdateList.size() > 0){
            try{
                  Database.SaveResult[] saveResultList1 = Database.update(CaseUpdateList, false);
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
        
        if(caseContactMap != null && caseContactMap.size() > 0){
           //  Update caseContactMap.values();
            try{
              Database.SaveResult[] saveResultList2 = Database.update(caseContactMap.values(), false);
                // Iterate through saveResultList based on isSuccess capture the failed records
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
        
        if(caseAccountMap != null && caseAccountMap.size() > 0){
            // Update caseAccountMap.values();
            try{
              Database.SaveResult[] saveResultList3 = Database.update(caseAccountMap.values(), false);
                for (Database.SaveResult sr : saveResultList3) {
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
               /* if((civilemailIdList != null && civilemailIdList.size() > 0) || 
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
                 
                 Messaging.sendEmail(new Messaging.SingleEmailMessage [] { mail }); 
            } */
                settingsConst    = BatchConstantValues__c.getinstance('BatchBrandProtection');
                String adminEmails = settingsConst.X3_Strike_Admin_EmailIds__c;
                if(!String.isEmpty(adminEmails)){
                    try{
                        String[] toAddresses= adminEmails.split(','); 
                        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                          TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('Batch apex Job JuulSalesOpsBatchBrandProtection ' + a.Status);
                        mail.setPlainTextBody('The batch Apex job JuulSalesOpsBatchBrandProtection processed ' + a.TotalJobItems +
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