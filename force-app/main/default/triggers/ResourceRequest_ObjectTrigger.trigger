trigger ResourceRequest_ObjectTrigger on pse__Resource_Request__c (before insert, before update, after insert, after update) {
	
    // Hours Distribution Sync 
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c')) return;
	HoursDistroSync_Handler.processTriggerResourceRequest(Trigger.new, Trigger.oldMap);


}