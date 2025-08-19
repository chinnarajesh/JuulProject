/*******************************************************************************************
* @Name         CaseCleanupBatchTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         11/05/2018
* @Group        Customer Service
* @Description  Test class for CaseCleanupBatch class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         11/05/2018          Initial Creation
*******************************************************************************************/
@IsTest(seeAllData=false)
private class CaseCleanupBatchTest {
    /**************************************************************************************
    * @Description this method creates setup records
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    @testSetup static void setup() {
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
                    SuppliedEmail = 'jamesconway0@mailinator.com');
            caseListUS.add(c);
        }
        insert caseListUS;

        //create accounts for UK market
        List<Account> accountListUK = new List<Account>();
        for (Integer i = 1; i < 2; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListUK.add(newAccountObj);
        }
        insert accountListUK;
        //create cases
        List<Case> caseListUK = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, Case_Region__c = null, SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway1@mailinator.com', Origin = 'UK E2C');
            caseListUK.add(c3);
        }
        insert caseListUK;

        //create accounts for Israel market
        List<Account> accountListIsrael = new List<Account>();
        for (Integer i = 2; i < 3; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListIsrael.add(newAccountObj);
        }
        insert accountListIsrael;
        //create cases
        List<Case> caseListIsrael = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway2@mailinator.com', Case_Region__c = null, Origin = 'Israel E2C');
            caseListIsrael.add(c3);
        }
        insert caseListIsrael;

        //create accounts for Russia market
        List<Account> accountListRussia = new List<Account>();
        for (Integer i = 3; i < 4; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListRussia.add(newAccountObj);
        }
        insert accountListRussia;

        //create cases
        List<Case> caseListRussia = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, Origin = 'Russia E2C', SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway3@mailinator.com', Case_Region__c = null);
            caseListRussia.add(c3);
        }
        insert caseListRussia;

        //create accounts for Switzerland market
        List<Account> accountListSwitzerland = new List<Account>();
        for (Integer i = 4; i < 5; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListSwitzerland.add(newAccountObj);
        }
        insert accountListSwitzerland;

        //create cases
        List<Case> caseListSwitzerland = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, Origin = 'Switzerland DE E2C', SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway4@mailinator.com', Case_Region__c = null);
            caseListSwitzerland.add(c3);
        }
        insert caseListSwitzerland;

        //create accounts for Germany market
        List<Account> accountListGermany = new List<Account>();
        for (Integer i = 5; i < 6; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListGermany.add(newAccountObj);
        }
        insert accountListGermany;
        //create cases
        List<Case> caseListGermany = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, Origin = 'Germany E2C', SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway5@mailinator.com', Case_Region__c = null);
            caseListGermany.add(c3);
        }
        insert caseListGermany;
        /*
        //create accounts for France market
        List<Account> accountListFrance = new List<Account>();
        for (Integer i = 6; i < 7; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListFrance.add(newAccountObj);
        }
        insert accountListFrance;
        //create cases
        List<Case> caseListFrance = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, Origin = 'France E2C', SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway6@mailinator.com');
            caseListFrance.add(c3);
        }
        insert caseListFrance;

        //create accounts for Canada English market
        List<Account> accountListCanada = new List<Account>();
        for (Integer i = 7; i < 8; i++) {
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            newAccountObj.FirstName = 'James';
            newAccountObj.LastName = 'Conway' + i;
            newAccountObj.PersonEmail = 'jamesconway' + i + '@mailinator.com';
            newAccountObj.Phone = '1233438861';
            newAccountObj.VIP__c = false;
            accountListCanada.add(newAccountObj);
        }
        insert accountListCanada;
        //create cases
        List<Case> caseListCanada = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c3 = new Case(Description = 'description' + i, SuppliedName = 'James Conway',
                    SuppliedEmail = 'jamesconway7@mailinator.com', Origin = 'Canada E2C - English');
            caseListCanada.add(c3);
        }
        insert caseListCanada;
        */
    }
    /**************************************************************************************
    * @Description this method runs the batch
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testRunBatch() {
        Test.startTest();
        CaseCleanupBatch batch = new CaseCleanupBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}