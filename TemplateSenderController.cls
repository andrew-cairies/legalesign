public with sharing class TemplateSenderController {
	
    public String templateId;
    public String recordId;
    public Legalesign_Template__c template;
    public List<TemplateBuilderController.FieldMapping> fieldMappings = new List<TemplateBuilderController.FieldMapping>();
    public List<TemplateBuilderController.FieldMapping> fieldValueMappings = new List<TemplateBuilderController.FieldMapping>();
        
    public Legalesign_Document_Signer__c signer1 { 
        get {
            if(signer1==null) 
                signer1 = new Legalesign_Document_Signer__c();
         	return signer1;   
        } set;
    }
    
    public TemplateSenderController() {
		templateId = ApexPages.currentPage().getParameters().get('templateId');
		recordId = ApexPages.currentPage().getParameters().get('recordId');        
        getTemplate();
        getFieldMappings();
        populateFieldValueMappings();        
    }
    
    public void getTemplate() {
    	template = [ SELECT id, Object__c, template_name__c, template_id__c, Field_Mappings__c, group__c FROM Legalesign_Template__c WHERE id=: templateId ];              
    }
    
    public void getFieldMappings() {
        fieldMappings = (List<TemplateBuilderController.FieldMapping>)JSON.deserialize(template.Field_Mappings__c, List<TemplateBuilderController.FieldMapping>.class);  
        system.debug('***field mappings ' + fieldMappings);
    }    
    
    public void populateFieldValueMappings() {        
        SObject record;
        Set<String> fieldSet = new Set<String>();
        for(TemplateBuilderController.FieldMapping fieldMapping : fieldMappings) {
            if(!fieldSet.contains(fieldMapping.field)) {
                fieldSet.add(fieldMapping.field);
            }         
        } 
        String SOQL = 'SELECT ';
        for(String field : fieldSet) {
            SOQL += field + ',';            
        }
        SOQL = SOQL.substring(0, SOQL.length()-1);
        SOQL += ' FROM ' + template.Object__c;
        SOQL += ' WHERE id = \'' + recordId + '\'';
        system.debug(SOQL);
        List<SObject> objs = Database.query(SOQL);
        if(objs != null)
        	record = objs[0]; 
        	Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Schema.SObjectType sobjType = gd.get(template.Object__c); 
            Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
            Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();    
        	for(TemplateBuilderController.FieldMapping fieldMapping : fieldMappings) {
                String value = '';
                Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldMapping.field).getDescribe();
                if(fieldDescribe.getType() == Schema.DisplayType.STRING){
                    value = (String)record.get(fieldMapping.field);
                } else {                     
                    value = String.valueOf(record.get(fieldMapping.field)); 
                }
                if(value==null) value ='';
                TemplateBuilderController.FieldMapping fm = new TemplateBuilderController.FieldMapping(fieldMapping.label, value);
                fieldValueMappings.add(fm);
            }   
        
    }
    
    public List<TemplateBuilderController.FieldMapping> getFieldValueMappings() {
        return fieldValueMappings;
    }
    
    public PageReference send() {
        String name = template.template_name__c;        
        Legalesign_Document__c  document = new Legalesign_Document__c ();
        document.name = name;
        document.Legalesign_Template__c = template.Id;
        if(recordId.startsWith('001'))
	        document.Account__c = recordId;
        if(recordId.startsWith('003'))
            document.Contact__c = recordId;
        insert document;        
        signer1.Legalesign_Document__c = document.id;
        signer1.Signing_Order__c = 0;
        insert signer1;                 
        
		map<string,string> valuemap = new map<string, string>();
        for(TemplateBuilderController.FieldMapping mapping : fieldValueMappings ) {
            valuemap.put(mapping.label, mapping.field);            
        }
        system.debug('*** valuemap ' + valuemap);
        LegalesignDocumentServices.SendForSignatureFromRecord(document.Id, template.Template_ID__c, valuemap, name, template.Group__c);
        return new PageReference('/'+recordId);
    }
    
    public PageReference cancel() {
                return null;
    }
        
}