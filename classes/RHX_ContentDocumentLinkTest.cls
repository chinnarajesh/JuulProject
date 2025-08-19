@isTest(SeeAllData=false)
public class RHX_ContentDocumentLinkTest {

          static testmethod void makedata()
    {
            Test.startTest();
            ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
        
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
             
        Test.stopTest();
        
    }
}