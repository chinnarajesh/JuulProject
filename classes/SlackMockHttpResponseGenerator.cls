@isTest
global class SlackMockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Id":"a002800000YzD9nAAF","Message__c":"Please look into Case : <https://ap2.salesforce.com/{!Case.Id}|CaseNumber:{!Case.CaseNumber}>"}');
        res.setStatusCode(200);
        return res;
    }
}