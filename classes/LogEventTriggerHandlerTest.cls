@isTest(seeAllData = false)
public class LogEventTriggerHandlerTest{

     public static testMethod void insertLog_Test1(){
     List<Account> testAccDataToInsert = new List<Account>();
     List<Product2> testProdDataToInsert = new List<Product2>();
     List<Asset_Request_Iteam__c> listAssetReqItemToInsert = new List< Asset_Request_Iteam__c>();
     List<Field_B2B_Goods_Request__c> listFieldB2BToInsert = new List<Field_B2B_Goods_Request__c>();
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
        //accList.add testAccDataToInsert;
         
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
            for(Integer n=0;n<1;n++){
                listFieldB2BToInsert.add(new Field_B2B_Goods_Request__c(
                                        RecordTypeId = Schema.SObjectType.Field_B2B_Goods_Request__c.getRecordTypeInfosByName().get('Marketing Assets').getRecordTypeId(),
                                        Status__c = 'Approved',
                                        Account__c = acct.id
                                        ));
            }
        }
       // insert listFieldB2BToInsert;
        for(Integer p=0;p<24;p++){
            Field_B2B_Goods_Request__c fieldRec = listFieldB2BToInsert[p];
            for(Integer q=0;q<1;q++){
                listAssetReqItemToInsert.add(new Asset_Request_Iteam__c(
                                     Asset__c = testProdDataToInsert[0].id,
                                     Quantity__c = 10,
                                     Field_B2B_Goods_Request__c=listFieldB2BToInsert[p].id
                                    ));
            }
            for(Integer r=0;r<1;r++){
                listAssetReqItemToInsert.add(new Asset_Request_Iteam__c(
                                     Asset__c = testProdDataToInsert[1].id,
                                     Quantity__c = 10,
                                     Field_B2B_Goods_Request__c=listFieldB2BToInsert[p].id
                                    ));
            }
            
        }
        Database.SaveResult[] srList = Database.insert(listAssetReqItemToInsert, false);
        List<Database.Error> errorData = new List<Database.Error>();
        for(Integer index = 0, size = srList.size(); index < size; index++) {
               if(!srList[index].isSuccess()){
                  LogEventTriggerHandler.insertBatchLog(srList[index].getErrors(), 'Test', 'Test', 'Test', 'Test');
               }
           }
        
    }
     public static testMethod void insertLog_Test2(){
         List<Log_Event__e> logToInsert = new List<Log_Event__e >();
         for(Integer i=0; i<10; i++){
             logToInsert.add(new Log_Event__e(
                               Message__c = 'Test Message'  
                             ));
         }
        List<Database.SaveResult> sr = EventBus.publish(logToInsert);
        LogEventTriggerHandler.insertLog(logToInsert);
     }
}