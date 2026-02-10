trigger Assignment_ObjectTrigger on pse__Assignment__c (before insert, before update, after insert, after update) {
    
	// Hours Distribution Sync 
	try {
		if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c')) return;
	} catch (Exception e) {
		if (e instanceof HoursDistroSync_RunKeyHelper.MissingConfigurationException) {
			System.debug('HoursDistroSync disabled due to missing configuration: ' + e.getMessage());
			return;
		}
		throw e;
	}
	HoursDistroSync_Handler.processTriggerAssignment(Trigger.new, Trigger.oldMap);


}