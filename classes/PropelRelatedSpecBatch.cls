public with sharing class PropelRelatedSpecBatch implements Database.Batchable<sObject>, Database.Stateful{
    public static final integer DEFAULT_BATCHSIZE = 200;
    public static Integer batchSize;
    PDLM__Configuration__c batchScope = [SELECT PDLM__Value__c FROM PDLM__Configuration__c WHERE Name = 'RelatedSpecBatchScope' LIMIT 1];
    List<Id> parentRevIds = new List<Id>();

    /**
     * getBatchSize the as configured size is available to use
     */
    public Integer getBatchSize() {
        Integer batchSize = DEFAULT_BATCHSIZE;

        if (batchScope != null && Integer.valueof(batchScope.PDLM__Value__c) > 0 && Integer.valueof(batchScope.PDLM__Value__c) <= 200) {
            batchSize = Integer.valueof(batchScope.PDLM__Value__c) ;
        }

        return batchSize;
    }

    //
    // Batchable
    //
    public PropelRelatedSpecBatch(List<Id> revIds) {
        batchSize = getBatchSize();
        parentRevIds = revIds;
    }

    //
    // Batchable Interface
    //

    //Where the Batch starts
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('parentRevIds: '+ parentRevIds);

        return Database.getQueryLocator(
            [
                SELECT Id, Name, PCBA_Project_Type__c, D1_Spec__c, Steam_US_S2_Spec__c, Steam_US_PCBA_Config_1__c, Steam_US_PCBA_Config_2__c,
                Steam_US_PCBA_Config_3__c, Steam_US_PCBA_Config_4__c, Steam_US_PCBA_Config_5__c, Steam_US_PCBA_Config_6__c
                FROM PDLM__Item_Revision__c 
                WHERE Id IN :parentRevIds
            ]
        );
    }

    //Where the Batch executes
    public void execute(Database.BatchableContext bc, List<PDLM__Item_Revision__c> scope) {
        System.debug('scope: ' + scope);

        List<PDLM__Assembly__c> assembliesToUpdate = new List<PDLM__Assembly__c>();

        for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item_Revision__r.PCBA_Project_Type__c, PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_S2_Spec__c, 
                                     PDLM__Item__r.PDLM__Latest_Released_Revision__r.D1_Spec__c,
                                      PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_1__c, PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_2__c,
                PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_3__c, PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_4__c, PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_5__c, 
                                      PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_6__c,  
                                      Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c IN :scope 
                                      AND PDLM__Item__r.PDLM__Latest_Released_Revision__c != null]){
            if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'D1 Spec'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.D1_Spec__c;
                assembliesToUpdate.add(ass);
            }
            else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US/S2 Spec'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_S2_Spec__c;
                assembliesToUpdate.add(ass);
            }
                       else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US PCBA Config 1'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_1__c;
                assembliesToUpdate.add(ass);
            }
            else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US PCBA Config 2'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_2__c;
                assembliesToUpdate.add(ass);
            }
                                                      else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US PCBA Config 3'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_3__c;
                assembliesToUpdate.add(ass);
            }
            else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US PCBA Config 4'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_4__c;
                assembliesToUpdate.add(ass);
            }
             else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US PCBA Config 5'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_5__c;
                assembliesToUpdate.add(ass);
            }
            else if (ass.PDLM__Item_Revision__r.PCBA_Project_Type__c == 'Steam US PCBA Config 6'){
                ass.Related_document__c = ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Steam_US_PCBA_Config_6__c;
                assembliesToUpdate.add(ass);
            }
             
        }

        System.debug('assembliesToUpdate: ' + assembliesToUpdate);
        if (assembliesToUpdate.size() > 0){
            update assembliesToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug(Logginglevel.WARN, 'PropelRelatedSpecBatch: finish()');
    }
}