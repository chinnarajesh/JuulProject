/*******************************************************************************************
* @Name         SalesOrderController
* @Author       Pooja Gite <pooja.gite@juul.com>
* @Description  A method to get list of Sales Order data as per filter criteria.
*******************************************************************************************/
public class SalesOrderController {
    @AuraEnabled(Cacheable = true)
    public static List<salesOrder__c> getSalesOrder(String accId) 
    {
        return [select id,Name, Customer_PO_Number__c, Order_Date__c,orderTotal__c FROM salesOrder__c where orderType__c = 'BO' AND Customer__c=:accId ORDER BY Order_Date__c DESC limit 10];
    }

}