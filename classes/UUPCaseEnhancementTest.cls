/**********************************************************************/
/* VERSION     AUTHOR                     DATE                        */
/*     1.0     Jyoti Choudhary          14-06-2021                    */
/* Class Name: UUPCaseEnhancementTest                                 */
/* Description: Code Coverage for UUPCaseEnhancement                  */
/**********************************************************************/
@isTest
public class UUPCaseEnhancementTest {
@testSetup
    public static void setup(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AccountTrigger',Enabled__c=true);
        insert(triggerController); 
        Trigger_Controller__c triggerController2 = new Trigger_Controller__c(Name='CaseTrigger',Enabled__c=true);
        insert(triggerController2);
    }
    
    static testMethod void testUUPCaseEnhancement(){
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<Account> listAcc = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Juul Account';
        acc.Email__c = 'testacc@juul.com';
        acc.Type = 'Independent Retailer';
        acc.ShippingCountry = 'US';
        acc.ShippingStreet = '1';
        acc.ShippingPostalCode='001';
        acc.ShippingCity='Lyonn';
        acc.CurrentPOSProvider__c='Advent POS';
        listAcc.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'Juul Account1';
        acc1.Type = 'Independent Retailer';
        acc1.Email__c = 'testacc1@juul.com';
        acc1.ShippingCountry = 'US';
        acc1.ShippingStreet = '1';
        acc1.ShippingPostalCode='001';
        acc1.ShippingCity='Lyonn';
        acc1.Status__c='Suspended';
        acc1.CurrentPOSProvider__c='Advent POS';
        listAcc.add(acc1);  
        
        Account acc2 = new Account();
        acc2.Name = 'Juul Account2';
        acc2.Email__c = 'testacc2@juul.com';
        acc2.Type = 'Independent Retailer';
        acc2.ShippingCountry = 'US';
        acc2.ShippingStreet = '1';
        acc2.ShippingPostalCode='001';
        acc2.ShippingCity='Lyonn';
          acc2.Status__c='Promotional Funding Suspended';
        acc2.CurrentPOSProvider__c='Advent POS';
        listAcc.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'Juul Account3';
        acc3.Type = 'Independent Retailer';
        acc3.Email__c = 'testacc3@juul.com';
        acc3.ShippingCountry = 'US';
        acc3.ShippingStreet = '1';
        acc3.ShippingPostalCode='001';
        acc3.ShippingCity='Lyonn';
         acc3.Status__c='Promotional Funding Suspended';
      acc3.CurrentPOSProvider__c='Advent POS';
        listAcc.add(acc3); 
        insert listAcc;
        
        List<Contact> listCon = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'Test Juul';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        listCon.add(con);

        Contact con1 = new Contact();
        con1.FirstName = 'Test Juul1';
        con1.LastName = 'Contact';
        con1.AccountId = acc1.Id;
        listCon.add(con1);
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test Juul2';
        con2.LastName = 'Contact';
        con2.AccountId = acc2.Id;
        listCon.add(con2);
        
        Contact con3 = new Contact();
        con3.FirstName = 'Test Juul3';
        con3.LastName = 'Contact';
        con3.AccountId = acc3.Id;
        listCon.add(con3);
        
        insert listCon;
     /*   
        List<Case> listCase = new List<Case>();
        Case c = new Case();
        c.accountId = acc.Id;
        c.contactId = con.Id;
        c.Subject = 'Quantity Purchase Limit Mystery Shop';
        c.Type = 'Mystery Shop';
        //c.Sub_Type__c = 'Product Quantity Limits';
        //c.Regulatory_Action__c = 'Promotional Funding Removed';
        c.Secret_Shop_Group__c = 'Visit 1';
        listCase.add(c);
        
        Case c1 = new Case();
        c1.accountId = acc1.Id;
        c1.contactId = con1.Id;
        c1.Subject = 'EAC Assessment';
        c1.Type = 'Mystery Shop';
        //c1.Sub_Type__c = 'Product Quantity Limits';
        //c1.Regulatory_Action__c = 'Promotional Funding Removed';
        c1.Secret_Shop_Group__c = 'Re-shop 1';
        c1.Secret_Shop_Status__c = 'Fail';
        listCase.add(c1);          
        
        Case c2 = new Case();
        c2.accountId = acc2.Id;
        c2.contactId = con2.Id;
        c2.Subject = 'Quantity Purchase Limit Mystery Shop';
        c2.Type = 'Mystery Shop';
        //c2.Sub_Type__c = 'Product Quantity Limits';
        //c2.Regulatory_Action__c = 'Promotional Funding Removed';
        c2.Secret_Shop_Group__c = 'Visit 1';       
        c2.Secret_Shop_Status__c = 'Fail';
        listCase.add(c2);
        
        Case c3 = new Case();
        c3.accountId = acc3.Id;
        c3.contactId = con3.Id;
        c3.Subject = 'Quantity Purchase Limit Mystery Shop';
        c3.Type = 'Mystery Shop';
        //c3.Sub_Type__c = 'Product Quantity Limits';
        //c3.Regulatory_Action__c = 'No-Sale-List';
        c3.Secret_Shop_Group__c = 'Re-shop 2';
        listCase.add(c3);
        
          Case c4 = new Case();
        c4.accountId = acc3.Id;
        c4.contactId = con3.Id;
        c4.Subject = 'Age Verification Compliance Audit';
        c4.Type = 'Mystery Shop';
        //c3.Sub_Type__c = 'Product Quantity Limits';
        //c3.Regulatory_Action__c = 'No-Sale-List';
        c4.Secret_Shop_Group__c = 'Re-shop 3';
        listCase.add(c4);
        //insert listCase;
       */ 
        
        List<vz__Print_Mail_Content__c> listPrintMailContent = new List<vz__Print_Mail_Content__c>();
        vz__Print_Mail_Content__c pmc = new vz__Print_Mail_Content__c();
        pmc.Name = 'template-a'; 
        listPrintMailContent.add(pmc);  
        
        vz__Print_Mail_Content__c pmc1 = new vz__Print_Mail_Content__c();        
        pmc1.Name = 'template-b';    
        listPrintMailContent.add(pmc1);
        
        vz__Print_Mail_Content__c pmc2 = new vz__Print_Mail_Content__c();        
        pmc2.Name = 'template-c';    
        listPrintMailContent.add(pmc2);
        
         vz__Print_Mail_Content__c pmc3 = new vz__Print_Mail_Content__c();        
        pmc3.Name = 'template-d';    
        listPrintMailContent.add(pmc3);
        
        insert listPrintMailContent;
        
        test.startTest();
        User u1 = [SELECT Id,FirstName, LastName from User where IsActive = true LIMIT 1];
        List<Case> listCase1 = New List<Case>([Select Id, AccountId, ContactId, UUP_Case_Key__c, Secret_Shop_Group__c, Subject, Type, Sub_Type__c, Account.Type, Account.ShippingCountry, RecordType.Name from Case ]);
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;
        System.runas(u1) 
        {
                try
                {
                 List<Case> listCase = new List<Case>();
                 
                    Case ca = new Case();
                    ca.accountId = acc.Id;
                    ca.contactId = con.Id;
                    ca.Subject = 'Quantity Purchase Limit Mystery Shop';
                    ca.Secret_Shop_Group__c = 'Re-shop 1';
                    ca.Status = 'Retail Case Closed';
                    ca.Type = 'Mystery Shop';
                    ca.Secret_Shop_Status__c = 'Fail';
                    //ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
                    ca.RecordTypeId=B2BSupportCaseRecordTypeId;
                  //  insert ca;
                  listCase.add(ca);
                  
                 
        Case c = new Case();
        c.accountId = acc.Id;
        c.contactId = con.Id;
        c.Subject = 'Quantity Purchase Limit Mystery Shop';
        c.Type = 'Mystery Shop';
        //c.Sub_Type__c = 'Product Quantity Limits';
        //c.Regulatory_Action__c = 'Promotional Funding Removed';
        c.Secret_Shop_Group__c = 'Visit 1';
        listCase.add(c);
        
        Case c1 = new Case();
        c1.accountId = acc1.Id;
        c1.contactId = con1.Id;
        c1.Subject = 'EAC Assessment';
        c1.Type = 'Mystery Shop';
        //c1.Sub_Type__c = 'Product Quantity Limits';
        //c1.Regulatory_Action__c = 'Promotional Funding Removed';
        c1.Secret_Shop_Group__c = 'Re-shop 1';
        c1.Secret_Shop_Status__c = 'Fail';
        listCase.add(c1);          
        
        Case c2 = new Case();
        c2.accountId = acc2.Id;
        c2.contactId = con2.Id;
        c2.Subject = 'Quantity Purchase Limit Mystery Shop';
        c2.Type = 'Mystery Shop';
        //c2.Sub_Type__c = 'Product Quantity Limits';
        //c2.Regulatory_Action__c = 'Promotional Funding Removed';
        c2.Secret_Shop_Group__c = 'Visit 1';       
        c2.Secret_Shop_Status__c = 'Fail';
        listCase.add(c2);
        
        Case c3 = new Case();
        c3.accountId = acc3.Id;
        c3.contactId = con3.Id;
        c3.Subject = 'Quantity Purchase Limit Mystery Shop';
        c3.Type = 'Mystery Shop';
        //c3.Sub_Type__c = 'Product Quantity Limits';
        //c3.Regulatory_Action__c = 'No-Sale-List';
        c3.Secret_Shop_Group__c = 'Re-shop 2';
        listCase.add(c3);
        
          Case c4 = new Case();
        c4.accountId = acc3.Id;
        c4.contactId = con3.Id;
        c4.Subject = 'Age Verification Compliance Audit';
        c4.Type = 'Mystery Shop';
        //c3.Sub_Type__c = 'Product Quantity Limits';
        //c3.Regulatory_Action__c = 'No-Sale-List';
        c4.Secret_Shop_Group__c = 'Re-shop 3';
        listCase.add(c4);
       
      // insert listCase;
                  
                  system.debug(listCase.size());
                    system.debug(listCase);
                  
                   UUPCaseEnhancement.UUPCaseEnhancementMethod(listCase);
                    UUPCaseEnhancementBatch u = new UUPCaseEnhancementBatch(listCase);
                   Database.executeBatch(u);
                                      
                    //Database.BatchableContext sc;
                   //u.start(sc);
                   
                   List<Account> accountList=new List<Account>( [SELECT Id,Status__c,OwnerId from Account where Id IN: listAcc]) ;

                    // u.execute(sc,accountList);
                     
                   //UUPCaseEnhancementSch sch1= new UUPCaseEnhancementSch();
                 //  String sch = '0 0 23 * * ?';
                   //        system.schedule('Test check', sch, sch1);
                   //SchedulableContext sc1;
                  //sch1.execute(sc1);
                 
               

                }
                catch(exception ex)
                {
                    System.debug('Inside Test class Catch and exception occur==>'+ex);
                }     
        test.stopTest();
            List<Account> listAC = [Select Id, Name, Status__c from Account];
            System.debug('listAC[0].Status__c ==>'+listAC[0].Status__c);
            //System.debug('listAC[1].Status__c ==>'+listAC[1].Status__c);
            //System.debug('listAC[2].Status__c ==>'+listAC[2].Status__c);
            //System.debug('listAC[3].Status__c ==>'+listAC[3].Status__c);
            //System.assertEquals(listAC[0].Status__c,'Suspended');
           
        }
    }
}