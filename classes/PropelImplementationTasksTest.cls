@isTest
public with sharing class PropelImplementationTasksTest {
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

    @isTest public static void PropelImplementationTasksTest(){
        //Get User
        Id userId = [SELECT Id FROM User WHERE IsActive = true ORDER BY CreatedDate Desc LIMIT 1].Id;

        //Create Change Order
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='XCO', PDLM__primary_key__c = 'XCO');
        insert lifecycle;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, PDLM__No_Approval__c = true, 
        PDLM__lifecycle__c = lifecycle.id);
        insert pendingPhase;

        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='Implementation', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
        PDLM__lifecycle__c = lifecycle.id);
        insert CCBPhase;

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(name='Autonumber for XCO', PDLM__prefix__c = 'XCO-', 
        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(name='XCO', PDLM__autonumber__c = autonumberChange.id, 
        PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

        Schema.SObjectField searchField = PDLM__Change__c.Accessible_By__c;
        List<String> groupNames = getPicklistvalues(searchField);
        PDLM__Change__c change = new PDLM__Change__c(Name = 'XCO-00001', PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test XCO', 
                                                     PDLM__primary_Key__c = 'XCO1', Accessible_By__c = groupNames[0] + ';' + groupNames[1]);
        insert change;

        Id propelAmlRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Propel_AML').getRecordTypeId();
        
        //Needed for JUUL Account Triggers
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;

        Account acc1 = new Account(recordTypeId = propelAmlRecordTypeId, Name =  groupNames[0], Implementation_Approver__c = userId, Quality_Review_Approver__c = userId);
        insert acc1;
        Account acc2 = new Account(recordTypeId = propelAmlRecordTypeId, Name =  groupNames[1], Quality_Review_Approver__c = userId);
        insert acc2;

        Id changePhaseId = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name like '%Implementation%' Limit 1].Id; 
        
        //Invoke the method
        PropelImplementationTasks.GetRequestsfromFlow flow = new PropelImplementationTasks.GetRequestsfromFlow();
        flow.change = change;
        flow.accessibleBy = change.Accessible_By__c;
        flow.changePhaseId = changePhaseId;
        PropelImplementationTasks.PropelImplementationTasks(new List<PropelImplementationTasks.GetRequestsfromFlow> {flow});

        List<PDLM__Deliverable__c> activities = [SELECT Id FROM PDLM__Deliverable__c WHERE PDLM__Change__c = :change.Id];
        System.assertEquals(2, activities.size());
    }
}