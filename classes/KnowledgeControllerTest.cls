/*******************************************************************************************
 * @Name         KnowledgeControllerTest
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
@IsTest
private class KnowledgeControllerTest {

    @IsTest
    static void testFindArticles() {

        KnowledgeController.findArticleByDataCategory('en_US', 'Ireland__c', null);
        KnowledgeController.findArticleByDataCategory('en_US', 'Ireland__c', 'Juul_Device_Basics__c');

        //insert an article
        IKB_Master__kav articleObj = new IKB_Master__kav();
        articleObj.Title = 'test Title';
        articleObj.UrlName = 'test';
        articleObj.Language = 'en_US';
        insert articleObj;

        KnowledgeController.getArticleURL(articleObj.Id);
    }
}