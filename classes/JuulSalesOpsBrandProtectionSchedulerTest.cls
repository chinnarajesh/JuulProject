@isTest
public class JuulSalesOpsBrandProtectionSchedulerTest {
    public static void loadData(){
        BatchConstantValues__c sett = new BatchConstantValues__c();
        sett.Name = 'BatchBrandProtection';
        sett.X3_Strike_Enforcement_Start_Date__c= Date.newInstance(2018, 6, 1);
        sett.Next_Secret_Shop_Date_of_1__c= 30;
        sett.Next_Secret_Shop_Date_of_2__c= 1;
        sett.Next_Secret_Shop_Date_of_3__c= 3;
        sett.Next_Secret_Shop_Date_of_4__c= 6;
        sett.Next_Secret_Shop_Date_of_5__c= 12;
        sett.Between_Months_of_CreatedStartDT_1__c= -1;
        sett.Between_Months_of_CreatedStartDT_2__c= -2;
        sett.X3_Strike_Account_Blacklist_Reset__c=-12;
        sett.X3_Strike_Account_Suspension_Reset__c=-6;
        sett.X3_Strike_Admin_EmailIds__c='srikanth.bumhyavaram@juul.com';
        sett.Scheduler_Batch_Size__c = 50;
        insert sett;
     }
    
    @isTest static void executeTest(){
        Test.startTest();
        loadData();
        SchedulableContext sc = null;
        JuulSalesOpsBrandProtectionScheduler BPBatchSchl = new JuulSalesOpsBrandProtectionScheduler();
        BPBatchSchl.execute(sc);
        Test.stopTest();
    } 
}