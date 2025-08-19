/*
* Test class for Case Skills Based Rotuing
*/
@isTest
private class CaseSkillsRoutingAssignmentTest {
    @testSetup
    private static void createTestData(){
        CaseSkillBaseAssignment__c setting = CaseSkillBaseAssignment__c.getInstance();
        if(setting == null){
            setting =new CaseSkillBaseAssignment__c();
        }
        setting.active__c = true;
        upsert setting;

        UserCaseAssignmentConfigController configCon = new UserCaseAssignmentConfigController();
        configCon.addUsers();
        List<UserCaseAssignmentConfigController.CongigurationSetting>
                configs = UserCaseAssignmentConfigController.getConfigSettings('', true, '', 'JUUL');
        List<UserCaseAssignmentConfigController.LookupResult> issues = UserCaseAssignmentConfigController.getPickListVal('Issue__c','JUUL');
        List<UserCaseAssignmentConfigController.LookupResult> recordTypes = UserCaseAssignmentConfigController.getPickListVal('Record_Type__c', 'JUUL');
        List<UserCaseAssignmentConfigController.LookupResult> products = UserCaseAssignmentConfigController.getPickListVal('Product__c', 'JUUL');
        for(UserCaseAssignmentConfigController.CongigurationSetting config : configs){
            //for(UserCaseAssignmentConfigController.LookupResult issue : issues){
                config.issues.add('Degradation');
            //}
            //for(UserCaseAssignmentConfigController.LookupResult r : recordTypes){
                config.products.add('JUUL');
            //}
            //for(UserCaseAssignmentConfigController.LookupResult p : products){
                //config.types.add(p.Id);
            //}
        }

        UserCaseAssignmentConfigController.save(configs);

        List<QueueSobject> queuesUnAssigned = [SELECT 
                                                    Id,QueueId,SobjectType,Queue.Name 
                                              FROM QueueSobject WHERE SobjectType = 'Case' and queue.developerName = 'Tier_1_PHI' limit 1];
                    
        
        
        Contact conToBeDeleted = new contact(FirstName='Test',LastName='Contact',Phone='12345',Email='Test@example.com',
                                         MailingCity='Test',MailingState='PA',MailingCountry='USA',Fax='123456');
        insert conToBeDeleted;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName='Test',LastName='Account',PersonEmail='Test@example.com',recordTypeId=recordTypeId);
        insert acc;

        List<Case> cases = new List<Case>();
        for(Integer i =0; i<10;i++){
            Case caseWithSubject = new Case(Status='New', Product__c = 'JUUL', Issue__c = 'JUUL', Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',contactId=conToBeDeleted.Id,AccountId=acc.Id); 
            caseWithSubject.OwnerId = queuesUnAssigned[0].queueId;
            caseWithSubject.Topic__c = 'Battery';
            caseWithSubject.Issue__c = 'Degradation';
            cases.add(caseWithSubject);
        }


        insert cases;

        cases = [SELECT 
                    Status, Id, RecordType.Name, Product__c, Issue__c, OwnerId 
                    , Owner.Name, Slack_Count__c, Owner.Type
                FROM 
                    Case 
                WHERE 
                        Id in : cases
                Order by Slack_Count__c desc , Total_Case_Score__c desc ];

        System.debug('-----' +cases);
        for(Case c : cases){
            System.assertEquals(c.Product__c, 'JUUL');
            System.assertEquals(c.OWnerId, queuesUnAssigned[0].queueId);
            System.assertEquals(c.Issue__c, 'Degradation');
            System.assertEquals(c.Status, 'New');
            //System.assertNotEquals(c.Owner.Name, null);
            //System.assertEquals(c.Owner.Type, 'Queue');
            
        }
        Integer i = 0;
        for(UserCaseAssignmentRuleConfigSetting__c config : [SELECT 
                                                                Id, User__r.Name, User__c , Issues_Selected__c, Product__c, Record_Type__c, User__r.SmallPhotoUrl,Active__c, Tier__c
                                                                , User__r.UserRole.Name
                                                            FROM 
                                                                UserCaseAssignmentRuleConfigSetting__c 
                                                            where 
                                                                User__r.isActive = true AND Active__c = true
                                                                AND User__c not in (SELECT OwnerId from Case where isClosed = false and Status != 'Pending' AND Owner.Type = 'User' and Skill_Routing_Exception__c = false)]){
           // System.assertEquals(config.Issues_Selected__c, 'Degradation');
            //System.assertEquals(config.Product__c, 'PAX');
            i++;
        }   

        System.assertNotEquals(i,0);
    }

    
    private static testmethod void testCasesAssignments(){
        List<Case> cases = [SELECT 
                                Status, Id, RecordType.Name, Product__c, Issue__c, OwnerId 
                                , Owner.Name, Slack_Count__c, Owner.Type
                            FROM 
                                Case 
                            Order by Slack_Count__c desc , Total_Case_Score__c desc ];

        System.debug('-----' +cases);
        for(Case c : cases){
            c.Outgoing_Time_Stamp__c = DateTime.now();
        }

        update cases;

        for(Case c : cases){
            c.Incoming_Time_Stamp__c = DateTime.now();
        }

        update cases;

        for(Case c : cases){
            c.Status = 'Pending';
        }

        update cases;

        for(Case c : cases){
            c.Incoming_Time_Stamp__c = DateTime.now();
            c.Status = 'Open';
        }

        update cases;

        cases[0].Previous_Queue_Owner_Id__c = 'SKIP';
        update cases;

        cases[0].Previous_Queue_Owner_Id__c = 'SKIP';
        cases[0].Status = 'Pending';
        update cases;

        delete cases;
        
    }

