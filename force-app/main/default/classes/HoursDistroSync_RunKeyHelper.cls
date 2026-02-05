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

        // Validate supported object names so unsupported names fail fast
        if (objectApiName != 'pse__Assignment__c' && objectApiName != 'pse__Resource_Request__c') {
            throw new UnsupportedObjectApiNameException('Unsupported objectApiName: ' + objectApiName);
        }

        // Use dynamic describe and dynamic SOQL to avoid compile-time dependency on a
        // custom setting or its fields. If the object/field is missing, treat as enabled.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('HoursDistributionSettings__c')) return true;

        Schema.SObjectType sd = gd.get('HoursDistributionSettings__c');
        Map<String, Schema.SObjectField> fieldMap = sd.getDescribe().fields.getMap();
        String fieldName = (objectApiName == 'pse__Assignment__c')
            ? 'Assignment_Enable_HoursDistro_Sync__c'
            : 'Resource_Request_Enable_HoursDistro_Sync__c';

        if (!fieldMap.containsKey(fieldName)) return true;

        try {
            String soql = 'SELECT ' + fieldName + ' FROM HoursDistributionSettings__c LIMIT 1';
            List<SObject> rows = Database.query(soql);
            if (rows.isEmpty()) return true;
            SObject rec = rows[0];
            Object val = rec.get(fieldName);
            if (val == null) return true;
            if (val instanceof Boolean) return (Boolean)val;
            return String.valueOf(val).toLowerCase() == 'true';
        } catch (Exception e) {
            System.debug('HoursDistroSync_RunKeyHelper.isEnabled (dynamic) error: ' + e);
            return true;
        }
    }

}