@isTest
public class BulkReassignPLMApprovalsTest {

    public static Map<String,Id> createObjects() {
    
        Map<String,Id> returnMap = new Map<String,Id>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user1 = new User(ProfileId = p.Id, Alias = 'standt', Email = 'walk_plmA@test.com', UserName = 'walk_plmABAB@test.com',
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing',
                                LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');

        User user2 = new User(ProfileId = p.Id, Alias = 'walker', Email = 'walk_plmB@test.com', UserName = 'walk_plmBABA@test.com',
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing',
                                LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert new SObject[]{ user1, user2 };
        
        returnMap.put('user1', user1.Id);
        returnMap.put('user2', user2.Id);
    
        // objs
        PDLM__Lifecycle__c change_life = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'eco_change');
        insert change_life;
        insert new PDLM__Phase__c( Name='Initial', PDLM__lifecycle__c = change_life.id, PDLM__order__c = 1, PDLM__Is_First_Phase__c = true, PDLM__Default_No_Change_Control__c = true, PDLM__No_Approval__c = true);
        insert new PDLM__Phase__c( Name='Change Review', PDLM__lifecycle__c = change_life.id, PDLM__order__c = 5, PDLM__Default_No_Change_Control__c = true, PDLM__Auto_Submit_For_Approval__c  = true);
        insert new PDLM__Phase__c( Name='Approval', PDLM__lifecycle__c = change_life.id, PDLM__order__c = 15, PDLM__Default_No_Change_Control__c = true, PDLM__Auto_Submit_For_Approval__c  = true, PDLM__Approve_Change_Phase__c = true);
        insert new PDLM__Phase__c( Name='Approved', PDLM__lifecycle__c = change_life.id, PDLM__order__c = 25, PDLM__Default_No_Change_Control__c = true, PDLM__No_Approval__c = true);
        PDLM__Category__c category = new PDLM__Category__c(name='ECOCat', PDLM__lifecycle__c = change_life.id, PDLM__Type__c = 'Change');
        insert category;

        PDLM__Change__c change = new PDLM__Change__c( Name = 'ECO-1001', PDLM__Category__c = category.Id, PDLM__Primary_Key__c = 'eco_aaaa');
        PDLM__Change__c change_B = new PDLM__Change__c( Name = 'ECO-2002', PDLM__Category__c = category.Id, PDLM__Primary_Key__c = 'eco_bbbb');
        insert new SObject[]{ change, change_B };

        PDLM__Change_Phase__c[] cps = [select Id, PDLM__Approver_1__c, PDLM__Phase__r.Name from PDLM__Change_Phase__c where PDLM__Change_lk__c = :change.Id];

        for (PDLM__Change_Phase__c cp : cps) {
            if (cp.PDLM__Phase__r.Name == 'Change Review' || cp.PDLM__Phase__r.Name == 'Approval') {
                cp.PDLM__Approver_1__c = user1.Id;
            }
        }

        PDLM__Change_Phase__c cp_b = [select Id, PDLM__Approver_1__c, PDLM__Approver_2__c from PDLM__Change_Phase__c where PDLM__Change_lk__c = :change_B.Id AND PDLM__Phase__r.Name = 'Approval'];
        cp_b.PDLM__Approver_1__c = user1.Id;
        cp_b.PDLM__Approver_1__c = user2.Id;

        update cps;
        update cp_b;
        
        returnMap.put('change', change.Id);
        return returnMap;
    }


    @IsTest
    static void testMethod1(){

        
        Test.startTest();
        Map<String, Id> data = createObjects();

        Id user1 = data.get('user1');
        Id user2 = data.get('user2');
        PDLM__Change__c change = [select Id, PDLM__Status_lk__c, PDLM__In_Approval_Process__c from PDLM__Change__c where Id = :data.get('change')];
        PDLM__Change_Phase__c cp_review = [select Id, PDLM__Approver_1__c, PDLM__Approver_Count__c, PDLM__Phase__r.Name from PDLM__Change_Phase__c where PDLM__Change_lk__c = :change.Id AND PDLM__Phase__r.Name = 'Change Review' LIMIT 1];
        System.debug(change);
        change.PDLM__Status_lk__c = cp_review.Id;
        update change;

        System.debug(change.PDLM__In_Approval_Process__c);
        Exception e_test;

        if (!change.PDLM__In_Approval_Process__c) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(cp_review.Id);
            
            Approval.ProcessResult result;
            try {
                result = Approval.process(req);
            } catch (Exception e) {
                e_test = e;
            }
        }

        BulkReassignPLMApprovals.ReassignRequest request = new BulkReassignPLMApprovals.ReassignRequest();
        request.originalApproverId = user1;
        request.newApproverId = user2;
        BulkReassignPLMApprovals.executeReassignRequest(new BulkReassignPLMApprovals.ReassignRequest[]{ request });

        PDLM__Change_Phase__c cp_approval = [select Id, PDLM__Approver_1__c from PDLM__Change_Phase__c where PDLM__Change_lk__c = :change.Id AND PDLM__Phase__r.Name = 'Approval' LIMIT 1];

        System.assertEquals(null, e_test, 'Should not receive error when trying to submit for approval: '+ e_test);
        System.assertEquals(1, cp_review.PDLM__Approver_Count__c, 'should be same approver count');
        System.assertEquals(user2, cp_approval.PDLM__Approver_1__c, 'approver 1 should change to user 2 for next approval phase');

        Test.stopTest();
        
    }
}