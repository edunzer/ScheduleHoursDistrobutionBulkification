trigger ResourceRequest_HoursDistroSync on pse__Resource_Request__c (before insert, before update, after insert, after update) {
	// Short-circuit if processing is disabled via custom setting for Resource Request
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c')) return;

	List<pse__Resource_Request__c> pending = new List<pse__Resource_Request__c>();

	if (Trigger.isInsert) {
		for (pse__Resource_Request__c r : Trigger.new) {
			if (r.HoursDistro_Sync_Status__c == 'Pending') {
				pending.add(r);
			}
		}
	} else if (Trigger.isUpdate) {
		for (pse__Resource_Request__c r : Trigger.new) {
			pse__Resource_Request__c oldR = Trigger.oldMap.get(r.Id);
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