trigger USPSShippmentTrigger on zkusps__Shipment__c (after insert,after update) {
    USPSShippmentHandler.syncToCase(trigger.new);
}