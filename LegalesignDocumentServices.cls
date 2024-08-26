public class LegalesignDocumentServices { 
    
    @future(callout=true)
    public static void SendForSignatureFromRecord(String documentId, String templateId, Map<String, String> fieldValues, String name, String groupName) {                    
        
        list<Legalesign_Document_Signer__c> signers = [SELECT id, Contact__r.firstname, Contact__r.lastname, Contact__r.email, Signing_Order__c 
                                                       FROM Legalesign_Document_Signer__c 
                                                       WHERE Legalesign_Document__c =: documentId];
        
        HttpResponse res = LegalesignAPIHandler.SignTemplate(templateId, signers, name, fieldValues, groupName);
        if(res.getStatusCode() == 201) {
            String location = res.getHeader('Location');
            String uuid = location.substringBetween('status/', '/');
            SetTemplateID(documentId, templateId, uuid);   
            SetStatus(documentId, 'Awaiting Signature');
        } else {
            SetError(documentId, res.getBody());
        }
        
    }
    @future(callout=true)
    public static void SendSetForSignatureFromRecord(String templateList) {                    
        
        
        HttpResponse res = LegalesignAPIHandler.SignTemplateSet(templateList);
        if(res.getStatusCode() == 201) {
            system.debug('*** signedtemplateresponse ' + res.getBody());
            for (SignTemplateSetResponseJSON signed : SignTemplateSetResponseJSON.parse(res.getBody())) {
                String uuid = signed.location.substringBetween('status/', '/');
                String batch = signed.batch;
                String documentId = signed.tag;
                SetTemplateIDFromSet(documentId, uuid, batch);
                SetStatus(documentId, 'Awaiting Signature');
            }	                        
        } else {
            //SetError(documentId, res.getBody());
        }
        
    }
    @future(callout=true)
    public static void GetSignedTemplate(String documentId) {
        Legalesign_Document__c document = [SELECT id, uuid__c, locationid__c, name, account__c, contact__c FROM Legalesign_Document__c WHERE id=: documentId];       
        HttpResponse res = LegalesignAPIHandler.GetSignedTemplate(document.uuid__c);
        if(res.getStatusCode() == 200) {
            ContentVersion signedPDF = new ContentVersion();       
            signedPDF.VersionData = res.getBodyAsBlob();
            signedPDF.PathOnClient = document.name + '_Signed' + '.pdf';
            signedPDF.Title = document.name + '_Signed';
            signedPDF.OwnerId = userinfo.getUserId();
            signedPDF.firstPublishLocationId= userinfo.getUserId();
            insert signedPDF;        
            ContentVersion insertedPDF = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :signedPDF.Id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = documentId;
            contentlink.contentdocumentid = insertedPDF.contentdocumentid; 
            contentlink.ShareType = 'I';
            insert contentlink; 
            ContentDocumentLink contentlinkacct = new ContentDocumentLink();
            if(document.Account__c <> null)
	            contentlinkacct.LinkedEntityId = document.account__c;
            if(document.Contact__c <> null)
	            contentlinkacct.LinkedEntityId = document.Contact__c;
            contentlinkacct.contentdocumentid = insertedPDF.contentdocumentid;
            contentlinkacct.ShareType = 'I';
            insert contentlinkacct;
            document.Status__c = 'Signed Document Downloaded';
            update document;
        } else SetError(documentId, 'Error retrieving signed document');
    }
    @future(callout=true)
    public static void UpdateObjectFieldsFromSignedDocument(String documentId) {
        Legalesign_Document__c document = [SELECT id, uuid__c, locationid__c, name, account__c, contact__c, Legalesign_Template__r.Field_Mappings__c, Legalesign_Template__r.object__c FROM Legalesign_Document__c WHERE id=: documentId]; 
        if(document.Legalesign_Template__r.Field_Mappings__c <> null) {
            List<TemplateBuilderController.FieldMapping> fieldMappings = (List<TemplateBuilderController.FieldMapping>)JSON.deserialize(document.Legalesign_Template__r.Field_Mappings__c, List<TemplateBuilderController.FieldMapping>.class);  
            system.debug('***field mappings ' + fieldMappings);
            Map<String, String> fieldMap = new Map<String, String>();
            for(TemplateBuilderController.FieldMapping mapping : fieldMappings) {
                fieldMap.put(mapping.label, mapping.field);
            }
            system.debug('***fieldmap + ' + fieldMap);
            HttpResponse res = LegalesignAPIHandler.GetDocumentFields(document.uuid__c);
            List<GetDocumentFieldsResponseJSON> fields = GetDocumentFieldsResponseJSON.parse(res.getBody());
            
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Schema.SObjectType sobjType = gd.get(document.Legalesign_Template__r.object__c); 
            Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
            Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
            sObject obj = sobjType.newSObject();
            if(document.account__c <> null)
	            obj.put('Id', document.account__c);
            if(document.contact__c <> null)
	            obj.put('Id', document.contact__c);
            for(GetDocumentFieldsResponseJSON field : fields) {
                if(field.element_type == 'text' && field.label <> '' && field.value <> '') {
                    if(fieldMap.containsKey(field.label)) {                                            
                        Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldMap.get(field.label)).getDescribe();
                        system.debug('*** type ' + fieldDescribe.getType());
                        if(fieldDescribe.getType() == Schema.DisplayType.Date) {
                            try {
	                            obj.put(fieldMap.get(field.label), Date.parse(field.value));                                                                         
                            } catch (Exception e) {
                            	system.debug('*** invalid date returned ' + field.value); 
                            }
                        } else if(fieldDescribe.getType() == Schema.DisplayType.Boolean) {
                            if(field.value == '&#10004;') {
                            	obj.put(fieldMap.get(field.label), true);     
                            }
                        } else if(fieldDescribe.getType() == Schema.DisplayType.DOUBLE) {      
                            try {
	                            obj.put(fieldMap.get(field.label), Double.valueOf(field.value));      
                            } catch (Exception e) {
                            	system.debug('*** invalid double returned ' + field.value); 
                            }
                        } else if(fieldDescribe.getType() == Schema.DisplayType.INTEGER) {  
                            try {
                            	obj.put(fieldMap.get(field.label), Integer.valueOf(field.value));      
                            } catch (Exception e) {
                            	system.debug('*** invalid integer returned ' + field.value); 
                            }
                        }
                        else {
                            try {
	                            obj.put(fieldMap.get(field.label), field.value);      
                            } catch (Exception e) {
                            	system.debug('*** invalid field returned ' + field.value); 
                            }
                    	}	    
                	}
            	}
            }
            try {
	            update obj;        	
            } catch (Exception e) {
                document.Error_Message__c = e.getMessage();
                document.Status__c = 'Error';
                update document;
            }
        }                 
    }
    public static void SetTemplateIDFromSet(String documentId, String uuid, String batch) {
        Legalesign_Document__c doc = new Legalesign_Document__c();
        doc.Id = documentId;
        doc.uuid__c = uuid;        
        doc.batchId__c = batch;
        update doc;
    }   
    public static void SetTemplateID(String documentId, String locationId, String uuid) {
        Legalesign_Document__c doc = new Legalesign_Document__c();
        doc.Id = documentId;
        doc.uuid__c = uuid;
        doc.locationid__c = locationId;
        update doc;  
    }    
    public static void SetStatus(String documentId, String status) {
        Legalesign_Document__c doc = new Legalesign_Document__c();
        doc.Id = documentId;        
        doc.Status__c = status;
        doc.Error_Message__c = ''; 
        update doc;
    }
    public static void SetError(String documentId, String error) { 
        Legalesign_Document__c doc = new Legalesign_Document__c();
        doc.Id = documentId;
        doc.Error_Message__c = error;
        doc.Status__c = 'Error'; 
        update doc; 
    }
    public static Map<String, GetTemplateResponseJSON.Templates> GetTemplates() {
        HttpResponse res = LegalesignAPIHandler.GetTemplates();
        GetTemplateResponseJSON templates = GetTemplateResponseJSON.parse(res.getBody());
        Map<String, GetTemplateResponseJSON.Templates> templateMap = new Map<String, GetTemplateResponseJSON.Templates>();                       
        for(GetTemplateResponseJSON.Templates template : GetTemplateResponseJSON.getTemplateList()) {
            if(template.title <> '') {          			
                templateMap.put(template.uuid, template);                  
            }
        }
        return templateMap;
    }
    public static List<GetTemplateFieldsResponseJSON.Fields> GetTemplateFields(String locationId) {
        HttpResponse res = LegalesignAPIHandler.GetTemplateFields(locationId);
        GetTemplateFieldsResponseJSON fields = GetTemplateFieldsResponseJSON.parse(res.getBody());
        return GetTemplateFieldsResponseJSON.getFieldsList();
    }     
    
    /*
    @future(callout=true)
    public static void SendForSignature(String documentId) {                    
        list<ContentDocumentLink> docLinks = [SELECT id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: documentId];    
        ContentDocument doc = [SELECT id, title FROM ContentDocument WHERE id=: docLinks[0].ContentDocumentId];
        ContentVersion pdf = [SELECT id, title, VersionData FROM ContentVersion WHERE ContentDocumentId=:doc.id LIMIT 1];
        HttpResponse res = LegalesignAPIHandler.CreateTemplate(pdf);
        if(res.getStatusCode() == 201) {
            String location = res.getHeader('Location');
            String locationId = location.substringBetween('pdf/', '/');
            res = LegalesignAPIHandler.CheckTemplate(locationId);                
            TemplateValidateJSON validTemplate = (TemplateValidateJSON)JSON.deserialize(res.getBody(), TemplateValidateJSON.class);
            list<Legalesign_Document_Signer__c> signers = [SELECT id, Contact__r.firstname, Contact__r.lastname, Contact__r.email, Signing_Order__c 
                                                           FROM Legalesign_Document_Signer__c 
                                                           WHERE Legalesign_Document__c =: documentId];
            if(signers.size() != validTemplate.signer_count) {                	
                SetError(documentId, 'Incorrect Number of Signers - expected ' + validTemplate.signer_count + ' provided ' + signers.size());
            } else if(validTemplate.valid == true) {                    
                res = LegalesignAPIHandler.SignTemplate(locationId, signers, pdf.title, null);
                if(res.getStatusCode() == 201) {
                    location = res.getHeader('Location');
                    String uuid = location.substringBetween('status/', '/');
                    SetTemplateID(documentId, locationId, uuid);   
                    SetStatus(documentId, 'Awaiting Signature');
                } else {
                    SetError(documentId, res.getBody());
                }
            } else {                    	
                SetError(documentId, 'Invalid Template');
            }
        } else {
            SetError(documentId, res.getBody());
        }             
    }*/
}