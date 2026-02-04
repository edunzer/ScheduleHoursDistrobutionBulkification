public with sharing class HoursDistroSync_Handler {
    public HoursDistroSync_Handler() {

    }

    public static void handleBeforeUpdate(List<pse__Resource_Request__c> newPending, Map<Id, pse__Resource_Request__c> oldMap) {
        if (newPending == null || newPending.isEmpty()) return;
        String runKey = HoursDistroSync_RunKeyHelper.getRunKey();
        for (pse__Resource_Request__c r : newPending) {
            r.HoursDistro_Sync_RunKey__c = runKey;
            r.HoursDistro_Sync_Status__c = 'Pending';
        }
    }

    public static void handleAfterUpdate(List<pse__Resource_Request__c> newPending, Map<Id, pse__Resource_Request__c> oldMap) {
        if (HoursDistroSync_RunKeyHelper.markEnqueued()) {
            System.enqueueJob(new HoursDistroSync_QueueableWorker(HoursDistroSync_RunKeyHelper.getRunKey()));
        }
    }
}