trigger Assignment_HoursDistroSync on pse__Assignment__c (before insert, before update, after insert, after update) {
	// Short-circuit if processing is disabled via custom setting for Assignment
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c')) return;

	List<pse__Assignment__c> pending = new List<pse__Assignment__c>();

	if (Trigger.isInsert) {
		for (pse__Assignment__c r : Trigger.new) {
			if (r.HoursDistro_Sync_Status__c == 'Pending') {
				pending.add(r);
			}
		}
	} else if (Trigger.isUpdate) {
		for (pse__Assignment__c r : Trigger.new) {
			pse__Assignment__c oldR = Trigger.oldMap.get(r.Id);
			if (r.HoursDistro_Sync_Status__c == 'Pending'
				&& (oldR == null || oldR.HoursDistro_Sync_Status__c != 'Pending')) {
				pending.add(r);
			}
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