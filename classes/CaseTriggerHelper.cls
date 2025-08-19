/*
Class having trigger helper methods for trigger on Case object
*/
public with sharing class CaseTriggerHelper {
    public static List<Case> newList;
    public static List<Case> oldList;
    public static Map<Id, Case> newMap;
    public static Map<Id, Case> oldMap;
    
     public static Boolean runTrigger = true;
    
    @Future
    public static void updateContactsFuture(Set<Id> caseIds) {
        
        List<Case> cases = [ Select SourceId, ContactId 
                            From Case where id IN: caseIds And SourceId != null ];
        Set<Id> spIds = new Set<Id>();
        
        Map<Id, Case> mapSourceIdToCase = new Map<Id, Case>();
        for( Case caseObj : cases ) {
            if( CaseObj.SourceId != null && String.ValueOf(caseObj.SourceId).startsWith('0ST')){   
                mapSourceIdToCase.put(caseObj.SourceId , caseObj);
            }
        }
        List<SocialPost> spList = [Select id, content 
                                   , notes 
                                   from SocialPost 
                                   where Id =:mapSourceIdToCase.keySet()];
        Map<Id, Case> mapCaseToUpdate = new Map<Id, Case>();
       
        for(SocialPost sp : spList){
            Case caseObj = mapSourceIdToCase.get( sp.Id );
            if(sp.Content != null && sp.Content != '' && caseObj != null ){
                caseObj.Post_Content__c =  sp.Content;
                caseObj.Priority =  'High';
                if(sp.Notes != null && sp.Notes != ''){
                   caseObj.Description = sp.Notes;
                }
                mapCaseToUpdate.put( caseObj.Id, caseObj );
            }
            
        }
        if( mapCaseToUpdate.size() > 0 ) {
            update mapCaseToUpdate.values();
        }
    }
    
    public static void updateContacts(){
        updateContactsFuture( Trigger.newMap.keySet() );
    }
    
    public void populateScoreOninsert(List<Case> lstCases) {
      map<String,Case_Issue__c> mpCaseIssue = Case_Issue__c.getAll();
      for(Case cs : lstCases) {
        if(cs.Issue__c != NULL && mpCaseIssue.containsKey(cs.Issue__c)) {
          cs.Case_Score__c = mpCaseIssue.get(cs.Issue__c).Point_Value__c;
        }
      } 
    }
    
    
    
}