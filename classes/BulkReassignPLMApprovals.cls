public with sharing class BulkReassignPLMApprovals {

    public class ReassignRequest {
        @InvocableVariable(label='Original Approver Id' required=true) public Id originalApproverId;
        @InvocableVariable(label='Reassigned Approver Id' required=true) public Id newApproverId;
    }

    @InvocableMethod(label='Bulk Reassign Approvals' description='Reassigns all pending and future approvals to user(s) provided')
    public static void executeReassignRequest(ReassignRequest[] requests) {
        Map<Id, Id> reassignApprovalMap = new Map<Id, Id>();
        for (ReassignRequest req : requests) {
            reassignApprovalMap.put(req.originalApproverId, req.newApproverId);
        }

        bulkReassignPendingApprovals(reassignApprovalMap);
    }

    /***
     *  bulkReassignPendingApprovals
     *  @description Method will reassign all approvals, either current in approval or in future approval phases to a 
     *      specific approver
     *  @param {Map<Id, Id>} reassignApprovalMap: Map containing key:value pairs of original approver Id <> new approver Id 
     */
    public static void bulkReassignPendingApprovals(Map<Id, Id> reassignApprovalMap) {
        Set<Id> oldApproverIds = reassignApprovalMap.keySet();
        ProcessInstanceWorkItem[] workItems = [select Id, OriginalActorId, ActorId, ProcessInstance.TargetObjectId 
            from ProcessInstanceWorkitem 
            where ActorId in :oldApproverIds OR originalActorId in :oldApproverIds];

        // Map containing original Approver to process work item values
        Map<Id, ProcessInstanceWorkItem[]> prevApproverWorkItemMap = new Map<Id, ProcessInstanceWorkItem[]>();
        Set<Id> cpIds = new Set<Id>();
        for (ProcessInstanceWorkItem wItem : workItems) {
            Id oldApproverId = oldApproverIds.contains(wItem.ActorId) ? wItem.ActorId : wItem.OriginalActorId;

            // Update work item to reflect reassigned approver if needed
            if (wItem.ActorId != reassignApprovalMap.get(oldApproverId)) {
                cpIds.add(wItem.ProcessInstance.TargetObjectId);
                Id prevApproverId = wItem.ActorId;
                wItem.ActorId = reassignApprovalMap.get(oldApproverId);

                if (!prevApproverWorkItemMap.containsKey(prevApproverId)) {
                    prevApproverWorkItemMap.put(prevApproverId, new List<ProcessInstanceWorkItem>());
                }
                prevApproverWorkItemMap.get(prevApproverId).add(wItem);
            }
        }

        Map<Id, PDLM__Change_Phase__c> changePhaseMap = new Map<Id, PDLM__Change_Phase__c>([select Id, Name, PDLM__Change_lk__r.Name from PDLM__Change_Phase__c where Id in :cpIds AND PDLM__Change_lk__c != null]);

        List<Id> userIds = new List<Id>();
        userIds.addAll(oldApproverIds);
        userIds.addAll(reassignApprovalMap.values());
        userIds.addAll(prevApproverWorkItemMap.keySet());
        Map<Id, String> idNameMap = new Map<Id,String>();
        for ( User u : [select Id, Name FROM User where Id in :userIds] ) {
            idNameMap.put(u.Id, String.valueOf(u.Name));
        }

        List<PDLM__Change_History__c> historyToInsert = new List<PDLM__Change_History__c>();
        for (Id prevApprover : prevApproverWorkItemMap.keySet()) {
            for (ProcessInstanceWorkItem wItem : prevApproverWorkItemMap.get(prevApprover)) {
                Id cpId = wItem.ProcessInstance.TargetObjectId;
                historyToInsert.add(new PDLM__Change_History__c(
                    PDLM__Field__c          = 'Reassigned Approver | ' + String.valueOf(changePhaseMap.get(cpId).Name),
                    PDLM__OldValue__c       = idNameMap.get(prevApprover),
                    PDLM__NewValue__c       = idNameMap.get(wItem.ActorId),
                    PDLM__Old_Id__c         = prevApprover,
                    PDLM__New_Id__c         = wItem.ActorId,
                    PDLM__Parent_Id__c      = changePhaseMap.get(cpId).PDLM__Change_lk__c,
                    PDLM__Object_Id__c      = String.valueOf(changePhaseMap.get(cpId).PDLM__Change_lk__c),
                    PDLM__Object_Name__c    = changePhaseMap.get(cpId).PDLM__Change_lk__r.Name
                ));
            }
        }

        List<PDLM__Change_Phase__c> changePhases = bulkTransferFutureApprovals(reassignApprovalMap, idNameMap);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = true;
        if (!historyToInsert.isEmpty()) {
            // Update work item records to complete reassign
            Database.update( workItems, dmo );
            // Insert audit trail records for reassigning
            Database.insert( historyToInsert, dmo );
        }
        if (changePhases.size() > 0) {
            // Update change phase records to complete reassign
            Database.update( changePhases, dmo );            
        }
    }

    /***
     *  bulkTransferFutureApprovals
     *  @description Method will transfer all future approvals from the original approver to a specified approver
     *  @param {Map<Id, Id>} transferApprovalMap: Map containing key:value pairs of original approver Id <> new approver Id
     *  @param {Map<Id, String>} idNameMap: Map containing key:value pairs of approver Id <> approver names
     *  @return {List<Change_Phase__c} Returns a list of change phase records where 1 or more approvers have been changed
     */
    public static List<PDLM__Change_Phase__c> bulkTransferFutureApprovals(Map<Id, Id> transferApprovalMap, Map<Id, String> idNameMap) {
        Set<Id> oldApproverIds = transferApprovalMap.keySet();

        List<String> approverFields = new List<String>();
        for (Integer i=1; i<=19; i++) {
            approverFields.add('PDLM__Approver_'+ i +'__c');
        }

        String query = 'select Id, Name, PDLM__Change_lk__r.Name, PDLM__In_Approval_Process__c, PDLM__Completed__c, PDLM__Approver_Count__c, ';
        query += String.join(approverFields, ', ') + ' from PDLM__Change_Phase__c where PDLM__Completed__c = false AND PDLM__In_Approval_Process__c = false AND PDLM__Change_lk__r.PDLM__Cancelled__c = false AND (';
        for (String field : approverFields) {
            query += field + ' in :oldApproverIds OR ';
        }
        query += 'PDLM__Approver_20__c in :oldApproverIds)';
        PDLM__Change_Phase__c[] phases = Database.query(query);

        for (PDLM__Change_Phase__c cp : phases) {
            Integer approverNum = findApproverInChangePhase(cp, oldApproverIds);
            if (approverNum == 0) { continue; }
            
            Id oldApproverId = (Id)cp.get('PDLM__Approver_'+ approverNum +'__c');
            transferApproval(cp, approverNum, transferApprovalMap.get(oldApproverId));
        }

        return phases;
    }

    /***
     *  findApproverInChangePhase
     *  @description Method finds which approver number the provided approver is within the given change phase
     *  @param {Change_Phase__c} cp: Change Phase record
     *  @param {Set<Id>} oldApproverIds: Set of approver Ids to search for within the change phase
     *  @return {Integer} Returns the approver number if approver is found | 0 if not found
     */
    public static Integer findApproverInChangePhase(PDLM__Change_Phase__c cp, Set<Id> oldApproverIds) {
        Integer approverNum = 0;
        for (Integer i=1; i<=cp.PDLM__Approver_Count__c; i++) {
            String fieldName = 'PDLM__Approver_'+ i +'__c';
            if (oldApproverIds.contains((Id)cp.get(fieldName))) {
                approverNum =  i;
                break;
            }
        }

        return approverNum;
    }

    /***
     *  transferApproval
     *  @description Method transfers the approval from a certain approver to a new approver, ensuring the new
     *      approver isn't already an approver and the Approver 1-20 fields are adjusted accordingly
     *  @param {Change_Phase__c} cp: Change Phase record
     *  @param {Integer} approverNum: Number of the approver who needs to be removed
     *  @param {Id} newApproverId: Id of the new approver who needs to be added
     */
    public static void transferApproval(PDLM__Change_Phase__c cp, Integer approverNum, Id newApproverId) {
        if (findApproverInChangePhase(cp, new Set<Id>{ newApproverId }) == 0) { 
            String field = 'PDLM__Approver_'+ approverNum +'__c';
            cp.put(field, newApproverId);
        } else {
            String field;
            if (approverNum < cp.PDLM__Approver_Count__c) {
                for (Integer i=approverNum; i<cp.PDLM__Approver_Count__c; i++) {
                    field = 'PDLM__Approver_'+ i +'__c';
                    String runner = 'PDLM__Approver_'+ (i+1) +'__c';
                    cp.put(field, cp.get(runner));
                }
            }
            field = 'PDLM__Approver_'+ cp.PDLM__Approver_Count__c +'__c';
            cp.put(field, '');
        }
    }
}