public with sharing class HoursDistroSync_RunKeyHelper {
    private static Map<String, String> runKeys = new Map<String, String>();
    private static Set<String> enqueuedObjects = new Set<String>();

    private HoursDistroSync_RunKeyHelper() {
        // static helper only
    }

    public static String getRunKey(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        if (!runKeys.containsKey(objectApiName)) {
            String rk = objectApiName + '_hrs_' + String.valueOf(DateTime.now().getTime()) + '_' + String.valueOf(Math.abs((Integer)(Math.random() * 1000000)));
            runKeys.put(objectApiName, rk);
        }
        return runKeys.get(objectApiName);
    }

    /**
     * Returns true if this call successfully marked the transaction as having queued a job
     * for the given object. Ensures only one Queueable is enqueued per object per transaction.
     */
    public static Boolean markEnqueued(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        if (enqueuedObjects.contains(objectApiName)) return false;
        enqueuedObjects.add(objectApiName);
        return true;
    }

    public static void clearEnqueued(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        enqueuedObjects.remove(objectApiName);
        runKeys.remove(objectApiName);
    }

    /**
     * Returns whether processing is enabled via the HoursDistributionSettings__c custom setting.
     * If the setting or field is missing, defaults to true (enabled).
     * Expected checkbox field API name: Resource_Request_Enable_HoursDistro_Sync__c
     */
    public static Boolean isEnabled() {
        return isEnabled('pse__Resource_Request__c');
    }

    public static Boolean isEnabled(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');

        try {
            HoursDistributionSettings__c s = [SELECT Resource_Request_Enable_HoursDistro_Sync__c, Assignment_Enable_HoursDistro_Sync__c FROM HoursDistributionSettings__c LIMIT 1];
            if (s == null) return true;

            if (objectApiName == 'pse__Assignment__c') {
                Object o = s.get('Assignment_Enable_HoursDistro_Sync__c');
                if (o == null) return true;
                if (o instanceof Boolean) return (Boolean)o;
                return String.valueOf(o).toLowerCase() == 'true';
            } else if (objectApiName == 'pse__Resource_Request__c') {
                Object o = s.get('Resource_Request_Enable_HoursDistro_Sync__c');
                if (o == null) return true;
                if (o instanceof Boolean) return (Boolean)o;
                return String.valueOf(o).toLowerCase() == 'true';
            } else {
                throw new Exception('Unsupported objectApiName: ' + objectApiName);
            }
        } catch (Exception e) {
            // Missing setting or field — treat as enabled; rethrow only for unsupported object names
            if (e.getMessage() != null && e.getMessage().startsWith('Unsupported objectApiName:')) {
                throw e;
            }
            return true;
        }
        }

    }