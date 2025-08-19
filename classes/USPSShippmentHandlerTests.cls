@isTest
private class USPSShippmentHandlerTests{
    static testMethod void testUSPSShippmentHandler(){
        Case c  = new Case(
            Status = 'New',
            Origin = 'Email'
        );
        
        insert c;
        
        zkusps__Shipment__c s = new zkusps__Shipment__c(
            Case__c = c.Id,
            zkusps__trackingNumber__c = '1234',
            zkusps__lastTrackUpdateStatusCode__c = 'N'
        );
        
        USPSShippmentHandler.syncToCase(new List<zkusps__Shipment__c>{s});
        
    }
    
    static testMethod void testInsert(){
        Case c  = new Case(
            Status = 'New',
            Origin = 'Email'
        );
        
        insert c;
        try{
            zkusps__Shipment__c s = new zkusps__Shipment__c(
                Case__c = c.Id,
                zkusps__trackingNumber__c = '1234',
                zkusps__lastTrackUpdateStatusCode__c = 'N'
            );
            
            insert s;
        }
        catch(Exception ex){
        
        }
    }
}