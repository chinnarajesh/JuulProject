trigger PropelRelatedSpecTrigger on PDLM__Item_Revision__c (after update) {
    /**
     * When PDLM__Item_Revision__c.PCBA_Project_Type__c is changed and it has a BOM
     * Update PDLM__Assembly__c.Related_document__c for level 1 Children
     */

    if(PDLM__Configuration__c.getInstance('RelatedSpecTrigger') == null ||
    PDLM__Configuration__c.getInstance('RelatedSpecTrigger').PDLM__Value__c != 'true'){return;}
    
    List<Id> parentRevIds = new List<Id>();

    if (Trigger.isAfter && Trigger.isUpdate){
        for(PDLM__Item_Revision__c rev : Trigger.New){
            PDLM__Item_Revision__c oldRev = Trigger.oldMap.get(rev.id);

            if (rev.PCBA_Project_Type__c != oldRev.PCBA_Project_Type__c && rev.PCBA_Project_Type__c != null && 
            rev.PDLM__Has_Bom__c == true){
                parentRevIds.add(rev.Id);
            }

            //Call the batch Apex
            if (parentRevIds.size() > 0){
                System.debug('Call PropelRelatedSpecBatch');
                Database.executeBatch(new PropelRelatedSpecBatch(parentRevIds));
            }
        }
    }
}