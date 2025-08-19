/*****************************************************************************************
*
*   @File Name: ActiveOpponAccount_Handler
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
public without sharing class ActiveOpponAccount_Handler
{
    public void activeOpp(List<Opportunity> Oppty)
    {
       if(checkRecursivetrigger.runOnce())
        {
        set<Id> accid= new Set<Id>();
        set<Id> Oppid= new Set<Id>();
        
          for(Opportunity opp:Oppty)
          {
            if(opp.Accountid!=null && opp.Active__c==true)
            {
                accid.add(opp.Accountid);
                Oppid.add(opp.Id);
            }  
       }
    map<id,Opportunity> oppmap = new map<id,Opportunity>();
    Id OppBDFRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BDF').getRecordTypeId();
    Id OppBDFReadOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BDF-Read Only').getRecordTypeId();
    
    List<Opportunity> OppList =[Select id,name,Active__c,RecordTypeId,AccountId from Opportunity where Active__c=True and Accountid IN:accid and ID!=:Oppid and (RecordTypeId =: OppBDFReadOnlyRecordTypeId  OR RecordTypeId =: OppBDFRecordTypeId)];
    for(Opportunity OppActive: OppList){
         oppmap.put(OppActive.Accountid,OppActive);
    
    }
            //checking the size of the list
            if(oppmap.size()>0)
            {
                for(Opportunity opp:Oppty)
                 { 
                 if(oppmap.get(opp.Accountid).Accountid == opp.Accountid){
                    opp.adderror('An active BDF Opportunity already exists for this HQ account. Please de-activate the other Active BDF Opportunity by deselecting the checkbox');
                  }
                 }
            }
}
}
}