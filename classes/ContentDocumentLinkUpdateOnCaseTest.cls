/**********************************************************************/
/* Developer Name: Pooja Gite
/* Class Name: ContentDocumentLinkUpdateOnCase                        */
/* Description: Code coverage for ContentDocumentLinkUpdateOnCase.*/
/**********************************************************************/
@isTest
public class ContentDocumentLinkUpdateOnCaseTest {
    @testSetup
    public static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController); 
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='CaseTrigger',Enabled__c=true);
        insert(triggerController2);
    }
    
     static testmethod void contentDocLinktestmethod1(){
       Test.startTest();
         Id EACCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EAC Certification').getRecordTypeId();
         Account acc =new Account();
         acc.Name='Demo1';
         acc.Type = 'HQ';
         insert acc ; 
         
        Account accA =new Account(Name='Demo');
		accA.ParentId  = acc.Id;       
        insert accA ; 
        
        ContentVersion content=new ContentVersion(
        Title = 'Penguins',
  		PathOnClient = 'Penguins.jpg',
  		VersionData = Blob.valueOf('Test Content'),
 		IsMajorVersion = true,
       	origin = 'H');
        insert content;
         
        ContentDocumentLink contentlink=new ContentDocumentLink();
       	contentlink.LinkedEntityId=accA.ParentId;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
         
        List<Case> listCase = new List<Case>();
        Case c = new Case();
        c.accountId = accA.Id;
        c.RecordTypeId = EACCertCaseRecordTypeId;
        c.Attachment_Name__c = content.Title;
        listCase.add(c);
         
        ContentDocumentLinkUpdateOnCase.ContentDocumentLinkUpdateOnCases(listCase);

        Test.stopTest();
    }
    
    static testmethod void contentDocLinktestmethod2(){
       Test.startTest();
         Id EACCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EAC Certification').getRecordTypeId();
         Account acc =new Account();
         acc.Name='Demo1';
         acc.Type = 'HQ';
         insert acc ; 
         
        Account accA =new Account(Name='Demo');
		accA.ParentId  = acc.Id;       
        insert accA ; 
        
        
         
        List<Case> listCase = new List<Case>();
        Case c = new Case();
        c.accountId = accA.Id;
        c.RecordTypeId = EACCertCaseRecordTypeId;
        listCase.add(c);
         
        ContentDocumentLinkUpdateOnCase.ContentDocumentLinkUpdateOnCases(listCase);

        Test.stopTest();
    }
}