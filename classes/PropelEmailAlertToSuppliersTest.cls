@isTest
public with sharing class PropelEmailAlertToSuppliersTest {
    //Get picklist values
    public static List<String> getPicklistValues(SObjectField field) {
        Schema.DescribeFieldResult fieldMetadata = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldMetadata.getPicklistValues();
    
        List<String> picklistValues = new List<String>();
        for(Schema.PicklistEntry picklistEntry : picklistEntries) {
        picklistValues.add(picklistEntry.getValue());
        }
        return picklistValues;
    }
    
    @isTest public static void PropelEmailAlertToSuppliersTest() {
        User PropelUser = [Select Id, Name from User where firstname = 'Propel' limit 1];
        
        Schema.SObjectField accessibleByField = PDLM__Change__c.Accessible_By__c;
        List<String> accessibleByGroups = getPicklistvalues(accessibleByField);

        //Create Change Order
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'ECO');
        insert lifecycle;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__order__c = 1, PDLM__No_Approval__c = true, 
        PDLM__lifecycle__c = lifecycle.id);
        insert pendingPhase;

        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='CCB', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
        PDLM__lifecycle__c = lifecycle.id);
        insert CCBPhase;

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', 
        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(name='ECO', PDLM__autonumber__c = autonumberChange.id, 
        PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

        PDLM__Change__c change = new PDLM__Change__c(PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test ECO', 
        PDLM__primary_Key__c = 'ECO1', Accessible_By__c = accessibleByGroups[0]);
        insert change;

        change = [select id, Name, Accessible_By__c, PDLM__Status_lk__c from PDLM__Change__c where id =: change.id];

        //Invoke the method
        PropelEmailAlertToSuppliers.GetRequestsfromPB notificationGroup = new PropelEmailAlertToSuppliers.GetRequestsfromPB();
        notificationGroup.changeID = change.Id;
        notificationGroup.accessibleBy = change.Accessible_By__c;
        notificationGroup.emailTemplate = 'Change_Shared_with_Accessible_By_Group_s';
        PropelEmailAlertToSuppliers.PropelEmailAlertToSuppliers(new List<PropelEmailAlertToSuppliers.GetRequestsfromPB> {notificationGroup});

        //Did I send that email?
        System.assert(PropelEmailAlertToSuppliers.num_of_emails_sent >= 1, 'Expected at least 1');      
    }
}