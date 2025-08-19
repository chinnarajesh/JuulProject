public class JuulCommunityUserService{

    @future
    public static void addPortalUserToRetailers(set<String> userIdSet ){
        
        Map<String,set<String>> distributorVsPortalUser = new Map<String,Set<String>>();
        for(user user:[select id,accountid,contactid from user where id in:userIdSet and isactive=true]){
                  if(!distributorVsPortalUser.containsKey(user.accountid))
                    distributorVsPortalUser.put(user.accountid, new Set<String> ());
                    distributorVsPortalUser.get(user.accountid).add(user.contactid);  
        }
        system.debug('****distributorVsPortalUser:'+distributorVsPortalUser);
        List<AccountContactRelation> acrList= new List<AccountContactRelation>();
         Map<String,Set<String>> accountidToContactId=new  Map<String,Set<String>>();
         Set<String> retailerSet=new Set<String>();
        List<Distributor_Retailer_Link__c>  drlList=[select id,name,Retailer__c,Distributor__c from Distributor_Retailer_Link__c where Distributor__c in:distributorVsPortalUser.keyset()];
        for(Distributor_Retailer_Link__c  drl:drlList){
               if(drl.Retailer__c!=null){
                   retailerSet.add(drl.Retailer__c);
               }
        }
                system.debug('****drlList:'+drlList.size());

        for(AccountContactRelation existingACR:[select Accountid,Contactid from AccountContactRelation where accountid in:retailerSet]){
                    if(!accountidToContactId.containsKey(existingACR.Accountid))
                    accountidToContactId.put(existingACR.Accountid, new Set<String> ());
                    accountidToContactId.get(existingACR.Accountid).add(existingACR.contactid);  
         }
         system.debug('****accountidToContactId:'+accountidToContactId.size());
         Set<String> UniQueSet=new  Set<String>();
        for(Distributor_Retailer_Link__c  drl:drlList){
            if(distributorVsPortalUser.containsKey(drl.Distributor__c)){
              for(String ContactId:distributorVsPortalUser.get(drl.Distributor__c)){
                     if(!accountidToContactId.containskey(drl.Retailer__c) || (accountidToContactId.containskey(drl.Retailer__c) && !accountidToContactId.get(drl.Retailer__c).Contains(ContactId))){
                               
                               if(!UniQueSet.contains(drl.Retailer__c+''+ContactId)){
                                AccountContactRelation acr= new AccountContactRelation(AccountId=drl.Retailer__c,
                                                                   ContactId=ContactId);
                                 acrList.add(acr);
                                 UniQueSet.add(drl.Retailer__c+''+ContactId);
                                 
                                 }
                       }
                }
            
            }
        }
        system.debug('****UniQueSet:'+UniQueSet.size());
       system.debug('****acrList:'+acrList.size());

        try{
            //insert acrList; 
            Database.SaveResult[] srList = Database.insert(acrList, false);

// Iterate through each returned result
for (Database.SaveResult sr : srList) {
    if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
    }
    else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
        }
    }
}           
        }Catch(Exception e){
            system.debug('Exception'+e);
        }
    }
}