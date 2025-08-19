@isTest(SEEALLDATA =False) 
private class UtilityBatchTest {
    static testMethod void testSalesOrderDeletion(){
    ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        Account a = new Account(Name ='Test');
        insert(a);
        insert(new SalesOrder__c(Customer__c = a.Id));
        UtilityBatch con = new UtilityBatch('Mode');
        Test.startTest();
            database.executeBatch(new UtilityBatch('Delete Sales Orders', 'SELECT id FROM SalesOrder__c'));
        Test.stopTest();
    }
}