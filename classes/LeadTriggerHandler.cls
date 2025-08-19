public class LeadTriggerHandler {
    public static Boolean INSERT_TRIGGER_BYPASS = false;
    public static Boolean UPDATE_TRIGGER_BYPASS = false;
    public static Id recTypeLeadRACS;
    public static Id recTypeOpptyRACS;
    public LeadTriggerHandler(){
        Map<String,Schema.RecordTypeInfo> rtMapLead = Schema.SObjectType.Lead.getRecordTypeInfosByName();
        Map<String,Schema.RecordTypeInfo> rtMapOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        recTypeLeadRACS = rtMapLead.get('RACS Independent Lead').getRecordTypeId();  
        recTypeOpptyRACS = rtMapOppty.get('RACS Independent Onboarding').getRecordTypeId();   
        
    }
    public static void handleBeforeInsert( List<Lead> triggerObjects ) {
        if(INSERT_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'State', new Map<String,Object>(), triggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'Country', new Map<String,Object>(), triggerObjects );
        }
    }
    
    public static void handleBeforeUpdate( List<Lead> oldTriggerObjects, List<Lead> newTriggerObjects ) {
        if(UPDATE_TRIGGER_BYPASS!=true){
            TerritoryUtility.standardizeField( 'State', 'State', new Map<String,Object>(), newTriggerObjects );
            TerritoryUtility.standardizeField( 'Country', 'Country', new Map<String,Object>(), newTriggerObjects );
        }
    }
    /**
        Ticket Reference: SFDC - 0000000112 : https://juullabs.lightning.force.com/lightning/r/ticket__c/aAN1O000000PDpyWAG/view
        This method will be used to update the Opportunity record type to RACS for new and existing.
     */
    public void updateOpptyonLeadConvert(List<Lead> newTriggerList, Map<Id,Lead> oldMapTrigger, System.TriggerOperation triggerEvent){
        Map<Id,Id> mapLeadIdToOpptyId = new Map<Id,Id>();
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        switch on triggerEvent{
            when AFTER_UPDATE{
                for(Lead leRec : newTriggerList){
                    if(leRec.RecordTypeId == recTypeLeadRACS && leRec.isConverted && leRec.convertedOpportunityId <> NULL){
                        mapLeadIdToOpptyId.put(leRec.convertedOpportunityId, leRec.Id);
                    }
                }
            Map<Id,Opportunity> fetchOpptyMap = new Map<Id,Opportunity>([Select Id, Name,stageName, RecordTypeId from Opportunity Where ID IN : mapLeadIdToOpptyId.keySet()]);
            for(Lead leRec : newTriggerList){
                if(fetchOpptyMap != null && fetchOpptyMap.containsKey(leRec.convertedOpportunityId)){
                    if(fetchOpptyMap.get(leRec.convertedOpportunityId).RecordTypeId != null && fetchOpptyMap.get(leRec.convertedOpportunityId).RecordTypeId != recTypeOpptyRACS){
                        fetchOpptyMap.get(leRec.convertedOpportunityId).RecordTypeId = recTypeOpptyRACS;
                        fetchOpptyMap.get(leRec.convertedOpportunityId).StageName = 'Qualify';
                        
                        listOppToUpdate.add(fetchOpptyMap.get(leRec.convertedOpportunityId));
                    }
                } 
            }
            if(listOppToUpdate != null && listOppToUpdate.size()>0){
                 //Database.SaveResult[] srList = Database.Update(listOppToUpdate, false);
                 update listOppToUpdate;
            }
             
        }
       }   
    }
}