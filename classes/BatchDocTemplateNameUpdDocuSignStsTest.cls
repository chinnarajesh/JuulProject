/*******************************************************************************************
* @Name         BatchDocTemplateNameUpdDocuSignStsTest
* @Author       Sushma Manickam
* @Date         09/01/2020
* @Group        
* @Description  Test Class for BatchDocTemplateNameUpdateDocuSignStatus          
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Sushma          09/01/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class BatchDocTemplateNameUpdDocuSignStsTest {
@TestSetup
    public static void TestSetup(){
        MSASalesDataProcessBatch__c MSACustomSetting = new MSASalesDataProcessBatch__c();
        MSACustomSetting.Name = 'MSASalesDataProcessBatch';
        MSACustomSetting.Country_List_for_DPD_Dates__c = 'CA';
        MSACustomSetting.AdminEmailIds__c = 'abc@gmail.com';
        insert MSACustomSetting;  
         
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Account businnessA = new Account();
        businnessA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        businnessA.Name = 'Test';
        businnessA.CurrencyIsoCode = 'USD';
        insert businnessA;
    }
    
    public static testMethod void OneTimeTestWithoutCD(){        
        
        Account a = [select id from Account LIMIT 1];
        dsfs__DocuSign_Status__c dss = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Completed',dsfs__Company__c = a.id);
        insert dss;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.IsMajorVersion = true;
        cv.VersionData = Blob.valueOf('Test Content');               
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        list<ContentVersion> CVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where id =: cv.id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=dss.id; 
        contentlink.ContentDocumentId=documents[0].Id;       
        contentlink.Visibility = 'AllUsers';
        insert contentlink; 
        BatchDocTemplateNameUpdateDocuSignStatus BatchCAA = new BatchDocTemplateNameUpdateDocuSignStatus();
        DataBase.executeBatch(BatchCAA, 20);
    } 
    
    public static testMethod void OneTimeTestWithCD(){  
      
        Account a = [select id from Account LIMIT 1];
        dsfs__DocuSign_Status__c dss = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Completed',dsfs__Company__c = a.id);
        insert dss;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document11';
        cv1.PathOnClient = 'TestDocument11.pdf';
        cv1.IsMajorVersion = true;
        cv1.VersionData = Blob.valueOf('Test Content11');               
        insert cv1;
        
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv1.id;
        cd.Name = cv1.Title;
        cd.PreferencesNotifyOnVisit = false;
        insert cd;
        
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        list<ContentVersion> CVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where id =: cv1.id];
        
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=dss.id; 
        contentlink1.ContentDocumentId=documents1[0].Id;       
        contentlink1.Visibility = 'AllUsers';
        insert contentlink1; 
        
        BatchDocTemplateNameUpdateDocuSignStatus BatchCAA = new BatchDocTemplateNameUpdateDocuSignStatus();
        DataBase.executeBatch(BatchCAA, 20);
    }
}