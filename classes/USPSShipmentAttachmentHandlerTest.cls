@IsTest(SeeAllData=true)
private class USPSShipmentAttachmentHandlerTest {
     
    private testmethod static void testUSPSShipmentAttachmentHandler () {
      //  List<zkusps__Shipment__c> shipments =[SELECT Id FROM zkusps__Shipment__c WHERE Case__c!=null limit 1] ;
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
        
        insert s;
        
       // if(!shipments.isEmpty()){
            Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=s.id; //shipments[0].id;
            insert attach; 
       // }               
    }    
}