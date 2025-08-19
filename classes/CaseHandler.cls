/*******************************************************************************************
* @Name         CaseHandler
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         01/16/2019
* @Group        Customer Service
* @Description  Handler for Case Trigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil              01/16/2019          Initial Creation
*   1.1              Jyoti Choudhary    08/16/2021          UUP Case Enhancement
*******************************************************************************************/
public with sharing class CaseHandler {

    public static Boolean isSkipPrintmailCreation = false;
    /**************************************************************************************
    * @Description This method is the entry point of all records from the trigger
    * @Param   trigger.new, trigger.old,trigger.newmap,trigger.oldmap, trigger context
    * @Return  --none--
    **************************************************************************************/
    public static void handleTrigger(List<Case> newCaseList, List<Case> oldCaseList, Map<Id, Case> newCaseMap,
            Map<Id, Case> oldCaseMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                //populate contact if person account is linked to the case
                PersonAccountService.attachContactWithCase(newCaseList);
                //added by JC for SFDC - 0000004902
                UUPCaseEnhancement.UUPCaseEnhancementMethod(newCaseList);
               //map file name to the case 
                ContentDocumentLinkUpdateOnCase.ContentDocumentLinkUpdateOnCases(newCaseList);
                
                
                BusinessAccountService.updateCaseStatus(newCaseList);
                BusinessAccountService.updateAccountStatus(newCaseList, oldCaseMap);
            
            
            }
            
             when BEFORE_UPDATE {
               
               //map file name to the case 
                ContentDocumentLinkUpdateOnCase.ContentDocumentLinkUpdateOnCases(newCaseList);
            
            }
            
            
            when AFTER_INSERT {
                //create/update person account
                PersonAccountService.attachPersonAccountWithCase(newCaseList);
                //assign case owner
                CaseRoutingService.routeCaseViaOwnerName(newCaseList);
                
            }

            when AFTER_UPDATE {
                if(!isSkipPrintmailCreation){
                    isSkipPrintmailCreation = true;
                    //added by JC for SFDC - 0000004902
                    UUPCaseEnhancement.UUPCaseEnhancementMethod(newCaseList);
                }
                BusinessAccountService.updateAccountStatus(newCaseList, oldCaseMap);
                
            }
        }
    }
}