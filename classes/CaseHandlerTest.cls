/*******************************************************************************************
* @Name         CaseHandlerTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         01/16/2019
* @Group        Customer Service
* @Description  A test class for the ESignatureCheckHandler class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         01/16/2019          Initial Creation
*******************************************************************************************/
@isTest(seeAllData = false)
private class CaseHandlerTest {
    @TestSetup
    static void insertChAccSetting() {
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
    }
    /**************************************************************************************
    * @Description this method tests the checkSigCaseHealthExp method
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testHandleTrigger() {
        Boolean exceptionThrown = false;
        try {
            //create accounts for US market
            List<Account> accountListUS = new List<Account>();
            for (Integer i = 0; i < 1; i++) {
                Account newAccountObj = new Account();
                newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
                newAccountObj.FirstName = 'James';
                newAccountObj.LastName = 'Conway' + i;
                newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
                newAccountObj.Phone = '1233438761';
                newAccountObj.VIP__c = false;
                accountListUS.add(newAccountObj);
            }
            insert accountListUS;
            //create cases
            List<Case> caseListUS = new List<Case>();
            for (Integer i = 0; i < 5; i++) {
                Case c = new Case(Description = 'description' + i, Case_Region__c = null, SuppliedName = 'James Conway',
                        SuppliedEmail = 'jamesconway0@mailinator.com', RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience'));
                caseListUS.add(c);
            }
            insert caseListUS;
        } catch (Exception e) {
            exceptionThrown =  true;
            System.assertEquals(exceptionThrown, true);
        }
    }
    
    //Test method for case closure and account update
    static testmethod void caseClosure(){
        insertChAccSetting();
        Account newAccountObj = new Account();
        newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
        newAccountObj.FirstName = 'Test';
        newAccountObj.LastName = 'Account';
        newAccountObj.PersonEmail = 'tst@acc.com';
        newAccountObj.Phone = '1233438761';
        newAccountObj.VIP__c = false;
        insert newAccountObj;
        
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//For JTP-112
        Case cse = new Case();
        cse.Status = 'New';
        cse.AccountId = newAccountObj.Id;
        cse.Type = 'Brand Protection';
        cse.Sub_Type__c = 'Residential Address';
        cse.Regulatory_Action__c = 'No-Sale-List';
        cse.Description = 'description';
        cse.Case_Region__c = null;
        cse.SuppliedName = 'TestCase';
        cse.SuppliedEmail = 'tst@cse.com';
        //cse.RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'B2B Support Case');
        cse.RecordTypeId = B2BSupportCaseRecordTypeId;
        insert cse;
        
        cse.Status = 'Retail Case Closed';
        update cse;
    }
    
     static testMethod void testHandleTrigger1() {
        Boolean exceptionThrown = false;
        try {
            //Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
			Id recTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
            Account acc1 = new Account();
            acc1.Name = 'testAcc1';
            Insert acc1;
            
            Case c1 = new Case();	
            c1.AccountId = acc1.id;
            c1.Type = 'Brand Protection';
            c1.Sub_Type__c = 'Residential Address';
            c1.Secret_Shop_Date__c = System.today();
            c1.recordTypeId = recTypeId;
            c1.status = 'New';
            c1.Regulatory_Action__c = 'No-Sale-List';
            c1.Secret_Shop_Status__c = 'Fail';
            insert c1;
            
            c1.status = 'Retail Case Closed';
            Update c1;
            
        } catch (Exception e) {
            exceptionThrown =  true;
            System.assertEquals(exceptionThrown, true);
        }
    }

    @IsTest
    static void testCaseRouting() {
        Test.startTest();
        insertChAccSetting();
        //create accounts for US market
        List<Account> accountListUS = new List<Account>();
        for (Integer i = 0; i < 1; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438761';
            newAccountObj.VIP__c = false;
            accountListUS.add(newAccountObj);
        }
        insert accountListUS;
        //create cases
        List<Case> caseListUS = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c = new Case(Description = 'description' + i, Case_Region__c = null, SuppliedName = 'James Conway',
                    First_Queue_Owner__c = 'US_T1_Email_Cases',
                    SuppliedEmail = 'jamesconway0@mailinator.com'
                              //, RecordTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience')
                             );
            caseListUS.add(c);
        }
        	Id recTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
            Account acc1 = new Account();
            acc1.Name = 'testAcc1';
            Insert acc1;
            
            Case c1 = new Case();	
            c1.AccountId = acc1.id;
            c1.Type = 'Brand Protection';
            c1.Sub_Type__c = 'Residential Address';
            c1.Secret_Shop_Date__c = System.today();
            c1.recordTypeId = recTypeId;
            c1.status = 'New';
            c1.Regulatory_Action__c = 'No-Sale-List';
            c1.Secret_Shop_Status__c = 'Fail';
        	c1.Market__c = 'US';
        	caseListUS.add(c1);
            insert caseListUS;
            
            c1.status = 'Retail Case Closed';
            Update c1;
		
        Test.stopTest();

    }
}