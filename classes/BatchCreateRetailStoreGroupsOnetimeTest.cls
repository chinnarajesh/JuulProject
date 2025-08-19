/*******************************************************************************************
* @Name         BatchCreateRetailStoreGroupsOnetimeTest
* @Author       Srikanth Bumhyavaram
* @Date         06/27/2020
* @Group        Sales Ops
* @Description  Test Class for BatchCreateRetailStoreGroupsOnetime          
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Srikanth          06/27/2020         Initial Creation
*******************************************************************************************/
@isTest(SeeAllData = false)
public class BatchCreateRetailStoreGroupsOnetimeTest{
@TestSetup
    public static void makeData(){
      MSASalesDataProcessBatch__c MSACustomSetting = new MSASalesDataProcessBatch__c();
      MSACustomSetting.Name = 'MSASalesDataProcessBatch';
      MSACustomSetting.Country_List_for_DPD_Dates__c = 'CA';
      MSACustomSetting.AdminEmailIds__c = 'abc@gmail.com';
      insert MSACustomSetting;

      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=false);
      insert(triggerController);   
      List<User> listUserToInsert = new List<User>();
      for(Integer i=0; i<5; i++){
        User u = new User(
            ProfileId = [Select Id from Profile Where Name='System Administrator'].id,
            LastName = 'last'+i,
            Email = 'abc+'+i+'@gmail.com',
            Username = 'abc'+i+'@gJuul456.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias'+i,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
      listUserToInsert.add(u);
      }
      insert listUserToInsert;
       /**** Creation of Account records *****/ 
       List<Account> testAccDataToInsert = new List<Account>();
        Account HQaccRec1 = new Account();
            HQaccRec1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            HQaccRec1.Name = 'Test National HQ Account';
            HQaccRec1.Type = 'HQ';
            HQaccRec1.OwnerId = listUserToInsert[0].Id;
            HQaccRec1.ShippingCountry='US';
            insert HQaccRec1;
        Account AZHQaccRec = new Account();
            AZHQaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            AZHQaccRec.Name = 'Test AZ HQ Account';
            AZHQaccRec.Type = 'HQ';
            AZHQaccRec.OwnerId = listUserToInsert[1].Id;
            AZHQaccRec.parentId = HQaccRec1.id;
            AZHQaccRec.Ultimate_Parent_Account__c  = HQaccRec1.id;
            AZHQaccRec.ShippingCountry='US';
            insert AZHQaccRec;
       Account TXHQaccRec = new Account();
            TXHQaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            TXHQaccRec.Name = 'Test TX HQ Account';
            TXHQaccRec.Type = 'HQ';
            TXHQaccRec.OwnerId = listUserToInsert[2].Id;
            TXHQaccRec.parentId = HQaccRec1.id;
            TXHQaccRec.Ultimate_Parent_Account__c  = HQaccRec1.id;
            TXHQaccRec.ShippingCountry='US';
            insert TXHQaccRec;
        for(Integer i=0; i<3; i++){
            Account AZRaccRec = new Account();
            AZRaccRec.Name ='Test AZ Retail Account '+i;
            AZRaccRec.Type = 'Chain';
            AZRaccRec.OwnerId = listUserToInsert[1].Id;
            AZRaccRec.parentId = AZHQaccRec.id;
            AZRaccRec.Ultimate_Parent_Account__c  = HQaccRec1.id;
            AZRaccRec.ShippingCountry='US';
            AZRaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(AZRaccRec);
        }
        for(Integer i=0; i<3; i++){
            Account TXRaccRec = new Account();
            TXRaccRec.Name ='Test TX Retail Account '+i;
            TXRaccRec.Type = 'HQ';
            TXRaccRec.OwnerId = listUserToInsert[4].Id;
            TXRaccRec.parentId = TXHQaccRec.id;
            TXRaccRec.Ultimate_Parent_Account__c  = HQaccRec1.id;
            TXRaccRec.ShippingCountry='US';
            TXRaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(TXRaccRec);
        } 
        insert testAccDataToInsert;
       /**** End of creation of Account records *****/   
    } 
    public static testMethod void OneTimeTest(){
        
        String UltimateAccountId = [select Id from Account where Name = 'Test National HQ Account' limit 1].Id;
        BatchCreateRetailStoreGroupsOnetime BatchCAA = new BatchCreateRetailStoreGroupsOnetime(UltimateAccountId);
        DataBase.executeBatch(BatchCAA, 20);
    }
}