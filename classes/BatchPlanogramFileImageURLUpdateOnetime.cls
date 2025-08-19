/*******************************************************************************************
* @Name         BatchPlanogramFileImageURLUpdateOnetime
* @Author       Sushma Manickam
* @Date         07/01/2020
* @Group        
* @Description  Onetime batch job - To update the Image URL in Planogram from Content Distribution
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Sushma          07/01/2020         Initial Creation
*******************************************************************************************/
global class BatchPlanogramFileImageURLUpdateOnetime implements Database.Batchable<sObject>, Database.Stateful {
    String AdminEmailIds; 
    Integer TotalCDExists=0,TotalCDInsert=0,TotalCDErrors=0,TotalPOGUpdate=0,TotalPOGErrors=0,TotalCDRecords=0,TotalPOGRecords=0 ;
    global BatchPlanogramFileImageURLUpdateOnetime(){
        MSASalesDataProcessBatch__c MSACustomSetting = MSASalesDataProcessBatch__c.getinstance('MSASalesDataProcessBatch');
        AdminEmailIds   = MSACustomSetting.AdminEmailIds__c;      
    }
    
    /**************************************************************************************
    * @Description this method generates the scope of the records in the database
    * @Param   Database.BatchableContext
    * @Return  Database.QueryLocator
    **************************************************************************************/ 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        query =  'SELECT Id,Name FROM Planogram__c WHERE ImageURL__c = null';
        return Database.getQueryLocator(query);
    }      
    
    /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<Account>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Planogram__c> listPOGs) {
        List<Database.Error> insertlistCDError  = new List<Database.Error>();
        List<Database.Error> insertlistPOGError  = new List<Database.Error>();
        
        Set<Id> setPOGIds = new Set<Id>();
        Set<Id> setCDIds  = new Set<Id>();
        Set<Id> CDRecs    = new Set<Id>();
        Map<Id, Id> CDLId2POGId = new Map<Id, Id>();
        for(Planogram__c POGRec: listPOGs) {           
            setPOGIds.add(POGRec.Id);
        }      
        
        List<ContentDocumentLink> listCDL = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : SetPOGIds];
        for(ContentDocumentLink CDLRec: listCDL) {
            setCDIds.add(CDLRec.ContentDocumentId);
            CDLId2POGId.put(CDLRec.ContentDocumentId,CDLRec.LinkedEntityId);
        }
        if (setCDIds.size() > 0) {
            List<ContentVersion> listCV = [SELECT Id,Title,Active__c FROM ContentVersion WHERE IsLatest = True and ContentDocumentId IN :setCDIds];
            Set<Id> setCVIds = new Set<Id>();
            for(ContentVersion cv:listCV) {
                setCVIds.add(cv.id);
            }
            
            List<ContentDistribution> listCDexists = [select Id, Name,ContentVersionId from ContentDistribution where ContentVersionId IN:setCVIds];
            for(ContentDistribution cd: listCDexists) {
                setCVIds.remove(cd.ContentVersionId);
                CDRecs.add(cd.Id);
                TotalCDExists++;
            }
            
            if(setCDIds.size() > 0) {
                List<ContentVersion> listCVRem = [SELECT Id,Title,Active__c FROM ContentVersion WHERE Id IN :setCVIds and IsLatest = True and ContentDocumentId IN :setCDIds];
                List<ContentDistribution> listCDInsert = new List<ContentDistribution>();
                ContentDistribution newDistribution;
                for(ContentVersion CVRec : listCVRem) {
                    newDistribution = new ContentDistribution(ContentVersionId = CVRec.Id, 
                                                              Name = CVRec.Title+'.pdf',
                                                              PreferencesNotifyOnVisit = false);
                    listCDInsert.add(newDistribution);
                    TotalCDRecords++;
                }
                
                if(!listCDInsert.isEmpty()) {
                    List<Database.SaveResult> CDSaveResults = Database.insert(listCDInsert, false);
                    for(Integer i=0; i<CDSaveResults.size(); i++){
                        Database.SaveResult saveResult = CDSaveResults[i];
                        if(saveResult.isSuccess()){
                            listCDInsert[i].Id = saveResult.getId(); 
                            CDRecs.add(listCDInsert[i].Id);
                            TotalCDInsert++;
                        }
                        else{
                            insertlistCDError.addAll(saveResult.getErrors());
                            TotalCDErrors++;
                        }
                    }
                    if(insertlistCDError != null && insertlistCDError.size()> 0){
                        LogEventTriggerHandler.insertBatchLog(insertlistCDError, 'BatchPlanogramFileImageURLUpdateOnetime', 'execute', 'ContentDistribution', 'Database.Insert_Failed');
                    }   
                }
            }
            
            if(CDRecs != null) {
                List<ContentDistribution> listCDNew = [SELECT Id, ContentDocumentId,  ContentVersionId, DistributionPublicUrl FROM ContentDistribution WHERE Id IN : CDRecs];
                List<Planogram__c> listPOGsUpdate = new List<Planogram__c>();
                Planogram__c POGUpdate;
                for(ContentDistribution CDRec : listCDNew) {
                    POGUpdate = new Planogram__c(Id = CDLId2POGId.get(CDRec.ContentDocumentId),
                                                 ImageURL__c = CDRec.DistributionPublicUrl);
                    listPOGsUpdate.add(POGUpdate);
                    TotalPOGRecords++;
                }
                if(!listPOGsUpdate.isEmpty()) {               
                    List<Database.SaveResult> POGSaveResults = Database.Update(listPOGsUpdate, false);
                    for(Integer i=0; i<POGSaveResults.size(); i++) {
                        Database.SaveResult saveResult = POGSaveResults[i];
                        if(saveResult.isSuccess()){
                            TotalPOGUpdate++;
                        }
                        else {
                            insertlistPOGError.addAll(saveResult.getErrors());
                            TotalPOGErrors++;
                        }  
                    }
                    if(insertlistPOGError != null && insertlistPOGError.size()> 0){
                        LogEventTriggerHandler.insertBatchLog(insertlistPOGError, 'BatchPlanogramFileImageURLUpdateOnetime', 'execute', 'Planogram__c', 'Database.Insert_Failed');
                    }  
                }
            }
        }
    }  
    
    /**************************************************************************************
    * @Description this method executes any post processing tasks
    * @Param   Database.BatchableContext
    * @Return  --none--
    **************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        if(!String.isEmpty(AdminEmailIds)){
            try{
                String[] toAddresses= AdminEmailIds.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,CreatedDate, 
                                  CompletedDate, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String ElapsedTime='';
                datetime start = a.CreatedDate;
                datetime later = a.CompletedDate;
                decimal millisecs = decimal.valueOf(later.getTime() - start.getTime());
                decimal dDays = millisecs/1000/60/60/24;
                system.debug('dDays: ' +dDays);
                integer iDays = integer.valueOF(math.floor(dDays));
                decimal remainderDays = dDays- iDays;
                decimal dHours = remainderDays * 24;
                integer iHours = integer.valueOf(math.floor(dHours));
                decimal remainderHours = dHours - iHours;
                decimal dMinutes = remainderHours * 60;
                integer iMinutes = integer.valueOf(math.floor(dMinutes));
                decimal remainderMinutes = dMinutes - iMinutes;
                decimal dSeconds = remainderMinutes * 60;
                integer iSeconds = integer.valueOf(math.floor(dSeconds));
                decimal remainderSeconds = dSeconds - iSeconds;
                if(iDays >0) { ElapsedTime += iDays + ' Days ';  }
                if(iDays >0 || iHours >0) {ElapsedTime += iHours + ' Hrs '; }
                if(iHours >0 || iMinutes >0) {ElapsedTime += iMinutes + ' Min '; }  
                ElapsedTime += iSeconds + ' Sec';
                system.debug('Days: ' + iDays+' - '+'Hours: ' + iHours+' - '+'Minutes: ' + iMinutes+' - '+'Seconds: ' + iSeconds);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job BatchPlanogramFileImageURLUpdateOnetime ' + a.Status);
                mail.setPlainTextBody(
                    '  The batch Apex job BatchPlanogramFileImageURLUpdateOnetime processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + 
                    '\n The batch job started ' + a.CreatedDate + ' and completed '+ a.CompletedDate + ' with total elapsed time ' + ElapsedTime + '.' +
                    '\n ********** Processed record & Error counts **************** ' +
                    '\n Total CD Records Existing: ' + TotalCDExists                +
                    '\n Total CD Records for Insert: ' + TotalCDRecords             +
                    ',  Total CD Successful Inserts: ' + TotalCDInsert              +
                    ',  Total CD Error in Insert: ' + TotalCDErrors                 +  
                    '\n Total POG Records for Update: ' + TotalPOGRecords           +
                    ',  Total POG Successful Update: ' +TotalPOGUpdate              +
                    ',  Total POG Error in Update: ' + TotalPOGErrors               +
                    '\n *********************************************************** ' + '\n');
                
                system.debug('Email :'+ mail); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }              
        }
    }
}