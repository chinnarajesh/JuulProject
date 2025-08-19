trigger UserTrigger on User (after Insert) {

    Trigger_Controller__c triggerControl = Trigger_Controller__c.getInstance('UserTrigger'); //Get Trigger Controller Setting
    if( triggerControl != null && triggerControl.Enabled__c ){

        Set<String> usersetId=new Set<String>();
        
        Map<id,user> userMap=new Map<id,user>([select id,name,profile.name from user where id in:trigger.newMap.keyset() ]);  
        for(User user:trigger.new){
             if(user.accountid!=null && user.contactid!=null && userMap.get(user.id).profile.name=='Juul Community Distributor Plus'){
                 usersetId.add(user.id);
             }
        }
        if(!usersetId.isEmpty()){
            JuulCommunityUserService.addPortalUserToRetailers(usersetId);
        }
     }
}