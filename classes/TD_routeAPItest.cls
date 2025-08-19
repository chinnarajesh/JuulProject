@istest
public class TD_routeAPItest {
        public static LIST<Account> alist;
    
    static testMethod void testDoPost(){
        ID personType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' and id !=:personType LIMIT 1];
        Account a = new Account();
        a.name = 'Test Account';
        a.Phone = '+15555555555';
        a.RecordTypeID = rt.id;
        insert(a);
        system.debug(a);
        
        Account pa = new Account();
        pa.FirstName = 'Person';
        pa.LastName = 'account';
        pa.RecordTypeID = personType;
        pa.Phone = '+15555555556';
        insert(pa);
        system.debug(pa);

        Contact c= new Contact();
        c.AccountId=a.id;
        c.FirstName ='Test';
        c.LastName ='Contact';
        c.Phone = '+15555555557';
        c.MobilePhone = '+15555555557';
        c.HomePhone = '+15555555557';
        c.OtherPhone = '+15555555557';
        insert(c);
        system.debug(c);
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/routeAPIs'; 
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
         
        routeAPIController.getAccount('+15555555555');
        routeAPIController.getAccount('+15555555556');
        routeAPIController.getAccount('+15555555557');
        Test.stopTest();
}
}