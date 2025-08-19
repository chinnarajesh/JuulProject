/*****************************************************************************************
*
*   @File Name: ActiveOpportunityonAccount
*   @File Description: This trigger allows only one active Opportunity per HQ Account
*   @author - Karishma Agarwal
*
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Karishma Agarwal            03/07/19                Created
*****************************************************************************************/
trigger ActiveOpportunityonAccount on Opportunity (after insert, after update)  
{
    List<Opportunity> Oppty = new List<Opportunity>();
    if(trigger.isafter && (trigger.isinsert || trigger.isupdate))
      {  
      Id OppBDFRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BDF').getRecordTypeId();
      Id OppBDFOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BDF-Read Only').getRecordTypeId();

      for(Opportunity opp:trigger.new)
      {
          //checking all active Opportunities associated with an account
            if(opp.Accountid!=null && opp.active__c==true && (opp.RecordTypeId == OppBDFRecordTypeId  || opp.RecordTypeId == OppBDFOnlyRecordTypeId))
            {
            
                Oppty.add(opp);
                System.debug('@@Oppty'+opp.RecordTypeId);
            }
           ActiveOpponAccount_Handler handler = new  ActiveOpponAccount_Handler(); 
           handler.activeOpp(Oppty); 
      }
      }
}