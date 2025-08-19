/****************************************************************************************
*   @File Name: UUPCaseEnhancement
*   @File Description: To Update B2B Support Cases for UUP Case Enhancement.
*   @author - Jyoti Choudhary
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Jyoti Choudhary            31/05/21                Created
*****************************************************************************************/
public class UUPCaseEnhancement {
    
    Public static void UUPCaseEnhancementMethod(List<Case> TriggerNew)
    {
        List<Case> caseList = new List<Case>(); //adding the cases having record type 'B2B Support Case' and status is 'Retail Case Closed'.
        //Id B2BSupportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        Id B2BSupportCaseRecordTypeId = System.Label.B2B_Support_Case_Record_Type;//JTP-112
         
    	//System.debug('Inside After update Trigger IF : '+B2BSupportCaseRecordTypeId);        
            for(Case c:TriggerNew)
            {if(c.RecordTypeId == B2BSupportCaseRecordTypeId && c.Status == 'Retail Case Closed')
                {//System.debug('Inside Trigger IF Record type same');
                    caseList.add(c);
                }
            }
            //System.debug('caseList==>'+caseList.size());
            if(caseList.size()>0)
            {
            //UUPCaseEnhancementBatch u = new UUPCaseEnhancementBatch(caseList);
            //Database.executeBatch(u);            
            }
            
	}
}