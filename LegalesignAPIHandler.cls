public class LegalesignAPIHandler {
    
    //private static string groupName = '/api/v1/group/salesforce/';    
    
    public static Legalesign_API__mdt api_config() {
        return Legalesign_API__mdt.getInstance('current');
    }
    
    public static HttpResponse GetTemplates() {
        HttpResponse res;
        try {
            String endpoint = api_config().endpoint__c + '/templatepdf/?valid=true&limit=10000';
            String method = 'GET';       
            res = issueCallout(endpoint, method, '');  
        } catch (Exception e) {}
        return res;    
    }
    
    public static HttpResponse GetDocumentFields(String locationId) {
        HttpResponse res;
        try {
            String endpoint = api_config().endpoint__c + '/document/';
            String method = 'GET';       
            res = issueCallout(endpoint + locationId + '/' +'fields/', method, '');  
        } catch (Exception e) {}  
        return res;
    }
    public static HttpResponse GetTemplateFields(String locationId) {
        HttpResponse res;
        try {
            String endpoint = api_config().endpoint__c + '/templatepdf/';
            String method = 'GET';       
            res = issueCallout(endpoint + locationId + '/' +'fields/?limit=10000', method, '');  
        } catch (Exception e) {}  
        return res;
    }
    /*
    public static HttpResponse CreateTemplate(ContentVersion pdf) {
        HttpResponse res;
        try {
            String endpoint = api_config().endpoint__c + '/templatepdf/';
            String method = 'POST';
            String base64PDF = EncodingUtil.base64Encode(pdf.VersionData);
            CreateTemplateJSON template = new CreateTemplateJSON(
                api_config().group__c, pdf.title, base64PDF, 'true');        
            res = issueCallout(endpoint, method, JSON.serialize(template).replace('"zGroup":', '"group":'));        
            List<string> headers = res.getHeaderKeys();
            for(String s : headers)
                system.debug('header ' + s + ' : ' + res.getHeader(s));
            system.debug('body ' + res.getBody());  
        } catch (Exception e) {}
        return res;             
    }
    
    public static HttpResponse CheckTemplate(String locationId) {
        HttpResponse res;
        try {
            String endpoint =  api_config().endpoint__c +'/templatepdf/';
            String method = 'GET';       
            res = issueCallout(endpoint + locationId + '/', method, '');  
        } catch (Exception e) {}
        return res;        
    }
    */
    public static HttpResponse SignTemplate(String locationId, list<Legalesign_Document_Signer__c> signers, String templateName, Map<String, String> fieldValues, String groupName) {
        HttpResponse res;
        try {
            String endpoint = api_config().endpoint__c + '/document/';
            String method = 'POST';
            TemplateSigningJSON template = new TemplateSigningJSON();
            template.name = templateName;
            template.zGroup = groupName;
            template.templatepdf = '/api/v1/templatepdf/' + locationId + '/';
            template.do_email = 'true';
            template.pdftext = fieldValues;
            template.convert_sender_to_signer = '1';
            list<TemplateSigningJSON.signers> allSigners = new list<TemplateSigningJSON.signers>();
            for(Legalesign_Document_Signer__c signer : signers) {
                TemplateSigningJSON.Signers tSigner = new TemplateSigningJSON.Signers();
                tSigner.firstname = signer.Contact__r.firstname;
                tSigner.lastname = signer.Contact__r.lastname;
                tSigner.email = signer.Contact__r.email;
                tSigner.order = Integer.valueOf(signer.Signing_Order__c);
                allSigners.add(tSigner);            
            }
            template.signers = allSigners;   
            String templateString = JSON.serialize(template);
            templateString = templateString.replace('"zGroup":', '"group":');
            templateString = templateString.replace('\\', '');            
            res = issueCallout(endpoint, method, templateString);
            List<string> headers = res.getHeaderKeys();
            for(String s : headers)
                system.debug('header ' + s + ' : ' + res.getHeader(s));
            system.debug('body ' + res.getBody());                         
        } catch (Exception e){}
        return res;
    }
    
    public static HttpResponse SignTemplateSet(String templateList) {
        HttpResponse res;
        try {
            String endpoint = api_config().endpoint__c + '/documents/';
            String method = 'POST';                             
            res = issueCallout(endpoint, method, templateList);
            List<string> headers = res.getHeaderKeys();
            for(String s : headers)
                system.debug('header ' + s + ' : ' + res.getHeader(s));
            system.debug('body ' + res.getBody());                         
        } catch (Exception e){}
        return res;
    }
    
    public static HttpResponse GetSignedTemplate(String uuid) {        
        String endpoint = api_config().endpoint__c + '/pdf/';
        String method = 'GET';
        HttpResponse res = issueCallout(endpoint + uuid + '/', method, '');  
        return res;
    }
    
    public static HttpResponse issueCallout(String endpoint, String method, String body) {
        
        Http h = new Http(); 
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Legalesign_API__mdt config = Legalesign_API__mdt.getInstance('current');
        String apikey = config.apikey__c;
        String group_name = config.group__c;
        String end_point = config.endpoint__c;
        req.setEndpoint(endpoint);
        req.setMethod(method);                                    
        req.setHeader('Authorization', apikey);
        req.setHeader('Content-Type', 'application/json');        
        if(body != '') req.setBody(body);
        system.debug('body' + body);            
        res = h.send(req);          
        system.debug('response' + res);
        List<string> headers = res.getHeaderKeys();
        for(String s : headers)
            system.debug('header ' + s + ' : ' + res.getHeader(s));
        system.debug('response body' + res.getBody());        
        return res;
    }  
    
    public static TemplateSigningJSON GetTemplateJSON(String locationId, String templateName, Map<String, String> fieldValues, String documentId, String groupName) {
        
        list<Legalesign_Document_Signer__c> signers = [SELECT id, Contact__r.firstname, Contact__r.lastname, Contact__r.email, Signing_Order__c 
                                                       FROM Legalesign_Document_Signer__c 
                                                       WHERE Legalesign_Document__c =: documentId];
        
        TemplateSigningJSON template = new TemplateSigningJSON();
        try {            
            system.debug('*** signers ' + signers); 
            template.name = templateName;
            template.zGroup = groupName;
            template.templatepdf = '/api/v1/templatepdf/' + locationId + '/';
            template.do_email = 'true';
            template.pdftext = fieldValues;
            template.convert_sender_to_signer = '1';
            system.debug('*** documentid ' + documentId);
            template.tag = documentId;
            list<TemplateSigningJSON.signers> allSigners = new list<TemplateSigningJSON.signers>();
            for(Legalesign_Document_Signer__c signer : signers) {
                TemplateSigningJSON.Signers tSigner = new TemplateSigningJSON.Signers();
                tSigner.firstname = signer.Contact__r.firstname;
                tSigner.lastname = signer.Contact__r.lastname;
                tSigner.email = signer.Contact__r.email;
                tSigner.order = Integer.valueOf(signer.Signing_Order__c);
                allSigners.add(tSigner);            
            }
            template.signers = allSigners;                                  
        } catch (Exception e){}
        return template;
    }
    
    
    
    
}