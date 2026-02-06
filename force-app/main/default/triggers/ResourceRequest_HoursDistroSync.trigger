trigger ResourceRequest_HoursDistroSync on pse__Resource_Request__c (before insert, before update, after insert, after update) {
	// Short-circuit if processing is disabled via custom setting for Resource Request
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c')) return;

	HoursDistroSync_Handler.processTriggerResourceRequest(Trigger.new, Trigger.oldMap);
}