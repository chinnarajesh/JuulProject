@isTest
public with sharing class PropelEmailUponRejectionTest { 
    public static testmethod void PropelEmailUponRejectionTest() {
        User PropelUser = [Select Id, Name from User where firstname = 'Propel' limit 1];

        //Create Change Order
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'ECO');
        insert lifecycle;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                         PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        insert pendingPhase;

        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
                                                     PDLM__lifecycle__c = lifecycle.id);
        insert CCBPhase;

        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Approved', PDLM__order__c = 3, 
                                                         PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        insert approvedPhase;

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', 
        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(name='ECO', PDLM__autonumber__c = autonumberChange.id, 
        PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

        PDLM__Change__c change = new PDLM__Change__c(PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test ECO', 
        PDLM__primary_Key__c = 'ECO1');
        insert change;

        //Move the change to an approval phase
        PDLM__Change_Phase__c plmReviewPhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.id and Name = 'PLM Review' LIMIT 1];
        plmReviewPhase.PDLM__Approver_1__c = PropelUser.Id;
        update plmReviewPhase;

        change.PDLM__Status_lk__c = plmReviewPhase.Id;
        update change;

        PDLM__Change_Phase__c initialPhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.id and Name = 'Pending' LIMIT 1];
        
        change.PDLM__Status_lk__c = initialPhase.Id;
        update change;

        Test.startTest();
        Integer emailbefore = Limits.getEmailInvocations();

        plmReviewPhase.Rejected__c = true;
        update plmReviewPhase;

        //Did I send that email?
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have changed');
        Test.stopTest();    
    }
}