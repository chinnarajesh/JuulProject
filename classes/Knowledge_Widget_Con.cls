public with sharing class Knowledge_Widget_Con {

    private static final String QUERY_TEMPLATE = 'SELECT {0} FROM {1} WHERE Language =\'en_US\' AND PublishStatus =\'Online\'';

    public Knowledge_Widget_Con(ApexPages.StandardController controller) {}

    @AuraEnabled
    @RemoteAction
    public static List<Object> getArticles(){
        List<SObject> sobjs = new List<SObject>();
        List<Schema.SObjectType> sTypes = getAllArticleObjects();
        for(Schema.SObjectType stype : sTypes){
            String qry = 'SELECT '+ String.join(getFields(sType),',')
            + ',(SELECT Id, DataCategoryName FROM DataCategorySelections) FROM '+sType
            + ' WHERE Language =\'en_US\' AND PublishStatus =\'Online\'';
            sobjs.addAll(Database.query(qry));
        }
        return sobjs;
    }
    
	@AuraEnabled
    @RemoteAction
    public static Case getCase(String caseId){
        return [SELECT Id,Subject,Description FROM Case WHERE Id =:caseId LIMIT 1];   
    }
    
    @AuraEnabled
    @RemoteAction
    public static Object getDataCategories(){
        return JSON.deserializeUntyped(JSON.serialize(DescribeDataCategoryGroupStructures.getDescribeDataCategoryGroupStructureResults()));
    }

    @AuraEnabled
    @RemoteAction
    public static Object getArticleType(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<String,String> m = new Map<String, String>{};
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            Schema.DescribeSObjectResult dr = objectType.getDescribe();
            if (key.endsWith('__kav') && dr.isAccessible()) {
               m.put(dr.getLabel(), dr.getName().toLowerCase());
            }
        }
        return m;
    }


    private static List<String> getFields(SObjectType stype){
        Map<String,Schema.SObjectField> mfields = stype.getDescribe().fields.getMap();
        return new List<String> (mfields.keySet());
    }

    private static List<SObjectType> getAllArticleObjects(){
        List<Schema.SObjectType> sTypes = new List<Schema.SObjectType>();
        for(Schema.SObjectType typ : Schema.getGlobalDescribe().values()){
            Schema.DescribeSObjectResult dr = typ.getDescribe();
            if(String.valueOf(typ).endsWith('__kav') && dr.isAccessible())
                sTypes.add(typ);
        }
        return sTypes;
    }

    @AuraEnabled
    @RemoteAction
    public static SObject getArticleDetail(String apiName,String publishStatus,String articleId){
        String queryStr = 'SELECT Id,KnowledgeArticleId,Title,ArticleNumber,FirstPublishedDate,ValidationStatus,LastPublishedDate,' + (apiName.equalsIgnoreCase('How_To_Guide__kav') ? 'KB_Description__c' : 'Body__c') +
        ' FROM '+ apiName +
        ' WHERE PublishStatus =' + '\''+publishStatus+'\'' + ' AND KnowledgeArticleId =' + '\''+articleId+'\''  ;
        return Database.query(queryStr);
    }

	@AuraEnabled
    @RemoteAction
    public static List<CaseArticle> getAllCaseArticle(List<String> articleIds,String caseId){
        return [
            SELECT Id,CaseId,KnowledgeArticleId
            FROM CaseArticle
            WHERE KnowledgeArticleId IN :articleIds AND CaseId =:caseId
        ];
    }

    @AuraEnabled
    @RemoteAction
    public static CaseArticle insertCaseArticle(String articleId , String caseId){
        CaseArticle article = new CaseArticle();
        article.CaseId = caseId;
        article.KnowledgeArticleId = articleId;
        if(!Test.isRunningTest())
            insert article ;
        return article ;
    }

    @AuraEnabled
    @RemoteAction
    public static Boolean deleteCaseArticle(String caseArticleId){
        Boolean isSuccess = false;
        CaseArticle article = new CaseArticle(Id = caseArticleId);
        if(!Test.isRunningTest()){
            delete article;
            isSuccess = true ;
        }
        return isSuccess ;
    }

}