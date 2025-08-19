/*******************************************************************************************
* @Name         InvocableHECaseCreate
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         10/21/2019
* @Group        CS
* @Description  This will create the Health Experience Case from XDSR.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          10/21/2019            Initial Creation
*******************************************************************************************/
global without sharing class InvocableHECaseCreate {
    // Declare variables to be used with Flow and invocable method
    global class variables{

        @InvocableVariable(label='Account Id' required='false')
        global String varAccountId;
        
        @InvocableVariable(label='Description' required='false')
        global String varTextBody;
        
        @InvocableVariable(label='Health Mention' required='false')
        global Boolean varHealthMention;
        
        @InvocableVariable(label='Device Firmware Version' required='false')
        global String varDeviceFirmwareVersion;

        @InvocableVariable(label='Language Preference' required='false')
        global String varLanguagePreference;
        
        @InvocableVariable(label='Market' required='false')
        global String varMarket;
        
        @InvocableVariable(label='Mobile Device Model' required='false')
        global String varMobileDeviceModel;
        
        @InvocableVariable(label='Mobile Device OSVersion' required='false')
        global String varMobileDeviceOSVersion;

        @InvocableVariable(label='Case Origin' required='false')
        global String varOrigin;

        @InvocableVariable(label='Case Owner Id' required='false')
        global String CaseOwnerId;

        @InvocableVariable(label='Record Id' required='false')
        global String recordId;
        
 }   
   @InvocableMethod(label='Create HE Case')
    global static void createHealthExperienceCase(List<variables> passedData){
        List<Case> listCaseToInsert = new List<Case>();
        for(Variables vRec : passedData){
            Case caRecToInsert = new Case();
                caRecToInsert.AccountId = vRec.varAccountId <> NULL ? vRec.varAccountId : null;
                caRecToInsert.Created_from_XDSR__c = true;
                caRecToInsert.Description = vRec.varTextBody;
                caRecToInsert.Health_Mention__c = vRec.varHealthMention;
                caRecToInsert.JUUL_Device_Firmware_Version__c = vRec.varDeviceFirmwareVersion;
                caRecToInsert.Language_Preference__c = vRec.varLanguagePreference;
                caRecToInsert.Market__c = vRec.varMarket;
                caRecToInsert.Mobile_Device_Model__c = vRec.varMobileDeviceModel;
                caRecToInsert.Mobile_Device_OS_Version__c = vRec.varMobileDeviceOSVersion;
                caRecToInsert.Origin = vRec.varOrigin;
                caRecToInsert.OwnerId = vRec.CaseOwnerId;
                caRecToInsert.XDSR__c = vRec.recordId;
                caRecToInsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Health Experience').getRecordTypeId(); 
                listCaseToInsert.add(caRecToInsert);
        }
        if(listCaseToInsert != null && listCaseToInsert.size()>0){
            List<Database.SaveResult> insertCaseResults = Database.Insert(listCaseToInsert, false);
            List<Database.Error> listError = new List<Database.Error>();
            for(Integer index = 0, size = insertCaseResults.size(); index < size; index++){
                if(!insertCaseResults[index].isSuccess()){
                    listError.addAll(insertCaseResults[index].getErrors());
                }
            } 
            LogEventTriggerHandler.insertBatchLog(listError, 'InvocableHECaseCreate', 'createHealthExperienceCase', 'Case', 'Database.Insert_Failed');
        }
    }
}