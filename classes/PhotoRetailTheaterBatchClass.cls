global class PhotoRetailTheaterBatchClass implements Database.Batchable<sObject>, Database.Stateful{
    
      //public Map<string,Number> ContenntveriosnMap = new Map<string,Number>();

      public Map<string,string> TotalContenntveriosnMap = new Map<string,string>();
      global Database.Querylocator start (Database.BatchableContext BC) {
          
        return Database.getQueryLocator('SELECT id,Checksum FROM ContentVersion');
        }

      global void execute (Database.BatchableContext BC,List<ContentVersion> ContentVersionList) {
          
          for(ContentVersion ct : ContentVersionList){

            List<ContentVersion> DulicatchecksumList =[SELECT id,Checksum,ContentDocumentId FROM ContentVersion where Checksum =: ct.Checksum and Retail_Theater__c =null and DuplicateCheck__c =False];
            if(DulicatchecksumList.size()>1){
                //system.debug('Duplicate ct ++ '+ct.Checksum+':'+ct.id);
                //system.debug('Duplicate ct ++ '+ct.Checksum+':'+ct.get('Checksum'));

                Set<Id> ContentDocumentIdSet = new Set <Id>();
                for(ContentVersion ct1 : DulicatchecksumList){
                  ContentDocumentIdSet.add(ct1.ContentDocumentId);
                }
                List<ContentDocumentLink> ContentDocumentLinkList =[SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId, ShareType,LinkedEntity.Type FROM ContentDocumentLink where ContentDocumentId IN: ContentDocumentIdSet];
               
                List<ContentVersion> UpdateContentVersionList = new List<ContentVersion>();
                for(ContentDocumentLink ct2 : ContentDocumentLinkList){
                  Map<Id,Retail_Theater__c> RetailTheaterMap = new Map<Id,Retail_Theater__c>([SELECT id,Name FROM Retail_Theater__c where id =: ct2.LinkedEntityId]);
                  if(RetailTheaterMap.size()>0){
                    Map<Id,ContentVersion> ContentVersionList2 =new Map<Id,ContentVersion>([SELECT id,ContentDocumentId,Retail_Theater__c,DuplicateCheck__c FROM ContentVersion where ContentDocumentId =: ct2.ContentDocumentId]);
                    ContentVersion ct3 = ContentVersionList2.get(ct2.ContentDocumentId);
                    ct3.Retail_Theater__c = ct2.LinkedEntityId;
                    ct3.DuplicateCheck__c=true;
                    UpdateContentVersionList.add(ct3);
                  }
                }
                if(UpdateContentVersionList.size()>0){
                  update UpdateContentVersionList;
                }
              //TotalContenntveriosnMap.put(ct.Checksum,string.valueOf(ct.get('repeatedCount')));
          }
        }
       }
      global void finish(Database.BatchableContext BC){
         
        System.debug('TotalRecordsCount++ '+TotalContenntveriosnMap.size());
        System.debug('TotalRecords '+TotalContenntveriosnMap);      
      }
}