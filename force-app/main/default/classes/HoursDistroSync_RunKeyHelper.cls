public with sharing class HoursDistroSync_RunKeyHelper {
    public class UnsupportedObjectApiNameException extends Exception {}
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

        // Validate supported object names before querying so unsupported names fail fast
        if (objectApiName != 'pse__Assignment__c' && objectApiName != 'pse__Resource_Request__c') {
            throw new UnsupportedObjectApiNameException('Unsupported objectApiName: ' + objectApiName);
        }

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
            }
        } catch (Exception e) {
            System.debug('HoursDistroSync_RunKeyHelper.isEnabled error: ' + e);
            // Rethrow our specific unsupported-object exception so callers see the error
            if (e instanceof UnsupportedObjectApiNameException) {
                throw e;
            }
            // Missing setting or field — treat as enabled
            return true;
        }
        // Safety return to satisfy compiler; unreachable when supported objectApiName handled above
        return true;
    }

}