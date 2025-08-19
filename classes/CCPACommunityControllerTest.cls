@isTest
public class CCPACommunityControllerTest {
    /*******************************************************************************************
* @Name         CCPACommunityControllerTest
* @Author       Mohit Singh <Mohit.Singh@juul.com>
* @Date         04/23/2020
* @Group        Service Ops
* @Description  This Class provides coverage CCPACommunityController Apex Class
*******************************************************************************************/
    static testMethod void CCPACommunityControllerTestMethod(){
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        
        Juul_CCPAComSetting__c settings = Juul_CCPAComSetting__c.getOrgDefaults();
        upsert settings custSettings__c.Id;
        
        CCPACommunityController USCom = new CCPACommunityController();
        CCPACommunityController.getEndpointData();
        case caseparam = new case(web_first_name__c = 'Test',web_last_name__c ='LastTest',
                                  suppliedEmail ='test@test.com', suppliedPhone='123-456-7890');
        case caseparam1 = new case(web_first_name__c = 'Test',web_last_name__c ='LastTest',
                                   suppliedEmail ='test@test.com', suppliedPhone='123-456-7890');
        case caseparam2 = new case(web_first_name__c = 'Test',web_last_name__c ='LastTest',
                                   suppliedEmail ='test@test.com', suppliedPhone='123-456-7890');
        Test.startTest();
        Case createdCase = CCPACommunityController.createCaseForDataAccess(caseparam,'Data Access');
        Case createdCase1 = CCPACommunityController.createCaseForDataAccess(caseparam1,'Account Deletion');
        Case createdCase2 = CCPACommunityController.createCaseForDataAccess(caseparam2,'Do Not Sell Info');
        Test.stopTest();
    }
}