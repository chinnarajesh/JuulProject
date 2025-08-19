/*******************************************************************************************
* @Name         PersonAccountServiceTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         05/23/2019
* @Group        Customer Service
* @Description  Test class for PersonAccountService
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         05/23/2019        Initial Creation
*******************************************************************************************/
@isTest(seeAllData = false)
private class PersonAccountServiceTest {

     @TestSetup
    public static void makeData(){
      ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
    }
    /**************************************************************************************
    * @Description This method tests upserting person accounts with case payload
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testAttachPersonAccWithCase() {
        Test.startTest();
        List<Case> casesToInsert = new List<Case>();
        for (Integer i=0; i<3; i++) {
            Case c = new Case();
            c.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
            c.Origin = 'Support Form';
            c.SuppliedEmail = 'brucewayne@mail.com';
            casesToInsert.add(c);
        }
		system.debug('casesToInsert'+casesToInsert);
        insert casesToInsert;
        
        
        List<Case> casesToInsert1 = new List<Case>();
        for (Integer i=0; i<2; i++) {
            Case c = new Case();
            c.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'JUUL2 App Pairing & Connectivity');
            c.Origin = 'Support Form';
            c.First_Queue_Owner__c = 'Test Owner';
            c.SuppliedEmail = 'brucewayne@mail.com';
            casesToInsert1.add(c);
        }
        insert casesToInsert1;
        
        List<Case> casesToInsert2 = new List<Case>();
        for (Integer i=0; i<2; i++) {
            Case c = new Case();
            c.RecordTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
            //c.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'B2B Support Case');/
            c.Origin = 'Support Form';
            c.SuppliedEmail = 'brucewayne@mail.com';
            casesToInsert2.add(c);
        }
        insert casesToInsert2;
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description This method tests linking contact with the case if account exists
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testLinkContactWithCase() {
        Test.startTest();
        Account newAccountObj = new Account();
        newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account','Person Account');
        newAccountObj.FirstName = 'James';
        newAccountObj.LastName = 'Conway';
        newAccountObj.PersonEmail = 'jamesconway@mailinator.com';
        newAccountObj.Phone = '1233438761';
        insert newAccountObj;

        List<Case> casesToInsert = new List<Case>();
       // for (Integer i=0; i<3; i++) {
            Case c = new Case();
            c.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
            c.Origin = 'Support Form';
            c.AccountId = newAccountObj.Id;
            casesToInsert.add(c);
       // }
        system.debug('casesToInsert'+casesToInsert);
        insert casesToInsert;
        
        List<Case> casesToInsert1 = new List<Case>();
      //  for (Integer i=0; i<2; i++) {
            Case c2 = new Case();
            c2.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'JUUL2 App Pairing & Connectivity');
            c2.Origin = 'Support Form';
            c2.SuppliedEmail = 'brucewayne@mail.com';
            casesToInsert1.add(c2);
       // }
        insert casesToInsert1;
        
        List<Case> casesToInsert2 = new List<Case>();
       // for (Integer i=0; i<2; i++) {
            Case c1 = new Case();
        	c1.RecordTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
            //c1.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'B2B Support Case');
            c1.Origin = 'Support Form';
            c1.SuppliedEmail = 'brucewayne@mail.com';
            casesToInsert2.add(c1);
       // }
        insert casesToInsert2;
        Test.stopTest();
    }

    /**************************************************************************************
    * @Description This method tests upserting person accounts with XDSR payload
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testUpsertPersonAccWithXDSR() {
        List<CustomerInfoWrapper> custList = new List<CustomerInfoWrapper>();
        CustomerInfoWrapper wrapperObj = new CustomerInfoWrapper();
        wrapperObj.phone_number = '1233438761';
        wrapperObj.first_name = 'James';
        wrapperObj.last_name = 'Conway0';
        wrapperObj.email_address = 'jamesconway@mailinator.com';
        wrapperObj.date_received = String.valueOf(Date.newInstance(2018,12,10));
        wrapperObj.submission_channel = 'Focus Group';
        wrapperObj.health_event_mentioned = true;
        wrapperObj.id = '123';
        wrapperObj.country = 'United States';
        wrapperObj.language = 'English';
        custList.add(wrapperObj);
        PersonAccountService.upsertPersonAccUsingXDSR(custList);
    }

    /**************************************************************************************
    * @Description This method tests upserting person accounts with Zendesk ticket payload
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testUpsertPersonAccWithZDTicket() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 5; i++) {
            Zendesk__Zendesk_Ticket__c zt = new Zendesk__Zendesk_Ticket__c();
            zt.Zendesk_First_Name__c = 'Bruce';
            zt.Zendesk_Last_Name__c = 'Wayne';
            zt.Zendesk__RequesterEmailAddress__c = 'brucewayne' + '@mailinator.com';
            zt.Phone_Number__c = '908969969';
            zt.Zendesk__Brand__c = 'JUUL US';
            zt.Language_Preference__c = 'en-US';
            zt.Zendesk__Subject__c = 'zendesk subject';
            zt.Zendesk__Description__c = 'zendesk description';
            zt.Zendesk__Type__c = 'Problem';
            zt.Zendesk__Priority__c = 'High';
            zt.Order_Number__c = '122287312';
            zt.Promotion_Code__c = '1221promo';
            zt.Retailer_Promotion_Code__c = '1232121retprom';
            //basic juul info & what's the nicotine content
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'basic_juul_info';
            zt.Basic_Juul_Info_Type__c = 'what_is_the_nicotine_content';
            tickList.add(zt);
        }
        PersonAccountService.upsertPersonAccUsingZendeskTicket(tickList);
    }
}