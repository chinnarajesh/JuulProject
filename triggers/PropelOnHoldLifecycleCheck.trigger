trigger PropelOnHoldLifecycleCheck on PDLM__Item_Revision__c (before insert, before update) {
    /**
     * When saving Item Revision with the On-Hold Lifecycle Phase, check all the immediate parents
     * Throw an error if not all the immediate parents (latest revision) are on the On-Hold Lifecycle
     */

    if(PDLM__Configuration__c.getInstance('OnHoldLifecycleCheck') == null ||
    PDLM__Configuration__c.getInstance('OnHoldLifecycleCheck').PDLM__Value__c != 'true'){return;}
    
    Map<Id, PDLM__Item_Revision__c> childItemIdRevRecMap = new Map<Id, PDLM__Item_Revision__c>();

    if (Trigger.isBefore && Trigger.isUpdate){
        for(PDLM__Item_Revision__c rev : Trigger.New){
            PDLM__Item_Revision__c oldRev = Trigger.oldMap.get(rev.id);

            if (rev.PDLM__Lifecycle_Phase__c == 'On-Hold' && rev.PDLM__Lifecycle_Phase__c != oldRev.PDLM__Lifecycle_Phase__c){
                childItemIdRevRecMap.put(rev.PDLM__Master_Item__c, rev);
            }
        }

        System.debug('childItemIdRevRecMap: ' + childItemIdRevRecMap);
        if (childItemIdRevRecMap.size() == 0){return;}

        checkForError(childItemIdRevRecMap);
    }

    if (Trigger.isBefore && Trigger.isInsert){
        for(PDLM__Item_Revision__c rev : Trigger.New){

            if (rev.PDLM__Lifecycle_Phase__c == 'On-Hold'){
                childItemIdRevRecMap.put(rev.PDLM__Master_Item__c, rev);
            }
        }

        System.debug('childItemIdRevRecMap: ' + childItemIdRevRecMap);
        if (childItemIdRevRecMap.size() == 0){return;}

        checkForError(childItemIdRevRecMap);
    }

    static void checkForError(Map<Id, PDLM__Item_Revision__c> childItemIdRevRecMap){
        for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item_Revision__c, PDLM__Item__c, 
                                      PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Latest_Revision__r.PDLM__Lifecycle_Phase__c 
                                      FROM PDLM__Assembly__c WHERE PDLM__Item__c IN :childItemIdRevRecMap.keySet()  
                                      AND PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Latest_Revision__r.PDLM__Lifecycle_Phase__c != 'On-Hold']){
            PDLM__Item_Revision__c childRevRec = childItemIdRevRecMap.get(ass.PDLM__Item__c);
            childRevRec.addError('You cannot set this Item Revision\'s Lifecycle Phase to On-Hold. Please make sure all the immediate parents are at the On-Hold Lifecycle Phase.');
        }
    }
}