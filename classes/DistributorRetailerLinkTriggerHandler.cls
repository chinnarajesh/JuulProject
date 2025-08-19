public class DistributorRetailerLinkTriggerHandler{
    public static Boolean INSERT_TRIGGER_BYPASS = false;
    public static void handleAfterInsert(List<Distributor_Retailer_Link__c> triggerObjects){
        if(!INSERT_TRIGGER_BYPASS){
            checkDuplicateLinks(triggerObjects);  
            createACRforDistributors(triggerObjects);   
        }
    }
    public static void createACRforDistributors(List<Distributor_Retailer_Link__c> newRecords){
          Try{
              Set<String> distributorIDs=new Set<String>();
              Set<String> retailerIDs=new Set<String>();
              list<AccountContactRelation> acrList=new List<AccountContactRelation>();
              List<AccountShare> shares = new list<AccountShare>();

              Map<String,String> retailvsDistributorMap=new Map<String,String>();
              for(Distributor_Retailer_Link__c drl:newRecords){
                     if(drl.Distributor__c!=null){
                         distributorIDs.add(drl.Distributor__c);
                     }
              }
             Map<id,List<user>> distributorMap=new Map<id,List<user>>();
             for(User userRecord:[SELECT Id,Contact.Id,Accountid,Name,Email FROM User WHERE IsActive=TRUE AND AccountID!=null and AccountID IN :distributorIDs]){
                   if(!distributorMap.containsKey(userRecord.Accountid))
                   distributorMap.put(userRecord.Accountid, new List<user> ());
                   distributorMap.get(userRecord.Accountid).add( userRecord);   
             }
             for(Distributor_Retailer_Link__c drl:newRecords){
                     if(drl.Distributor__c!=null && drl.Retailer__c!=null && distributorMap.containskey(drl.Distributor__c)){
                         for(User user:distributorMap.get(drl.Distributor__c)){
                           AccountContactRelation acr=new AccountContactRelation(
                           Accountid=drl.Retailer__c,contactId=user.contactId);
                           acrList.add(acr);
                           system.debug('ACR'+acr);
                           /**
                           
                          
                           AccountShare accountshare=new AccountShare(
                           AccountId= drl.Retailer__c,
                           UserOrGroupId = user.id,
                           AccountAccessLevel= 'Read'
                           );
                           shares.add(accountshare);
                             **/
                         }
                     }
              }
              system.debug('acrList:'+acrList.size());
              if(!acrList.isEmpty()){
                Database.insert(acrList,false);
              }
              }
              catch(Exception ex){
              system.debug('Exception:'+ex.getmessage());
              }
             
    }
    public static void checkDuplicateLinks(List<Distributor_Retailer_Link__c> triggerObjects){
        System.debug('Begin Checking for Duplicate Links');
        Set<Id> distributorIds = new Set<Id>();
        Set<Id> retailerIds = new Set<Id>();
        Map<Id,Map<Id,Distributor_Retailer_Link__c>> insertedLinkMap = new Map<Id,Map<Id,Distributor_Retailer_Link__c>>(); //Distributor Id -> Retailer Id -> Link

        for(Distributor_Retailer_Link__c distLink : triggerObjects){
            distributorIds.add(distLink.Distributor__c);
            retailerIds.add(distLink.Retailer__c);

            if(!insertedLinkMap.containsKey(distLink.Distributor__c))
                insertedLinkMap.put(distLink.Distributor__c, new Map<Id,Distributor_Retailer_Link__c>());
            
            insertedLinkMap.get(distLink.Distributor__c).put(distLink.Retailer__c, distLink);
        }

        Map<Id,Set<Id>> existingLinks = new Map<Id,Set<Id>>();

        for(Distributor_Retailer_Link__c existingLink : [SELECT Distributor__c, Retailer__c, Id FROM Distributor_Retailer_Link__c WHERE Distributor__c IN : distributorIds AND Retailer__c IN : retailerIds]){
            if(insertedLinkMap.containsKey(existingLink.Distributor__c) && insertedLinkMap.get(existingLink.Distributor__c).containsKey(existingLink.Retailer__c) && existingLink.Id != insertedLinkMap.get(existingLink.Distributor__c).get(existingLink.Retailer__c).Id){
                insertedLinkMap.get(existingLink.Distributor__c).get(existingLink.Retailer__c).addError('This Distributor/Retailer Link already exists.');
            }
        }
    }
        
    public static void handleBeforeInsert(List<Distributor_Retailer_Link__c> triggerObjects){   
       for(Distributor_Retailer_Link__c distLink : triggerObjects){ 
            distLink.External_ID__c = distLink.Distributor__c+'_'+distLink.Retailer__c;   
        }
    }
}