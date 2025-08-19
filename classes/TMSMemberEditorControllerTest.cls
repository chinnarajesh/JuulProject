@isTest(SeeAllData=false)                             
private class TMSMemberEditorControllerTest {
    public static Account testAccount;
    public static Trade_Marketing_Survey__c tms;
    public static Trade_Marketing_Survey_Member__c tmsm;
    static testMethod void testInsertMode(){
        setUpData();
        Test.setCurrentPage(Page.TMSMemberEditor);

        /*Trade_Marketing_Survey_Member__c newTMSM = new Trade_Marketing_Survey_Member__c(Account__c=testAccount.Id, Status__c='Pending', Trade_Marketing_Survey__c=tms.Id);

        ApexPages.StandardController stdController = new ApexPages.StandardController(newTMSM);
        TMSMemberEditorController controller = new TMSMemberEditorController(stdController);
        controller.init();
        controller.activateTempPhoto();
        controller.categoryAction = 'Merchandising';
        controller.descriptionAction = 'Front of store';
        for(Integer i=0; i<controller.categoryToPhotoWrapperMap.get('Merchandising').size(); i++){
            if(controller.categoryToPhotoWrapperMap.get('Merchandising')[i].photo.Description__c == 'Front of store'){
                controller.attachId = controller.categoryToPhotoWrapperMap.get('Merchandising')[i].attach.Id;
                break;
            }
        }
        controller.deletePhoto();
        controller.attachmentBody = Blob.valueOf('Unit Test Attachment Body Front of Store');
        controller.uploadPhoto();
        controller.save();

        // Misc
        controller.OpenEditPage();
        TMSMemberEditorController.MAX_MULTISELECT_SIZE = 5;
        TMSMemberEditorController.STATUS_TO_VALIDATE = 'Survey Complete';

        controller.addQuestion();
        
*/
    }

    static testMethod void testEditMode(){
        setUpData();
        Test.setCurrentPage(Page.TMSMemberEditor);

        ApexPages.StandardController stdController = new ApexPages.StandardController(tmsm);
        TMSMemberEditorController controller = new TMSMemberEditorController(stdController);
        
        controller.init();
        controller.activateTempPhoto();
        controller.categoryAction = 'Merchandising';
        controller.descriptionAction = 'Front of store';
        for(Integer i=0; i<controller.categoryToPhotoWrapperMap.get('Merchandising').size(); i++){
            if(controller.categoryToPhotoWrapperMap.get('Merchandising')[i].photo.Description__c == 'Front of store'){
                controller.attachId = controller.categoryToPhotoWrapperMap.get('Merchandising')[i].attach.Id;
                break;
            }
        }
        controller.deletePhoto();
        controller.attachmentBody = Blob.valueOf('Unit Test Attachment Body Front of Store');
        controller.uploadPhoto();
        controller.save();
    }
    static testMethod void testTMSGalleryView(){
        setUpData();
        Trade_Marketing_Survey__c tms = [SELECT id,Name FROM Trade_Marketing_Survey__c LIMIT 1];
        TMSGalleryViewController.getViewObject(tms.Name);
        TMSGalleryViewController con = new TMSGalleryViewController();
    }
    static testMethod void testClone(){
        setUpData();
        Trade_Marketing_Survey__c tms = [SELECT id FROM Trade_Marketing_Survey__c LIMIT 1];
        TradeMarketingSurveyWebservice.cloneTradeMarketingSurvey(tms.id);
        
        delete([SELECT id FROM Trade_Marketing_Survey_Default_Question__c]);
    }
    
    public static void setUpData(){
             ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        List<Account> accList = new List<Account>();
        Account testAccount = new Account();
        testAccount.Name='Test';
        testAccount.Type='HQ';
        testAccount.ShippingState ='HI';
        testAccount.BillingCountry ='USA';
        testAccount.ComplianceMechanism__c='Menthol Ban';
        accList.add(testAccount);
        insert accList;
        // Create TMS
        tms = new Trade_Marketing_Survey__c(Name='Test TMS 1');
        insert(tms);

        // Create Trade Marketing Survey Default Photo
        Trade_Marketing_Survey_Default_Photo__c tmsdp = new Trade_Marketing_Survey_Default_Photo__c(Category__c='Merchandising', Description__c='Front of store', Required__c=false, Trade_Marketing_Survey__c=tms.Id);
        insert(tmsdp);

        // Create Attachment
        insert(new Attachment(Name='TestAttachment.png', ParentId=tmsdp.Id, Body=Blob.valueOf('Unit Test Attachment Body')));

        // Trade Marketing Survey Default Question
        insert(new Trade_Marketing_Survey_Default_Question__c(Answer__c='1,2', Answer_Options__c='1,2,3', Category__c='Merchandising', Question__c='What Number?', Question_Answer_Type__c='MultiSelect Picklist', Required__c=false, Sort_Order__c=1, Trade_Marketing_Survey__c=tms.Id));

        // Trade Marketing Survey Member
        tmsm = new Trade_Marketing_Survey_Member__c(Account__c=testAccount.Id, Status__c='Pending', Trade_Marketing_Survey__c=tms.Id);
        insert(tmsm);

        // Create Trade Marketing Survey Default Photo
        Trade_Marketing_Survey_Member_Photo__c tmsmp = new Trade_Marketing_Survey_Member_Photo__c(Category__c='Merchandising', Description__c='Front of store', Required__c=false, Trade_Marketing_Survey_Member__c=tmsm.Id);
        insert(tmsmp);

        // Create Attachment
        insert(new Attachment(Name='TestAttachment.png', ParentId=tmsmp.Id, Body=Blob.valueOf('Unit Test Attachment Body')));

        // Trade Marketing Survey Member Question
        insert(new Trade_Marketing_Survey_Member_Question__c(Answer__c='1,2', Answer_Options__c='1,2,3', Category__c='Merchandising', Question__c='What Number?', Question_Answer_Type__c='MultiSelect Picklist', Required__c=false, Sort_Order__c=1, Trade_Marketing_Survey_Member__c=tmsm.Id));
        
        // Trade Marketing Survey Default Question
        insert(new Trade_Marketing_Survey_Default_Question__c(Answer__c='1,2', Answer_Options__c='1,2,3', Category__c='Merchandising', Question__c='What Number?', Question_Answer_Type__c='MultiSelect Picklist', Required__c=false, Sort_Order__c=1, Trade_Marketing_Survey__c=tms.Id));

    }
}