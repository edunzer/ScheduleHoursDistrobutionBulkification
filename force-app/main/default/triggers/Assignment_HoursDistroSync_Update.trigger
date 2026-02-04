trigger Assignment_HoursDistroSync_Update on pse__Assignment__c (before update, after update) {
	// Short-circuit if processing is disabled via custom setting for Assignment
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c')) return;

	List<pse__Assignment__c> pending = new List<pse__Assignment__c>();
	for (pse__Assignment__c r : Trigger.new) {
		pse__Assignment__c oldR = Trigger.oldMap.get(r.Id);
		if (r.HoursDistro_Sync_Status__c == 'Pending'
			&& (oldR == null || oldR.HoursDistro_Sync_Status__c != 'Pending')) {
			pending.add(r);
		}
	}

	if (pending.isEmpty()) return;

	if (Trigger.isBefore) {
		HoursDistroSync_Handler.handleBeforeUpdate(pending, Trigger.oldMap);
	}
	if (Trigger.isAfter) {
		HoursDistroSync_Handler.handleAfterUpdate(pending, Trigger.oldMap);
	}
}