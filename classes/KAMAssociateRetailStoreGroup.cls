/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Praveen Gupta        06-09-2020                     */
/* Class Name: KAMAssociateRetailStoreGroup                       */
/* Description:To associate retail store group in action plan template"  */
/**********************************************************************/

public class KAMAssociateRetailStoreGroup {
    public static String class_Name='KAMAssociateRetailStoreGroup';
    @AuraEnabled
    public static string getAllRetailStoreGroups(Id ActionPlanTemplateId){
        //SOQL on juntion object AccountActionPlanTemplate to get 
        Id accountId; 
  
        List<ActionPlanTemplate__c> APT = new List<ActionPlanTemplate__c>([SELECT Id, Name, ActionPlanType__c, AccountId__c from ActionPlanTemplate__c where Id =:ActionPlanTemplateId and AccountId__c != null]);

        if(APT.size() > 0){
            accountId = APT[0].AccountId__c;
        }
       
        system.debug('accountId'+accountId);
        
        List<Account> Acc = new List<Account>();
        if(accountId != null){
            Acc = [SELECT Id, Type, Ultimate_Parent_Account__c, ParentId from Account where Id =: accountId AND Type = 'HQ'];
        }
        
        System.debug('Acc :'+Acc.size());
        
        List<RetailLocationGroup__c> rsgList = new List<RetailLocationGroup__c>();
        
        if(Acc != null && Acc.size() > 0){
            if(Acc[0].Ultimate_Parent_Account__c == null && Acc[0].ParentId == null)    {
                rsgList = [Select id, Name, Description__c, CurrencyIsoCode, NumberStoreLocations__c, AccountId__c from RetailLocationGroup__c where AccountId__c =: accountId or UltimateParentId__c =: accountId];
                System.debug('Corporate HQ :'+rsgList);
            } else if(Acc[0].ParentId != null && Acc[0].Ultimate_Parent_Account__c == Acc[0].ParentId){
                 rsgList = [Select id, Name, Description__c, CurrencyIsoCode, NumberStoreLocations__c, AccountId__c from RetailLocationGroup__c where AccountId__c =: accountId];
                System.debug('Regional HQ :'+rsgList);
            } 
        }
        
        Set<Id> aaptIds = new Set<Id>();
        for(AccountActionPlanTemplate__c a: [select RetailLocationId__c from AccountActionPlanTemplate__c where ActionPlanTemplateId__c = :ActionPlanTemplateId] ){
            if(a.RetailLocationId__c != null){
                aaptIds.add(a.RetailLocationId__c);    
            }        
        }
        System.debug('aaptIds :'+aaptIds);

        List<RSGWrapper> rsgWrapList = new List<RSGWrapper>();
        for(RetailLocationGroup__c rsg : rsgList){  
            RSGWrapper rsgWraper = new RSGWrapper();             
            rsgWraper.Id = rsg.Id;
            rsgWraper.name = rsg.Name;
            rsgWraper.description = rsg.Description__c;
            rsgWraper.storeLocation = String.ValueOf(rsg.NumberStoreLocations__c);
            rsgWraper.expanded = false;
            if(aaptIds.contains(rsg.id)){
                rsgWraper.disabled = true;
                rsgWraper.selected = true;
                rsgWraper.className = 'slds-hint-parent slds-is-selected';
            }else{
                rsgWraper.disabled = false;
                rsgWraper.className = 'slds-hint-parent';
            }
            rsgWrapList.add(rsgWraper);
        }  
        system.debug('rsgWrapList'+rsgWrapList);   

        return JSON.serializePretty(rsgWrapList);
    }

    @AuraEnabled
    public static string associateRetailStoreGroupsOnApt(Id ActionPlanTemplateId,  List<Id> selectedRSGList) { 
        system.debug('templateId'+ActionPlanTemplateId);
        system.debug('selectedRSGList--->'+selectedRSGList);
        String returnResponse;  
        Set<Id> successRSGRecords = new Set<Id>();
        String method_Name='associateRetailStoreGroupsOnApt';
        String operationType = 'Database.Insert_Failed';
        Boolean associateStoreGroupsFailure = false;

        List<AccountActionPlanTemplate__c> AAPTList = new List<AccountActionPlanTemplate__c>();
        if(selectedRSGList.size()>0 && ActionPlanTemplateId != null){
            try{
                for(Id rsgId : selectedRSGList) {
                    AccountActionPlanTemplate__c AAPT = new AccountActionPlanTemplate__c();
                    AAPT.ActionPlanTemplateId__c = ActionPlanTemplateId;
                    AAPT.RetailLocationId__c = rsgId;
                    AAPT.Active__c = true;
                    AAPTList.add(AAPT);
                }
                system.debug('AAPTList'+AAPTList);
                if (ActionPlanTemplateId != null && AAPTList.size() > 0) {
                    List<Database.SaveResult> insertedRSGroups = Database.insert(AAPTList, true);
                    List<Database.Error> errorRsGroup = new  List<Database.Error>();
                    for (Integer index = 0, size = insertedRSGroups.size(); index < size; index++) {
                        if (!insertedRSGroups[index].isSuccess()) {
                            associateStoreGroupsFailure = true;
                            errorRsGroup.addAll(insertedRSGroups[index].getErrors());
                            returnResponse= errorRsGroup[0].getMessage();
                        }else{
                            successRSGRecords.add(insertedRSGroups[index].id);
                        }
                    }
                    //Insert exceptions in Log__c object, If any
                    if(errorRsGroup.size()>0)
                    {
                        LogEventTriggerHandler.insertBatchLog(errorRsGroup,class_Name,method_Name,'Account Action Plan Template',operationType);
                    }
                }
                returnResponse ='Retail Store Groups associated successfully';
            }catch(Exception ex){
                throw new AuraHandledException('Error: '
                + 'This Action Plan Template Is In Execution. You Cannot Add Retail Store Groups On This Action Plan Template');
                
            }
        } else{
            returnResponse = 'Please select retail store groups.';
        }
        return returnResponse;
    }

    public Class RSGWrapper{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String storeLocation {get;set;}
        @AuraEnabled
        public boolean expanded {get;set;}      
        @AuraEnabled
        public boolean disabled {get;set;}   
        @AuraEnabled
        public boolean selected {get;set;}   
        @AuraEnabled
        public String className {get;set;}    
    }
}