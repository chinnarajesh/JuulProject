trigger AssetRequestItemTrigger on Asset_Request_Iteam__c (Before Update, After Update) {
   Trigger_Controller__c AssetRequestItemTriggerControl = Trigger_Controller__c.getInstance('AssetRequestItemTrigger'); //Get Trigger Controller Setting
    
    if( AssetRequestItemTriggerControl != null && AssetRequestItemTriggerControl.Enabled__c ){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
               //Add Future Logic Here
            } 
            if (Trigger.isUpdate) {
               //Add Future Logic Here
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) {
            } 
            if (Trigger.isUpdate) {
                AssetRequestItemTriggerHandler.updateStatusOnAsset(Trigger.New, Trigger.OldMap);
            }
            if (Trigger.isDelete) {
                //Add Future Logic Here
            }
        }
    }
}