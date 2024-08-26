public class TemplateBuilderController {
    
    Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
 	public ApexPages.StandardController controller;
    public Legalesign_Template__c setup;
    public boolean showMappings {get ; set;}
    public String name;
    
    public class FieldMapping {
        public String label {get ; set;}
        public String field {get ; set;}
        public FieldMapping(String pLabel, String pField) {
            this.label = pLabel; 
            this.field = pField;
        }
    } 	
    
    public TemplateBuilderController(ApexPages.StandardController standardController) {
        this.controller = standardController;
        setup = (Legalesign_Template__c)controller.getRecord();
        showMappings = false;
    }
    
    public List<FieldMapping> fieldMappings {get;set;}   
    
    public List<FieldMapping> fieldMappingsToSave  = new List<FieldMapping>();
    
    
    public void getFieldMappings() {
        showMappings = true; 
        fieldMappings = new List<FieldMapping>();
        if(template <> '') {             	
	            for(GetTemplateFieldsResponseJSON.Fields field : LegalesignDocumentServices.GetTemplateFields(template)) {
                	if(field.label <> null && field.label <> '') {                          
                        FieldMapping fm = new FieldMapping(field.label, 'empty');
                        fieldMappings.add(fm);
                    }
                }
        	}                    
    }
    
    public PageReference save() {        
        setup.Object__c = sObjects;
        setup.template_name__c = templateMap.get(template).title;
        setup.template_ID__c = template;
        for(FieldMapping fm : fieldMappings) {
            if(fm.field <> null) {
             	fieldMappingsToSave.add(fm);   
            }
        }
        setup.Field_Mappings__c = JSON.serialize(fieldMappingsToSave);
        name = sObjects + ' - ' + templateMap.get(template).title;
        setup.name = name;
        setup.Group__c = templateMap.get(template).group_Z;
        insert setup;
        return new PageReference('/' + setup.Id);        
    }
    
    String sObjects = '';    
    public List<SelectOption> getsObjectOptions() {
        List<SelectOption> options = new List<SelectOption>();                        
        for(Schema.SobjectType obj : gd.values()) {
            Schema.DescribeSobjectResult objResult = obj.getDescribe();
            if(objResult.isCustom()) {
                options.add(new SelectOption(objResult.getname(), objResult.getname()));                       
            }
        }
        options.add(new SelectOption('Contact', 'Contact'));  
        options.add(new SelectOption('Account', 'Account'));  
        return options;
    }
    
    public String getsObjects() {
        
        return sObjects;
    }
    
    public void setsObjects(String sObjects) {
        
        this.sObjects = sObjects;
    }
    
    String template = '';
    
    Map<String, GetTemplateResponseJSON.Templates> templateMap;
    
    public List<SelectOption> getTemplateOptions() {
        List<SelectOption> options = new List<SelectOption>();                        
        templateMap = LegalesignDocumentServices.GetTemplates();
        for(String uuid : templateMap.keySet()) {
         	options.add(new SelectOption(uuid, templateMap.get(uuid).title));  
        } 
        return options;
    }
    
    public String getTemplate() {
        
        return template;
    }
    
    public void setTemplate(String template) {
        
        this.template = template;
    }        
    
    public List<SelectOption> getsObjectFieldOptions() {
        List<SelectOption> options = new List<SelectOption>();   
        if(sObjects <> '') {
            Schema.SObjectType sobjType = gd.get(sObjects); 
            Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
            Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
            options.add(new SelectOption('', ''));  
            for(String field : fieldsMap.keyset()) {
                
                options.add(new SelectOption(field, field));                       
            }
            options.sort();
        }
        
        return options;
    }         
}