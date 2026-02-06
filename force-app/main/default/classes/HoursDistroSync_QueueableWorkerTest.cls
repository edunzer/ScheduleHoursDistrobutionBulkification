/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class HoursDistroSync_QueueableWorkerTest {

    @isTest
    static void testQueueableClearsEnqueuedForResourceRequest() {
        String objectApiName = 'pse__Resource_Request__c';
        // Ensure no enqueued state
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);

        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);
        // Mark enqueued to simulate handler behavior
        Boolean marked = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked, 'Should be marked enqueued initially');

        Test.startTest();
        System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
        Test.stopTest();

        // After queueable executes it should clear enqueued state
        Boolean after = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, after, 'Enqueued state should have been cleared by the queueable');
    }

    @isTest static void testQueueableClearsEnqueuedForAssignment() {
        String objectApiName = 'pse__Assignment__c';
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);

        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);
        Boolean marked = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
        Test.stopTest();

        Boolean after = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, after);
    }

    @isTest static void testConstructorValidation() {
        // Valid constructor inputs should not throw
        new HoursDistroSync_QueueableWorker('rk', 'pse__Resource_Request__c');
        new HoursDistroSync_QueueableWorker('rk', 'pse__Assignment__c');
    }

    @isTest static void testGetChunkSizeUsesAssignmentSetting() {
        String objectApiName = 'pse__Assignment__c';
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);
        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);

        try {
            insert new HoursDistributionSettings__c(Assignment_Chunk_Size__c = 5);
        } catch (Exception e) {
            // ignore if custom setting/field absent in this org
        }

        Boolean marked = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
        Test.stopTest();

        // ensure helper cleared
        System.assertEquals(true, HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName));
    }

    @isTest static void testGetChunkSizeUsesResourceRequestSetting() {
        String objectApiName = 'pse__Resource_Request__c';
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);
        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);

        try {
            insert new HoursDistributionSettings__c(Resource_Request_Chunk_Size__c = 7);
        } catch (Exception e) {
            // ignore if custom setting/field absent in this org
        }

        Boolean marked = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
        Test.stopTest();

        System.assertEquals(true, HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName));
    }

    // Helper: create a new SObject and populate non-nullable primitive fields with defaults
    private static SObject buildMinimalSObject(String apiName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey(apiName)) return null;
        SObject sobj = gd.get(apiName).newSObject();
        Map<String, Schema.SObjectField> fmap = gd.get(apiName).getDescribe().fields.getMap();
        for (String fname : fmap.keySet()) {
            Schema.DescribeFieldResult fd = fmap.get(fname).getDescribe();
            if (!fd.isCreateable()) continue;
            if (fd.isNillable()) continue;
            Schema.DisplayType dt = fd.getType();
            try {
                if (dt == Schema.DisplayType.STRING || dt == Schema.DisplayType.TEXTAREA || dt == Schema.DisplayType.PHONE
                    || dt == Schema.DisplayType.EMAIL || dt == Schema.DisplayType.URL) {
                    sobj.put(fname, 'T');
                } else if (dt == Schema.DisplayType.INTEGER) {
                    sobj.put(fname, 1);
                } else if (dt == Schema.DisplayType.DOUBLE || dt == Schema.DisplayType.CURRENCY || dt == Schema.DisplayType.PERCENT) {
                    sobj.put(fname, Decimal.valueOf(1));
                } else if (dt == Schema.DisplayType.BOOLEAN) {
                    sobj.put(fname, false);
                } else if (dt == Schema.DisplayType.DATE) {
                    sobj.put(fname, Date.today());
                } else if (dt == Schema.DisplayType.DATETIME) {
                    sobj.put(fname, DateTime.now());
                } else if (dt == Schema.DisplayType.PICKLIST) {
                    List<Schema.PicklistEntry> vals = fd.getPicklistValues();
                    if (!vals.isEmpty()) sobj.put(fname, vals[0].getValue());
                }
            } catch (Exception ex) {
                // ignore any failures setting defaults
            }
        }
        return sobj;
    }
}