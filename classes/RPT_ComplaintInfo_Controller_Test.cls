@isTest
public class RPT_ComplaintInfo_Controller_Test {
    static testMethod void CustomRptTest() { 
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Language_Preference__c = 'English';
        cs.Market__c = 'United States';
        cs.AccountId = '0017000001Os1Rr';
        cs.Priority = 'Normal';
        
        insert cs;
        
        Id case_id = System.currentPageReference().getParameters().put('id', cs.Id);
        ApexPages.StandardController std = new ApexPages.standardController(cs);
              
        Test.StartTest();
        RPT_ComplaintInfo_Controller render = new RPT_ComplaintInfo_Controller(std);
        Test.StopTest();
        }       
}