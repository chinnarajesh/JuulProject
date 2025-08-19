@isTest(SeeAllData = false)
public class AssetRequestItemTriggerHandlerTest{
    @testSetup static void testDataPrep(){
    
     ChildAccountShare__c sett = new ChildAccountShare__c();
     sett.Name = 'ChidlAccountShare';
     sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
     insert sett;
     
     List<Account> testAccDataToInsert = new List<Account>();
     List<Asset> testAssetDataToInsert = new List<Asset>();
     List<Product2> testProdDataToInsert = new List<Product2>();
     List<Asset_Request_Iteam__c> listAssetReqItemToInsert = new List< Asset_Request_Iteam__c>();
     List<Field_B2B_Goods_Request__c> listFieldB2BToInsert = new List<Field_B2B_Goods_Request__c>();
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AssetRequestItemTrigger',Enabled__c=true);
        insert(triggerController);
       /**** Creation of Account records *****/ 
        for(Integer i=0; i<24; i++){
            Account accRec = new Account();
            accRec.Name='TestAccount '+i;
            accRec.ShippingStreet = 'Test Street'+i;
            accRec.ShippingCity = 'Test City'+i;
            accRec.ShippingState = 'Test State'+i;
            accRec.ShippingPostalCode ='945'+i;
            accRec.ShippingCountry='US';
            accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
            testAccDataToInsert.add(accRec);
        }
        insert testAccDataToInsert;
      /**** Creation of Product records *****/
        Product2 p1 = new Product2();
            p1.Name = 'Test Product';
            p1.Family ='Marketing Assets';
            p1.isActive = true;
        testProdDataToInsert.add(p1);
         Product2 p2 = new Product2();
            p2.Name = 'Test Product';
            p2.Family ='Marketing Assets';
            p2.isActive = false;
        testProdDataToInsert.add(p2);
        insert testProdDataToInsert;
       /**** End of creation of Product records *****/  
       /**** Creation of Asset records *****/ 
        for (Integer j=0;j<24;j++) {
            Account acct = testAccDataToInsert[j];
            for (Integer k=0;k<1;k++){
                testAssetDataToInsert.add(new Asset(Name=acct.Name + ' Asset ' + k,
                                       Quantity = 10,
                                       Status = 'Approved',
                                       Product2Id =testProdDataToInsert[0].id,
                                       AccountId=acct.Id));
            }
            for(Integer n=0;n<1;n++){
                listFieldB2BToInsert.add(new Field_B2B_Goods_Request__c(
                                        RecordTypeId = Schema.SObjectType.Field_B2B_Goods_Request__c.getRecordTypeInfosByName().get('Marketing Assets').getRecordTypeId(),
                                        Status__c = 'Approved',
                                        BDF__c = true,
                                        Account__c = acct.id,
                    					Additional__c = 'Test data for Field B2B Goods Request',
                    					Shipping_Country__c = 'US',
        								Shipping_State__c = 'CA'
                                        ));
            }
        }
        insert testAssetDataToInsert;
        insert listFieldB2BToInsert;
        for(Integer p=0;p<24;p++){
            Field_B2B_Goods_Request__c fieldRec = listFieldB2BToInsert[p];
            for(Integer q=0;q<1;q++){
                listAssetReqItemToInsert.add(new Asset_Request_Iteam__c(
                                     Asset__c = testProdDataToInsert[0].id,
                                     Quantity__c = 10,
                                     Status__c = 'Requested',
                                     Field_B2B_Goods_Request__c=listFieldB2BToInsert[p].id,
                                     Retailer_Asset_Id__c = testAssetDataToInsert[p].id
                    				 ));
            }
            
        }
        insert listAssetReqItemToInsert;
        
    }
    private static testMethod void updateStatusOnAsset_Test(){
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='AssetRequestItemTrigger',Enabled__c=true);
        insert(triggerController);
    List<Asset_Request_Iteam__c> listAssetReqItemToUpdate = new List< Asset_Request_Iteam__c>();
      List<Asset_Request_Iteam__c> listAssetReq = [Select Id, Status__c,Asset__c,Quantity__c,Field_B2B_Goods_Request__c,Retailer_Asset_Id__c from Asset_Request_Iteam__c LIMIT 25];
       Map<Id,Asset_Request_Iteam__c> oldMap = new Map<Id,Asset_Request_Iteam__c>();
        for(Asset_Request_Iteam__c rt : listAssetReq){
            oldMap.put(rt.ID, rt);
        }
      System.debug('listAssetReqlistAssetReq******************* '+listAssetReq);
      for(Asset_Request_Iteam__c aReq : listAssetReq){
          aReq.Status__c = 'Shipped';
          listAssetReqItemToUpdate.add(aReq);
      } 
      update listAssetReqItemToUpdate; 
        AssetRequestItemTriggerHandler.updateStatusOnAsset(listAssetReqItemToUpdate,oldMap);
    }
}