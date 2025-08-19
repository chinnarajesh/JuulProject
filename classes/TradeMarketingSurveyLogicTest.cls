@isTest                             
private class TradeMarketingSurveyLogicTest {
    static testMethod void testBarsUploadBatch(){
              ChildAccountShare__c sett = new ChildAccountShare__c();
        sett.Name = 'ChidlAccountShare';
        sett.Shipping_Country_List__c = 'US,United States,USA,CAN,CAD,CA';
        insert sett;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.Type='HQ';
        acc.ShippingState ='HI';
        acc.BillingCountry ='USA';
        acc.ComplianceMechanism__c='Menthol Ban';
        accList.add(acc);
        insert accList;
        
        Trade_Marketing_Survey__c tms = new Trade_Marketing_Survey__c(name='Bars Test');
        insert(tms);
        
        Trade_Marketing_Survey_Default_Question__c tmsQ = new Trade_Marketing_Survey_Default_Question__c(Trade_Marketing_Survey__c = tms.Id);
        Trade_Marketing_Survey_Default_Photo__c tmsP = new Trade_Marketing_Survey_Default_Photo__c(Trade_Marketing_Survey__c = tms.Id);
        insert(tmsQ);
        insert(tmsP);
        
        tmsQ = [SELECT Name FROM Trade_Marketing_Survey_Default_Question__c WHERE Id=: tmsQ.Id LIMIT 1];
        tmsP = [SELECT Name FROM Trade_Marketing_Survey_Default_Photo__c WHERE Id =: tmsP.Id LIMIT 1];
        
        TradeMarketingSurveyUploadBatch tmsBatch = new TradeMarketingSurveyUploadBatch('Test','Test','Bars');
        tmsBatch.tmsData = new List<List<String>>{
            new List<String>{'Questions','Test Question','Test Photo'},
            new List<String>{'Survey','Bars Test','Bars Test'},
            new List<String>{'Question Type','Question','Photo'},
            new List<String>{'SF Question Id',tmsQ.Name,tmsP.Name},
            new List<String>{acc.Id,'Test 1','Test.JPG'}
        };
        Test.startTest();
            database.executeBatch(tmsBatch);
        Test.stopTest();
    }
    static testMethod void testCSVUtility(){
        CSVUtility.parseCSV('Test,Test,Test,Test\nTest,Test,Test,Test', false);  
    }
}