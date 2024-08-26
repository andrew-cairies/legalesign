@isTest                        
global class GetTemplateFieldsResponseJSONMock implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"meta":{"limit":20,"next":null,"offset":0,"previous":null,"total_count":18},"objects":[{"align":1,"ax":0.24068416414659993,"ay":0.21142423049817408,"bx":0.8838026027533751,"by":0.22423782022533614,"element_type":"admin","fieldorder":null,"font_name":"arial","font_size":12,"hide_border":false,"label":"Company Name","label_extra":"","logic_action":null,"logic_group":null,"map_to":"","optional":true,"options":"","page":1,"signer":1,"substantive":false,"validation":null,"value":""},{"align":1,"ax":0.17080811649113545,"ay":0.24711923045241127,"bx":0.48525033094072567,"by":0.2599328201795733,"element_type":"admin","fieldorder":null,"font_name":"","font_size":12,"hide_border":false,"label":"Phone","label_extra":"","logic_action":null,"logic_group":null,"map_to":"","optional":true,"options":"","page":1,"signer":1,"substantive":false,"validation":null,"value":""}]}');
        res.setStatusCode(200);
        return res;
    }
}