@isTest                        
global class GetSignedTemplateResponseMock implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        
        res.setBody('test');
        res.setStatusCode(200);
        return res;
    }
}