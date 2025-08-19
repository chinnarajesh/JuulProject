@isTest(SeeAllData = False)
public class OpportunityTriggerHandlerTest {
    @testSetup
    public static void makeData(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='OpportunityTrigger',Enabled__c=true);
        insert(triggerController);
        
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        List<OpportunityContactRole> listOppConRoleToInsert = new List<OpportunityContactRole>();
        
         Test.startTest();
         
        Account accRec= new Account();
        accRec.Name = 'Test Account_Distributor';
        accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
        accRec.type='Regional Chain Retailer';
        insert accRec;
        
        Contact conRec = new Contact(FirstName = 'Test First', LastName = 'Test Last', AccountId = accRec.id);
        insert conRec;
       
        
        RetailLocationGroup__c rsgTest = new RetailLocationGroup__c();
        rsgTest.AccountId__c = accRec.Id;
        rsgTest.Pricing_State__c = 'AK';
        insert rsgTest;
       
        AccountRetailStoreGroup__c accrsg = new AccountRetailStoreGroup__c();
        accrsg.AccountId__c = accRec.Id;
        accrsg.RetailStoreGroupId__c = rsgTest.id;
        insert accrsg;
        
       
         
        for(Integer i=0; i<5; i++){
            Opportunity oppRec = new Opportunity();
            oppRec.Name = 'Test Opportunity '+i;
            oppRec.AccountId = accRec.id;
            oppRec.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
            oppRec.CloseDate = System.Today();
            oppRec.StageName = 'Nurture';
            oppRec.POS_Order_Date__c = null;
            listOppToInsert.add(oppRec);
        }
        insert listOppToInsert;
        
        for(Integer i=0; i<5; i++){
            OpportunityContactRole oppConRole = new OpportunityContactRole();
            oppConRole.ContactId = conRec.id;
            oppConRole.OpportunityId = listOppToInsert[i].id;
            oppConRole.Role = 'Business User';
            listOppConRoleToInsert.add(oppConRole);
        } 
        insert listOppConRoleToInsert;
        
