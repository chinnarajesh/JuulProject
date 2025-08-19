/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       05-17-2021                    */
/* Class Name: UndeleteAssetBatchTest                       */
/* Description: Test class for coverage UndeleteAssetBatchTest  */
 /*Ticket Number:     */
/**********************************************************************/
@isTest(SEEALLDATA = FALSE)
public class UndeleteAssetBatchTest {
    
    @TestSetup
    public static void custData(){
        ChildAccountShare__c sett = new ChildAccountShare__c();
      sett.Name = 'ChidlAccountShare';
      sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
      insert sett;
    }    
    static testmethod void userRestrictAsset(){
                 
        Profile p = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.LastName = 'Ownbackup User';
        u.Alias = 'ownb';
        u.Email = 'ownbackup@gmail.com';
        u.Username = 'ownbackup@gmail.com';
        u.ProfileId = p.Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.TimeZoneSidKey =  'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        System.runAs(u){          
                     
            Account acc = new Account();
            acc.Name = 'Test Account 1';
            insert acc; 
            
            List<Product2> lstPrd = new List<Product2>();
            Product2 pr = new Product2();
            pr.Name = 'US Basic Device Kit Silver';
            pr.ProductCode = 'J1D1846';
            pr.ProductPricingFamily__c = 'DK';
            pr.Family = 'Devices';            
            lstPrd.add(pr);  
            insert  LstPrd;
            
            List<Asset> assLst = new List<Asset>();
            Asset asst = new Asset();
            asst.Name = 'Test asset';
            asst.Product2Id = pr.Id;
           asst.AccountId = acc.Id;
           asst.Quantity = 12;
            asst.PurchaseDate = Date.today();
            asst.CurrencyIsoCode ='USD';
            assLst.add(asst);
            insert assLst;
            
            Test.startTest();
            delete assLst;  
            List<Asset> lstAsset = [SELECT Id, Name FROM Asset WHERE isDeleted=true ALL ROWS];
            //undelete c1;
            UndeleteAssetBatch restrictBatchAsset = new UndeleteAssetBatch();
            Database.executeBatch(restrictBatchAsset);
            Test.stopTest();
            
            Asset a1 = [SELECT Id, Name FROM Asset WHERE Id =: asst.Id];
            System.assertEquals(a1.Name, 'Test asset');
        }
    }
}