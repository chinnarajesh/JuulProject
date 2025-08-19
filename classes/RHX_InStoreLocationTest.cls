@isTest
public class RHX_InStoreLocationTest  {

    
     @testSetup static void setup(){
            ChildAccountShare__c sett = new ChildAccountShare__c();
            sett.Name = 'ChidlAccountShare';
            sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
            insert sett;
            Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountOrGroupAlertTrigger',Enabled__c=true);
            insert(triggerController);
            Trigger_Controller__c triggerController1 = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
            insert(triggerController1);
            Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='ActionPlanTemplateTrigger',Enabled__c=true);
            insert(triggerController2);
            Trigger_Controller__c triggerController3 = new Trigger_Controller__c(Name='InStoreLocationTrigger',Enabled__c=true);
            insert(triggerController3);
            
            Apex_Code_Controller__c KAMAlertControl = new Apex_Code_Controller__c(Name = 'KAMCreateAlertAndNotifications', Enabled__c=true);
            insert (KAMAlertControl);
            
        }
    public static testmethod void testCreatealertandNotification() {
        Account ac =  new Account();
        ac.Name=  'test account';
        ac.JLP_Tier__c = 'Silver';
        ac.ShippingCountry='US';
        insert  ac;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> userList = new List<User>();
        for (Integer i = 0; i< 5; i++) {
            // observe the same name for Opp and TSG
            USer newUser = new User(lastname = 'Test',Alias = 'Test',TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'eu_ES',EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.id,LanguageLocaleKey = 'en_US',
            userName='Test' + i + '@sdkksdhfhdsjhf.com',email='Test' + i + '@asjgdgsad.com');
            userList.add(newUser);
        }
        insert userList;

        //Create the AccountTeam
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        For (Integer i = 0; i< 5; i++) {
            if(i< 2){
                AccountTeamMember newTeam = new AccountTeamMember(AccountId = ac.ID,
                TeamMemberRole = 'Distribution Manager',UserId = userList[i].ID);
                teamList.add(newTeam);
            }else{
                AccountTeamMember newTeam = new AccountTeamMember(AccountId = ac.ID,
                TeamMemberRole = 'KAPM',UserId = userList[i].ID);
                teamList.add(newTeam);
            }
        }
        insert teamList;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'ActionPlanTemplate__c' AND Name = 'Promotional Activity Process'];
        
        List<ActionPlanTemplate__c> testAPTList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c APT = new ActionPlanTemplate__c();
        APT.StrategyStartDate__c = System.today()+1;
      //  APT.StrategyEndDate__c = System.today()+7;
        APT.AllowedChainLimit__c = '8';
        APT.AccountId__c = ac.Id;
        APT.Name = 'test';
        APT.RequestedStartDate__c = System.today()+1;
        APT.RequestedEndDate__c = System.today() + 7;
        APT.ProjectType__c  = 'New Install';
        APT.TypeOfExecution__c = 'By Vendor- 3rd Party Scheduled';
        APT.RecordTypeId = rt.ID;
        APT.CurrentApproverList__c = 'Manager';
        APT.TotalTradeCollateralCost__c = 500;
        APT.TradeCollateralCostPerDoor__c = 500; 
        APT.AnticipatedTotalCostCollaterals__c = 500; 
        APT.CurrentApprover__c = APT.OwnerId;
        APT.Country__c='US';
        testAPTList.add(APT);
        insert testAPTList;
        APT.Status__c = 'Needs Approval';
        APT.CurrentApproverList__c = 'KAPM';
        APT.CurrentApprover__c = APT.OwnerId;
        update APT;
        KAMCreateAlertAndNotifications.createAlertandGroupAlert(testAPTList);
    }

        
    public static testmethod void testRecalledAPT() {

        Account ac =  new Account();
        ac.Name=  'test account new';
        ac.JLP_Tier__c = 'Silver';
        ac.ShippingState ='HI';
        ac.ShippingCountry = 'US';
        insert ac;
        system.debug('@@acid'+ac.id);
 
        List<RetailLocationGroup__c> rlgList = new List<RetailLocationGroup__c>();
        RetailLocationGroup__c rlg = new RetailLocationGroup__c();
        rlg.Name = 'Test RLG';
        rlg.AccountId__c= ac.id;
        rlg.Pricing_State__c = ac.ShippingState;
        rlg.Country__c='US';
        rlgList.add(rlg);
        insert rlgList;
        
        system.debug('@@rlgList : '+rlgList);
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'ActionPlanTemplate__c' AND Name = 'Promotional Activity Process'];
        
        Set<id> accIdSet = new Set<Id>();
        List<AccountRetailStoreGroup__c> arsgList = new List<AccountRetailStoreGroup__c>();
        AccountRetailStoreGroup__c arsg = new AccountRetailStoreGroup__c();
        arsg.RetailStoreGroupId__c = rlgList[0].Id;
        arsg.AccountId__c = ac.Id;
        arsgList.add(arsg);
        insert arsgList;
        
        List<InStoreLocation__c> Islist = new List<InStoreLocation__c>();
        InStoreLocation__c sl = new InStoreLocation__c();
        //sl.RetailStoreGroupActionPlanTemplate__c = aapt.id;
        sl.RetailLocationId__c =ac.Id  ;
        sl.StartDate__c = System.today()+1;
        sl.EndDate__c =System.today()+7;
        Islist.add(sl);
        insert Islist;
       
        List<StoreProduct__c> spList = new List<StoreProduct__c>();
        StoreProduct__c sp = new StoreProduct__c();
        sp.RetailStoreId__c = ac.id;
        sp.InStoreLocationId__c= sl.id;
        spList.add(sp);
        //insert spList;
        
        Product2 p1= new Product2();
        p1.name= 'Test Items2';
        p1.Family='Accessories';
        p1.IsActive = true;
        p1.Product_Country__c = 'US';
        p1.ProductPricingFamily__c='DK';
        p1.US_E_Order_Enabled__c = true;
        insert p1;
        
        List<Asset> assList = new List<Asset>();
        Asset ass= new asset();
        ass.AccountId =  ac.id;
        ass.Product2Id =p1.Id;
        ass.name= p1.name;
        assList.add(ass);
        insert assList;
          
        List<ActionPlanTemplate__c> testAPTList = new List<ActionPlanTemplate__c>();
        ActionPlanTemplate__c APT = new ActionPlanTemplate__c();
        APT.StrategyStartDate__c = System.today()+1;
        APT.StrategyEndDate__c = System.today()+7;
        //APT.StrategyEndDate__c = System.today()+7;
        APT.AllowedChainLimit__c = '8';
        APT.AccountId__c = ac.Id;
        APT.Name = 'test';
        APT.RequestedStartDate__c = System.today()+1;
        APT.RequestedEndDate__c = System.today()+7;
        APT.ProjectType__c  = 'New Install';
        APT.TypeOfExecution__c = 'By Vendor- 3rd Party Scheduled';
        APT.RecordTypeId = rt.ID;
        APT.CurrentApproverList__c = 'Manager';
        APT.TotalTradeCollateralCost__c = 500;
        APT.TradeCollateralCostPerDoor__c = 500; 
        APT.AnticipatedTotalCostCollaterals__c = 500; 
        APT.CurrentApprover__c = APT.OwnerId;
        APT.Status__c = 'Execution';
        APT.Country__c='US';
        testAPTList.add(APT);
        insert testAPTList;
        
        APT.Status__c = 'Recalled';
        APT.AccountId__c = ac.Id;
        update APT;
     
       List<Mission__c> msList = new List<Mission__c>();
        Mission__c visitObj = new Mission__c();
        //visitObj.AccountId__c = ac.id;
        visitObj.Status__c = 'Planned';
        visitObj.AccountId__c = ac.Id;
        msList.add(visitObj);
        insert msList;
        
        List<ActionPlan__c> apList = new List<ActionPlan__c>();
        ActionPlan__c aPlanObj1 = new ActionPlan__c();
        aPlanObj1.ActionPlanTemplateId__c = APT.Id;
        apList.add(aPlanObj1);
        insert apList;
     
        AccountActionPlanTemplate__c aapt = new AccountActionPlanTemplate__c();
        aapt.ActionPlanTemplateId__c = APT.id;
        aapt.RetailLocationId__c = rlg.id;
        insert aapt;
        
        
    }    
           
    
}