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

    // Trigger-friendly entry points that perform the same pending-filtering the triggers previously did.
    public static void processTriggerResourceRequest(List<pse__Resource_Request__c> triggerNew, Map<Id, pse__Resource_Request__c> oldMap) {
        if (triggerNew == null || triggerNew.isEmpty()) return;
        List<pse__Resource_Request__c> pending = new List<pse__Resource_Request__c>();
        if (Trigger.isInsert) {
            for (pse__Resource_Request__c r : triggerNew) {
                if (r.HoursDistro_Sync_Status__c == 'Pending') pending.add(r);
            }
        } else if (Trigger.isUpdate) {
            for (pse__Resource_Request__c r : triggerNew) {
                pse__Resource_Request__c oldR = (oldMap == null) ? null : oldMap.get(r.Id);
                if (r.HoursDistro_Sync_Status__c == 'Pending' && (oldR == null || oldR.HoursDistro_Sync_Status__c != 'Pending')) pending.add(r);
            }
        }
        if (pending.isEmpty()) return;
        if (Trigger.isBefore) handleBeforeUpdate(pending, oldMap == null ? null : (Map<Id,SObject>)oldMap, 'pse__Resource_Request__c');
        if (Trigger.isAfter) handleAfterUpdate(pending, oldMap == null ? null : (Map<Id,SObject>)oldMap, 'pse__Resource_Request__c');
    }

    public static void processTriggerAssignment(List<pse__Assignment__c> triggerNew, Map<Id, pse__Assignment__c> oldMap) {
        if (triggerNew == null || triggerNew.isEmpty()) return;
        List<pse__Assignment__c> pending = new List<pse__Assignment__c>();
        if (Trigger.isInsert) {
            for (pse__Assignment__c r : triggerNew) {
                if (r.HoursDistro_Sync_Status__c == 'Pending') pending.add(r);
            }
        } else if (Trigger.isUpdate) {
            for (pse__Assignment__c r : triggerNew) {
                pse__Assignment__c oldR = (oldMap == null) ? null : oldMap.get(r.Id);
                if (r.HoursDistro_Sync_Status__c == 'Pending' && (oldR == null || oldR.HoursDistro_Sync_Status__c != 'Pending')) pending.add(r);
            }
        }
        if (pending.isEmpty()) return;
        if (Trigger.isBefore) handleBeforeUpdate(pending, oldMap == null ? null : (Map<Id,SObject>)oldMap, 'pse__Assignment__c');
        if (Trigger.isAfter) handleAfterUpdate(pending, oldMap == null ? null : (Map<Id,SObject>)oldMap, 'pse__Assignment__c');
    }
}