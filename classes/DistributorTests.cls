@isTest 
private class DistributorTests {
    static testMethod void testAccountEndpointGet(){     
        DistributorAccountCreationController.doGet();
        DistributorAccountCreationController.doPost();
    }
    
    static testMethod void testDistributorSalesOrderPage(){
        DistributorSalesOrderController con = new DistributorSalesOrderController();
        con.switchToViewMode();
        con.switchToCreateMode();
        con.queryExistingSalesOrders();
        
        Account upd = new Account(Name='UPD', Type='Distributor', RecordTypeId='012700000005vMFAAY');
        insert upd;
        
        Account a = new Account(UPD_Upload_Id__c='test1',name='test1', BillingStreet='test1', Distributor__c = upd.Id, Type='Retailer');
        insert a;
        
        insert(new Distributor_Retailer_Link__c(Distributor__c = upd.Id, Retailer__c = a.Id, Link_Status__c = 'Active'));
        
        DistributorSalesOrderController.getViewObject(upd.Id);
        
        DistributorSalesOrderController.saveSalesData(new List<Sales_Data__c>{new Sales_Data__c()}, 'uploadVerification', 'distributorAccountId');
    }
    
    static testMethod void testDistributorUploadPage(){
        DistributorUploadController con = new DistributorUploadController();
        
        Account a = new Account(UPD_Upload_Id__c='test1',name='test1');
        insert(a);
        
        //DistributorUploadController.getUnmatchedAccounts(new List<String>{'test1','test2'});
        
        //DistributorUploadController.kickOffDistributorUploadBatch(new Map<String,String>());
        
        DistributorUploadController.kickOffDistributorUploadBatchDirectly(new Map<String,String>());
        
        DistributorUploadController.insertSalesData(new List<Sales_Data__c>());
        
        DistributorUploadController.getCommunityURL();
        
        /*
Account portalAccount = new Account(name = 'portalAccount', Distributor_Abbreviation__c='Test');//create a portal account first
insert portalAccount;
Contact portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id); //create a portal contact
insert portalContact;
List<Profile> portalProfiles = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Customer Community'];

User u1 = new User( email='test.portal@gmail.com',
profileid = portalProfiles[0].Id, 
UserName='test.portal@gmail.com',
Alias = 'GDS',
TimeZoneSidKey='America/New_York',
EmailEncodingKey='ISO-8859-1',
LocaleSidKey='en_US', 
LanguageLocaleKey='en_US',
ContactId = portalContact.Id,
FirstName = 'Test',
LastName = 'Portal User');
*/
        //Create portal account owner
    }
    static testMethod void testDistributorUploadPageCommunities(){     
        User userWithRole;
        if(UserInfo.getUserRoleId() == null) {
            UserRole r = new UserRole(name = 'TEST ROLE');
            Database.insert(r);
            userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(),CommunityNickname = 'test1234895',
                                    Username = System.now().millisecond() + 'test123458@test.com',
                                    timezonesidkey='America/Los_Angeles');
        } else {
            userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
        }
        
        Contact contact1;
        system.runAs(userWithRole) {
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                Distributor_Abbreviation__c = 'Test'
            );
            Database.insert(portalAccount1);
            
