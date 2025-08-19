/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Naveen         10-09-2019                                            */
/* Class Name:     JuulSalesOpsGBBatchCaseUpdate                                        */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class JuulSalesOpsGBBatchCaseUpdate implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
     Map<String, String> mapInputs =  new Map<String, String>();
    public List<String> civilemailIdList {get;set;}
    public List<String> ageemailIdList {get;set;}
    public List<String> bulkemailIdList {get;set;}
    public BatchConstantValues__c settingsConst {get;set;}
    public static user userRec = new user();
   
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }

    global JuulSalesOpsGBBatchCaseUpdate(){
        /* this.mapInputs = mapInputs; 
        civilemailIdList = new List<String>();
        ageemailIdList = new List<String>();
        bulkemailIdList = new List<String>();
        settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');
        settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');*/
        
        
    }
    /*****************************************************************************/
    /* Method Name:    start                                                     /*
    /* Description:    start method of Batchable Interface                       /*
    /*                 Forms SQL Query for Batch processing                      /*
    /*****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String overrideQuery = '';
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
        if(mapInputs.get('overrideQuery') != null && mapInputs.get('overrideQuery') != ''){
           overrideQuery = ' AND ' + mapInputs.get('overrideQuery'); }
        
        String query = 'Select id,AccountID,Secret_Shop_Date__c,Secret_Shop_Status__c from case where RecordTypeId =: B2BSupportCaseRecordTypeId AND Type = \'Mystery Shop\' AND Sub_Type__c = \'Age Verification\' AND Next_Secret_Shop_Date__c = NULL AND RMA_Country__c=\'GB\'';

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
        set<id> setAccIds = new set<id>();
        map<id,Account> mapIdtoAccount = new map<id,Account>();
        list<Account> lstAcToUpdate = new list<Account>();
        list<Case> lstCaseToUpdate = new list<Case>();
        list<task> lsttask = new list<task>();
        UserRec =[select id from user where name='Elly Beattie'];
        system.debug('UserRec=='+UserRec);
        set<id> setAccid = new set<id>();
        for(Case cs:caseList)
        {
            if(cs.AccountID != null)
                setAccIds.add(cs.AccountID);
            
        }
        system.debug('setAccIds=='+setAccIds);
        if(setAccIds.size()>0)
        {
            for(Account objAc:[select ownerid,id,SS_First_Violation_Date__c,SS_Second_Violation_Date__c,SS_Third_Violation_Date__c from account where id in:setAccIds])
            {
                string strId = string.valueof(objAc.id).substring(0,15);
                mapIdtoAccount.put(strId,objAc);
            }
            
            for(Case cs:caseList)
            {
                if(mapIdtoAccount.get(cs.Accountid) != null)
                {
                    system.debug('pass from here==');
                    Account ac = mapIdtoAccount.get(cs.Accountid);
                    if(cs.Secret_Shop_Status__c == 'fail')
                    {
                        if(ac.SS_First_Violation_Date__c == null && ac.SS_Second_Violation_Date__c == null && ac.SS_Third_Violation_Date__c == null)
                        {
                        system.debug('pass from here1==');
                            //cs.Regulatory_Action__c ='First Visit Fail';//JTP-112
                            ac.SS_First_Violation_Date__c    = cs.Secret_Shop_Date__c;
                            cs.Next_Secret_Shop_Date__c =(cs.Secret_Shop_Date__c != null?cs.Secret_Shop_Date__c.adddays(40):system.today().adddays(40));
                            
                            if(setAccid.contains(ac.id) ==false)
                            {
                                lstAcToUpdate.add(ac);
                                setAccid.add(ac.id);
                            }
                            lstcaseToUpdate.add(cs);
                            lsttask.add(CreateTask('C25 Visit Fail',ac.ownerid,cs.id,3));
                        }
                        else if(ac.SS_First_Violation_Date__c != null && ac.SS_Second_Violation_Date__c == null && ac.SS_Third_Violation_Date__c == null)
                        {
                            system.debug('pass from here2==');
                            //cs.Regulatory_Action__c ='Second Visit Fail';//JTP-112
                            ac.SS_Second_Violation_Date__c    = cs.Secret_Shop_Date__c;
                            cs.Next_Secret_Shop_Date__c =(cs.Secret_Shop_Date__c != null?cs.Secret_Shop_Date__c.adddays(40):system.today().adddays(40));
                            
                            if(setAccid.contains(ac.id) ==false)
                            {
                                lstAcToUpdate.add(ac);
                                setAccid.add(ac.id);
                            }
                            lstcaseToUpdate.add(cs);
                            system.debug('UserRec2=='+UserRec.id);
                            lsttask.add(CreateTask('C25 second visit Fail',UserRec.id,cs.id,3));
                        }
                        else if(ac.SS_First_Violation_Date__c != null && ac.SS_Second_Violation_Date__c != null && ac.SS_Third_Violation_Date__c == null)
                        {
                            system.debug('pass from here3==');
                            //cs.Regulatory_Action__c ='Third Visit Fail';//JTP-112
                            ac.SS_Third_Violation_Date__c    = cs.Secret_Shop_Date__c;
                            ac.Status__c = 'Suspended';
                            cs.Next_Secret_Shop_Date__c =(cs.Secret_Shop_Date__c != null?cs.Secret_Shop_Date__c.adddays(40):system.today().adddays(40));
                            
                            if(setAccid.contains(ac.id) ==false)
                            {
                                lstAcToUpdate.add(ac);
                                setAccid.add(ac.id);
                            }
                            lstcaseToUpdate.add(cs);
                            system.debug('UserRec3=='+UserRec.id);
                            lsttask.add(CreateTask('C25 Visit Fail',UserRec.id,cs.id,90));
                        }
                    }
                    else if(cs.Secret_Shop_Status__c == 'Pass')
                    {
                        cs.Next_Secret_Shop_Date__c =(cs.Secret_Shop_Date__c != null?cs.Secret_Shop_Date__c.adddays(40):system.today().adddays(40));
                        lstcaseToUpdate.add(cs);
                        
                        ac.SS_First_Violation_Date__c    = null;
                        ac.SS_Second_Violation_Date__c    = null;
                        ac.SS_Third_Violation_Date__c    = null;
                        ac.status__c = 'Suspended';
                        if(setAccid.contains(ac.id) ==false)
                        {
                            lstAcToUpdate.add(ac);
                            setAccid.add(ac.id);
                        }
                        
                    }
                    
                }
                    
                
            }
            
            system.debug('lstcaseToUpdate=='+lstcaseToUpdate);
            if(lstcaseToUpdate != null && lstcaseToUpdate.size()>0){
             //   update lstcaseToUpdate;
             createBatchLog(Database.Update(lstcaseToUpdate, false), 'Case');
            }    
            
            system.debug('lstAcToUpdate=='+lstAcToUpdate);
            if(lstAcToUpdate != null && lstAcToUpdate.size()>0){
               // update lstAcToUpdate;
                createBatchLog(Database.Update(lstAcToUpdate, false), 'Account');
            }
            
            
            system.debug('lsttask=='+lsttask);
            if(lsttask != null && lsttask.size()>0){
              //  insert lsttask;
              createBatchLog(Database.Insert(lsttask , false), 'Task');
           } 
            
        }
        
    }        

    /*****************************************************************************/
    /* Method Name:    executeOrderUpdate                                       /*
    /* Description:    method to run the Batch process from Page                 /*
    /*****************************************************************************/
    public task CreateTask(string strSubject,id parentId,id whatid,integer dueDay) {
        Task objTask = new Task();
        objTask.Subject = strSubject;
        objTask.whatId = whatId;
        objTask.Transcript_Link__c = whatId;
        objTask.Priority = 'Normal';
        objTask.Status = 'New';
        objTask.ownerId = parentId;
        objTask.Description = strSubject;
        objTask.ActivityDate = System.today().adddays(dueDay);
        return objTask;
        //Database.DMLOptions notifyOption = new Database.DMLOptions();
        //Database.insert(new task[]{objTask}, notifyOption);
    }
    
    /*****************************************************************************/
    /* Method Name:    finish                                                    /*
    /* Description:    finish method of Batchable Interface                      /*
    /*****************************************************************************/
    global void finish(Database.BatchableContext BC) {
        settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');
        String adminEmails = settingsConst.X3_Strike_Admin_EmailIds__c;
        if(!String.isEmpty(adminEmails)){
            try{
                String[] toAddresses= adminEmails.split(','); 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                  TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job JuulSalesOpsUKBatchCaseUpdate ' + a.Status);
                mail.setPlainTextBody('The batch Apex job JuulSalesOpsUKBatchCaseUpdate  processed ' + a.TotalJobItems +
                                      ' batches with '+ a.NumberOfErrors + ' failures.' + 
                                      '\n Input Paramterers provided for batch job: ' );
                                      
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        }       
               
    }
     public void createBatchLog(List<Database.SaveResult> updateResults, String ObjectType) {
        List<Database.Error> listError = new List<Database.Error>();
        for(Integer index = 0, size = updateResults.size(); index < size; index++) {
            if(!updateResults[index].isSuccess()){                
                listError.addAll(updateResults[index].getErrors());
            }
        }
        if(ObjectType == 'Case'){
             LogEventTriggerHandler.insertBatchLog(listError, 'JuulSalesOpsUKBatchCaseUpdate', 'execute', 'Case', 'Database.Update_Failed');
        }
        if(ObjectType == 'Account'){
            LogEventTriggerHandler.insertBatchLog(listError, 'JuulSalesOpsUKBatchCaseUpdate', 'execute', 'Account', 'Database.Update_Failed');
        }
        
        if(ObjectType == 'Task'){
            LogEventTriggerHandler.insertBatchLog(listError, 'JuulSalesOpsUKBatchCaseUpdate', 'execute', 'Task', 'Database.Insert_Failed');
        }

     }
}