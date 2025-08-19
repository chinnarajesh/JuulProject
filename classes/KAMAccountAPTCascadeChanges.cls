/*****************************************************************************/
/* VERSION     AUTHOR                  DATE                                  */
/*     1.0     Shreya Raut             06-17-2020                            */
/* Class Name: KamAccountAPTCascadeChanges                                   */
/* Description: To ISL and Mission records with requested start and end date */
/*****************************************************************************/
public class KAMAccountAPTCascadeChanges {
    @AuraEnabled 
    public static void CascadeChanges(Id apt){
       System.debug('Selected APT'+apt);
        set<ID> RSGIDs = new set<ID>();
        ActionPlanTemplate__c selectedAPTQueried = [Select Id,RequestedStartDate__c,RequestedEndDate__c,Status__c from ActionPlanTemplate__c where Id =:apt];
        for(AccountActionPlanTemplate__c a : [select id,RetailLocationId__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c =:apt])
        {
            RSGIDs.add(a.RetailLocationId__c);
        }
        for(ID RSGid : RSGIDs ){
        BatchKAMCascadeChangesISL b = new BatchKAMCascadeChangesISL(apt,RSGid);
        Database.executeBatch(b);
        }
    }
       
}