            //Create contact
            contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'Test2',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);
        }          
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Distributor Portal User%' Limit 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test 3',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);
        system.runAs(user1) {
            DistributorUploadController con = new DistributorUploadController();
            Map<String, String> params = new Map<String,String>();
            params.put('totalAccounts','100');
            params.put('totalSalesOrders','100');
            params.put('totalDocumentDetails','100');
            DistributorUploadController.insertUploadQueue(params);
        }
        
    }
    
    static testMethod void testDistributorUploadBatch(){
        String uploadVerification = 'Distributor - 07/12/2018 9:32 PM - UPD';
        DistributorSalesUploadBatch dsub = new DistributorSalesUploadBatch();
        DistributorSalesUploadBatch.generateCsvBodyOneRow('Id,Date,Product', null);
        DistributorSalesUploadBatch.generateCsvBodyOneRow('Id,Date,Product', 'Quantity');
        DistributorSalesUploadBatch.sendEmail(new List<String>(), '', '', new Map<String, String>{'a'=>'b'}, 'additional email');
        DistributorSalesUploadBatch.constructInternalEmailBody(false, 1, 1, 'UPD', '2018-05-02', 1, 1, 1, uploadVerification);
        
        insert new Custom_Code_Configuration__c(Communities_Upload_In_Progress__c = false);
        
        Account distributor = new Account(Name = 'Distributor');
        insert distributor;
        
        Product2 testProduct = new Product2(Name='Test Product');
        insert(testProduct);
        Sales_Data__c sd1 = new Sales_Data__c(Upload_Verification__c = uploadVerification,
                                              Account_Name__c = 'Account_Name__c',
                                              Address_1__c = 'Address_1__c',
                                              Address_2__c = 'Address_2__c',
                                              City__c = 'City__c',
                                              Date__c = '6/2/18',
                                              Distributor_Address_1__c = 'Distributor_Address_1__c',
                                              Distributor_City__c = 'Distributor_City__c',
                                              Distributor_External_Id__c = 'Distributor_External_Id__c',
                                              Distributor_Name__c = 'Distributor_Name__c',
                                              Distributor_SFDC_Account_Id__c = distributor.Id,
                                              Distributor_State__c = 'Distributor_State__c',
                                              Distributor_Zip_Code__c = 'Distributor_Zip_Code__c',
                                              Format__c = 'UPD',
                                              JUUL_Item_Number__c = 'JUUL_Item_Number__c',
                                              Product__c = testProduct.Id,
                                              Quantity__c = '5',
                                              Retailer_Address_1__c = 'Retailer_Address_1__c',
                                              Retailer_Address_2__c = 'Retailer_Address_2__c',
                                              Retailer_City__c = 'Retailer_City__c',
                                              Retailer_External_Id__c = 'Retailer_External_Id__c',
                                              Retailer_Name__c = 'Retailer_Name__c',
                                              Retailer_Country__c = 'Retailer_Country__c',
                                              Retailer_Phone__c = 'Retailer_Phone__c',
                                              Retailer_Email__c = 'Retailer_Email__c',
                                              Retailer_State__c = 'Retailer_State__c',
                                              Retailer_Zip_Code__c = 'Retailer_Zip_Code__c',
                                              State__c = 'State__c',
                                              TD_Store_Address_1__c = 'TD_Store_Address_1__c',
                                              TD_Store_City__c = 'TD_Store_City__c',
                                              TD_Store_Code__c = 'TD_Store_Code__c',
                                              TD_Store_Name__c = 'TD_Store_Name__c',
                                              TD_Store_State__c = 'TD_Store_State__c',
                                              TD_Store_Zip_Code__c = 'TD_Store_Zip_Code',
                                              Zip_Code__c = 'Zip_Code__c'
                                             );
        insert sd1;
        Sales_Data_Upload_Queue__c suq = new Sales_Data_Upload_Queue__c(Name = 'Sales_Data_Upload_Queue__c',
                                                                        Distributor_Id__c = distributor.Id,
                                                                        Is_Processed__c = false,
                                                                        Upload_Verification__c = uploadVerification,
                                                                        Upload_Format__c = 'UPD'
                                                                       );
        insert suq;
        DistributorSalesUploadBatch.executeBatch();
        
        sd1.Retailer_Email__c = 'distributor@gmail.com';
        update sd1;
        suq = new Sales_Data_Upload_Queue__c(Name = 'Sales_Data_Upload_Queue__c',
                                             Distributor_Id__c = distributor.Id,
                                             Is_Processed__c = false,
                                             Upload_Verification__c = uploadVerification,
                                             Upload_Format__c = 'UPD'
                                            );
        insert suq;
        DistributorSalesUploadBatch.executeBatch();
        
        CSVUtility.parseCSV('a,b,c\n1,2,3', false);
    }
    static testMethod void testDistributorUploadBatchUS(){
        String uploadVerification = 'Distributor - 07/12/2018 9:32 PM - US';
        DistributorSalesUploadBatch dsub = new DistributorSalesUploadBatch();
        DistributorSalesUploadBatch.generateCsvBodyOneRow('Id,Date,Product', null);
        DistributorSalesUploadBatch.generateCsvBodyOneRow('Id,Date,Product', 'Quantity');
        DistributorSalesUploadBatch.sendEmail(new List<String>(), '', '', new Map<String, String>{'a'=>'b'}, 'additional email');
        DistributorSalesUploadBatch.constructInternalEmailBody(false, 1, 1, 'US', '2018-05-02', 1, 1, 1, uploadVerification);
        
        insert new Custom_Code_Configuration__c(Communities_Upload_In_Progress__c = false);
        
        Account distributor = new Account(Name = 'Distributor');
        insert distributor;
        
        Product2 testProduct = new Product2(Name='Test Product');
        insert testProduct;
        Sales_Data__c sd1 = new Sales_Data__c(Upload_Verification__c = uploadVerification,
                                              Account_Name__c = 'Account_Name__c',
                                              Address_1__c = 'Address_1__c',
                                              Address_2__c = 'Address_2__c',
                                              City__c = 'City__c',
                                              Date__c = '6/2/18',
                                              Distributor_Address_1__c = 'Distributor_Address_1__c',
                                              Distributor_City__c = 'Distributor_City__c',
                                              Distributor_External_Id__c = 'Distributor_External_Id__c',
                                              Distributor_Name__c = 'Distributor_Name__c',
                                              Distributor_SFDC_Account_Id__c = distributor.Id,
                                              Distributor_State__c = 'Distributor_State__c',
                                              Distributor_Zip_Code__c = 'Distributor_Zip_Code__c',
                                              Format__c = 'US',
                                              JUUL_Item_Number__c = 'JUUL_Item_Number__c',
                                              Product__c = testProduct.Id,
                                              Quantity__c = '5',
                                              Retailer_Address_1__c = 'Retailer_Address_1__c',
                                              Retailer_Address_2__c = 'Retailer_Address_2__c',
                                              Retailer_City__c = 'Retailer_City__c',
                                              Retailer_External_Id__c = 'Retailer_External_Id__c',
                                              Retailer_Name__c = 'Retailer_Name__c',
                                              Retailer_Country__c = 'Retailer_Country__c',
                                              Retailer_Phone__c = 'Retailer_Phone__c',
                                              Retailer_Email__c = 'Retailer_Email__c',
                                              Retailer_State__c = 'Retailer_State__c',
                                              Retailer_Zip_Code__c = 'Retailer_Zip_Code__c',
                                              State__c = 'State__c',
                                              TD_Store_Address_1__c = 'TD_Store_Address_1__c',
                                              TD_Store_City__c = 'TD_Store_City__c',
                                              TD_Store_Code__c = 'TD_Store_Code__c',
                                              TD_Store_Name__c = 'TD_Store_Name__c',
                                              TD_Store_State__c = 'TD_Store_State__c',
                                              TD_Store_Zip_Code__c = 'TD_Store_Zip_Code',
                                              Zip_Code__c = 'Zip_Code__c'
                                             );
        insert sd1;
        Sales_Data_Upload_Queue__c suq = new Sales_Data_Upload_Queue__c(Name = 'Sales_Data_Upload_Queue__c',
                                                                        Distributor_Id__c = distributor.Id,
                                                                        Is_Processed__c = false,
                                                                        Upload_Verification__c = uploadVerification,
                                                                        Upload_Format__c = 'US'
                                                                       );
        insert suq;
        
        DistributorSalesUploadBatch.executeBatch();
        DistributorSalesUploadBatch.schedule();
   
        sd1.Retailer_Email__c = 'distributor@gmail.com';
        update sd1;
        
        suq = new Sales_Data_Upload_Queue__c(Name = 'Sales_Data_Upload_Queue__c',
                                             Distributor_Id__c = distributor.Id,
                                             Is_Processed__c = false,
                                             Upload_Verification__c = uploadVerification,
                                             Upload_Format__c = 'US'
                                            );
        insert suq;
        DistributorSalesUploadBatch.executeBatch();
        
        CSVUtility.parseCSV('a,b,c\n1,2,3', false);
    }
}