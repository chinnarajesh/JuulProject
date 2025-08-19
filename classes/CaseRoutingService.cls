public without sharing class CaseRoutingService {

    /**************************************************************************************
    * @Description This method receives the cases and assigns an ownerID based on owner name
    * @Param   cases list
    * @Return  --none--
    **************************************************************************************/
    public static void routeCaseViaOwnerName(List<Case> caseList) {

        if (!caseList.isEmpty()) {
            //get all record type IDs currently in use
            Id genInqRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
            Id ecommerceRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
            Id warrantyRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Product Troubleshooting & Warranty Fulfillment');
            Id appTroubleRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
            Id healthExpRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience');
            Id uapRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Under Age Prevention Retailer');
            Id JUUL2RecTypeID = RecordTypeUtil.recordTypeId('Case', 'JUUL2 App Pairing & Connectivity');
            Id EACCertRecTypeId=RecordTypeUtil.recordTypeId('Case', 'EAC Certification');
            Set<Id> casesWithQueueOwnerSet = new Set<Id>();
            System.debug('caseList line 29-> ' + caseList);
            for (Case c : caseList) {
                if ((c.RecordTypeId == genInqRecTypeId || c.RecordTypeId == ecommerceRecTypeId ||
                        c.RecordTypeId == warrantyRecTypeId || c.RecordTypeId == appTroubleRecTypeId
                        || c.RecordTypeId == healthExpRecTypeId || c.RecordTypeId == uapRecTypeId || c.Recordtypeid==EACCertRecTypeId || c.RecordTypeId==JUUL2RecTypeID) && String.isNotBlank(c.First_Queue_Owner__c)) {
                    System.debug('case line 34-> ' + c);
                    casesWithQueueOwnerSet.add(c.Id);
                }
            }
            System.debug('casesWithQueueOwnerSet'+casesWithQueueOwnerSet);
            if (!casesWithQueueOwnerSet.isEmpty()) {
                //get the owner id and attach to the case in a separate transaction
                updateCaseOwnerAsync(casesWithQueueOwnerSet);
            }
        }
    }
    @Future
    public static void updateCaseOwnerAsync(Set<Id> caseIdSet) {
        //get cases to update
        Map<Id, Case> caseWithQueueMap = new Map<Id, Case>([SELECT Id,OwnerId,First_Queue_Owner__c FROM Case WHERE Id = :caseIdSet]);
        //get owner developer names from the cases
        List<String> firstOwnerNameList = new List<String>();
        if (!caseWithQueueMap.isEmpty()) {
            for (Case c : caseWithQueueMap.values()) {
                if (String.isNotBlank(c.First_Queue_Owner__c)) {
                    firstOwnerNameList.add(c.First_Queue_Owner__c);
                }
            }
            if (!firstOwnerNameList.isEmpty()) {
                Map<String, Id> groupIdByNameMap = CSCountryConfigUtil.getGroupIdByName(firstOwnerNameList);
                System.debug('groupIdByNameMap-> ' + groupIdByNameMap);
                //update case with owner Ids
                if (!groupIdByNameMap.isEmpty()) {
                    for (Case c : caseWithQueueMap.values()) {
                        if (groupIdByNameMap.containsKey(c.First_Queue_Owner__c)) {
                            c.OwnerId = groupIdByNameMap.get(c.First_Queue_Owner__c);
                        }
                    }
                    Database.update(caseWithQueueMap.values(), false) ;
                }
            }
        }
    }
}