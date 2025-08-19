public class TMSDefaultQuestionTriggerHandler{
    public static void InsertHandler(List<Trade_Marketing_Survey_Default_Question__c> newTriggerObjects){
        database.executeBatch(new TradeMarketingSurveyUtilityBatch('Add Default Member Question',newTriggerObjects));
    }
    public static void DeleteHandler(List<Trade_Marketing_Survey_Default_Question__c> newTriggerObjects){
        database.executeBatch(new TradeMarketingSurveyUtilityBatch('Delete Default Member Question',newTriggerObjects));
    }
}