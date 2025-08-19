global class BatchSyncTicketForce implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful {
	string authorizationHeader; 
	public BatchSyncTicketForce(string authorizationHeader){
		this.authorizationHeader = authorizationHeader;
	}
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'SELECT Id,' +
                '       Name, Updated__c' +
                ' FROM  Ticket_Batch_Sync__c' +
                ' WHERE Updated__c = false limit 10000';   
        
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       String ticketNames = '';
       for(Ticket_Batch_Sync__c obj : (List<Ticket_Batch_Sync__c>)scope){
       		obj.Updated__c = true;
       		ticketNames = (ticketNames == '' ? '' : ',') + obj.Name;
       }
       string url = 'https://ploom.zendesk.com/api/v2/tickets/update_many.json?ids=' +ticketNames;
       
       Http h = new Http();

     	// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint(url);
    	req.setMethod('PUT');
    	req.setHeader('Authorization', authorizationHeader);
    	req.setHeader('Content-Type', 'application/json');
    	req.setBody('{"ticket": {  "updateSFDC": true }}');
    	if(! Test.isRunningTest()){
	    	HttpResponse res = h.send(req);
	    	system.debug('---' + res);
	    	if(res.getStatusCode() == 200){
	    		update scope;
	    	}
    	}
       
       
    }
    global void finish(Database.BatchableContext BC) {
        // Access initialState here
    }
    @isTest
    private static void testMe(){
    	Ticket_Batch_Sync__c obj = new Ticket_Batch_Sync__c(name='123');
    	insert obj;
    	Test.startTest();
    		Database.executeBatch( new BatchSyncTicketForce('23'));
    	Test.stoptest();
    }
}