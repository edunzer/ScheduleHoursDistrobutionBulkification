public with sharing class HoursDistroSync_Handler {
    public HoursDistroSync_Handler() {

    }
    // Generic handlers that operate on SObjects for a given object API name
    public static void handleBeforeUpdate(List<SObject> newPending, Map<Id, SObject> oldMap, String objectApiName) {
        if (newPending == null || newPending.isEmpty()) return;
        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);
        for (SObject r : newPending) {
            r.put('HoursDistro_Sync_RunKey__c', runKey);
            r.put('HoursDistro_Sync_Status__c', 'Pending');
        }
    }

    public static void handleAfterUpdate(List<SObject> newPending, Map<Id, SObject> oldMap, String objectApiName) {
        if (HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName)) {
            System.enqueueJob(new HoursDistroSync_QueueableWorker(HoursDistroSync_RunKeyHelper.getRunKey(objectApiName), objectApiName));
        }
    }

    // Typed wrappers for existing objects (keeps backwards compatibility)
    public static void handleBeforeUpdate(List<pse__Resource_Request__c> newPending, Map<Id, pse__Resource_Request__c> oldMap) {
        if (newPending == null || newPending.isEmpty()) return;
        List<SObject> sNew = new List<SObject>();
        for (pse__Resource_Request__c r : newPending) sNew.add(r);
        Map<Id, SObject> sOld = new Map<Id, SObject>();
        if (oldMap != null) {
            for (Id k : oldMap.keySet()) sOld.put(k, oldMap.get(k));
        }
        handleBeforeUpdate(sNew, sOld, 'pse__Resource_Request__c');
    }

    public static void handleAfterUpdate(List<pse__Resource_Request__c> newPending, Map<Id, pse__Resource_Request__c> oldMap) {
        if (newPending == null || newPending.isEmpty()) return;
        List<SObject> sNew = new List<SObject>();
        for (pse__Resource_Request__c r : newPending) sNew.add(r);
        Map<Id, SObject> sOld = new Map<Id, SObject>();
        if (oldMap != null) {
            for (Id k : oldMap.keySet()) sOld.put(k, oldMap.get(k));
        }
        handleAfterUpdate(sNew, sOld, 'pse__Resource_Request__c');
    }

    // New typed wrappers for pse__Assignment__c
    public static void handleBeforeUpdate(List<pse__Assignment__c> newPending, Map<Id, pse__Assignment__c> oldMap) {
        if (newPending == null || newPending.isEmpty()) return;
        List<SObject> sNew = new List<SObject>();
        for (pse__Assignment__c r : newPending) sNew.add(r);
        Map<Id, SObject> sOld = new Map<Id, SObject>();
        if (oldMap != null) {
            for (Id k : oldMap.keySet()) sOld.put(k, oldMap.get(k));
        }
        handleBeforeUpdate(sNew, sOld, 'pse__Assignment__c');
    }

    public static void handleAfterUpdate(List<pse__Assignment__c> newPending, Map<Id, pse__Assignment__c> oldMap) {
        if (newPending == null || newPending.isEmpty()) return;
        List<SObject> sNew = new List<SObject>();
        for (pse__Assignment__c r : newPending) sNew.add(r);
        Map<Id, SObject> sOld = new Map<Id, SObject>();
        if (oldMap != null) {
            for (Id k : oldMap.keySet()) sOld.put(k, oldMap.get(k));
        }
        handleAfterUpdate(sNew, sOld, 'pse__Assignment__c');
    }
}