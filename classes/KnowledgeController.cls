/*******************************************************************************************
 * @Name         KnowledgeController
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         12/05/2019
 * @Group        Customer Service
 * @Description  This service returns knowledge articles from the server
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/10/2019          Initial Creation
*******************************************************************************************/

public with sharing class KnowledgeController {

    /**************************************************************************************
     * @Description this method returns knowledge articles by topic ID
     * @Param   language, region and csf name from the client
     * @Return  List of knowledge articles
     **************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<IKB_Master__kav> findArticleByDataCategory(String language, String region, String csf) {
        try {
            System.debug('csf-> ' + csf);
            String queryString;
            //WITH DATA CATEGORY doesn't support bind variables so build the query string dynamically
            if (String.isNotBlank(csf)) {
                queryString = 'SELECT Summary, Title FROM IKB_Master__kav WHERE PublishStatus = \'Online\''
                        + ' AND Language=\'' + language + '\'' + ' AND RecordTypeId IN (Select Id from RecordType WHERE Name = \'FAQ\')'
                        + ' WITH DATA CATEGORY FAQ__c AT ' + region + ' AND CSF__c AT '
                        + csf + ' ORDER BY ArticleTotalViewCount DESC LIMIT 5';
                System.debug('query with CSF-> ' + queryString);
            } else {
                queryString = 'SELECT Summary, Title FROM IKB_Master__kav WHERE PublishStatus = \'Online\''
                        + ' AND Language=\'' + language + '\'' + ' AND RecordTypeId IN (Select Id from RecordType WHERE Name = \'FAQ\')'
                        + ' WITH DATA CATEGORY FAQ__c AT ' + region + ' ORDER BY ArticleTotalViewCount DESC LIMIT 5';
                System.debug('query without CSF-> ' + queryString);
            }
            return Database.query(queryString);
        } catch (Exception e) {
            System.debug('error from findArticleByDataCategory-> ' + e.getMessage());
        }
        return null;
    }

    /**************************************************************************************
     * @Description this method returns the public URL name of the knowledge article by ID
     * @Param   article salesforce ID
     * @Return  URL of the knowledge article
     **************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getArticleURL(String articleId) {
        if (String.isNotBlank(articleId)) {
            IKB_Master__kav articleObj = [SELECT UrlName, Language FROM IKB_Master__kav WHERE Id = :articleId LIMIT 1];
            if (articleObj != null) {
                if (String.isNotBlank(articleObj.UrlName) && String.isNotBlank(articleObj.Language)) {
                    String finalUrl = Site.getBaseRequestUrl() + '/article/' + articleObj.UrlName + '?language=' + articleObj.Language;
                    return finalUrl;
                } else return null;
            }

        }
        return null;
    }
}