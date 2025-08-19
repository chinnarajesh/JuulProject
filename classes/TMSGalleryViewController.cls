public class TMSGalleryViewController {
    public static String ACCOUNT_NAME = 'Account Name';
    public static String RECORD_NAME = 'Record Name';
    public static String ITC = 'Independent Trade Class';
    public static String CTC = 'Chain Trade Class';
    public static String REVENUE = 'Revenue';
    public static String DELIMITER = '^^^^^';
    public Trade_Marketing_Survey_Member__c dummyMember { get;set; }
    
    public TMSGalleryViewController(){
        dummyMember = new Trade_Marketing_Survey_Member__c(); 
    }

    @RemoteAction @ReadOnly
    public static Map<String, Object> getViewObject(String TMSName){
        Map<String, Map<String, TMSPhotoWrapper>> viewObject = new Map<String, Map<String, TMSPhotoWrapper>>();
        Map<String, Map<String, String>> extraCols = new Map<String, Map<String, String>>();
        System.debug(TMSName);
        Map<Id, Trade_Marketing_Survey_Member__c> TMSMMap = new Map<Id, Trade_Marketing_Survey_Member__c>([SELECT Id, Name, Account__r.JUUL_Revenue__c, Account__r.Name, Account__r.RecordType.Name, Account__r.Independent_Trade_Class__c, Account__r.Chain_Trade_Class__c FROM Trade_Marketing_Survey_Member__c WHERE Trade_Marketing_Survey__r.Name = :TMSName]);
        for(Id TMSMId : TMSMMap.keySet()){
            Trade_Marketing_Survey_Member__c member = TMSMMap.get(TMSMId);
            extraCols.put(member.Id, new Map<String, String>());
            extraCols.get(member.Id).put(ACCOUNT_NAME, member.Account__r.Name);
            extraCols.get(member.Id).put(RECORD_NAME, member.Account__r.RecordType.Name);
            extraCols.get(member.Id).put(ITC, member.Account__r.Independent_Trade_Class__c);
            extraCols.get(member.Id).put(CTC, member.Account__r.Chain_Trade_Class__c);
            extraCols.get(member.Id).put(REVENUE, String.valueOf(member.Account__r.JUUL_Revenue__c));
            if(viewObject.get(member.Id) == null)
                viewObject.put(member.Id, new Map<String, TMSPhotoWrapper>());
        }
        System.debug(TMSMMap);
        for(Trade_Marketing_Survey_Default_Photo__c TMSDP : [SELECT Id, Category__c, Description__c FROM Trade_Marketing_Survey_Default_Photo__c WHERE Trade_Marketing_Survey__r.Name = :TMSName ORDER BY Category__c, Description__c]){
            for(String viewKey : viewObject.keySet()){
                viewObject.get(viewKey).put(TMSDP.Category__c + DELIMITER + TMSDP.Description__c, new TMSPhotoWrapper(TMSDP));
            }
        }
        Map<Id, Trade_Marketing_Survey_Member_Photo__c> TMSMPhotosMap = new Map<Id, Trade_Marketing_Survey_Member_Photo__c>([SELECT Id, Category__c, Description__c, Trade_Marketing_Survey_Member__c FROM Trade_Marketing_Survey_Member_Photo__c WHERE Trade_Marketing_Survey_Member__c IN :TMSMMap.keySet()]);
        System.debug(TMSMPhotosMap);
        for(Attachment a : [SELECT Id, ParentId FROM Attachment WHERE ParentId IN :TMSMPhotosMap.keySet()]){
            Trade_Marketing_Survey_Member_Photo__c photo = TMSMPhotosMap.get(a.ParentId);
            Trade_Marketing_Survey_Member__c member = TMSMMap.get(photo.Trade_Marketing_Survey_Member__c);
            if(viewObject.get(member.Id) == null)
                viewObject.put(member.Id, new Map<String, TMSPhotoWrapper>());
            viewObject.get(member.Id).get(photo.Category__c + DELIMITER + photo.Description__c).attachmentId = a.Id;
        }
        return new Map<String, Object> {'extraCols' => extraCols,
                                        'viewObject' => viewObject,
                                        'categories' => Trade_Marketing_Survey_Member_Photo__c.Category__c.getDescribe().getPicklistValues(),
                                        'recordTypes' => [SELECT Name FROM RecordType WHERE SobjectType = 'Account'],
                                        'itcs' => Account.Independent_Trade_Class__c.getDescribe().getPicklistValues(),
                                        'ctcs' => Account.Chain_Trade_Class__c.getDescribe().getPicklistValues()};
    }

    public class TMSPhotoWrapper{
        // public String name { get;set; }
        // public String accountName { get;set; }
        public Id attachmentId { get;set; }
        // public Trade_Marketing_Survey_Member_Photo__c TMSMPhoto { get;set; }
        public String category { get;set; }
        public String description { get;set; }
        public TMSPhotoWrapper(Trade_Marketing_Survey_Member_Photo__c TMSMP, Attachment a){
            // name = member.Name;
            // accountName = member.Account__r.Name;
            attachmentId = a.Id;
            // TMSMPhoto = TMSMP;
            category = TMSMP.Category__c;
            description = TMSMP.Description__c;
        }

        public TMSPhotoWrapper(Trade_Marketing_Survey_Default_Photo__c TMSDP){
            // name = member.Name;
            // accountName = member.Account__r.Name;
            // attachmentId = a.Id;
            // TMSMPhoto = TMSMP;
            category = TMSDP.Category__c;
            description = TMSDP.Description__c;
        }
    }
}