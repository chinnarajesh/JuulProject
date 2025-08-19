global with sharing class TMSMemberEditorController {
    // Placeholder & Multiselect settings
    public static Boolean USE_PLACEHOLDER = true;
    public static String SELECT_PLACEHOLDER { get{return '--';}set; }
    public static Integer MAX_MULTISELECT_SIZE { get{return 5;}set; }
    public static String STATUS_TO_VALIDATE { get{return 'Survey Complete';}set; }

    // Object declaration
    public Transient Blob attachmentBody { get;set; }
    public Attachment attachment { get;set; }
    public String descriptionAction { get;set; }
    public String categoryAction { get;set; }
    public Id attachId { get;set; }
    public Boolean insertAction;
    public Id tempPhotoStorageId;

    // Data structure declaration
    public Map<String,List<QuestionWrapper>> categoryToQuestions { get;set; }
    public Map<String,List<PhotoWrapper>> categoryToPhotoWrapperMap { get;set; }
    public List<String> collateralCategories {get;set;}
    public List<SelectOption> statusOptions {get;set;}
    public List<SelectOption> statusCollateralOptions {get;set;}
    public List<SelectOption> statusSurveyOptions {get;set;}

    // Special object declaration
    ApexPages.StandardController sc;
    Trade_Marketing_Survey_Member__c TMSM;
    public Boolean viewMode;
    
    public TMSMemberEditorController(ApexPages.StandardController controller) {
        collateralCategories= new List<String>{'Merchandising','Fixture', 'Collateral', 'Training',  'Competitors', 'Other'};
 
        categoryToPhotoWrapperMap = new Map<String,List<PhotoWrapper>>();
        categoryToQuestions = new Map<String,List<QuestionWrapper>>();
        attachment = new Attachment();
        sc = controller;

        TMSM = (Trade_Marketing_Survey_Member__c)controller.getRecord();
        insertAction = (TMSM.Id == null);

        System.debug('Insert Action' + insertAction);
    }

    public void init(){
        if(insertAction)
            activateTempPhoto();
            
        initializeStatus();

        for(String category : collateralCategories){
            categoryToPhotoWrapperMap.put(category, new List<PhotoWrapper>());
            categoryToQuestions.put(category, new List<QuestionWrapper>());
        }

        populateMemberInfo();
    }
    
    public void initView(){
        viewMode = true;
                   
        initializeStatus();

        for(String category : collateralCategories){
            categoryToPhotoWrapperMap.put(category, new List<PhotoWrapper>());
            categoryToQuestions.put(category, new List<QuestionWrapper>());
        }

        populateMemberInfo();
    }
    public void initializeStatus(){
        statusOptions = new List<SelectOption>();
        statusCollateralOptions = new List<SelectOption>();
        statusSurveyOptions = new List<SelectOption>();
        
        if(USE_PLACEHOLDER){
            statusOptions.add(new SelectOption( '',SELECT_PLACEHOLDER));
            statusCollateralOptions.add(new SelectOption( '',SELECT_PLACEHOLDER));
            statusSurveyOptions.add(new SelectOption( '',SELECT_PLACEHOLDER));
        }
        for(Schema.PicklistEntry option : Trade_Marketing_Survey_Member__c.Status__c.getDescribe().getPicklistValues()){
            statusOptions.add(new SelectOption(option.getValue(), option.getLabel()));
        }
        for(Schema.PicklistEntry option : Trade_Marketing_Survey_Member__c.Status_Collateral__c.getDescribe().getPicklistValues()){
            statusCollateralOptions.add(new SelectOption(option.getValue(), option.getLabel()));
        }
        for(Schema.PicklistEntry option : Trade_Marketing_Survey_Member__c.Status_of_Survey_Visit__c.getDescribe().getPicklistValues()){
            statusSurveyOptions.add(new SelectOption(option.getValue(), option.getLabel()));
        }
    }

    public void populateMemberInfo(){
        Set<Id> photoIds = new Set<Id>();
        Map<Id, PhotoWrapper> photoIdToPhotoWrapper = new Map<Id, PhotoWrapper>();
        Integer questionCount = 0;
        if(insertAction) {
            System.debug('Insert OR current member has no question & photos');
            List<Trade_Marketing_Survey_Member_Photo__c> newPhotos = new List<Trade_Marketing_Survey_Member_Photo__c>();
            
            // Get all TMS default photo Ids
            for(Trade_Marketing_Survey_Default_Photo__c photo : [SELECT Id, Category__c, Description__c, Required__c FROM Trade_Marketing_Survey_Default_Photo__c WHERE Trade_Marketing_Survey__c = :TMSM.Trade_Marketing_Survey__c ORDER BY Description__c ASC]){
                System.debug('Photo ' + photo.Description__c );
                photoIds.add(photo.Id);
                PhotoWrapper newPW = new PhotoWrapper(photo);
                categoryToPhotoWrapperMap.get(photo.Category__c).add(newPW);
                System.debug('After add ' + categoryToPhotoWrapperMap.get(photo.Category__c));
                
                photoIdToPhotoWrapper.put(photo.Id, newPW);
                newPW.photo.Trade_Marketing_Survey_Member__c = TMSM.Id;
                newPhotos.add(newPW.photo);
            }
            
            // Retrieve all attachments with photo ids
            for(Attachment attach : [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN :photoIds ]){
                photoIdToPhotoWrapper.get(attach.ParentId).attach = new Attachment(Id=attach.Id);
                photoIdToPhotoWrapper.get(attach.ParentId).isNewPhoto = false;
                photoIdToPhotoWrapper.get(attach.ParentId).isParentPhoto = true;
                photoIdToPhotoWrapper.get(attach.ParentId).isPlaceholder = false;
            }
            
            // Retrieve all default questions
            for(Trade_Marketing_Survey_Default_Question__c question : [SELECT Id, Category__c, Answer__c, Question__c, Answer_Options__c, Question_Answer_Type__c, Required__c, Sort_Order__c FROM Trade_Marketing_Survey_Default_Question__c WHERE Trade_Marketing_Survey__c = :TMSM.Trade_Marketing_Survey__c ORDER BY Sort_Order__c,Name]){
                categoryToQuestions.get(question.Category__c).add(new QuestionWrapper(question, true)); // Since we are retrieving from parent, they are counted as new questions, hence true.
            }
        }
        else if(!insertAction){
            System.debug('Not an insert');
            // Get all TMS member photo Ids
            for(Trade_Marketing_Survey_Member_Photo__c photo : [SELECT Id, Category__c, Description__c, Required__c FROM Trade_Marketing_Survey_Member_Photo__c WHERE Trade_Marketing_Survey_Member__c = :TMSM.Id ORDER BY Description__c ASC]){
                System.debug('Photo ' + photo.Description__c );
                photoIds.add(photo.Id);
                PhotoWrapper newPW = new PhotoWrapper(photo);
                categoryToPhotoWrapperMap.get(photo.Category__c).add(newPW);
                System.debug('After add ' + categoryToPhotoWrapperMap.get(photo.Category__c));
                photoIdToPhotoWrapper.put(photo.Id, newPW);
            }
            // Retrieve all attachments with photo ids
            for(Attachment attach : [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN :photoIds ]){
                photoIdToPhotoWrapper.get(attach.ParentId).attach = new Attachment(Id=attach.Id, ParentId=attach.ParentId);
                photoIdToPhotoWrapper.get(attach.ParentId).isNewPhoto = false;
                photoIdToPhotoWrapper.get(attach.ParentId).isParentPhoto = false;
                photoIdToPhotoWrapper.get(attach.ParentId).isPlaceholder = false;
            }
            // Retrieve all member questions
            for(Trade_Marketing_Survey_Member_Question__c question : [SELECT Id, Name, Category__c, Answer__c, Question__c, Answer_Options__c, Question_Answer_Type__c, Required__c, Sort_Order__c, Trade_Marketing_Survey_Member__c FROM Trade_Marketing_Survey_Member_Question__c WHERE Trade_Marketing_Survey_Member__c = :TMSM.Id ORDER BY Sort_Order__c,Name]){            
                categoryToQuestions.get(question.Category__c).add(new QuestionWrapper(question, false));
                questionCount++;
            }

            if(photoIds.size()==0){ 
                List<Trade_Marketing_Survey_Member_Photo__c> newPhotos = new List<Trade_Marketing_Survey_Member_Photo__c>();
            
                // Get all TMS default photo Ids
                for(Trade_Marketing_Survey_Default_Photo__c photo : [SELECT Id, Category__c, Description__c, Required__c FROM Trade_Marketing_Survey_Default_Photo__c WHERE Trade_Marketing_Survey__c = :TMSM.Trade_Marketing_Survey__c ORDER BY Description__c ASC]){
                    System.debug('Photo ' + photo.Description__c );
                    photoIds.add(photo.Id);
                    PhotoWrapper newPW = new PhotoWrapper(photo);
                    categoryToPhotoWrapperMap.get(photo.Category__c).add(newPW);
                    System.debug('After add ' + categoryToPhotoWrapperMap.get(photo.Category__c));
                    
                    photoIdToPhotoWrapper.put(photo.Id, newPW);
                    newPW.photo.Trade_Marketing_Survey_Member__c = TMSM.Id;
                    newPhotos.add(newPW.photo);
                }
                
                if(viewMode != true) //Only add new photos if we don't have any
                    insert(newPhotos);
                
                // Retrieve all attachments with photo ids
                for(Attachment attach : [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN :photoIds ]){
                    photoIdToPhotoWrapper.get(attach.ParentId).attach = new Attachment(Id=attach.Id);
                    photoIdToPhotoWrapper.get(attach.ParentId).isNewPhoto = false;
                    photoIdToPhotoWrapper.get(attach.ParentId).isParentPhoto = true;
                    photoIdToPhotoWrapper.get(attach.ParentId).isPlaceholder = false;
                }
            }

            if(questionCount==0){
                // Retrieve all default questions
                for(Trade_Marketing_Survey_Default_Question__c question : [SELECT Id, Category__c, Answer__c, Question__c, Answer_Options__c, Question_Answer_Type__c, Required__c, Sort_Order__c FROM Trade_Marketing_Survey_Default_Question__c WHERE Trade_Marketing_Survey__c = :TMSM.Trade_Marketing_Survey__c ORDER BY Sort_Order__c,Name]){
                    categoryToQuestions.get(question.Category__c).add(new QuestionWrapper(question, true)); // Since we are retrieving from parent, they are counted as new questions, hence true.
                }
            }
        } 
    }

    /** Called by VF upon page load. Checks and assigns tempPhotoStorageId for photo uploading. Also creates the Temporary Photo Storage Trade_Marketing_Survey__c object if it has not been created. */
    public void activateTempPhoto(){
        try{
            for(Trade_Marketing_Survey__c TMS : [SELECT Id FROM Trade_Marketing_Survey__c WHERE Name = 'Temporary Photos' LIMIT 1])
                tempPhotoStorageId = TMS.Id;
            if(tempPhotoStorageId == null){
                Trade_Marketing_Survey__c tempTMS = new Trade_Marketing_Survey__c(Name = 'Temporary Photos');
                insert tempTMS;
                tempPhotoStorageId = tempTMS.Id;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    /** Called by VF upon clicking on Add Question button (Obsolete) */
    public void addQuestion(){
        categoryToQuestions.get(categoryAction).add(new QuestionWrapper(categoryAction));
    }

    /** Called by VF upon clicking on Upload Photo */
    public void uploadPhoto(){
        //try{
            // Figure out where to insert the image by category and description. If a photowrapper with the same description in the same category is not found, we insert in the first index.
            Integer indexToPut = -1;
            for(Integer i=0; i<categoryToPhotoWrapperMap.get(categoryAction).size(); i++){
                if(categoryToPhotoWrapperMap.get(categoryAction)[i].photo.Description__c == descriptionAction){
                    indexToPut = i;
                    break;
                }
            }
            if(indexToPut == -1)
                indexToPut = 0;

            System.debug('Uploading photo at index ' + indexToPut);

            PhotoWrapper currentPW = categoryToPhotoWrapperMap.get(categoryAction)[indexToPut];

            if(Test.isRunningTest()) // We need to assign the name since it isn't auto-assigned from VF.
                attachment.Name = 'TestAttachment.png';

            if(insertAction){ 
                // This is a hacky way to do it, but we want to be able to see the attachment as we upload them. 
                // Since we don't have a TMS member id yet, we upload the attachment to a temporary TMS object first and then delete it later when we click save.
                // Alternative 1: Create a custom object 'Temp Attachment Storage' for storing attachment temporarily.
                // Alternative 2: Use standard controller to save the TMS member object so we have the TMS member id, but have to be careful if user cancels without clicking save.
                attachment.ParentId = tempPhotoStorageId; 
                attachment.Body = attachmentBody;
                insert attachment;
                currentPW.attach = new Attachment(Id=attachment.Id);
                currentPW.isNewPhoto = true;
                currentPW.isParentPhoto = true;
                currentPW.isPlaceholder = false;
            } else {
                attachment.ParentId = categoryToPhotoWrapperMap.get(categoryAction)[indexToPut].photo.Id;
                attachment.Body = attachmentBody;
                insert attachment;
                currentPW.attach = new Attachment(Id=attachment.Id, ParentId=attachment.ParentId);
                currentPW.isNewPhoto = true;
                currentPW.isParentPhoto = false;
                currentPW.isPlaceholder = false;
            }
            attachment = new Attachment(Body=null);
        //} catch (Exception e) {
        //    ApexPages.addMessages(e);
        //}
    }

    /** Called by VF upon clicking on Delete Photo icon */
    public void deletePhoto(){
        try{
            Boolean isParentPhoto = true;
            for(Integer i=0; i<categoryToPhotoWrapperMap.get(categoryAction).size(); i++){
                if(categoryToPhotoWrapperMap.get(categoryAction)[i].attach.Id == attachId){
                    isParentPhoto = categoryToPhotoWrapperMap.get(categoryAction)[i].isParentPhoto;
                    categoryToPhotoWrapperMap.get(categoryAction)[i].attach = new Attachment();
                    categoryToPhotoWrapperMap.get(categoryAction)[i].isParentPhoto = true;
                    categoryToPhotoWrapperMap.get(categoryAction)[i].isPlaceholder = true;
                    break;
                }
            }

            if(!isParentPhoto) // Don't delete parent's photo!
                delete([SELECT Id FROM Attachment WHERE Id = :attachId]);
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    /** Called by VF upon clicking on Save button */
    public PageReference save(){
        try{
            PageReference ret = sc.save();
            ret.setRedirect(true);
            Id TMSMID = (insertAction?sc.getId():TMSM.Id);
            List<Trade_Marketing_Survey_Member_Question__c> questionsToInsert = new List<Trade_Marketing_Survey_Member_Question__c>();
            List<Trade_Marketing_Survey_Member_Photo__c> photosToInsert = new List<Trade_Marketing_Survey_Member_Photo__c>();
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            Map<PhotoWrapper,Trade_Marketing_Survey_Member_Photo__c> photoWrapperToPhotoMap = new Map<PhotoWrapper,Trade_Marketing_Survey_Member_Photo__c>();
            Map<Id,Trade_Marketing_Survey_Member_Photo__c> attachmentToPhotoMap = new Map<Id,Trade_Marketing_Survey_Member_Photo__c>();
            
            for(String category : collateralCategories){
                Integer questionSortOrder=1;
                if(categoryToQuestions.get(category) != null){
                    for(QuestionWrapper qw : categoryToQuestions.get(category)){
                        qw.TMSMQ.Sort_order__c = questionSortOrder;
                        if(qw.newQuestion)
                            qw.TMSMQ.Trade_Marketing_Survey_Member__c = TMSMID;
                        if(qw.TMSMQ.Question_Answer_Type__c == 'MultiSelect Picklist'){
                            qw.TMSMQ.Answer__c = join(qw.multiselectAnswer, ',');
                        }
                        questionsToInsert.add(qw.TMSMQ);
                        questionSortOrder++;
                    }
                }
                if(categoryToPhotoWrapperMap.get(category) != null && categoryToPhotoWrapperMap.get(category).size() > 0){
                    for(PhotoWrapper pw : categoryToPhotoWrapperMap.get(category)){
                        pw.photo.Trade_Marketing_Survey_Member__c = TMSMID;
                        photosToInsert.add(pw.photo);
                        if(pw.isParentPhoto) // If it's an parent photo, we need to insert our own attachments too
                            attachmentToPhotoMap.put(pw.attach.Id, pw.photo);
                    }
                }
            }
            upsert questionsToInsert;
            upsert photosToInsert;
            // We have to loop 2 times because Attachment.ParentId is Trade_Marketing_Survey_Member_Photo__c, so we need to insert Trade_Marketing_Survey_Member_Photo__c first to get the Id
            for(Attachment attach : [SELECT Id, Name, Body FROM Attachment WHERE Id IN :attachmentToPhotoMap.KeySet()]){
                    attachmentsToInsert.add(new Attachment(Body = attach.Body, Name = attach.Name, ParentId = attachmentToPhotoMap.get(attach.Id).Id));
            }
            insert attachmentsToInsert;

            List<Attachment> attachmentsToDelete = new List<Attachment>();
            if(insertAction){ // We borrowed TMS object to store the attachment temporarily, we need to remove them now.
                for(Attachment a : [SELECT Id FROM Attachment WHERE ParentId = :tempPhotoStorageId])
                    attachmentsToDelete.add(a);
            }
            delete attachmentsToDelete;
            if(attachmentsToDelete != null && attachmentsToDelete.size() != 0) Database.emptyRecycleBin(attachmentsToDelete);

            return ret;
            // return new PageReference('/apex/TMSMemberViewer?id='+TMSM.Id);
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    public String join(List<String> strList, String delimiter){
        String returnStr = '';
        for (Integer i = 0; i < strList.size(); i++) {
            returnStr += strList[i];
            if (i != (strList.size() - 1)) returnStr += delimiter;            
        }
        return returnStr;
    }
    
    public PageReference OpenEditPage(){
        PageReference pref = new PageReference('/apex/TMSMemberEditor?id='+TMSM.Id);
        pref.setRedirect(true);
        return pref;
    }

    public class QuestionWrapper{
        public Trade_Marketing_Survey_Member_Question__c TMSMQ { get;set; }
        public Boolean newQuestion { get;set; }
        public List<SelectOption> options { get;set; }
        public List<String> multiselectAnswer { get;set; }
        public Integer multiselectNumOptions { get;set; }

        public QuestionWrapper(Trade_Marketing_Survey_Member_Question__c TMSMQuestion, Boolean newQ){
            newQuestion = newQ;
            TMSMQ = TMSMQuestion;
            this.populateOptions();
        }

        public QuestionWrapper(Trade_Marketing_Survey_Default_Question__c TMSDQ, Boolean newQ){
            newQuestion = newQ;
            TMSMQ = new Trade_Marketing_Survey_Member_Question__c(Category__c=TMSDQ.Category__c, Answer__c=TMSDQ.Answer__c, Question__c=TMSDQ.Question__c, Question_Answer_Type__c=TMSDQ.Question_Answer_Type__c, Answer_Options__c=TMSDQ.Answer_Options__c, Required__c=TMSDQ.Required__c, Sort_Order__c=TMSDQ.Sort_Order__c);
            this.populateOptions();
        }

        public QuestionWrapper(String cat){
            newQuestion = true;
            TMSMQ = new Trade_Marketing_Survey_Member_Question__c(Category__c = cat, Question_Answer_Type__c = 'Text', Required__c=false);
        }

        public void populateOptions(){
            options = new List<SelectOption>();
            if(TMSMQ.Question_Answer_Type__c == 'MultiSelect Picklist' || TMSMQ.Question_Answer_Type__c == 'Picklist'){
                if(USE_PLACEHOLDER)
                    options.add(new SelectOption('', SELECT_PLACEHOLDER));
                if(TMSMQ.Answer_Options__c!=null){
                    for(String opt : TMSMQ.Answer_Options__c.split(','))
                        options.add(new SelectOption(opt, opt));
                    if(TMSMQ.Question_Answer_Type__c == 'MultiSelect Picklist' && TMSMQ.Answer__c != null && TMSMQ.Answer__c != '')
                        multiselectAnswer = new List<String>(TMSMQ.Answer__c.split(','));
                }
                multiselectNumOptions = options.size();
            }
        }
    }

    public class PhotoWrapper{
        public Trade_Marketing_Survey_Member_Photo__c photo { get;set; }
        public Attachment attach { get;set; }
        public Boolean isNewPhoto { get;set; }
        public Boolean isParentPhoto { get;set; }
        public Boolean isPlaceholder { get;set; }

        public PhotoWrapper(Trade_Marketing_Survey_Member_Photo__c p){
            photo = p;
            attach = new Attachment();
            isNewPhoto = true;
            isParentPhoto = false;
            isPlaceholder = true;
        }

        public PhotoWrapper(Trade_Marketing_Survey_Default_Photo__c p){
            photo = new Trade_Marketing_Survey_Member_Photo__c(Category__c = p.Category__c, Description__c = p.Description__c, Required__c = p.Required__c);
            attach = new Attachment();
            isNewPhoto = true;
            isParentPhoto = true;
            isPlaceholder = true;
        }
    }
}