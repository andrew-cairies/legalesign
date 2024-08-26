@isTest                        
global class RealTimeEventResponseJSONMock implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"4031ae54-bb86-4ae6-b6c1-3884b4334c69","created":1668069477,"event":"rejected","z_object":"document","data":{"tag":"","name":"Company Details","uuid":"7232847d-4c8b-4555-b45e-e6889c7252c0","z_group":"salesforce","status":50,"statusText":"rejected","resourceUri":"/api/v1/document/7232847d-4c8b-4555-b45e-e6889c7252c0/","participants":[{"uuid":"c869984f-5f7c-4888-89b9-d397aefa9dac","email":"andrew@cairies.com","order":0,"status":60,"lastname":"Mowat","roleText":"signer","firstname":"Andy","statusText":"rejected","resourceUri":"/api/v1/signer/c869984f-5f7c-4888-89b9-d397aefa9dac/","rejectReason":"ee"}],"z_groupResourceUri":"/api/v1/z_group/salesforce/"}}');
        res.setStatusCode(200);
        return res;
    }
}