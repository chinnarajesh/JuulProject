/*******************************************************************************************
* @Name         ESignatureCheckHandler
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         01/02/2019
* @Group        Customer Service
* @Description  Handler to check if Esignature is valid on a record
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/28/2018          Initial Creation
*******************************************************************************************/
public with sharing class ESignatureCheckHandler {
    /**************************************************************************************
    * @Description This method checks for eSignature on Case Health Experience Records
    * @Param   List<Case>
    * @Return  --none--
    **************************************************************************************/
    public static void checkSigCaseHealthExp(List<Case> healthExpRecs) {
        try {
            //first check if the record type is health experience, otherwise exit
            Id healthExpRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience');
            List<Case> caseListHealthExp = new List<Case>();
            for (Case c : healthExpRecs) {
                if (healthExpRecTypeId !=null && c.RecordTypeId == healthExpRecTypeId) caseListHealthExp.add(c);
            }
            //get parent case IDs & XDSR record ID
            //process further if there are any health experience cases
            if (!caseListHealthExp.isEmpty()) {
                Set<Id> parentCaseIds = new Set<Id>();
                Set<Id> xdsrRecIds = new Set<Id>();
                for (Case c : caseListHealthExp) {
                    parentCaseIds.add(c.ParentId);
                    xdsrRecIds.add(c.XDSR__c);
                }
                //Query Esignature Object
                List<eSignature__c> esigList = [
                        SELECT Id
                        FROM eSignature__c
                        WHERE (Case__c != NULL AND Case__c = :parentCaseIds AND OwnerId = :UserInfo.getUserId())
                        OR (XDSR__c != NULL AND XDSR__c = :xdsrRecIds AND OwnerId = :UserInfo.getUserId())
                ];
                System.debug('esigList--> ' + esigList);
                if (esigList.isEmpty()) {
                    for (Case c : caseListHealthExp) {
                      //  c.addError('Cannot create health experience because signature is not found. Please esign and try again.');
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}