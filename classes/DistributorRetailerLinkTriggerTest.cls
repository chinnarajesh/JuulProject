@isTest
private class DistributorRetailerLinkTriggerTest{
    static testMethod void TestDistributorRetailerLinkTrigger(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        insert( new Trigger_Controller__c( Name = 'DistributorRetailerLinkTrigger', Enabled__c = true ));
         
        RecordType distroRecordType = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Distributor' AND sObjectType = 'Account' AND isActive = true LIMIT 1];
        Account distroAccount = new Account(Name='Test', RecordTypeId = distroRecordType.Id);
        insert(distroAccount);
         
        Account baseAccount = new Account(Name='Test');
        insert(baseAccount);

         
        insert(new Distributor_Retailer_Link__c(Distributor__c=distroAccount.Id, Retailer__c=baseAccount.Id, Link_Status__c='Active'));
         
        System.assertEquals([SELECT Count() FROM Distributor_Retailer_Link__c],1);
        Boolean failedInsert = false;
        try{
            insert(new Distributor_Retailer_Link__c(Distributor__c=distroAccount.Id, Retailer__c=baseAccount.Id, Link_Status__c='Active'));
        } catch(exception e){ //The insert above should fail
            failedInsert = true;
        }

        System.assertEquals([SELECT Count() FROM Distributor_Retailer_Link__c],1);
        System.assertEquals(true,failedInsert);
    }
}