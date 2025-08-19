@isTest
public with sharing class PropelDeviationNotificationsTest {    
    public static testmethod void PropelDeviationNotificationsTest() {
        User PropelUser = [Select Id, Name from User where firstname = 'Propel' limit 1];

        //Create Change Order
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='Deviation', PDLM__primary_key__c = 'Deviation');
        insert lifecycle;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__order__c = 1, PDLM__No_Approval__c = true, 
        PDLM__lifecycle__c = lifecycle.id, PDLM__Is_First_Phase__c = true);
        insert pendingPhase;

        PDLM__Phase__c ActivePhase = new PDLM__Phase__c(Name='Active', PDLM__order__c = 2, PDLM__No_Approval__c = true,
        PDLM__lifecycle__c = lifecycle.id);
        insert ActivePhase;

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(name='Autonumber for Deviation', PDLM__prefix__c = 'DEV-', 
        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(name='Deviation', PDLM__autonumber__c = autonumberChange.id, 
        PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

        // Get all picklist values
        List<Schema.PicklistEntry> entries = PDLM__Change__c.Accessible_By__c.getDescribe().getPickListValues();
        List<String> pickListValuesList = new List<String>();
        for( Schema.PicklistEntry pickListVal : entries){
			pickListValuesList.add(pickListVal.getLabel());
		}     
        
        system.debug('entries: ' + entries);
        system.debug('picklist: ' + pickListValuesList);

        List<GroupMember> groupMembers = new List<GroupMember>([SELECT GroupId, UserOrGroupId FROM GroupMember WHERE Group.Name in : pickListValuesList]);
        List<Id> groupIds = new List<Id>();
        for (GroupMember gm : groupMembers){
            groupIds.add(gm.GroupId);
        }

        system.debug('groupIDs: ' + groupIds);

        Group gp = [Select Id, Name from Group where Id = :groupIDs[0]];

        PDLM__Change__c change = new PDLM__Change__c(PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test Deviation', 
        PDLM__primary_Key__c = 'DEV1', Accessible_By__c = gp.Name); //'Test Group 1');
        insert change;

        //Get Active Phase ID
        PDLM__Change_Phase__c activePhaseRecord = [Select Id, Name from PDLM__Change_Phase__c where PDLM__Change_lk__c = :change.Id and Name = 'Active' limit 1];
        
        //Update Change Status to kick off the trigger
        change.PDLM__Status_lk__c = activePhaseRecord.Id;
        update change;   
    }
}