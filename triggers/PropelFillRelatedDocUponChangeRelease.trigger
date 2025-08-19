trigger PropelFillRelatedDocUponChangeRelease on PDLM__Change_Event__e (after insert) {
    /**
     * When a Item Revision is released via a Change Order and it has a BOM
     * Update PDLM__Assembly__c.Related_document__c for level 1 Children
     */

    if(PDLM__Configuration__c.getInstance('RelatedSpecTrigger') == null ||
    PDLM__Configuration__c.getInstance('RelatedSpecTrigger').PDLM__Value__c != 'true'){return;}
    
    List<Id> changeIds = new List<Id>();
    List<Id> parentRevIds = new List<Id>();

    if (Trigger.isAfter && Trigger.isInsert){
        for(PDLM__Change_Event__e event : Trigger.New){
            if (event.PDLM__Is_Approved__c == true){
                changeIds.add(event.PDLM__Record_Id__c);
            }
        }

        if (changeIds.size() == 0){return;}

        for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item_Revision__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__r.PDLM__Related_Change__c in :changeIds]){
            parentRevIds.add(ass.PDLM__Item_Revision__c);
        }

        //Call the batch Apex
        if (parentRevIds.size() > 0){
            System.debug('Call PropelRelatedSpecBatch');
            Database.executeBatch(new PropelRelatedSpecBatch(parentRevIds));
        }
    }
}