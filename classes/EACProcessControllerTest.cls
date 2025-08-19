/**************************************************************************************/ 
/* Mehod Name : EACProcessControllerTest
/*Description: For EAC Process flow.                                                 
/* Added By : Pooja Gite     
 * Description: Test class for EACProcessController                                                                                      
/**************************************************************************************/   
@isTest
public class EACProcessControllerTest {
     @testSetup static void setup(){
            ChildAccountShare__c sett = new ChildAccountShare__c();
            sett.Name = 'ChidlAccountShare';
            sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
            insert sett;
            
            Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
            insert(triggerController1);
            
            Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
            insert(triggerController2);
         
           List<Account> accList = new List<Account>();
            Account acc = new Account();
            acc.Name='Test1';
            acc.Type='HQ';
            acc.ShippingState ='HI';
            acc.BillingCountry ='USA';
            acc.ComplianceMechanism__c='Menthol Ban';
            acc.ShippingCountry= 'US';
            accList.add(acc);
            insert accList;
      
            List<Id> aList = new List<Id>();
            List<Account> accList1 = new List<Account>();
            Account acc1 = new Account();
            acc1.Name='Test2';
            acc1.Type='HQ';
            acc1.ShippingState ='HI';
            acc1.BillingCountry ='USA';
            acc1.ComplianceMechanism__c='Menthol Ban';
            acc1.ShippingCountry= 'US';
            acc1.Chain_Expansion__c = 'M&A';
            acc1.EAC_Certification_Status__c = 'Certification Pending';
            acc1.DocAttachedCheck__c = true;
            accList1.add(acc1);
            
            insert accList1;
         //aList.add(acc1.Id);

         }

  static testMethod void fetchAccDetails(){
           Test.startTest();
             List<Account> aList = [Select Id from Account where Name = 'Test2'];
            List<Id> AccId = new List<Id>();
            AccId.add(aList[0].id);
            String AccIDString = aList[0].id;
            EACProcessController.getAccounts(AccIDString);
              try{
                  EACProcessController.updateAccount(AccId);
                  EACProcessController.updateAccountAnnotated(AccId);
                  
              }catch(exception e ){
                  System.debug('Error Msg'+e);
              }

           Test.stopTest();
  }  
}