/****************************************************************************************/
/* VERSION         AUTHOR         DATE                                                  */
/*     1.0         Naveen         10-17-2019                                            */
/* Class Name:     JuulSalesOrderEmailToContact                                          */
/* Description:    Batch                                                                */
/****************************************************************************************/
global class JuulSalesOrderNSLEmailToDistiContact implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    /*****************************************************************************/
    /* Method Name:    execute                                                   /*
    /* Description:    execute method of Schedulable Interface                   /*
    /*****************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this);
    }
       
    /*****************************************************************************/
    /* Method Name:    start                                                     /*
    /* Description:    start method of Batchable Interface                       /*
    /*                 Forms SOQL Query for Batch processing                      /*
    /*****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // Custom Setting 
        NSLOrderCutoffDate__c NSLEmailDate = NSLOrderCutoffDate__c.getValues('NSLEmailDate');
        if(NSLEmailDate != null){
            Date TodayDate = NSLEmailDate.CurrentDate__c;
            String fromEmailAddress = NSLEmailDate.Address__c;
        }
        
       
        
        String query = 'Select Id,Customer__c,Distributor__c,Order_Date__c,Customer__r.NSL_Effective_Date__c';
        query+= ' FROM salesOrder__c ';
        query+= 'Where Customer__r.NSL_Effective_Date__c  != null ';
        query+= 'and Order_Date__c != null AND Distributor__c != null'; 
        query+= ' and (Customer__r.Status__c = \'Blacklisted\' OR Customer__r.Status__c = \'Suspended\') and NSL_Email_Sent__c = False AND orderType__c IN  (\'BO\', \'MSA\') AND CreatedDate >= :TodayDate';             
     //   query += ' AND ';
     //   query += 'id=\'a1U2f000000dZvA\'';
        system.debug('Query####: ' + Query);
        return Database.getQueryLocator(query);        
    }
        
     /**********************************************************************************/
    /* Method Name:    execute                                                        /*
    /* Description:    execute method of Batchable Interface,                         /*
    /*                                                                                /*
    /**********************************************************************************/
    global void execute(Database.BatchableContext BC, List<salesOrder__c> salesOrderList){
        NSLOrderCutoffDate__c NSLEmailDate = NSLOrderCutoffDate__c.getValues('NSLOrderCutoffDate');
       System.debug('NSLOrderCutoffDate######### '+NSLEmailDate);
       String fromEmailAddress;
       if(NSLEmailDate != null){
            fromEmailAddress = NSLEmailDate.Address__c;
        }
        System.debug('fromEmailAddress ######### '+fromEmailAddress);
        System.debug('NSLEmailDate ######### '+NSLEmailDate);
        
        Set<ID> distributorIDSet = new Set<ID>();
        List<salesOrder__c> updatesalesOrderList = new List<salesOrder__c>();
        map<Id,Id> mapOfSalesordIdandAccountID = new map<Id,Id>();
        for(salesOrder__c salesOrder : salesOrderList){
            if(salesOrder.Order_Date__c > salesOrder.Customer__r.NSL_Effective_Date__c){
                distributorIDSet.add(salesOrder.Distributor__c);
                
                mapOfSalesordIdandAccountID.put(salesOrder.Id,salesOrder.Distributor__c);
            }           
        }
        
        //system.debug('@@distributorIDSet'+distributorIDSet);
        
        if(distributorIDSet.size()>0){          
            Map<ID, Account> accountMap = new Map<ID, Account>([Select Id,Owner.email,Owner.Manager.Email,Ultimate_Parent_Account_Owner__r.Email,
                                           (Select Id  
                                            From Contacts
                                            Where Communication_Type__c INCLUDES('Distributor No Sale List') AND Email != NULL limit 1) 
                                         FROM Account where ID IN : mapOfSalesordIdandAccountID.values()]);
                                        
                                         
            //system.debug('@@contactList '+contactList );
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Id templateId = [SELECT Id, Name, DeveloperName 
                             FROM EmailTemplate 
                             WHERE DeveloperName = 'Email_to_Contact_on_the_Distributor_Account' limit 1].ID;
                             
            for(Id salesorderId  : mapOfSalesordIdandAccountID.keySet()){
                Id AccountId = mapOfSalesordIdandAccountID.get(salesorderId);
                if(accountMap.containsKey(AccountId)){
                    Account acc = accountMap.get(AccountId);
                    if(acc.Contacts != null && acc.Contacts.size()>0){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] ccAddresses;
                        if(acc.Owner.Manager.Email <> NULL && acc.Ultimate_Parent_Account_Owner__r.Email <> NULL){
                            ccAddresses = new String[] {acc.Owner.Email,acc.Owner.Manager.Email,acc.Ultimate_Parent_Account_Owner__r.Email};
                         }else if(acc.Owner.Manager.Email <> NULL && acc.Ultimate_Parent_Account_Owner__r.Email == NULL){
                           ccAddresses = new String[] {acc.Owner.Email,acc.Owner.Manager.Email};         
                         }else{
                             ccAddresses = new String[] {acc.Owner.Email};
                         }
                        mail.setTemplateId(templateId);
                        mail.setTargetObjectId(acc.Contacts[0].Id);
                        mail.setccAddresses(ccAddresses);
                        //mail.setSaveAsActivity(true);
                        mail.setWhatId(salesorderId);
                        OrgWideEmailAddress OD = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress LIMIT 1];
                        mail.setOrgWideEmailAddressId(OD.Id);
                        mail.setReplyTo('no-reply@juul.com');
                        allmsg.add(mail); 
                        updatesalesOrderList.add(new salesOrder__c(Id=salesorderId,NSL_Email_Sent__c = true));
                    }
                }
            }
           
            system.debug('@@allmsg'+allmsg);
            Messaging.sendEmail(allmsg);
            if(updatesalesOrderList.size()>0){
                List<Database.SaveResult> updateResults = Database.Update(updatesalesOrderList, false);
                List<Database.Error> listError = new List<Database.Error>();
                for(Integer index = 0, size = updateResults.size(); index < size; index++) {
                    if(!updateResults[index].isSuccess()){                
                        listError.addAll(updateResults[index].getErrors());
                    }
                }
                LogEventTriggerHandler.insertBatchLog(listError, 'JuulSalesOrderNSLEmailToDistiContact', 'execute', 'Asset_Request_Iteam__c', 'Database.Insert_Failed');
            }
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
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                  TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch apex Job JuulSalesOrderEmailToContact ' + a.Status);
                mail.setPlainTextBody('The batch Apex job JuulSalesOrderEmailToContact processed ' + a.TotalJobItems +
                                      ' batches with '+ a.NumberOfErrors + ' failures.' + 
                                      '\n Input Paramterers provided for batch job: ' );                                      
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                system.debug('Error :'+e.getMessage());
            }  
        }         
    }
}