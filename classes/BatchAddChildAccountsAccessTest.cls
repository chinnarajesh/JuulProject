/*******************************************************************************************
* @Name         BatchAddChildAccountsAccessTest
* @Author       Anil Male <Anil.Male@juul.com>
* @Date         12/17/2019
* @Group        Sales Ops
* @Description  Test Class for BatchAddChildAccountsAccessParentId, 
*               BatchAddChildAccountsAccessOwnerId and BatchAddChildAccountsAccessOnetime         
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Anil/Srikanth      12/17/2019         Initial Creation
*******************************************************************************************/

@isTest(SeeAllData = false)
public class BatchAddChildAccountsAccessTest{
@TestSetup
    public static void makeData(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;

      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
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
            AZHQaccRec.ShippingCountry='US';
            insert AZHQaccRec;
       Account TXHQaccRec = new Account();
            TXHQaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            TXHQaccRec.Name = 'Test TX HQ Account';
            TXHQaccRec.Type = 'HQ';
            TXHQaccRec.OwnerId = listUserToInsert[2].Id;
            TXHQaccRec.parentId = HQaccRec1.id;
            TXHQaccRec.ShippingCountry='US';
            insert TXHQaccRec;
        for(Integer i=0; i<3; i++){
            Account AZRaccRec = new Account();
            AZRaccRec.Name ='Test AZ Retail Account '+i;
            AZRaccRec.Type = 'HQ';
            AZRaccRec.OwnerId = listUserToInsert[1].Id;
            AZRaccRec.parentId = AZHQaccRec.id;
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
            TXRaccRec.ShippingCountry='US';
            TXRaccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(TXRaccRec);
        } 
        insert testAccDataToInsert;
       /**** End of creation of Account records *****/   
    } 
    public static testMethod void ParentIdTest1(){
        Account accRec = [Select Id,Name,ParentId, OwnerId from Account WHERE Name = 'Test AZ HQ Account' LIMIT 1];
        Account fetchAcc = [SELECT Id, ParentId from Account Where Name = 'Test TX HQ Account' LIMIT 1];
        fetchAcc.ParentId = null;
        update fetchAcc;
    }
    public static testMethod void ParentIdTest2(){
        Account accRec = [Select Id,Name,ParentId, OwnerId from Account WHERE Name = 'Test AZ HQ Account' LIMIT 1];
        Account fetchAcc = [SELECT Id, ParentId from Account Where Name = 'Test TX HQ Account' LIMIT 1];
        fetchAcc.ParentId = accRec.Id;
        update fetchAcc;
    }
    public static testMethod void OwnerIdTest1(){
        Account accRec = [Select Id,Name,ParentId, OwnerId from Account WHERE Name = 'Test AZ HQ Account' LIMIT 1];
        Account fetchAcc = [SELECT Id, ParentId from Account Where Name = 'Test TX HQ Account' LIMIT 1];
        fetchAcc.OwnerId = accRec.OwnerId;
        update fetchAcc;
    }   
    public static testMethod void OwnerIdTest2(){
        Account accRec = [Select Id,Name,ParentId, OwnerId from Account WHERE Name = 'Test AZ HQ Account' LIMIT 1];
        Account fetchAcc = [SELECT Id, ParentId from Account Where Name = 'Test TX Retail Account 1' LIMIT 1];
        fetchAcc.OwnerId = accRec.OwnerId;
        update fetchAcc;
    }
    public static testMethod void OwnerIdTest3(){
        Account accRec = [Select Id,Name,ParentId, OwnerId from Account WHERE Name = 'Test TX HQ Account' LIMIT 1];
        Account fetchAcc = [SELECT Id, ParentId from Account Where Name = 'Test AZ Retail Account 1' LIMIT 1];
        fetchAcc.OwnerId = accRec.OwnerId;
        update fetchAcc;
    } 
    public static testMethod void OneTimeTest(){
        Map<String, String> mapInputs =  new Map<String, String>();
        String overrideQuery = 'Name like \'Test%Account%\' ';
        // String overrideQuery = 'Id != null ';
        mapInputs.put('overrideQuery', overrideQuery);
        BatchAddChildAccountsAccessOnetime BatchCAA = new BatchAddChildAccountsAccessOnetime(mapInputs);
        DataBase.executeBatch(BatchCAA, 20);
    }
}