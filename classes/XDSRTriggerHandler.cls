/*******************************************************************************************
* @Name         XDSRTriggerHandler
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         08/01/2019
* @Group        Sales Ops
* @Description  This Handler created for the trigger XDSRTrigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          08/01/2019            Initial Creation
*******************************************************************************************/
public with sharing class XDSRTriggerHandler {
   /*
   Added by Anil.   
   JIRA Ticket Reference: https://juullabs.atlassian.net/browse/CS-1586
   Description: This method will be used to assign the XDSR records based on country and language from the Custom Metadata Types. 
   */
   public static void XDSRAssignmentOnInsert(List<XDSR__c> newTriggerList, Map<Id,XDSR__c> oldMapTrigger, System.TriggerOperation triggerEvent){
       switch on triggerEvent {
           when BEFORE_INSERT {
               List<String> XDSRQueueNamesList = new List<String>();
               Map<String,String>  countryToQueueMap = new Map<String,String>();
               Map<String, Id> queueNameToQueueIdMap = new Map<String, Id>();
               List<CS_Country_Config__mdt> listCSCountry = [SELECT  Label,DeveloperName,XDSR_Assignment_Queue_Name__c,Market__c, Language__c FROM CS_Country_Config__mdt];
               for(CS_Country_Config__mdt mdt : listCSCountry){
                   if(mdt.Market__c <> NULL && mdt.Language__c <> NULL){
                       countryToQueueMap.put(mdt.Market__c+' '+mdt.Language__c, mdt.XDSR_Assignment_Queue_Name__c);
                    }
                    if(mdt.XDSR_Assignment_Queue_Name__c <> NULL){
                        XDSRQueueNamesList.add(mdt.XDSR_Assignment_Queue_Name__c);
                    }
                }
                if(XDSRQueueNamesList != null && XDSRQueueNamesList.size()>0){
                    List<Group> emailQueueIdList = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN : XDSRQueueNamesList AND Type = 'Queue']; 
                    for(Group g : emailQueueIdList){
                        queueNameToQueueIdMap.put(g.DeveloperName,g.id);
                    }
                }
                Group defaultQueue = [SELECT Id,Name FROM Group WHERE DeveloperName = 'US_XDSR_Needs_Review_English' AND Type = 'Queue' LIMIT 1];
                for(XDSR__c xdsrRec : newTriggerList){
                    if(countryToQueueMap != null && countryToQueueMap.containsKey(xdsrRec.Market__c+' '+xdsrRec.Language_Preference__c)){
                        if(queueNameToQueueIdMap != null && queueNameToQueueIdMap.size()>0){
                            xdsrRec.OwnerId = queueNameToQueueIdMap.get(countryToQueueMap.get(xdsrRec.Market__c+' '+xdsrRec.Language_Preference__c)) <> null ?queueNameToQueueIdMap.get(countryToQueueMap.get(xdsrRec.Market__c+' '+xdsrRec.Language_Preference__c)) : defaultQueue.id;
                        }else{
                            xdsrRec.OwnerId = defaultQueue.id;
                        }
                     }else{
                         xdsrRec.OwnerId = defaultQueue.id;
                    }
                }
            }
        }    
    }
}