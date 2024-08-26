@isTest                        
global class GetDocumentFieldsResponseJSONMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {            
        
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        
        res.setBody('[{"label":"Company Name","fieldorder":null,"value":"33333","state":true,"signer":1,"element_type":"text","validation":null}]');
        res.setStatusCode(200);
        return res;
        
    } 
}