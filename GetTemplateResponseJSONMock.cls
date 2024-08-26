@isTest                        
global class GetTemplateResponseJSONMock implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"meta":{"limit":1000,"next":null,"offset":0,"previous":null,"total_count":4},"objects":[{"archive_upon_send":false,"created":"2021-10-14T11:15:14","group":"/api/v1/group/salesforce/","modified":"2021-11-02T13:25:35","page_count":5,"resource_uri":"/api/v1/templatepdf/bffb5c4c-c5d2-4cce-a509-709d42536de7/","signer_count":1,"title":"AEO Information Request V5NC","user":"/api/v1/user/f49a4740-c8f2-4437-a5e9-a40080d53e9b/","uuid":"bffb5c4c-c5d2-4cce-a509-709d42536de7","valid":true},{"archive_upon_send":false,"created":"2021-02-02T15:06:00","group":"/api/v1/group/salesforce/","modified":"2021-10-14T11:33:17","page_count":1,"resource_uri":"/api/v1/templatepdf/7af3787c-3380-4049-8cc2-b8c5ed632d2d/","signer_count":1,"title":"Representation Letter","user":"/api/v1/user/f49a4740-c8f2-4437-a5e9-a40080d53e9b/","uuid":"7af3787c-3380-4049-8cc2-b8c5ed632d2d","valid":true},{"archive_upon_send":false,"created":"2021-10-14T11:22:45","group":"/api/v1/group/salesforce/","modified":"2021-10-14T11:35:47","page_count":1,"resource_uri":"/api/v1/templatepdf/fbf01b99-4c13-4a1a-bf83-707bd6ec224e/","signer_count":1,"title":"Request to insure all freight","user":"/api/v1/user/f49a4740-c8f2-4437-a5e9-a40080d53e9b/","uuid":"fbf01b99-4c13-4a1a-bf83-707bd6ec224e","valid":true},{"archive_upon_send":false,"created":"2021-10-14T11:02:29","group":"/api/v1/group/salesforce/","modified":"2021-11-03T11:47:48","page_count":2,"resource_uri":"/api/v1/templatepdf/5a9f33fc-309b-4a5e-a640-6955798168d8/","signer_count":1,"title":"Woodland Global Trade & Credit Application","user":"/api/v1/user/f49a4740-c8f2-4437-a5e9-a40080d53e9b/","uuid":"5a9f33fc-309b-4a5e-a640-6955798168d8","valid":true}]}');
        res.setStatusCode(200);
        return res;
    }
}