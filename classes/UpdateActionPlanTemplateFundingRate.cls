/****************************************************************************************************************************
Class Name : UpdateActionPlanTemplateFundingRate
Purpose    : Update JLP Tier on APT from the linked Account & update Default Funding Rate as defined in the Custom Metadata
Created By : Surabhi Rastogi
Test Class : ActionPlanTemplateHandlerTest
****************************************************************************************************************************/

public class UpdateActionPlanTemplateFundingRate {
   @AuraEnabled 
    public static void updateFundingRateonUpdate(List<ActionPlanTemplate__c> aptListNew){
        //---Start---Ticket: SFDC - 0000003311(Added by Pooja Gite)
        /*List<Action_Plan_Template_JLP__mdt> metadataList= [select id,JLP_Tier__c,Default_Funding_Rate__c from Action_Plan_Template_JLP__mdt];
        Map<String,Decimal> metaDataMap = new Map<String,Decimal>();
        List<ActionPlanTemplate__c> newUpdatedList = new List<ActionPlanTemplate__c>();
        for(Action_Plan_Template_JLP__mdt apltjlp : metadataList)
        {
            metaDataMap.put(apltjlp.JLP_Tier__c,apltjlp.Default_Funding_Rate__c);
            //system.debug('@@metaDataMap : '+metaDataMap);
        }*/
        //---End---Ticket: SFDC - 0000003311(Added by Pooja Gite)
        List<String> accountIdList = new List<String>();
        for(ActionPlanTemplate__c aptrec : aptListNew)
        {
            accountIdList.add(aptrec.AccountId__c);
        }
        //Map<Id,Account> accountMapAPT = new Map<Id,Account>([Select id,JLP_Tier__c from Account where id in:accountIdList]);//Commented by Pooja Gite
		Map<Id,Account> accountMapAPT = new Map<Id,Account>([Select id,JLP_Tier__c,JLP__c from Account where id in:accountIdList]);//Ticket: SFDC - 0000003311(Added by Pooja Gite)
        for(ActionPlanTemplate__c aptRec : aptListNew)
        {
            if(String.isNotBlank(aptRec.AccountId__c) && accountMapAPT.containsKey(aptRec.AccountId__c))
            {
                aptRec.JLPStatus__c = accountMapAPT.get(aptRec.AccountId__c).JLP_Tier__c;
				aptRec.CoFundingRates__c = accountMapAPT.get(aptRec.AccountId__c).JLP__c;//Ticket: SFDC - 0000003311(Added by Pooja Gite)  
                //Ticket: SFDC - 0000003311(Commented by Pooja Gite)
                /*if(metaDataMap.containsKey(accountMapAPT.get(aptRec.AccountId__c).JLP_Tier__c))
                {
                    aptRec.CoFundingRates__c = metaDataMap.get(accountMapAPT.get(aptRec.AccountId__c).JLP_Tier__c);
                }*/
            }
        }
    }
}