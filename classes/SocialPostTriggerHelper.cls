/*
Helper class for Trigger on Social Post
*/
public without sharing class SocialPostTriggerHelper {
    
    public static List<SocialPost> newList;
    public static List<SocialPost> oldList;
    public static Map<Id, SocialPost> newMap;
    public static Map<Id, SocialPost> oldMap;
    
    public static Boolean runTrigger = true;
    
    /*
    * Method to delete the new contact associated with social post. 
    If contact is exist with given email id , will use existing one
    else create new contact
    */
    public static void deleteContacts(){
    
        List<SocialPost> applicableSociaPosts = new List<SocialPost>();
        
        Set<String> emailsInPostTag = new Set<String>();
        for(SocialPost sp : newList){
            if( sp.PostTags != null ) {
                emailsInPostTag.add( sp.PostTags );
                applicableSociaPosts.add( sp );
            }
        }
        
        if( applicableSociaPosts.size() > 0 ) {
        
            List<String> exisitngEmailsList = new List<String>();
            List<Account> accLists = [Select Id,PersonEmail from Account 
                                      Where PersonEmail in: emailsInPostTag
                                      And PersonEmail !=: NULL ];
                                      
            Set<Id> newAccIds = new Set<Id>();
            Map<Id, String> newAccountToUpdateMap = new Map<Id, String>();
            Set<Id> personaIds = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            Map<String, Account> mapEmailToAccount = new Map<String, Account>();
            if(accLists.size() > 0){
                for(Account acc : accLists){
                    mapEmailToAccount.put( acc.PersonEmail.toLowerCase(), acc );
                } 
            }
            
            
            Map<Id, Account> mapSPIDToAccount = new Map<Id, Account>();
            
            for(SocialPost sp : applicableSociaPosts){
                //Check post tag contains email  
                if( sp.PostTags != null 
                    && sp.PostTags != '' 
                    && mapEmailToAccount.containsKey( sp.PostTags.toLowerCase() )) {
                    
                     Account matchedAccountForEmail = mapEmailToAccount.get( sp.PostTags.toLowerCase() );
                     mapSPIDToAccount.put( sp.Id, matchedAccountForEmail );
                     exisitngEmailsList.add(sp.PostTags);
                     // ids of account that will be deleted
                     newAccIds.add(sp.WhoId); 
                     personaIds.add(sp.PersonaId);
                     caseIds.add(sp.ParentId); 
                }
                else{
                       newAccountToUpdateMap.put(sp.WhoId , sp.PostTags); 
                }
            }
            
            if(exisitngEmailsList.size() > 0 
                && newAccIds.size() > 0){
                
                //Check if contact exists in SF, Also check for social Persona and Case associated with social post
                if( mapSPIDToAccount.size() > 0){
                    
                    
                    List<SocialPersona> socialpersonaToUpdate = new List<SocialPersona>();
                    List<SocialPost> spToUpdate = new List<SocialPost>();
                    List<Case> caseToUpdate = new List<Case>();
                    
                    Map<Id, Case> casesFromDB = new Map<Id, Case>( [Select id, status 
                               from case where 
                               Id =: caseIds 
                               AND Status != 'Closed' 
                               AND Status != 'New'
                              ]); 
                    
                    //assign existing contact id to social post whoId and update it.
                    for(SocialPost sp : applicableSociaPosts){
                        if( mapSPIDToAccount.containsKey( sp.Id )) {
                            Account matchedAcc = mapSPIDToAccount.get( sp.Id ); 
                            spToUpdate.add(new SocialPost(Id = sp.Id, 
                            WhoId = matchedAcc.Id));
                            
                            SocialPersona sper = new SocialPersona( Id = sp.PersonaId );
                            sper.ParentId = matchedAcc.Id;
                            socialpersonaToUpdate.add( sper );
                            
                            Case caseObj = new Case( Id = sp.ParentId );
                            caseObj.AccountId = matchedAcc.Id;
                            if( casesFromDB.containsKey( caseObj.Id )) {
                                caseObj.Status = 'Open';
                            }
                            caseToUpdate.add( caseObj );
                        }
                    }
                    
                    update socialpersonaToUpdate;
                    
                    runTrigger = False;
                    update spToUpdate;
                    runTrigger = True;
                    
                    update caseToUpdate;
                    
                    //Check if new contact exist in SF
                    if(newAccIds.size() > 0 ){
                        accountToDelete(newAccIds);
                    }
                }
            }
            if(newAccountToUpdateMap.size() > 0) {
                accountToUpdate(newAccountToUpdateMap);
            }
        }
    }
    
    @Future
    public static void accountToDelete(Set<Id> accIds){
        //Delete the newly created contact
        delete [select id from Account where id =: accIds];       
    }
    
    @Future
    public static void accountToUpdate(Map<Id, String> accToUpdate){
        //Delete the newly created contact
        List<Account> acclist = [Select id, PersonEmail from Account where Id =: accToUpdate.keySet()];
        for(Account acc : accList){
            acc.PersonEmail = accToUpdate.get(acc.Id);
        }
        update acclist;       
    }
    
}