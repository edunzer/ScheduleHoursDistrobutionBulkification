trigger Assignment_HoursDistroSync on pse__Assignment__c (before insert, before update, after insert, after update) {
	// Short-circuit if processing is disabled via custom setting for Assignment
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c')) return;

	HoursDistroSync_Handler.processTriggerAssignment(Trigger.new, Trigger.oldMap);
}