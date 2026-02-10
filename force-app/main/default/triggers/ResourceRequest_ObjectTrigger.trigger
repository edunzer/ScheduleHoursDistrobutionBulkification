trigger ResourceRequest_ObjectTrigger on pse__Resource_Request__c (before insert, before update, after insert, after update) {
	
	// Hours Distribution Sync 
	try {
		if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c')) return;
	} catch (Exception e) {
		if (e instanceof HoursDistroSync_RunKeyHelper.MissingConfigurationException) {
			System.debug('HoursDistroSync disabled due to missing configuration: ' + e.getMessage());
			return;
		}
		throw e;
	}
	HoursDistroSync_Handler.processTriggerResourceRequest(Trigger.new, Trigger.oldMap);


}