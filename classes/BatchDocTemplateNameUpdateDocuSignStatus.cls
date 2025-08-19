/*******************************************************************************************
* @Name         BatchDocTemplateNameUpdateDocuSignStatus
* @Author       Sushma Manickam
* @Date         09/01/2020
* @Group        
* @Description  Onetime batch job - To update the Document Template Name in DocuSignStatus from attachment
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Sushma          09/01/2020         Initial Creation
*******************************************************************************************/

global class BatchDocTemplateNameUpdateDocuSignStatus implements Database.Batchable<sObject>, Database.Stateful {
    String AdminEmailIds; 
    Integer TotalCDExists=0,TotalCDInsert=0,TotalCDErrors=0,TotalDSSUpdate=0,TotalDSSErrors=0,TotalCDRecords=0,TotalDSSRecords=0 ;
    global BatchDocTemplateNameUpdateDocuSignStatus(){
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
        query =  'SELECT Id,Name FROM dsfs__DocuSign_Status__c WHERE DocuSign_Template_Name__c = null';
        return Database.getQueryLocator(query);
    }      
    
    /**************************************************************************************
    * @Description this method holds the processing logic for each batch of records
    * @Param    Database.BatchableContext, List<dsfs__DocuSign_Status__c>
    * @Return  --none--
    **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<dsfs__DocuSign_Status__c> listDocSts) {
        List<Database.Error> insertlistCDError  = new List<Database.Error>();
        List<Database.Error> insertlistDSSError  = new List<Database.Error>();
        
        Set<Id> setDocStsIds = new Set<Id>();
        Set<Id> setCDIds  = new Set<Id>();
        Set<Id> CDRecs    = new Set<Id>();
        Map<Id, Id> CDLId2DSSId = new Map<Id, Id>();
        MAP<Id,dsfs__DocuSign_Status__c> DocuSignUpd = new MAP<Id,dsfs__DocuSign_Status__c>();
        
        for(dsfs__DocuSign_Status__c DocSts: listDocSts) {           
            setDocStsIds.add(Docsts.Id);
        }     
        
        List<ContentDocumentLink> listCDL = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : setDocStsIds];        
        
        for(ContentDocumentLink CDLRec: listCDL) {
            setCDIds.add(CDLRec.ContentDocumentId);           
            CDLId2DSSId.put(CDLRec.ContentDocumentId,CDLRec.LinkedEntityId);   
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
                                                              Name = CVRec.Title,
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
                List<ContentDistribution> listCDNew = [SELECT Id, ContentDocumentId, ContentVersionId, Name FROM ContentDistribution WHERE Id IN : CDRecs];
                
                List<dsfs__DocuSign_Status__c> listDSSs = new List<dsfs__DocuSign_Status__c>();
                dsfs__DocuSign_Status__c DocStatus;
                
                for(ContentDistribution CDRec : listCDNew) {
                    string Docname = CDRec.Name.replace('.pdf.pdf','.pdf');
                    if(CDLId2DSSId.containskey(CDRec.ContentDocumentId) != null)
                        DocStatus = new dsfs__DocuSign_Status__c(Id = CDLId2DSSId.get(CDRec.ContentDocumentId),
                                                                 DocuSign_Template_Name__c = Docname);
                    listDSSs.add(DocStatus);              
                    TotalDSSRecords++;
                }
                if(!listDSSs.isEmpty()) {  
                    DocuSignUpd.putall(listDSSs);
                }
                if(DocuSignUpd.size()>0) {              
                    List<Database.SaveResult> DSSSaveResults = Database.Update(DocuSignUpd.values(), false);
                    for(Integer i=0; i<DSSSaveResults.size(); i++) {
                        Database.SaveResult saveResult = DSSSaveResults[i];
                        if(saveResult.isSuccess()){
                            TotalDSSUpdate++;
                        }
                        else {
                            insertlistDSSError.addAll(saveResult.getErrors());
                            TotalDSSErrors++;
                        }  
                    }
                    if(insertlistDSSError != null && insertlistDSSError.size()> 0){
                        LogEventTriggerHandler.insertBatchLog(insertlistDSSError, 'BatchDocTemplateNameUpdateDocuSignStatus', 'execute', 'Planogram__c', 'Database.Insert_Failed');
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
                mail.setSubject('Batch apex Job BatchDocTemplateNameUpdateDocuSignStatus ' + a.Status);
                mail.setPlainTextBody(
                    '  The batch Apex job BatchDocTemplateNameUpdateDocuSignStatus processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + 
                    '\n The batch job started ' + a.CreatedDate + ' and completed '+ a.CompletedDate + ' with total elapsed time ' + ElapsedTime + '.' +
                    '\n ********** Processed record & Error counts **************** ' +
                    '\n Total CD Records Existing: ' + TotalCDExists                +
                    '\n Total CD Records for Insert: ' + TotalCDRecords             +
                    ',  Total CD Successful Inserts: ' + TotalCDInsert              +
                    ',  Total CD Error in Insert: ' + TotalCDErrors                 +  
                    '\n Total POG Records for Update: ' + TotalDSSRecords           +
                    ',  Total POG Successful Update: ' +TotalDSSUpdate              +
                    ',  Total POG Error in Update: ' + TotalDSSErrors               +
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