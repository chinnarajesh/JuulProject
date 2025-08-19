/*******************************************************************************************
* @Name         BatchPlanogramFileImageURLUpdateTest
* @Author       Sushma Manickam
* @Date         07/01/2020
* @Group        
* @Description  Test Class for BatchPlanogramFileImageURLUpdateOnetime          
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Sushma          07/01/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class BatchPlanogramFileImageURLUpdateTest {
    @TestSetup
    public static void TestSetup(){
        MSASalesDataProcessBatch__c MSACustomSetting = new MSASalesDataProcessBatch__c();
        MSACustomSetting.Name = 'MSASalesDataProcessBatch';
        MSACustomSetting.Country_List_for_DPD_Dates__c = 'CA';
        MSACustomSetting.AdminEmailIds__c = 'abc@gmail.com';
        insert MSACustomSetting;        
    }
    
    public static testMethod void OneTimeTestWithoutCD(){        
        POGs__c p = new POGs__c(Name = 'CK Corp Q2 2020 3ft STD Test');
        insert p;
        
        Planogram__c POG = new Planogram__c(Name_of_POG__c= p.id);
        insert POG;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.IsMajorVersion = true;
        cv.VersionData = Blob.valueOf('Test Content');               
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        list<ContentVersion> CVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where id =: cv.id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=POG.id; 
        contentlink.ContentDocumentId=documents[0].Id;       
        contentlink.Visibility = 'AllUsers';
        insert contentlink; 
        BatchPlanogramFileImageURLUpdateOnetime BatchCAA = new BatchPlanogramFileImageURLUpdateOnetime();
        DataBase.executeBatch(BatchCAA, 20);
    } 
    
    public static testMethod void OneTimeTestWithCD(){  
        POGs__c p1 = new POGs__c(Name = 'CK Corp Q2 2020 3ft STD Test1');
        insert p1;
        
        Planogram__c POG1 = new Planogram__c(Name_of_POG__c= p1.id);
        insert POG1;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document11';
        cv1.PathOnClient = 'TestDocument11.pdf';
        cv1.IsMajorVersion = true;
        cv1.VersionData = Blob.valueOf('Test Content11');               
        insert cv1;
        
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv1.id;
        cd.Name = cv1.Title+'.pdf';
        cd.PreferencesNotifyOnVisit = false;
        insert cd;
        
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        list<ContentVersion> CVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where id =: cv1.id];
        
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=POG1.id; 
        contentlink1.ContentDocumentId=documents1[0].Id;       
        contentlink1.Visibility = 'AllUsers';
        insert contentlink1; 
        
        BatchPlanogramFileImageURLUpdateOnetime BatchCAA = new BatchPlanogramFileImageURLUpdateOnetime();
        DataBase.executeBatch(BatchCAA, 20);
    }
}