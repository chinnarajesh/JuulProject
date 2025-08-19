/*****************************************************************************************
*
*   @File name: ContentVersionAccountTriggerHandler
*   @File Description: Trigger to validate only one active Plan on Page file in an account.
*   @author - Sanjeev Krishnan
*
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Sanjeev Krishnan           01/06/19                 created
*
*
*****************************************************************************************/ 
 public without sharing class ContentVersionAccountTriggerHandler
  {
  
  /*update content*/
    public void updateContent(List<ContentVersion> lstCV)
    {
      if(checkRecursivetrigger.runOnce())
             { 
    Set<Id> LinkedIDs= new Set<Id>();
    Set<Id> contentDocumentIdSet = new Set<Id>();
   // map<Id,ContentDocumentLink> mapCDL= new map<Id,ContentDocumentLink>();
    for(ContentVersion cv: lstCV){
        if(cv.ContentDocumentId != null){
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
    }
    
    Set<Id> lstContentDocument = new Set<Id>();
    list<ContentDocumentLink> lstContentDocumentLink =[SELECT ContentDocumentId, LINKEDENTITYID FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet LIMIT 1000000];
     
   
    
    for(ContentDocumentLink CDL : lstContentDocumentLink){
        LinkedIDs.add(CDL.LinkedEntityId);
        lstContentDocument.add(CDL.ContentDocumentId);
    } 
    
   // List<Account> childAccount = new List<Account>([Select id,POP__c from Account where Parentid IN: LinkedIDs LIMIT 1000000]);
    
    //List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
    List<Account> AccountId = new List<Account>([select Id,POP__c from Account where Id IN: LinkedIDs LIMIT 1000000]);
     Set<Id> accID = new Set<Id>();
    for(Account Acc:AccountId)
    {
      accID.add(Acc.id);
    }
   
    List<ContentDocumentLink> allCDL =new List<ContentDocumentLink>([Select ContentDocumentId,ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN:accID AND ContentDocument.LatestPublishedVersion.Active__c =true LIMIT 1000000]);
//******* update Current Record***
   
    for(ContentVersion cv: lstCV){          
        if(cv.Plan_On_Page__c==true && cv.Active__c==true){ 
            if(cv.ContentDocumentId != null){
                for(Account Acc :AccountId )       
                { 
                Acc.POP__c = System.Label.Link_CVATriggerHandler + cv.ContentDocumentId; 
                }
              }               
            }else if(allCDL.size() == 0){
            for(Account Acc : AccountId  )
            {
                Acc.POP__c = System.Label.NoActivePOP_CVATH;
                }
        }
    }
      try
            {
         
                //database.upsert(contentDocumentList);
               
                database.upsert(AccountId);        
               
            }
             catch(Exception e)
             {  e.getMessage();
            }
//******* END update current Record***    
    if(allCDL.size()>0){
     String name= allCDL[0].ContentDocument.Title;
     
        for(ContentVersion cv: lstCV)
        {  if(cv.Active__c == true && cv.ContentDocumentId != null ){         
                (cv.Active__c).addError('Active POP file already exist :'+name);
               }
                 
            
           }
        } 
    
  }
    }
}