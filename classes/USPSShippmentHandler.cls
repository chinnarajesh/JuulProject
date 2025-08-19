public class USPSShippmentHandler{
    public static void syncToCase(List< zkusps__Shipment__c > shipments){
        Map<Id,Case> caseUpdateMap = new Map<Id,Case>();
        for(zkusps__Shipment__c s : shipments){
            if(s.Case__c != NULL){
                caseUpdateMap.put(s.Case__c,new Case(
                    Id = s.Case__c,
                    USPS_Ship_Status__c = s.zkusps__lastTrackUpdateStatusCode__c,
                    USPS_Tracking_Number__c = s.zkusps__trackingNumber__c,
                    USPS_Shipment_Deleted__c = s.zkusps__shipmentDeleted__c
                ));
            }
        }
        update caseUpdateMap.values();
    }
}