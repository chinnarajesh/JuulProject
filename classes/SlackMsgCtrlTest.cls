@isTest
private Class SlackMsgCtrlTest{

    @testSetup
    static void setup(){
        Case c = new Case(Origin = 'Phone');
        insert c;
        
        Slack_Config__c config = new Slack_Config__c(Name = 'Test',Message_Editable__c = true,Message__c = 'Dear {!Case.CaseNumber}, welcome to salesforce',Webhook_URL__c = 'https://hooks.slack.com/services/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');
        insert config;    
    }
    // only DB Message
    static testMethod void testPageAction(){
        Case c = [SELECT Id from Case];
        PageReference pageRef = Page.SlackMsg;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('c', 'Test');
        pageRef.getParameters().put('id', c.Id);
        SlackMsgCtrl slack = new SlackMsgCtrl();

        PageReference p1 = slack.pageAction();
        system.assertEquals(null,p1);
    }
    
    // Both DB Message and URL Message 
    static testMethod void testPageAction1(){
        Case c = [SELECT Id from Case];
        PageReference pageRef = Page.SlackMsg;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('c', 'Test');
        pageRef.getParameters().put('id', c.Id);
        pageRef.getParameters().put('retURL', c.Id);
        pageRef.getParameters().put('msg', 'Check 001255642 for more details');
        SlackMsgCtrl slack = new SlackMsgCtrl();
        
        PageReference p1 = slack.pageAction();
        system.assertEquals(null,p1);
    }
    
    // No Message 
    static testMethod void testPageAction2(){
        Case c = [SELECT Id from Case];
        PageReference pageRef = Page.SlackMsg;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('c', 'Test');
        pageRef.getParameters().put('id', c.Id);
        pageRef.getParameters().put('retURL', c.Id);
        pageRef.getParameters().put('msg', '');
        Slack_Config__c config = [SELECT Message_Editable__c FROM Slack_Config__c LIMIT 1];
        config.Message__c = '';
        update config;
        SlackMsgCtrl slack = new SlackMsgCtrl();
        
        PageReference p1 = slack.pageAction();
        system.assertEquals(null,p1);
    }
    //Message Editable false
     
    static testMethod void testPageAction3(){
        Case c = [SELECT Id from Case];
        PageReference pageRef = Page.SlackMsg;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('c', 'Test');
        pageRef.getParameters().put('id', c.Id);
        pageRef.getParameters().put('retURL', c.Id);
        pageRef.getParameters().put('msg', '');
        Slack_Config__c config = [SELECT Message_Editable__c FROM Slack_Config__c LIMIT 1];
        config.Message_Editable__c = false;
        update config;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SlackMockHttpResponseGenerator());
        SlackMsgCtrl slack = new SlackMsgCtrl();
        slack.send();
        PageReference p1 = slack.pageAction();
        system.assertEquals(null,p1);
        Test.stopTest();
    }
}