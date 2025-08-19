global class TradeMarketingSurveyWebservice {
    webservice static Id cloneTradeMarketingSurvey(Id id){
        Trade_Marketing_Survey__c existingTMS = [SELECT Id, Name FROM Trade_Marketing_Survey__c WHERE Id = : id LIMIT 1];
        
        Trade_Marketing_Survey__c newTMS = new Trade_Marketing_Survey__c(Name = 'Copy of ' + existingTMS.Name);
        insert(newTMS);
        
        List<Trade_Marketing_Survey_Default_Question__c> existingTMSQS = [SELECT Id,Category__c, Answer__c,Answer_Options__c, Question__c, Question_Answer_Type__c, Required__c,Sort_Order__c FROM  Trade_Marketing_Survey_Default_Question__c WHERE Trade_Marketing_Survey__c = : id];
        List<Trade_Marketing_Survey_Default_Question__c> newTMSQS = new List<Trade_Marketing_Survey_Default_Question__c>();
        
        
        for(Trade_Marketing_Survey_Default_Question__c existingTMSQ : existingTMSQS){
            Trade_Marketing_Survey_Default_Question__c newTMSQ = existingTMSQ.clone(false,false,false,false);
            newTMSQ.Trade_Marketing_Survey__c = newTMS.Id;
            newTMSQS.add(newTMSQ);
        }
        
        List<Trade_Marketing_Survey_Default_Photo__c> existingTMSPS = [SELECT Id, Category__c,Description__c,Required__c FROM  Trade_Marketing_Survey_Default_Photo__c WHERE Trade_Marketing_Survey__c = : id];
        List<Trade_Marketing_Survey_Default_Photo__c> newTMSPS = new List<Trade_Marketing_Survey_Default_Photo__c>();
        
        
        for(Trade_Marketing_Survey_Default_Photo__c existingTMSP : existingTMSPS){
            Trade_Marketing_Survey_Default_Photo__c newTMSP = existingTMSP.clone(false,false,false,false);
            newTMSP.Trade_Marketing_Survey__c = newTMS.Id;
            newTMSPS.add(newTMSP);
        }
        
        insert(newTMSQS);
        insert(newTMSPS);
        return newTMS.Id;
    }
}