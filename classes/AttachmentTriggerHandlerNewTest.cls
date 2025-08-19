@isTest
public with sharing class AttachmentTriggerHandlerNewTest {
    @isTest static void testAttachmentDataHandler() {
        Case testCase = new Case(Status = 'New');
        insert testCase;
        Test.startTest();
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        Contentversion cont = new Contentversion();
        cont.Title='sample title';
        cont.PathOnClient='SampleTitle.jpg';
        cont.VersionData=bodyBlob;
        cont.origin = 'H';
        cont.IsMajorVersion = true;
        insert cont;
        ContentDocumentLink contDocmnt = new ContentDocumentLink();
        contDocmnt.ContentDocumentId=[SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cont.Id].ContentDocumentId;
        contDocmnt.LinkedEntityId = testCase.Id;
        contDocmnt.ShareType='V';
        insert contDocmnt;
        Test.stopTest();
     
    }
}