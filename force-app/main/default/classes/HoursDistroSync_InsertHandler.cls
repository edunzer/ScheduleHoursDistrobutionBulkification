public with sharing class HoursDistroSync_InsertHandler {
    public static void handleBeforeInsert(List<pse__Resource_Request__c> newRecords) {
        if (newRecords == null || newRecords.isEmpty()) return;
        String runKey = HoursDistroSync_RunKeyHelper.getRunKey();
        for (pse__Resource_Request__c r : newRecords) {
            r.HoursDistro_Sync_RunKey__c = runKey;
            r.HoursDistro_Sync_Status__c = 'Pending';
        }
    }

    public static void handleAfterInsert(List<pse__Resource_Request__c> newRecords) {
        // Ensure only one queueable is enqueued per transaction
        if (HoursDistroSync_RunKeyHelper.markEnqueued()) {
            System.enqueueJob(new HoursDistroSync_QueueableWorker(HoursDistroSync_RunKeyHelper.getRunKey()));
        }
    }
}