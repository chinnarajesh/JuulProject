public without sharing class CCPACommunityController {
    
    /*******************************************************************************************
* @Name         CCPACommunityController
* @Author       Mohit Singh <Mohit.Singh@juul.com>
* @Date         04/21/2020
* @Group        Service Ops
* @Description  This Class contains methods for US Community Lightning components
* @Test Class   CCPACommunityControllerTest
*******************************************************************************************/
    
    Public Juul_CCPAComSetting__c CCPASetting{get;set;}
    Public String EndPoint{get;set;}
    Public CCPACommunityController(){
        CCPASetting = Juul_CCPAComSetting__c.getOrgDefaults();
        EndPoint = URL.getSalesforceBaseUrl().toExternalForm();
    }
    @auraEnabled
    public static String getEndpointData(){
        String EndPoint = URL.getSalesforceBaseUrl().toExternalForm();
        return EndPoint;
    }
    
    @auraEnabled
    public static case createCaseForDataAccess(case caseParam, String caseType){
        Case cas = createCase (caseParam,caseType);
        system.debug(cas);
        Case caseRec = getCaseDetail(cas.Id);
        return caseRec;
    }
    
    public static Case getCaseDetail (Id caseId){
        Map<String, Schema.SObjectField> fieldMap = Case.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNames = fieldMap.keySet();
        List<Case> caseDetail = Database.query('select ' + string.join((Iterable<String>)fieldNames, ',') + ' from Case where Id = \'' + caseId + '\'');
        return caseDetail[0];
    }
    
    public static Case createCase (Case caseParam, String caseType){
        //caseParam.AccountId = acc.Id;
        caseParam.Origin = 'CCPA';
        caseParam.Topic__c = 'Data Privacy';
        caseParam.Do_Not_Assign__c = false;
        caseParam.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General Inquiry').getRecordTypeId();
        caseParam.Issue__c = caseType;
        caseParam.Web_Form__c = 'Community';
        caseParam.DO_NOT_NOTIFY__c = true;
        Insert caseParam;
        return caseParam;
    }
}