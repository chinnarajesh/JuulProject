/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Keerthana         04-01-2019                                         */
/* Class Name:     JuulSalesOpsTrueOutOfStockBatch                                      */
/* Description:    Querying the OOS object records to update True OOS flag if the       */
/*                 Audit date falls between order date -91 days                         */
/* -------------------------------------------------------------------------------------*/
/* MODIFICATION LOG                                                                     */
/* VERSION         AUTHOR         DATE            Descripton                            */
/*    1.1         Keerthana         04-03-2019    Declared auditDate variable and used  */
/*                                                as bind variable in SOQL Query        */
/*    1.1         Keerthana         04-04-2019    Added Try Catch block                 */
/*    1.2         Keerthana         04-15-2019    Modified code to group source records */
/*                                                by OOS Audit Date and process each    */
/*                                                source group.                         */
/****************************************************************************************/
global class JuulSalesOpsTrueOutOfStockBatch implements Database.Batchable<sObject>{
    
    // public List<Document_Details__c> ddList = new List<Document_Details__c>();
    Map<String, String> mapInputs =  new Map<String, String>();
    
    global JuulSalesOpsTrueOutOfStockBatch(Map<String, String> mapInputs){
        this.mapInputs = mapInputs;
    }
    /*****************************************************************************/
    /* Method Name:    start                                                     /*
    /* Description:    start method of Batchable Interface                       /*
    /*                 Forms SQL Query for Batch processing                      /*
    /*****************************************************************************/
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        String overrideQuery = '';
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Account__c, Product__c, Audit_Date__c, Validated_By__c, True_Out_of_Stock__c, True_OS_Status__c, True_OOS_Validation_Period_in_Days__c  FROM Out_Of_Stock__c ';
        // if overrideQuery is not null remove existing condition True_OS_Status__c = Unprocessed' and append overrideQuery
        if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
            overrideQuery = mapInputs.get('overrideQuery');
        }else{
            overrideQuery += ' WHERE True_OS_Status__c = \'Unprocessed\'';
            // if inputValidatedBy is not null add in to where condition
            if(mapInputs.get('Validated_By__c') != null && mapInputs.get('Validated_By__c') != ''){
                overrideQuery += ' AND Validated_By__c =\'' + mapInputs.get('Validated_By__c')+'\'';
            }
            // if AuditDate is not null add in to where condition
            if(mapInputs.get('Audit_Date__c') != null && mapInputs.get('Audit_Date__c') != ''){
               overrideQuery += ' AND Audit_Date__c =' + mapInputs.get('Audit_Date__c');
            }
        }
        query += overrideQuery; 
        query += ' Order By Audit_Date__c ASC';
        system.debug('Query##'+query); 
        return Database.getQueryLocator(query);
    }
    /*****************************************************************************/
    /* Method Name:    execute                                                   */
    /* Description:    execute method of Batchable Interface                     */
    /*****************************************************************************/
    global void execute(Database.BatchableContext bc, List<Out_Of_Stock__c> records){
        Set<Id>   SetAccountIds = new Set<Id>();
        Set<Id>   SetProductIds = new Set<Id>();
        Set<String> SetAuditDates  = new Set<String>();
        Map<String,Set<Id>> MapAuditDateAccountIds = new Map<String,Set<Id>>();
        Map<String,Set<Id>> MapAuditDateProductIds = new Map<String,Set<Id>>();
        Map<String, Date> acc_prod_OrdrDateMap = new Map<String, Date>(); // concatinate accid+prodid
        List<Out_Of_Stock__c> outofStockList = new List<Out_Of_Stock__c>(); // list to be updated
        String sAuditDate;
        try{
            //get the custom setting value
            True_Out_Of_Stock_ValidationPeriod__c objCSValidation = True_Out_Of_Stock_ValidationPeriod__c.getValues('OOS NumDays Emails');
            Integer CSValidationPeriod = Integer.ValueOf(objCSValidation.OOS_Validation_Period_In_Days__c);
            system.debug('##### objCSValidation: '+ objCSValidation);
            system.debug('##### CSValidationPeriod: '+ CSValidationPeriod);
            String AccountProductIds;
            system.debug('##### AccountProductIds: '+ AccountProductIds);
            // process each batch of records
            for(Out_Of_Stock__c os: records){
                sAuditDate = String.valueOf(os.Audit_Date__c);
                SetAuditDates.add(sAuditDate); // collect audit date
                if(!MapAuditDateAccountIds.containsKey(sAuditDate)) {
                    MapAuditDateAccountIds.put(sAuditDate,new Set<Id>()) ;
                }
                MapAuditDateAccountIds.get(sAuditDate).add(os.Account__c); 
                if(!MapAuditDateProductIds.containsKey(sAuditDate)) {
                    MapAuditDateProductIds.put(sAuditDate,new Set<Id>()) ;
                }
                MapAuditDateProductIds.get(sAuditDate).add(os.Product__c);
            }
            //system.debug('##### SetAuditDates: '+ SetAuditDates); 
            //system.debug('##### MapAuditDateAccountIds: '+ MapAuditDateAccountIds);
            //system.debug('##### MapAuditDateProductIds: '+ MapAuditDateProductIds);
            //system.debug('##### SetAccountIds: '+ SetAccountIds);
            //system.debug('##### SetProductIds: '+ SetProductIds);
            
            if(SetAuditDates != null && SetAuditDates.size() > 0 && MapAuditDateAccountIds != null && MapAuditDateAccountIds.size() > 0 && MapAuditDateProductIds != null && MapAuditDateProductIds.size() > 0){
                // fetch DD list records based on account Id and product Id
                Date MinOrderDate;
                Date MaxAuditDate;
                for (String auditdate:SetAuditDates)
                {
                    //system.debug('##### auditdate: '+ auditdate);
                    MaxAuditDate = Date.ValueOf(auditdate);
                    MinOrderDate = MaxAuditDate.addDays(CSValidationPeriod * -1);
                    system.debug('##### MinOrderDate: '+ MinOrderDate);
                    SetAccountIds = MapAuditDateAccountIds.get(auditdate);
                    SetProductIds = MapAuditDateProductIds.get(auditdate);
                    //system.debug('##### SetAccountIds: '+ SetAccountIds);
                    //system.debug('##### SetProductIds: '+ SetProductIds);
                    AggregateResult[] ddRecords = [SELECT SalesOrderNumber__r.Customer__c, Product__c, MAX(Order_Date__c) maxOrdrDate FROM Document_Details__c
                                                   WHERE SalesOrderNumber__r.Customer__c IN : SetAccountIds AND Product__c IN : SetProductIds AND quantity__c>0
                                                    AND Order_Date__c >= :MinOrderDate  AND Order_Date__c < :MaxAuditDate   
                                                   GROUP BY SalesOrderNumber__r.Customer__c, Product__c
                                                  ];
                    //system.debug('$$$ ddRecords:'+ ddRecords);
                    for(AggregateResult ar : ddRecords){
                        String accId_prodId = String.valueOf(ar.get('Customer__c')) + String.valueOf(ar.get('Product__c')) + auditdate; // concatinate the account&productId from DD object
                        acc_prod_OrdrDateMap.put(accId_prodId, Date.valueOf(ar.get('maxOrdrDate'))); // put the ccount&productId and the latestorderdate
                        //system.debug('##### accId_prodId:'+ accId_prodId);
                        //system.debug('##### accId_prodId:'+ Date.valueOf(ar.get('maxOrdrDate')));
                    }
                } 
            }
            //system.debug('AccountProductOrderDateMap##'+acc_prod_OrdrDateMap);
            Date auditDate;
            Date orderdate;
            String key;
            
            for(Out_Of_Stock__c os: records){
                auditDate = os.Audit_Date__c; // get the audit date from OOS
                sAuditDate = String.valueOf(AuditDate); // get the audit date from OOS
                key = os.Account__c +''+ os.Product__c + sAuditDate;
                system.debug('Key @'+key);
                orderDate = acc_prod_OrdrDateMap.get(key); // see if we have a match for account&productId in the map
                
                if(orderDate != null) {
                    if (orderDate >=  auditDate.addDays(CSValidationPeriod * -1)){ 
                        os.True_Out_of_Stock__c = true;
                    }else{
                        os.True_Out_of_Stock__c = false;
                    }
                }else{
                    os.True_Out_of_Stock__c = false;
                }
                os.True_OS_Status__c = 'Processed';
                os.True_OOS_Validation_Period_in_Days__c = CSValidationPeriod;
                outofStockList.add(os);
            }
            
            if(outofStockList != null && outofStockList.size() > 0){
                //update outofStockList;
                Database.SaveResult[] saveResultList = Database.update(outofStockList, false);
                
                // Iterate through saveResultList based on isSuccess capture the failed records
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }
        }    
        catch(Exception e){
            System.debug('Error :'+e.getMessage());
        }
    }    
    global void finish(Database.BatchableContext BC){
        //String[] toAddresses= new String[]{};
        /*List<User> listAdmins = [Select id, Name, Email from User where profile.Name = 'System Administrator'];
            for(User usr: listAdmins){
            toAddresses.add(usr.Email);
            System.debug('toAddresses'+toAddresses);
            }*/
        True_Out_Of_Stock_ValidationPeriod__c objOOSBatchAdmins = True_Out_Of_Stock_ValidationPeriod__c.getValues('OOS NumDays Emails');
        String adminEmails = objOOSBatchAdmins.Admin_Emails__c;
        if(!String.isEmpty(adminEmails)){
            try{
                String[] toAddresses= adminEmails.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                  TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job JuulSalesOpsTrueOutOfStockBatch ' + a.Status);
                mail.setPlainTextBody('The batch Apex job JuulSalesOpsTrueOutOfStockBatch processed ' + a.TotalJobItems +
                                      ' batches with '+ a.NumberOfErrors + ' failures.' + 
                                      '\n Input Paramterers provided for batch job: ' +
                                      '\n ValidatedBy   : ' + mapInputs.get('Validated_By__c') + 
                                      '\n AuditDate     : ' + mapInputs.get('Audit_Date__c') + 
                                      '\n OverrideQuery : ' + mapInputs.get('overrideQuery'));
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        } 
    } 
}