    @isTest
    private static void testSkillRotingConfiguration(){
        Test.startTest();
        Set<Id> serviceMgmt = new Set<Id>();
        for(UserRole role :  [SELECT Id FROM UserRole WHERE Name like '%Service Management']){
            serviceMgmt.add(role.Id);
        }
        //Search User 
        List<User> users = [SELECT Id,User.Name FROM User WHERE UserRole.ParentRoleId in:serviceMgmt AND  isActive = true];
        UserCaseAssignmentConfigController.searchUser(users[0].Name);
        UserCaseAssignmentConfigController.getPickListVal('Issue__c', 'JUUL');
        UserCaseAssignmentConfigController.getPickListVal('Product__c', 'JUUL');
        UserCaseAssignmentConfigController.getPickListVal('Record_Type__c','JUUL');
        List<UserCaseAssignmentConfigController.CongigurationSetting>
                configs = UserCaseAssignmentConfigController.getConfigSettings('', true, '', 'JUUL');
        UserCaseAssignmentConfigController.save(configs);
        configs = UserCaseAssignmentConfigController.getConfigSettings( 'Tier 1', false, '' ,'JUUL');
        configs = UserCaseAssignmentConfigController.getConfigSettings('', true, '' ,'JUUL');

        List<QueueSobject> queuesUnAssigned = [SELECT 
                                                    Id,QueueId,SobjectType,Queue.Name 
                                              FROM QueueSobject WHERE SobjectType = 'Case' and queue.developerName = 'Tier_1_PHI' limit 1];

        List<Case> cases = new List<Case>();
        for(Integer i =0; i<10;i++){
            Case caseWithSubject = new Case(Status='New', Product__c = 'JUUL', Issue__c = 'JUUL', Priority='New',subject='Zopim Chat Transcript',Description='Chat started on A',AccountId=[SELECT ID FROM ACCOUNT LIMIT 1].Id); 
            caseWithSubject.OwnerId = configs[0].config.User__c;
            caseWithSubject.Previous_Queue_Owner_Id__c = queuesUnAssigned[0].queueId;
            caseWithSubject.Topic__c = 'Battery';
            caseWithSubject.Issue__c = 'Degradation';
            cases.add(caseWithSubject);
        }


        insert cases;

        for(Case c : cases){
            c.OwnerId = configs[0].config.User__c;
        }

        update cases;
                    
        for(UserCaseAssignmentConfigController.CongigurationSetting config : configs){
            config.config.Active__c = false;
        }
        UserCaseAssignmentConfigController.save(configs);

        for(UserCaseAssignmentConfigController.CongigurationSetting config : configs){
            config.config.Active__c = true;
        }
        UserCaseAssignmentConfigController.save(configs);

        Test.stopTest();

    }


    
}