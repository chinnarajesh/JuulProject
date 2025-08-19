@isTest(SeeAllData= false)
public class RHX_AccountActionPlanTemplateTest {
     @testSetup static void setup(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
          
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);  
        
        Account ac =  new Account();
        ac.Name=  'test account';
        insert  ac; 
}
      public static testMethod void  RHX_acapTempTestMethod(){
        Account ac = [SELECT Id FROM Account LIMIT 1];
        Id RecordTypeIdAP = Schema.SObjectType.ActionPlanTemplate__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
          ActionPlanTemplate__c apt1 = new ActionPlanTemplate__c();
        apt1.Name ='TestPromo';
        //apt1.RecordTypeId = promoRecordTypeId;
        apt1.Status__c ='APT Approved & Locked';
        apt1.ActionPlanType__c ='Promotional Activity Process';
        //apt1.CommercialActivityId__c=ca.id;
        apt1.AccountId__c=ac.id;
        //apt1.StoreAssortment__c = storeAssort1.id;
        apt1.RequestedStartDate__c = date.newInstance(2020, 07, 02);
        apt1.RequestedEndDate__c =date.newInstance(2020, 09, 10);
        insert apt1;
        
 RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c = ac.Id;
        rsgTest.Pricing_State__c = 'AK';
        insert rsgTest;
        
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c= apt1.Id;
        aapt.RetailLocationId__c = rsgTest.Id;
        insert aapt;
        apt1.Status__c = 'Execution';
        //update apt1;
        try {
    		Database.delete(aapt);
		}catch(Exception e){
    		System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
		}
      }
}