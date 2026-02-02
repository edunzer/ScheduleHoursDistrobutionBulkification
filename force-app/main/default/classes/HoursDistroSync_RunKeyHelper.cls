public with sharing class HoursDistroSync_RunKeyHelper {
    private static String runKey;
    private static Boolean enqueued = false;

    private HoursDistroSync_RunKeyHelper() {
        // static helper only
    }

    public static String getRunKey() {
        if (runKey == null) {
            // create a compact, mostly-unique key per transaction
            runKey = 'hrs_' + String.valueOf(DateTime.now().getTime()) + '_' + String.valueOf(Math.abs((Integer)(Math.random() * 1000000)));
        }
        return runKey;
    }

    /**
     * Returns true if this call successfully marked the transaction as having queued a job.
     * Ensures only one Queueable is enqueued per transaction.
     */
    public static Boolean markEnqueued() {
        if (enqueued == null) enqueued = false;
        if (enqueued) return false;
        enqueued = true;
        return true;
    }

    /**
     * Returns whether processing is enabled via the HoursDistributionSettings__c custom setting.
     * If the setting or field is missing, defaults to true (enabled).
     * Expected checkbox field API name: Resource_Request_Enable_HoursDistro_Sync__c
     */
    public static Boolean isEnabled() {
        try {
            HoursDistributionSettings__c s = [SELECT Resource_Request_Enable_HoursDistro_Sync__c FROM HoursDistributionSettings__c LIMIT 1];
            if (s == null) return true;
            // If the field doesn't exist or is null, default to true
            if (((Map<String, Object>)s).containsKey('Resource_Request_Enable_HoursDistro_Sync__c')) {
                return s.Resource_Request_Enable_HoursDistro_Sync__c == true;
            }
        } catch (Exception e) {
            // Missing setting or field — treat as enabled
        }
        return true;
    }
}