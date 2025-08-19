/*******************************************************************************************
* @Name         Juul_SendEmailTest
* @Author       Mohit Singh <Mohit.Singh@juul.com>
* @Date         03/30/2020
* @Group        Customer Service
* @Description  Test class for SendEmail class
*******************************************************************************************/
@istest
Global class Juul_SendEmailTest {
    @isTest
    static void SendEmailTest() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            //CREATE EMAIL TEMPLATE
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'unique_name_testclasstest';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;        
            //CREATE TEST DATA
            Account acc= new Account(
                Name='Test Name',
                Phone = '1234',
                FAX = '123',
                Billingstreet = 'test'
            );
            insert acc;      
            
            Contact con= new Contact(
                FirstName='Test Name',
                LastName = 'test',
                AccountId = acc.Id,
                MobilePhone = '1234',
                email = 'test@test.com'
            );
            insert con; 
            
            ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
            
            string subjecttouse = 'subject';
            //CREATE SINGLE EMAIL
            Juul_SendEmail.InvokeSendEmail request = new Juul_SendEmail.InvokeSendEmail();
            request.ToAddresses ='test@test.com';
            request.ContactorLeadID = con.Id;
            request.Subject = subjecttouse;
            request.plainTextBody = 'body';
            request.EmailTemplateName ='US EN - 2nd Attempt';
            request.OrgWideEmailAddress = 'test@test.com';
            request.bccAddresses = 'test@test.com';
            request.ccAddresses = 'test@test.com';
            request.ContentVersionId=contentVersion_1.id;
            List<Juul_SendEmail.InvokeSendEmail> requests = new List<Juul_SendEmail.InvokeSendEmail>{ request };
                Test.startTest();    
            Juul_SendEmail.Sendemail( requests );
            Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();  
            system.assertEquals(1, invocations, 'An email should be sent');
        }
    }
}