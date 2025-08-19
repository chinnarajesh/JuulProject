public class TradeMarketingSurveyUtilityBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String mode;
    
    //Mode Variables
    Set<Id> TMSIds;
    List<Trade_Marketing_Survey_Default_Question__c> TMSDefaultQuestions;

    public TradeMarketingSurveyUtilityBatch(String m,List<Trade_Marketing_Survey_Default_Question__c> q) {
        mode = m;
        TMSDefaultQuestions = q;
        TMSIds = new Set<Id>();
        for(Trade_Marketing_Survey_Default_Question__c TMSDefaultQuestion : TMSDefaultQuestions){
            TMSIds.add(TMSDefaultQuestion.Trade_Marketing_Survey__c);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(mode == 'Add Default Member Question'){
            return Database.getQueryLocator([SELECT Id,Trade_Marketing_Survey__c FROM Trade_Marketing_Survey_Member__c WHERE Trade_Marketing_Survey__c IN : TMSIds AND Total_Questions__c > 0]);
        }
        else if(mode == 'Delete Default Member Question'){
            return Database.getQueryLocator([SELECT Id,Question__c, Trade_Marketing_Survey_Member__r.Trade_Marketing_Survey__c FROM Trade_Marketing_Survey_Member_Question__c WHERE Trade_Marketing_Survey_Member__r.Trade_Marketing_Survey__c IN : TMSIds]);
        }
        else
            return null;
    } 

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(mode=='Add Default Member Question'){
            Map<Id,List<Trade_Marketing_Survey_Default_Question__c>> TMStoQuestions = new Map<Id,List<Trade_Marketing_Survey_Default_Question__c>>();

            for(Trade_Marketing_Survey_Default_Question__c newTriggerObject : TMSDefaultQuestions){
                if(!TMStoQuestions.containsKey(newTriggerObject.Trade_Marketing_Survey__c))
                    TMStoQuestions.put(newTriggerObject.Trade_Marketing_Survey__c,new List<Trade_Marketing_Survey_Default_Question__c>());

                TMStoQuestions.get(newTriggerObject.Trade_Marketing_Survey__c).add(newTriggerObject);
            }

            List<Trade_Marketing_Survey_Member_Question__c> newQuestions = new List<Trade_Marketing_Survey_Member_Question__c>();

            for(sObject scopeObj:scope){
                Trade_Marketing_Survey_Member__c member = (Trade_Marketing_Survey_Member__c)scopeObj;
                for(Trade_Marketing_Survey_Default_Question__c defaultQuestion : TMStoQuestions.get(member.Trade_Marketing_Survey__c)){
                    Trade_Marketing_Survey_Member_Question__c newQuestion = new Trade_Marketing_Survey_Member_Question__c(Trade_Marketing_Survey_Member__c=member.Id);
                    newQuestion.Sort_Order__c = defaultQuestion.Sort_Order__c;
                    newQuestion.Answer__c = defaultQuestion.Answer__c;
                    newQuestion.Answer_Options__c = defaultQuestion.Answer_Options__c;
                    newQuestion.Category__c = defaultQuestion.Category__c;
                    newQuestion.Question__c = defaultQuestion.Question__c;
                    newQuestion.Question_Answer_Type__c = defaultQuestion.Question_Answer_Type__c;
                    newQuestion.Required__c = defaultQuestion.Required__c;
                    newQuestions.add(newQuestion);
                }
            }

            insert(newQuestions);
        }
        else if(mode=='Delete Default Member Question'){
            Map<Id,Set<String>> TMStoQuestionsToDelete = new Map<Id,Set<String>>();
            
            for(Trade_Marketing_Survey_Default_Question__c newTriggerObject : TMSDefaultQuestions){
                if(!TMStoQuestionsToDelete.containsKey(newTriggerObject.Trade_Marketing_Survey__c))
                    TMStoQuestionsToDelete.put(newTriggerObject.Trade_Marketing_Survey__c,new Set<String>());

                TMStoQuestionsToDelete.get(newTriggerObject.Trade_Marketing_Survey__c).add(newTriggerObject.Question__c);
            }

            List<Trade_Marketing_Survey_Member_Question__c> questionsToDelete = new List<Trade_Marketing_Survey_Member_Question__c>();

            for(sObject scopeObj: scope){
                Trade_Marketing_Survey_Member_Question__c question = (Trade_Marketing_Survey_Member_Question__c)scopeObj;
                if(TMStoQuestionsToDelete.get(question.Trade_Marketing_Survey_Member__r.Trade_Marketing_Survey__c).contains(question.Question__c))
                    questionsToDelete.add(question);
            }     

            delete(questionsToDelete);
        }
    }


    public void finish(Database.BatchableContext BC){}

}