         Test.stopTest();
    }
    public static testMethod void validationRACS_Test(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Account a = [select id from Account LIMIT 1];
        
        Test.startTest();
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        Opportunity oppRec1 = new Opportunity();
        oppRec1.Name='Test Opportunity 1';
        oppRec1.AccountId = a.id;
        oppRec1.StageName = 'Pending Certification';
        oppRec1.CloseDate = System.Today();
        oppRec1.Post_Implementation_Audit_1_Result__c = 'Fail - AV';
        oppRec1.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec1);
        
        Opportunity oppRec3 = new Opportunity();
        oppRec3.Name='Test Opportunity 3';
        oppRec3.AccountId = a.id;
        oppRec3.StageName = 'Recruit';
        oppRec3.CloseDate = System.Today();
        oppRec3.Additional_Follow_Up_Necessary__c = true;
        oppRec3.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec3); 
        
        Opportunity oppRec4 = new Opportunity();
        oppRec4.Name='Test Opportunity 4';
        oppRec4.AccountId = a.id;
        oppRec4.StageName = 'Onboard';
        oppRec4.POS_Followup_Needed_to_Confirm_Order__c = true;
        oppRec4.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec4);
        Opportunity oppRec5 = new Opportunity();
        oppRec5.Name='Test Opportunity 4';
        oppRec5.AccountId = a.id;
        oppRec5.StageName = 'Install';
        oppRec5.CloseDate = System.Today();
        oppRec5.Installation_Support_Level_Required__c = '3rd Party Installation';
        oppRec5.Additional_Post_Install_Support_Required__c = 'SKU Migration';
        oppRec5.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec5);
        Opportunity oppRec6 = new Opportunity();
        oppRec6.Name='Test Opportunity 4';
        oppRec6.AccountId = a.id;
        oppRec6.StageName = 'Install';
        oppRec6.CloseDate = System.Today();
        oppRec6.Second_RSS_Post_Install_Followup_Needed__c = true;
        oppRec6.Installation_Support_Level_Required__c = 'Remote Support (POS)';
        oppRec6.Chosen_Path_Forward__c = 'Nurture';
        oppRec6.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec6);
        Opportunity oppRec7 = new Opportunity();
        oppRec7.Name='Test Opportunity 4';
        oppRec7.AccountId = a.id;
        oppRec7.StageName = 'Install';
        oppRec7.CloseDate = System.Today();
        oppRec7.Chosen_Path_Forward__c = 'New POS System';
        oppRec7.Additional_Post_Install_Support_Required__c = 'Additional RSM follow-up visit';
        oppRec7.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec7);
        Opportunity oppRec8 = new Opportunity();
        oppRec8.Name='Test Opportunity 4';
        oppRec8.AccountId = a.id;
        oppRec8.StageName = 'Qualify';
        oppRec8.CloseDate = System.Today();
        oppRec8.RACS_Ops_Prioritization_Result__c = 'Pitch RACS';
        oppRec8.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec8); 
        Opportunity oppRec9 = new Opportunity();
        oppRec9.Name='Test Opportunity 9';
        oppRec9.AccountId = a.id;
        oppRec9.StageName = 'Install';
        oppRec9.CloseDate = System.Today();
        oppRec9.Installation_Support_Level_Required__c = 'Self-Installation';
        oppRec9.Additional_Post_Install_Support_Required__c = 'SKU Migration';
        oppRec9.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        oppRec9.POS_Installation_Date1__c = System.Today();
        oppRec9.POS_Installation_Date2__c = System.Today();
        oppRec9.POS_Installation_Date3__c = System.Today();
        oppRec9.POS_Installation_Date4__c = System.Today();
        oppRec9.White_Glove_Schedule_Date__c = System.Today();
        oppRec9.White_Glove_Installation_Notes__c = 'tstst';
        oppRec9.POS_Installation_Notes__c = 'tstst';
        listOppToInsert.add(oppRec9);           
        try{
            insert listOppToInsert;
        }catch(Exception e){
            System.debug(e.getMessage()); 
        }
        Test.stopTest();
    }
    
    public static testMethod void validationRACS_Test1(){
    
     Test.startTest();
         
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
            Account a = new Account();
            a.Name  = 'Test Account';
            a.Email__c = 'abc'+'@test.com';
            a.Phone = '1238901234';
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert a;
        
        List<Opportunity> listOppToInsert = new List<Opportunity>();
               
        Opportunity oppRec2 = new Opportunity();
        oppRec2.Name='Test Opportunity 2';
        oppRec2.AccountId = a.id;
        oppRec2.StageName = 'Pending Certification';
        oppRec2.CloseDate = System.Today();
        oppRec2.Post_Implementation_Audit_3_Result__c = 'Fail - AV';
        oppRec2.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('RACS Independent Onboarding').getRecordTypeId();
        listOppToInsert.add(oppRec2);
               
        try{
            insert listOppToInsert;
        }catch(Exception e){
            System.Assert(e.getMessage().contains('Please mark this checked')); 
        }
        Test.stopTest();
    }
    
   /* public static testMethod void createRACSInstallationCase_Test(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
           
           
            Test.startTest();   
        Account accRecord= new Account();   
        accRecord.Name = 'Test Account_Distributor';
        accRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
        accRecord.type='Regional Chain Retailer';
        insert accRecord;
        
            //    Account accRecord = [select id,name,RecordTypeId, type  from Account LIMIT 1];

       // Test.startTest();
        List<Opportunity> listOpp = [SELECT id,StageName,CloseDate, POS_Order_Date__c from Opportunity LIMIT 5];
        System.debug('lisOpplistOpp ************** '+listOpp);
        for(Opportunity oppRec : listOpp){
            oppRec.POS_Order_Date__c = System.Today(); 
            oppRec.AccountId =accRecord.id;
            listOppToUpdate.add(oppRec);
        }   
        update listOppToUpdate;
        Test.stopTest();
    }*/
    public static testMethod void UpdateRACSAccount_Test(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        RetailLocationGroup__c rsg = [select id,AccountID__c from RetailLocationGroup__c LIMIT 1];
            Account a1 = new Account();
            a1.Name  = 'Test Account';
            a1.Email__c = 'abc'+'@test.com'; 
            a1.Phone = '1238901234';
            a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        insert a1;
        
        Contact c = new Contact();
        c.LastName = 'Test';
        c.AccountId = a1.id;
        c.Type__c = 'Buyer';
        c.email='testing@abc.com';
        insert c;
        
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        
        Opportunity Opp = [SELECT id,StageName from Opportunity LIMIT 1];
        
        EAC_RSG__c eac = new EAC_RSG__c();
        eac.Opportunity__c = Opp.id;
        eac.Retail_Store_Group__c = rsg.id;
        insert eac;
        Test.startTest();
      
        Account acctRecord= new Account();
        acctRecord.Name = 'Test Account_Distributor';
        acctRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
          acctRecord.type='Regional Chain Retailer';
        insert acctRecord;
       
       //
                    //   Account acctRecord = [select id,name,RecordTypeId, type  from Account LIMIT 1];

 
        Opp.StageName = 'Committed';
        opp.accountID = acctRecord.id;
        update Opp;
        
        System.debug('opp.stagename'+Opp.StageName);
        Account a = [select RACS_Status__c from Account where id=:rsg.AccountId__c LIMIT 1]; 
        //System.assertEquals('Committed', a.RACS_Status__c);
        Opp.StageName = 'Closed/Won';
        update Opp;    
        Account aa = [select RACS_Status__c from Account where id=:rsg.AccountId__c LIMIT 1];
        //System.assertEquals('Certified', aa.RACS_Status__c);
        Test.stopTest();
    }
    
    
}