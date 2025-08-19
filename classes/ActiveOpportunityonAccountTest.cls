@isTest
public class ActiveOpportunityonAccountTest{
    
    @TestSetup
    public static void makeData(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
       
      Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
      insert(triggerController);  
    }
     
    public static testMethod void ActOppOnAccMethod(){
        
        Trigger_Controller__c customSetting = new Trigger_Controller__c();
        customSetting.Name = 'AccountRetailStoreGroupTrigger';
        customSetting.Enabled__c = true;
        Insert customSetting;
        
      
        
        List<Account> acList = new List<Account>();
        Account ac1 = new account();
        ac1.Name = 'test account 1';
        ac1.shippingCountry = 'US';
        acList.add(ac1);
        Account ac2 = new account();
        ac2.Name = 'test account 2';
        ac2.shippingCountry = 'US';
        acList.add(ac2);    
        insert acList;
        Account ac = new Account();
        ac.Name = 'test Parent account';
        ac.shippingCountry = 'US';
        Insert ac;
        RetailLocationGroup__c rsg = new RetailLocationGroup__c();
        rsg.Name = 'test retail location';
        rsg.AccountId__c = ac.ID;
        rsg.Country__c = 'US';
        rsg.Pricing_State__c = 'AK';
        insert rsg;
        
        Opportunity o = new Opportunity();
        o.Name = 'Opp 1';
        o.StageName = 'Ready';
        o.CloseDate = System.today()+30;
        insert o;
        
        EAC_RSG__c e = new EAC_RSG__c();
        e.Retail_Store_Group__c = rsg.Id;
        e.Opportunity__c = o.Id;
        insert e;
       
        List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
        AccountRetailStoreGroup__c arsg = new AccountRetailStoreGroup__c(AccountId__c = ac1.Id );
        arsg.AccountId__c = ac1.Id;
        arsg.RetailStoreGroupId__c = rsg.ID;
        arsgList.add(arsg);
        AccountRetailStoreGroup__c arsg2 = new AccountRetailStoreGroup__c(AccountId__c = ac2.ID);
        arsg2.AccountId__c = ac2.ID;
        arsg2.RetailStoreGroupId__c = rsg.Id;
        arsgList.add(arsg2);
        test.startTest();
        insert arsgList;
        arsg.AccountId__c = ac2.Id;
        update arsg;
        
        delete arsg2;
        test.stopTest();
        
    }

}