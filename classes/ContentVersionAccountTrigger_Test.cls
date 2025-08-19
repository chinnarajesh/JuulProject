@isTest
public class ContentVersionAccountTrigger_Test {

          static testmethod void testdata()
    {
            Test.startTest();
        
        Account Acc =new Account();
        Acc.Name='Account';
        insert Acc;
        
         Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        //ContentDocument cd = new contentDocument();
        
     
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient ='test';
        cv.title = 'test content trigger';  
        cv.VersionData =beforeblob;   
        cv.Plan_On_Page__c=true;          
        //cv.Active__c=false;       
        insert cv; 
       
             
        
       list <contentdocument> CD=[select id,LatestPublishedVersionId from contentdocument where LatestPublishedVersionId =: cv.id];
        
       
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=Acc.id;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId=CD[0].id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
         checkRecursivetrigger.resetRunOnceFlag(); 
        
        cv.Active__c=true;
        update cv;
        
        /*  ContentVersion cv1 = new ContentVersion();
        cv1.PathOnClient ='test';
        cv1.title = 'test content trigger';  
        cv1.VersionData =beforeblob;   
        cv1.Plan_On_Page__c=true;          
        cv1.Active__c=false;       
        insert cv1; 
          list <contentdocument> CD1=[select id,LatestPublishedVersionId from contentdocument where LatestPublishedVersionId =: cv1.id];
        
       
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=Acc.id;
        contentlink1.ShareType= 'I';
        contentlink1.ContentDocumentId=CD1[0].id;
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
       cv1.Active__c=true;
        update cv1;*/
             
        Test.stopTest();
        
    }
}