@isTest
private class Knowledge_Widget_ConTests{

    
    static testmethod void testRunCode(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = [SELECT Id FROM User WHERE profileId=:p.Id AND UserPermissionsKnowledgeUser =TRUE and isActive = true LIMIT 1];
        System.runAs(u){
            
            String rtId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
            Account acc = new Account(
                PersonEmail = 'test@test.com',
                RecordTypeId = rtId,
                LastName = 'test'
            );
            insert acc;
            
            Case cs = new Case(
                Priority='Low',
                status='New',
                Subject='Test',
                Do_Not_Notify__c = true,
                SuppliedEmail = acc.PersonEmail,
                AccountId = acc.Id
            );
            insert cs ;

            IKB_Master__kav csop = new IKB_Master__kav(
                Title='Test',
                Body__c='Test',
                language='en_US',
                UrlName='test'
            );
            insert csop;
            IKB_Master__kav a = [
                SELECT KnowledgeArticleId,PublishStatus 
                FROM IKB_Master__kav
                WHERE Id = :csop.Id
            ];
            KbManagement.PublishingService.publishArticle(a.KnowledgeArticleId, true);
            

            CaseArticle article = new CaseArticle(
                CaseId = cs.Id,
                KnowledgeArticleId = a.KnowledgeArticleId
            );
            insert article ;
			Knowledge_Widget_Con.getCase(cs.Id);
            Knowledge_Widget_Con.getArticles();
            Knowledge_Widget_Con.getDataCategories();
            Knowledge_Widget_Con.getArticleType();
            Knowledge_Widget_Con.getArticleDetail('IKB_Master__kav','Online',[SELECT Id,KnowledgeArticleId FROM IKB_Master__kav  WHERE PublishStatus ='Online' AND language='en_US'].KnowledgeArticleId) ;
            Knowledge_Widget_Con.getAllCaseArticle(new List<String>{[SELECT Id,KnowledgeArticleId FROM IKB_Master__kav  WHERE PublishStatus ='Online' AND language='en_US'].KnowledgeArticleId}, [SELECT Id FROM Case].Id) ;
            Knowledge_Widget_Con.insertCaseArticle([SELECT Id,KnowledgeArticleId FROM IKB_Master__kav  WHERE PublishStatus ='Online' AND language='en_US'].KnowledgeArticleId , [SELECT Id FROM Case].Id);
            Knowledge_Widget_Con.deleteCaseArticle([SELECT Id FROM CaseArticle].Id);
            system.assertEquals([SELECT count() FROM CaseArticle] ,1) ;
        }
    }
}