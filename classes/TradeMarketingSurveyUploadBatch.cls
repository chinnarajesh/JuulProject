public with sharing class TradeMarketingSurveyUploadBatch implements Database.Batchable<List<String>>,Database.AllowsCallouts, Database.Stateful {
    public List<List<String>> tmsData;
    public Trade_Marketing_Survey__c tradeMarketingSurvey;
    public List<String> memberDetailDescriptionsList;
    public List<String> memberDetailTypeList;
    public List<String> memberDetailNames;
    public Map<String,Trade_Marketing_Survey_Default_Question__c> defaultQuestionsMap;
    public Map<String,Trade_Marketing_Survey_Default_Photo__c> defaultPhotosMap;

    public String dataFormat; //Format of the Data i.e. Bars, etc.
    public String dataLocationType; //Location Type i.e. StaticResource, URL, Local
    public String dataLocation; //Static Resource Name or Location URL
    
    public TradeMarketingSurveyUploadBatch( String dlt, String dl, String dF ){
        this.dataFormat = dF;
        this.dataLocationType = dlt;
        this.dataLocation = dl;
    }
    
    //Only used in test class
    public TradeMarketingSurveyUploadBatch(List<List<String>> data, String dF ){
        this.tmsData = data;
        this.dataFormat = dF;
        this.dataLocationType = 'Local';
    }

    public Iterable<List<String>> start(Database.BatchableContext ctx) {
        System.debug('start');
        if(Test.isRunningTest()){
            
        }
        else if( this.dataLocationType == 'StaticResource' ){
            StaticResource resource = [SELECT Id, Body, Name FROM StaticResource Where Name = : dataLocation Limit 1];
            System.debug('body: ' + resource);           
            
            String body = resource.Body.toString();
            System.debug('body: ' + body);
            this.tmsData = CSVUtility.parseCSV(body, false);            
        } else if ( this.dataLocationType == 'URL' ){
            this.tmsData = getFileFromServer(dataLocation);
        }
        else if( this.dataLocationType == 'Local' ){
            
        }
        
        if( this.dataformat == 'Bars'){
            this.tradeMarketingSurvey = [SELECT Id,Name FROM Trade_Marketing_Survey__c WHERE Name = : this.tmsData[1][1] LIMIT 1];
            this.memberDetailDescriptionsList = this.tmsData[0];
            this.memberDetailNames = this.tmsData[3];
            this.memberDetailTypeList = this.tmsData[2];
            this.defaultQuestionsMap = new Map<String,Trade_Marketing_Survey_Default_Question__c>();
            
            for(Trade_Marketing_Survey_Default_Question__c defaultQuestion : [SELECT Id, Question__c,Name, Answer_Options__c, Required__c, Sort_Order__c, Category__c, Question_Answer_Type__c FROM Trade_Marketing_Survey_Default_Question__c WHERE Name IN : this.memberDetailNames]){
                defaultQuestionsMap.put(defaultQuestion.Name, defaultQuestion);
            }

            this.defaultPhotosMap = new Map<String,Trade_Marketing_Survey_Default_Photo__c>();

            for(Trade_Marketing_Survey_Default_Photo__c defaultPhoto : [SELECT Id, Name, Required__c,  Description__c, Category__c FROM Trade_Marketing_Survey_Default_Photo__c WHERE Name IN : this.memberDetailNames]){
                defaultPhotosMap.put(defaultPhoto.Name, defaultPhoto);
            }

            this.tmsData.remove(0);
            this.tmsData.remove(0);
            this.tmsData.remove(0);
            this.tmsData.remove(0);
        }
        return (Iterable<List<String>>)tmsData;
    }

    public void execute(Database.BatchableContext ctx, List<List<String>> tmsMemberData) {
        Map<String,Trade_Marketing_Survey_Member__c> tradeMarketingMembersMap = new Map<String,Trade_Marketing_Survey_Member__c>(); //Maps Account Name -> TMS Member     
        
        if( dataFormat == 'Bars' ){
            Map<String,Blob> urlBlobMap = new Map<String,Blob>();

            //Download URL images
            for(List<String> entryRow : tmsMemberData ){
                for(Integer i = 0; i < memberDetailDescriptionsList.size() ; i++){
                    if(memberDetailTypeList[i] == 'Photo'){    
                        System.debug('Running Index ' + i);
                        //Download Photo URL
                        Http h = new Http();
                        HttpRequest req = new HttpRequest();
                        string firstImageURL = entryRow[i];
                        firstImageURL = firstImageURL.replace(' ', '%20');
                        req.setEndpoint(firstImageURL);
                        req.setMethod('GET');
                        req.setHeader('Content-Type', 'image/jpeg');
                        req.setCompressed(true);
                        req.setTimeout(60000);
                                        
                        HttpResponse res = null;
                        blob image ;
                        if(!Test.isRunningTest() ){
                            if(firstImageURL!= null && firstImageURL != '' && firstImageURL != ' ' && firstImageURL != '%20'){
                                res = h.send(req);                            
                                string responseValue = '';
                                responseValue = res.getBody();
                                //system.debug('Response Body for File: ' + responseValue);
                                image = res.getBodyAsBlob();
                                urlBlobMap.put(entryRow[i],image);
                            }
                        }
                        else{
                            image = Blob.ValueOf('test');
                            urlBlobMap.put(entryRow[i],image);
                        }
                        
                    }
                }
            }

            //Gather Account Ids and find existing TMS Members
            Set<String> accountIds = new Set<String>();

            for(List<String> entryRow : tmsMemberData ){
                entryRow[0] = entryRow[0].left(15);
                accountIds.add(entryRow[0]);
            }

            for(Trade_Marketing_Survey_Member__c tmsMember :[SELECT Id, Account__c FROM Trade_Marketing_Survey_Member__c WHERE Account__c IN : accountIds AND Trade_Marketing_Survey__c = : tradeMarketingSurvey.Id]){
                tradeMarketingMembersMap.put(String.ValueOf(tmsMember.Account__c).left(15),tmsMember);
            }

            //Create Members if they don't exist
            for(String accountId : accountIds){
                if(!tradeMarketingMembersMap.containsKey(accountId)){
                    Trade_Marketing_Survey_Member__c tmsMember = new Trade_Marketing_Survey_Member__c();
                    tmsMember.Trade_Marketing_Survey__c = tradeMarketingSurvey.Id;
                    tmsMember.Account__c = accountId;
                    tmsMember.Status__c = 'Pending';
                    tmsMember.Status_Collateral__c = 'Incomplete';
                    tmsMember.Status_of_Survey_Visit__c = 'Pending';
                    tradeMarketingMembersMap.put(accountId, tmsMember);
                }
            }
            
            upsert(tradeMarketingMembersMap.values());

            List<Trade_Marketing_Survey_Member_Question__c> newMemberQuestions = new List<Trade_Marketing_Survey_Member_Question__c>();
            List<Trade_Marketing_Survey_Member_Photo__c> newMemberPhotos = new List<Trade_Marketing_Survey_Member_Photo__c>();
            Map<String,Map<String,Trade_Marketing_Survey_Member_Photo__c>> accountToPhotoMap = new Map<String,Map<String,Trade_Marketing_Survey_Member_Photo__c>>();

            //Create New Questions / Photos
            for(List<String> entryRow : tmsMemberData ){
                System.debug(entryRow);
                System.debug(entryRow.size());
                Id tmsMemberId = tradeMarketingMembersMap.get(entryRow[0]).Id;

                for(Integer i = 0; i < memberDetailDescriptionsList.size() ; i++){
                    if(memberDetailTypeList[i] == 'Question'){
                        Trade_Marketing_Survey_Member_Question__c newQuestion = new Trade_Marketing_Survey_Member_Question__c();
                        newQuestion.Trade_Marketing_Survey_Member__c = tmsMemberId;
                        newQuestion.Answer__c = entryRow[i].endsWith(',') ? entryRow[i].substringBeforeLast(',') : entryRow[i];

                        Trade_Marketing_Survey_Default_Question__c defaultQuestion = defaultQuestionsMap.get(memberDetailNames[i]);
                        newQuestion.Question_Answer_Type__c = defaultQuestion.Question_Answer_Type__c;
                        newQuestion.Answer_Options__c = defaultQuestion.Answer_Options__c;
                        newQuestion.Category__c = defaultQuestion.Category__c;
                        newQuestion.Question__c = defaultQuestion.Question__c;
                        newQuestion.Required__c = defaultQuestion.Required__c;
                        newQuestion.Sort_Order__c = defaultQuestion.Sort_Order__c;

                        newMemberQuestions.add(newQuestion);
                    }
                    else if(memberDetailTypeList[i] == 'Photo'){
                        Trade_Marketing_Survey_Member_Photo__c newPhoto = new Trade_Marketing_Survey_Member_Photo__c();
                        newPhoto.Trade_Marketing_Survey_Member__c = tmsMemberId;

                        Trade_Marketing_Survey_Default_Photo__c defaultPhoto = defaultPhotosMap.get(memberDetailNames[i]);
                        newPhoto.Description__c = defaultPhoto.Description__c;
                        newPhoto.Category__c = defaultPhoto.Category__c;
                        newPhoto.Required__c = defaultPhoto.Required__c;

                        newMemberPhotos.add(newPhoto);
                        if(!accountToPhotoMap.containsKey(entryRow[0]))
                            accountToPhotoMap.put(entryRow[0],new Map<String,Trade_Marketing_Survey_Member_Photo__c>());

                        accountToPhotoMap.get(entryRow[0]).put(memberDetailNames[i],newPhoto);
                    }
                }

            }

            insert(newMemberQuestions);
            insert(newMemberPhotos);
        
            List<Attachment> newAttachments = new List<Attachment>();

            //Add Photo Attachments
            for(List<String> entryRow : tmsMemberData ){
                Id tmsMemberId = tradeMarketingMembersMap.get(entryRow[0]).Id;

                for(Integer i = 0; i < memberDetailDescriptionsList.size() ; i++){
                    if(memberDetailTypeList[i] == 'Photo'){
                        if( urlBlobMap.get(entryRow[i]) != null){
                            Attachment newAttachment = new Attachment();
                            newAttachment.ParentId = accountToPhotoMap.get(entryRow[0]).get(memberDetailNames[i]).Id;
                            newAttachment.Body = urlBlobMap.get(entryRow[i]);
                            newAttachment.Name = tmsMemberId + ' - ' + i;
                            newAttachments.add(newAttachment);
                        }
                    }
                }
            }

            insert(newAttachments);
            
        }
     
    }
    
    public void finish(Database.BatchableContext ctx) {

    }
    
    public static List<List<String>> getFileFromServer(String dataLocation){

        return new List<List<String>>();
    }

}