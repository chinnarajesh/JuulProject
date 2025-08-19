@isTest
global class VisionService_MockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        String httpEndpoint = req.getEndpoint();
        String httpMethod = req.getMethod();
        if (httpMethod.equals('GET')) {
            if(httpEndpoint.equals('https://api.einstein.ai/v2/oauth2/token')) {
                return mockGetToken(req);
            }
        }
        if (httpMethod.equals('POST')) {
            if(httpEndpoint.equals('https://api.einstein.ai/v2/vision/detect')) {
                 return mockGetPrediction(req);
            }
        }
        return null;
    }
     private static HTTPResponse mockGetToken(HTTPRequest req) {
        
        String jsonResponse = '{"access_token":"LFJFASZSKNETKQ2SGZDUETKGKE3UKUKVKBDEUUSVKBCFMR2QIJKFAQ2DKNATOR2DKJJFMNSNLJGTMSJVIRNDMQSFJFLUMSSLIM3EOSBTKJEFCUSSGM2VAWSFIJKTGTCIIVIVGNBXLBEEUTBSKBLTIQ2RJVMVIUKXKBAVC7COIE","token_type":"Bearer","expires_in":"3602"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(200);
        return res;
        
    }
     private static HTTPResponse mockGetPrediction(HTTPRequest req) {
        
        String jsonResponse = '{"object":"predictresponse","probabilities":[{"probability":0.98796296,"label":"SILVER_Device","boundingBox":{"minX":665,"minY":465,"maxX":760,"maxY":648}},{"probability":0.9814975,"label":"SILVER_Device","boundingBox":{"minX":557,"minY":469,"maxX":648,"maxY":651}}]}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(200);
        return res;
        
    }
}