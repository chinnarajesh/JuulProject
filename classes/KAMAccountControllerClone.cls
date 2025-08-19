public with sharing class KAMAccountControllerClone {
    @AuraEnabled
    public static List <Account> getAccountRecords(Id recId) {
        CommercialActivity__c selectedCAQueried = [Select Id,Country__c from CommercialActivity__c where Id =:recId];
        return [Select Id, Name, Website, Type, BillingCountry from Account where Type = 'HQ' and ShippingCountry=:selectedCAQueried.Country__c
                ORDER BY Name
               ];
    }
    
    //Wrapper Class to return the success & error messages
    public class ReturnResponseWrapper{
        @AuraEnabled
        public String responseType{get;set;}
        @AuraEnabled
        public String responseMessage{get;set;}
        @AuraEnabled
        public Id aptRecordId{get;set;}
    }
    
    
    //Method to Clone ActionPlanTemplate record with ActionPlanTemplateItems
    @AuraEnabled
    public static ReturnResponseWrapper cloneRecords(Id recId, List < Id > accId) {
        
        String returnResponse = '';
        ReturnResponseWrapper returnResponseWrapper=new ReturnResponseWrapper();
        List < ActionPlanTemplate__c > actionTemplateInsert = new List < ActionPlanTemplate__c > ();
        Map < String, Schema.RecordTypeInfo > recordTypesAPT = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByDeveloperName();
        Set < String > fieldMap = Schema.SObjectType.CommercialActivity__c.fields.getMap().keySet();
        List < String > finalFields = new List < String > ();
        String objectAPIName = 'CommercialActivity__c';
        finalFields.addAll(fieldMap);
        
        Id newOwnerId = UserInfo.getUserId();
        
        //Query to retrieve APT record
        String query =
            'SELECT ' + String.join(finalFields, ',') +
            ' FROM ' + objectAPIName +
            ' WHERE Id = \'' + recId + '\'';
        try{
            List < CommercialActivity__c > actTempCurrentRecord = Database.query(query);
            system.debug('test' + actTempCurrentRecord);
            
            List<Account> accList = new List<Account>([Select Id,Name From Account Where Id IN: accId]);
            for (Account acc: accList) {
                CommercialActivity__c ca = actTempCurrentRecord[0];
                ActionPlanTemplate__c aptCopy = new ActionPlanTemplate__c();
                String APTName =ca.Name+' - '+ acc.Name;
                system.debug('ca name'+ca.Name+' APTName '+APTName);
                //Trim the Name if the length exceeds 73 characters
                if(APTName.length()>74){
                APTName = APTName.substring(0,74);
                }
                system.debug('apt Name '+APTName);
                aptCopy.RecordTypeId = recordTypesAPT.get('PromotionalActivityProcess').getRecordTypeId();
                                aptCopy.Name =  APTName ;
                                aptCopy.CommercialActivityId__c = recId;
                                aptCopy.AccountId__c = acc.Id;
                                aptCopy.Status__c = 'Planning';
                                aptCopy.OwnerId = newOwnerId;
                                aptCopy.Country__c = ca.Country__c;
                                aptCopy.RebateWithNoJLPContract__c = ca.Rebate_with_no_JLP_contract__c;
                                aptCopy.AllowedChainLimit__c = ca.Allowed_Chain_Range_Weeks__c;
                                aptCopy.StrategyStartDate__c =  ca.Strategy_Start_Date__c;
                                aptCopy.StrategyEndDate__c = ca.Strategy_End_Date__c;
                                // aptCopy.RequestedEndDate__c = system.today().addDays(2);
                                // aptCopy.RequestedStartDate__c = system.today();
            //     if (apt.RecordTypeId == recordTypesAPT.get('Strategy').getRecordTypeId()) {
            //         if (apt.Status__c == 'Published') {
            //             if (apt.ActionPlanType__c == 'Promotional Activity Process') {
            //                 aptCopy = apt.clone(false, true);
            //                 aptCopy.RecordTypeId = recordTypesAPT.get('PromotionalActivityProcess').getRecordTypeId();
            //                 aptCopy.Name =  APTName + ' Clone';
            //                 aptCopy.ActionPlanTemplateId__c = recId;
            //                 aptCopy.AccountId__c = accountId;
            //                 aptCopy.Status__c = 'Planning';
            //                 aptCopy.OwnerId = newOwnerId;
            //                 //Added for ticket SFDC - 0000003395
            //                 aptCopy.CascadeFlag__c = False; //sr01
            //                 aptCopy.ISL_Batch_Flag__c = False; //sr02
            //                 aptCopy.Cascade_Changes__c = False; //sr03
            //                 aptCopy.Batch_Details__c = '';
            //                 aptCopy.Override__c = false; //sr05
            //             } else if (apt.ActionPlanType__c == 'Account Plan') {
            //                 aptCopy = apt.clone(false, true); 
            //                 aptCopy.RecordTypeId = recordTypesAPT.get('AccountPlan').getRecordTypeId();
            //                 aptCopy.Name = APTName + ' Clone';
            //                 aptCopy.AccountId__c = accountId;
            //                 aptCopy.ActionPlanTemplateId__c = recId;
            //                 aptCopy.Status__c = 'Planning';
            //                 aptCopy.OwnerId = newOwnerId;
            //                 //Added for ticket SFDC - 0000003395
            //                 aptCopy.CascadeFlag__c = False;  //sr01
            //                 aptCopy.ISL_Batch_Flag__c = False; //sr02
            //                 aptCopy.Cascade_Changes__c = False; //sr03
            //                 aptCopy.Batch_Details__c = ''; //sr04
            //                 aptCopy.Override__c = false; //sr05
            //             } else if (apt.ActionPlanType__c == 'Reset Activity Process') {
            //                 aptCopy = apt.clone(false, true);
            //                 aptCopy.RecordTypeId = recordTypesAPT.get('ResetActivityProcess').getRecordTypeId();
            //                 aptCopy.Name = APTName + ' Clone';
            //                 aptCopy.AccountId__c = accountId;
            //                 aptCopy.ActionPlanTemplateId__c = recId;
            //                 aptCopy.Status__c = 'Reset Initiated';
            //                 aptCopy.OwnerId = newOwnerId;
            //                 //Added for ticket SFDC - 0000003395
            //                 aptCopy.CascadeFlag__c = False; //sr01
            //                 aptCopy.ISL_Batch_Flag__c = False; //sr02
            //                 aptCopy.Cascade_Changes__c = False; //sr03
            //                 aptCopy.Batch_Details__c = '';//sr04
            //                 aptCopy.Override__c = false; //sr05
            //             } else {
            //                 returnResponseWrapper.responseType='Error';
            //                 returnResponseWrapper.responseMessage= 'Action Plan Template of Action Plan Type' + apt.ActionPlanType__c + ' can not be cloned';
            //                 return returnResponseWrapper;
            //             }
                        
            //         } else {
            //             returnResponseWrapper.responseType='Error';
            //             returnResponseWrapper.responseMessage='Only Action Plan Templates which are published can be cloned';
            //             return returnResponseWrapper;
            //         }
            //     } else {
            //         aptCopy = apt.clone(false, true);
            //         aptCopy.Name = APTName + ' Clone';
            //         aptCopy.AccountId__c = accountId;
            //         aptCopy.OwnerId = newOwnerId;
            //         //Added for ticket SFDC - 0000003395
            //         aptCopy.CascadeFlag__c = False;  //sr01
            //         aptCopy.ISL_Batch_Flag__c = False; //sr02
            //         aptCopy.Cascade_Changes__c = False; //sr03
            //         aptCopy.Batch_Details__c = ''; //sr04
            //         aptCopy.Override__c = false; //sr05
            //     }
                actionTemplateInsert.add(aptCopy);
            }
            system.debug('@@aptCopy: '+actionTemplateInsert);
            system.debug('@@Size: ' + actionTemplateInsert.size());
            
            // //New Created records id
            Set < Id > newaptRecordId = new Set < Id > ();
            
            //Insert Cloned APT
            if (actionTemplateInsert.size() > 0) {
                List < Database.Error > listError = new List < Database.Error > ();
                List < Database.SaveResult > savedResultsAPT = Database.insert(actionTemplateInsert, false);
                Boolean someFailure = false;
                for (Database.SaveResult sr: savedResultsAPT) {
                    system.debug('sr '+sr);
                    if (!sr.isSuccess()) {
                        
                        someFailure = true;
                        for (Database.Error dberror: sr.getErrors()) {
                            system.debug('dberror'+dberror.getMessage());
                            returnResponseWrapper.responseType='Error';
                            returnResponseWrapper.responseMessage=+dberror.getMessage();
                            listError.add(dberror);
                        }
                    } 
                    
                    if (!someFailure) {
                        //Calling method to clone ActionPlanTemplateItems and assigning them to cloned APT
                        returnResponseWrapper.responseType='Success';
                        returnResponseWrapper.aptRecordId = sr.id;
                        returnResponseWrapper.responseMessage='Template Items have been cloned successfully';
                        returnResponse = cloneAPTItems(sr.id, recId);
                        
                    }	
                    
                }
                //Insert exceptions in Log__c object, If any
                if(listError.size()>0){
                    LogEventTriggerHandler.insertBatchLog(listError, 'KAMAccountControllerClone', 'cloneRecords', objectAPIName, 'Database.Insert_Failed');
                }
                
            }
            system.debug('@@Return Response : '+returnResponseWrapper);
            return returnResponseWrapper;
            
        }
        
        catch(Exception ex) {
            system.debug('Print Exception' + ex);
            returnResponse = ex.getMessage();
            returnResponseWrapper.responseType='Error';
            returnResponseWrapper.responseMessage=ex.getMessage();
            return returnResponseWrapper;
        }
        
    }
    
    //Method to clone ActionPlanTemplate Items and relate them to new cloned APT record
    public static string cloneAPTItems(id clonedAPT, Id oldAPT){
        String response='';
        List<ActionPlanTemplateItem__c> aptItemsCloned = new List<ActionPlanTemplateItem__c>();
        String objectAPIName = 'ActionPlanTemplateItem__c';
        Set <String> aptFieldMap = Schema.SObjectType.ActionPlanTemplateItem__c.fields.getMap().keySet();
        List<String> aptItemFields = new List<String>() ;
        aptItemFields.addAll(aptFieldMap);
        //Query to Retrieve related APTItems
        String query =
            'SELECT ' + String.join(aptItemFields, ',')+
            ' FROM ' + objectAPIName +
            ' WHERE ActionPlanTemplateId__c = \''+oldAPT+'\'';
        try{
            List<ActionPlanTemplateItem__c> aptItems = Database.query(query);
            system.debug('@@APTItems Count : ' + aptItems.size());
            if( aptItems != null && aptItems.size()>0){
                for(ActionPlanTemplateItem__c aptItem : aptItems){
                    //Clone APTItems record and link to the cloned APT record
                    ActionPlanTemplateItem__c aptItemCopy = aptItem.clone(false,true);
                    aptItemCopy.ActionPlanTemplateId__c = clonedAPT;
                    aptItemsCloned.add(aptItemCopy);
                }
                List<Database.SaveResult> savedResultsAPTItems = Database.insert(aptItemsCloned, true);
                List<Database.Error> listError = new  List<Database.Error>();
                for(Database.SaveResult currentAPTItem: savedResultsAPTItems){
                    if(!currentAPTItem.isSuccess()){
                        for (Database.Error err: currentAPTItem.getErrors()) {
                            listError.add(err);
                            response = err.getMessage();
                        }
                    }
                }
                //Insert exceptions in Log__c object, If any
                if(listError.size()>0)
                { 
                    LogEventTriggerHandler.insertBatchLog(listError, 'KAMAccountControllerClone', 'cloneAPTItems', objectAPIName, 'Database.Insert_Failed');
                }else
                {
                    response ='ActionPlanTemplateItemsCLoned';
                }
                
                
                
                
            }
            else{
                response = 'No Action Plan Template Items Present for the Action Plan Template';
            }
        }
        catch(Exception ex){
            system.debug('Print Exception' + ex);
            response = ex.getMessage();
        }
        return response;
        
    }
}