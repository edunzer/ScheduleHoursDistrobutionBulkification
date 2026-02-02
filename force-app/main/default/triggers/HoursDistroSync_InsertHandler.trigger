trigger HoursDistroSync_InsertHandler on pse__Resource_Request__c (before insert, after insert) {
	// Short-circuit if processing is disabled via custom setting
	if (!HoursDistroSync_RunKeyHelper.isEnabled()) return;

	if (Trigger.isBefore && Trigger.isInsert) {
		HoursDistroSync_InsertHandler.handleBeforeInsert(Trigger.new);
	}
	if (Trigger.isAfter && Trigger.isInsert) {
		HoursDistroSync_InsertHandler.handleAfterInsert(Trigger.new);
	}
}