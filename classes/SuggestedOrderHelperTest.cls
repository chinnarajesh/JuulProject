/*******************************************************************************************
* @Name         SuggestedOrderHelperTest
* @Author       Sushma Manickam
* @Date         07/24/2020
* @Description  Test Class for SuggestedOrderHelper 
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0            Sushma          07/24/2020         Initial Creation
*******************************************************************************************/
@isTest
private class SuggestedOrderHelperTest {
    
    static testMethod void UpdateDRL() {
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Account retailer = new Account(Name='TestRetailer',
                                       Type = 'HQ',            
                                       RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId()
                                      );
        insert retailer;
        
        Account distributor = new Account(Name='TestDistributor',
                                          Type = 'HQ',
                                          RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId()
                                         );
        insert distributor;
        
        Distributor_Retailer_Link__c DRL = new Distributor_Retailer_Link__c(Distributor__c = distributor.id, Retailer__c = retailer.id, Link_Status__c='Active');
        insert DRL;
        
        DRL.External_ID__c = DRL.Distributor__c +'_'+ DRL.Retailer__c;
        update DRL;
        
        Suggested_Order__c so = new Suggested_Order__c(Customer__c = retailer.id,Distributor__c = distributor.id, Suggested_Order_Date__c = system.today());
        insert so;
    }
}