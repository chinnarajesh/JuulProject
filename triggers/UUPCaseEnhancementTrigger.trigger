/*****************************************************************************************
*   @File Name: UUPCaseEnhancementTrigger
*   @File Description: This trigger allows UUP Cases and perform actions.
*   @author - Jyoti Choudhary
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Jyoti Choudhary            31/05/21                Created
* Benedek Blackthorn         11/07/24                Disabled trigger (batch UUPCaseEnhancementBatch got deprecated)
*****************************************************************************************/
trigger UUPCaseEnhancementTrigger on Case (before insert) {
/*    Public static ID BatchID;
    //System.debug('Inside Trigger');
    List<Case> caseList = new List<Case>();
    
    If(trigger.isBefore)
    {
        if(trigger.isinsert)
        {
        
        //System.debug('Inside Trigger IF');
        Id B2BSupportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Support Case').getRecordTypeId();
        for(Case c:trigger.new)
        {
            if(c.RecordTypeId == B2BSupportCaseRecordTypeId)
            {
                //System.debug('Inside Trigger IF Record type same');
                caseList.add(c);
            }
        }
        //System.debug('caseList==>'+caseList);
        if(caseList.size()>0)
        {
        UUPCaseEnhancementBatch u = new UUPCaseEnhancementBatch(caseList);
        BatchID = Database.executeBatch(u);
        }
        }
    }
*/
}