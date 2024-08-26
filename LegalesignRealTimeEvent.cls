@RestResource(urlMapping='/realTimeEvent')
global class LegalesignRealTimeEvent {
      
    @HttpPost
    global static String doPost() {
        RestRequest request = RestContext.request;         
        Map <String, String> params = request.params;
        for(String param : params.keyset()) 
            system.debug('*** param ' + param + ' value ' + params.get(param));
        Blob b = request.requestBody;
        String body = b.toString();
        body = body.replace('group', 'z_group');
        body = body.replace('object', 'z_object');
		system.debug('*** body ' + body);
        RealTimeEventJSON json = RealTimeEventJSON.parse(body);
        String event = json.event;
        system.debug('*** event ' + event);
        if(event=='rejected') {
            List<RealTimeEventJSON.Participants> participants = json.Data.Participants;
        	String uuid = json.Data.uuid;
        	system.debug('*** uuid ' + uuid);
            String reason = participants[0].rejectReason;
        	system.debug('*** reason ' + reason);      
            Legalesign_Document__c doc = [ SELECT id FROM Legalesign_Document__c WHERE uuid__c =: uuid LIMIT 1];      
            Legalesign_Document_Event__c docEvent = new Legalesign_Document_Event__c();
            docEvent.event__c = 'Rejected';
            docEvent.Reason__c = reason;
            docEvent.Legalesign_Document__c = doc.id;
        	insert docEvent;
        }
        
        
        return 'ok ';
    }
        
}