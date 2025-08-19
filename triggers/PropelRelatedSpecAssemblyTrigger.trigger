trigger PropelRelatedSpecAssemblyTrigger on PDLM__Assembly__c (after insert, after update) {
    /**
     * When a new Assembly record is inserted OR an assembly is replaced
     * AND PDLM__Item_Revision__c.PCBA_Project_Type__c is not blank
     */

    if(PDLM__Configuration__c.getInstance('RelatedSpecTrigger') == null ||
    PDLM__Configuration__c.getInstance('RelatedSpecTrigger').PDLM__Value__c != 'true'){return;}
    
    List<Id> preliminaryParentRevIds = new List<Id>();
    List<Id> parentRevIds = new List<Id>();

    if (Trigger.isAfter && Trigger.isInsert){
        for (PDLM__Assembly__c ass : Trigger.New){
            preliminaryParentRevIds.add(ass.PDLM__Item_Revision__c);
        }

        for (PDLM__Assembly__c assFiltered : [SELECT Id, PDLM__Item_Revision__r.PCBA_Project_Type__c FROM PDLM__Assembly__c 
                                              WHERE PDLM__Item_Revision__c IN :preliminaryParentRevIds AND 
                                              PDLM__Item_Revision__r.PCBA_Project_Type__c != null AND 
                                              PDLM__Item_Revision__r.PCBA_Project_Type__c != '']){
            parentRevIds.add(assFiltered.PDLM__Item_Revision__c);
        }

        //Call the batch Apex
        if (parentRevIds.size() > 0){
            System.debug('Call PropelRelatedSpecBatch');
            Database.executeBatch(new PropelRelatedSpecBatch(parentRevIds));
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate){
        for (PDLM__Assembly__c ass : Trigger.New){
            PDLM__Assembly__c oldAss = Trigger.oldMap.get(ass.id);

            if (ass.PDLM__Item__c != oldAss.PDLM__Item__c && ass.PDLM__Item__c != null){
                preliminaryParentRevIds.add(ass.PDLM__Item_Revision__c);
            }
        }

        for (PDLM__Assembly__c assFiltered : [SELECT Id, PDLM__Item_Revision__r.PCBA_Project_Type__c FROM PDLM__Assembly__c 
                                              WHERE PDLM__Item_Revision__c IN :preliminaryParentRevIds AND 
                                              PDLM__Item_Revision__r.PCBA_Project_Type__c != null AND 
                                              PDLM__Item_Revision__r.PCBA_Project_Type__c != '']){
            parentRevIds.add(assFiltered.PDLM__Item_Revision__c);
        }

        //Call the batch Apex
        if (parentRevIds.size() > 0){
            System.debug('Call PropelRelatedSpecBatch');
            Database.executeBatch(new PropelRelatedSpecBatch(parentRevIds));
        }
    }
}