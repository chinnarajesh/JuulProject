/**********************************************************************/
/* Developer Name: Pooja Gite
/* Class Name: ContentDocumentLinkUpdateOnCase                        */
/* Description: This class is to link content document link Name to Case filed.*/
/*TIcket: JTP-164
/**********************************************************************/
public class ContentDocumentLinkUpdateOnCase {
    public static void ContentDocumentLinkUpdateOnCases(List<Case> caseList)
    {
        //system.debug('Inside Content doc link'+caseList);
        List<ContentDocumentLink> contentDocLinksList = new List<ContentDocumentLink>();
        Set<Id> accIDs = new Set<Id>();
        Set<Id> accParentIDs = new Set<Id>();
        //list<contentdocument> Cdocidlst = [select id from contentdocument ORDER BY createdDate DESC limit 1] ;
        
        Integer count = 10;
		List<contentdocument> Cdocidlst = new List<contentDocument>();
		Date queryDate = system.today();
		queryDate = queryDate.addDays(-count);
		Cdocidlst = [select id 
						from contentdocument 
						where createdDate >= :queryDate 
						ORDER BY createdDate DESC 
						limit 1] ;
				
		if(Cdocidlst.size()  < 1){
			queryDate = queryDate.addDays(-(count*3));		
			Cdocidlst = [select id 
						from contentdocument 
						where createdDate >= :queryDate 
						ORDER BY createdDate DESC 
						limit 1] ;
		}                   
        
        system.debug('*******************************'+Cdocidlst);
        
        id cdocid ;
        for (contentdocument cd:Cdocidlst){
        cdocid=cd.id;
       system.debug('*******************************'+cdocid);

        
        
        }
       
        Id EACCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EAC Certification').getRecordTypeId();
        
        for(Case cs: caseList){
            if(cs.RecordTypeId == EACCertCaseRecordTypeId && cs.AccountId!=null)
            {
               accIDs.add(cs.AccountId);  
            }
        }
       // system.debug('accIDs: '+accIDs);
        if(accIDs.size()>0){
        for(Account a: [Select Id,ParentId from Account where Id IN: accIDs]){
            accParentIDs.add(a.ParentId);
        }
            
        }
        system.debug('accParentIDs: '+accParentIDs);
        
        if(accParentIDs.size()>0 && !accParentIDs.isempty() ){ 
        contentDocLinksList = [SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in  : accParentIDs AND ContentDocumentId =: Cdocid ];
        }
        system.debug('contentDocLinksList: '+contentDocLinksList);
        
        Set<Id> contentDocIds = new Set<Id>();
        for(ContentDocumentLink contentDocLink : contentDocLinksList) 
        {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }
        system.debug('contentDocIds: '+contentDocIds);
        Map<ID, contentVersion> contentVersions = new Map<ID, contentVersion>();
        for( contentVersion cv: [SELECT Id,ContentUrl,ContentDocumentId, Title FROM ContentVersion 
                                 WHERE ContentDocumentId IN :contentDocIds 
                                 AND IsLatest = True ORDER BY createdDate DESC limit 1])
            {
            contentVersions.put(cv.ContentDocumentId,cv);
            }
            system.debug('contentVersions: '+contentVersions);
            for(Case cs : caseList){
            for(ID dK : contentDocIds)
            {
            if(contentVersions.containskey(dk))
            {
            cs.Attachment_Name__c = contentVersions.get(dk).Title;
            }
            }
            }
      System.debug('caseList'+caseList);
    // update caseList;
    }
}