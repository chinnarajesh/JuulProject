trigger CallLWCFromAPT on ActionPlanTemplate__c (after update) {
    List<Call_LWC_From_Platfromevent__e> eventsToPublish = new List<Call_LWC_From_Platfromevent__e>();
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> recordIds = new Set<Id>();
        for (ActionPlanTemplate__c record : Trigger.new) {
            ActionPlanTemplate__c oldRecord = Trigger.oldMap.get(record.Id);
            
            if (oldRecord.RequestedStartDate__c == null && record.RequestedStartDate__c != null) {
                recordIds.add(record.Id);
            }
        }
        
        Map<Id, AccountActionPlanTemplate__c> aaptMap = new Map<Id, AccountActionPlanTemplate__c>();
        for (AccountActionPlanTemplate__c aapt : [SELECT Id,ActionPlanTemplateId__c FROM AccountActionPlanTemplate__c WHERE ActionPlanTemplateId__c IN :recordIds LIMIT 1]) {
            aaptMap.put(aapt.ActionPlanTemplateId__c, aapt);
        }
        
        for (ActionPlanTemplate__c record : Trigger.new) {
            if (recordIds.contains(record.Id)) {
                if (!aaptMap.containsKey(record.Id)) {
                    Call_LWC_From_Platfromevent__e event = new Call_LWC_From_Platfromevent__e(
                        Event_user__c = UserInfo.getUserId(),
                        Selected_AptId__c = record.Id
                    );
                    eventsToPublish.add(event);
                    
                    System.debug('Requested field is updated');
                }
            }
        }
        
        if (!eventsToPublish.isEmpty()) {
            EventBus.publish(eventsToPublish);
        }
    }
    
}