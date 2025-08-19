/*******************************************************************************************
* @Name         InvocableHECaseCreateTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         10/21/2019
* @Group        CS
* @Description  Test class for apex class InvocableHECaseCreate
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Anil          10/21/2019            Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class InvocableHECaseCreateTest {
    static testMethod void createCase() {
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController1);
        
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
        insert(triggerController2);
        
        List<Account> accList = new List<Account>();
        Account accRec = new Account();
        accRec.Name='Test';
        accRec.Type='HQ';
        accRec.ShippingState ='HI';
        accRec.BillingCountry ='USA';
        accRec.ComplianceMechanism__c='Menthol Ban';
        accList.add(accRec);
        insert accList;
        
        XDSR__c xdsrRec = new XDSR__c(External_ID__c = 'Test1234hgdhjgdhg63636',
                                      Language_Preference__c = 'English',
                                      Market__c = 'United States',
                                      Mobile_Device_Model__c = 'Test',
                                      Mobile_Device_OS_Version__c = 'Test Version',
                                      JUUL_Device_Firmware_Version__c = 'Test firm Version',
                                      Text_Body__c = 'Test Text Body',
                                      Health_Mention__c =true,
                                      Account__c = accRec.id
                                      );
        insert xdsrRec;
        String recordId = String.valueOf(xdsrRec.Id);
        InvocableHECaseCreate.variables variables =  new InvocableHECaseCreate.variables();
        variables.recordId = recordId;
        InvocableHECaseCreate.createHealthExperienceCase(new List<InvocableHECaseCreate.variables> {variables});
    }
}