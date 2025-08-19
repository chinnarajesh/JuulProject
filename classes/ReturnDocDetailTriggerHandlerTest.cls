@isTest(SeeAllData = false)
public class ReturnDocDetailTriggerHandlerTest{
  @testSetup static void prepData(){
  Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='ReturnDocDetailTrigger',Enabled__c=true);
        insert(triggerController);
       ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
         Account accRec = new Account();
            accRec.Name='TestAccount';
            accRec.ShippingStreet = 'Test Street';
            accRec.ShippingCity = 'Test City';
            accRec.ShippingState = 'Test State';
            accRec.ShippingPostalCode ='945';
            accRec.ShippingCountry='US';
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
            insert accRec;
         Case caRec = new Case();
         caRec.Subject = 'Test B2B RMA Case';  
         caRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B RMA').getRecordTypeId(); 
         caRec.Type = 'Misssing Product';
         caRec.Account_Type__c = 'Standard Distributor';
         caRec.AccountId = accRec.id;
         insert caRec;
      		System.debug('Account'+accRec);
      		system.debug('case' +caRec);
         Product2 p = new Product2();
            p.Name = 'CA Pods Virginia Tobacco 5.0% 2.8ml 4pack';
            p.IsActive = true;
            p.Pod_Strength__c = '5%';
            p.Pod_Pack_Size__c = '4';
            p.Family = 'Pods';
            p.Flavor_Family__c = 'Virginia Tobacco';
            insert p;
            
          salesOrder__c so = new salesOrder__c();
            so.Name ='SalesOrdertest';
            so.Customer__c = accRec.Id;
            so.Distributor__c =  accRec.id;
            so.Date__c = '04/15/2019';
        insert so;
           Document_Details__c ddRec = new Document_Details__c();
            ddRec.Name='Test Document Detail';
            ddRec.Quantity__c = 4;
            ddRec.Product__c = p.id;
            ddRec.salesOrderNumber__c = so.id;
           insert ddRec;
             
         Return_Order__c roRec = new Return_Order__c();
         roRec.Case__c = caRec.id;
         roRec.Customer__c = accRec.id;
         roRec.Original_SO_Number__c  = so.id;
         insert roRec;
      
      Return_Order__c roRec1 = new Return_Order__c();
         roRec1.Case__c = caRec.id;
         roRec1.Customer__c = accRec.id;
         roRec1.Original_SO_Number__c  = null;
         insert roRec1;
         Return_Document_Detail__c rdRec = new Return_Document_Detail__c();
           rdRec.Return_Order__c = roRec.id;
           rdRec.Return_Product__c = p.id;
           insert rdRec;
      
      Return_Document_Detail__c rdRec1 = new Return_Document_Detail__c();
           rdRec1.Return_Order__c = roRec1.id;
           rdRec1.Return_Product__c = p.id;
           insert rdRec1;
     }
    public static testMethod void testMethod1(){
       
       List<Return_Document_Detail__c>  rdDocDetail = [SELECT Id, SO_Document_Detail__c , Return_Order__c, Return_Product__c from Return_Document_Detail__c LIMIT 2];
         system.debug('Return_Document_Detail__c' +rdDocDetail);
        for(Return_Document_Detail__c rd : rdDocDetail){
              ReturnDocDetailTriggerHandler.updateSODocumentDetail(rd, null);
        }
    }
}