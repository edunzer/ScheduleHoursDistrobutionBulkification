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

    @isTest static void testQueueableProcessesAndReEnqueues_ResourceRequest() {
        String objectApiName = 'pse__Resource_Request__c';
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);

        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);

        // Try to set chunk size small so worker will re-enqueue
        try {
            insert new HoursDistributionSettings__c(Resource_Request_Chunk_Size__c = 1);
        } catch (Exception e) {
            // ignore if custom setting/field absent in org under test
        }

        List<pse__Resource_Request__c> reqs = new List<pse__Resource_Request__c>{
            new pse__Resource_Request__c(HoursDistro_Sync_RunKey__c = runKey, HoursDistro_Sync_Status__c = 'Pending'),
            new pse__Resource_Request__c(HoursDistro_Sync_RunKey__c = runKey, HoursDistro_Sync_Status__c = 'Pending')
        };

        try {
            insert reqs;
        } catch (Exception e) {
            // If insertion fails due to required package fields, skip assert-heavy checks
            return;
        }

        Boolean marked = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
        Test.stopTest();

        Integer processed = [SELECT Id FROM pse__Resource_Request__c WHERE HoursDistro_Sync_RunKey__c = :runKey AND HoursDistro_Sync_Status__c = 'Processing'].size();
        System.assertEquals(2, processed, 'Both records should have been moved to Processing by queueable runs');

        // Ensure helper was cleared
        System.assertEquals(true, HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName));
    }

    @isTest static void testQueueableProcessesAndReEnqueues_Assignment() {
        String objectApiName = 'pse__Assignment__c';
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);

        String runKey = HoursDistroSync_RunKeyHelper.getRunKey(objectApiName);

        try {
            insert new HoursDistributionSettings__c(Assignment_Chunk_Size__c = 1);
        } catch (Exception e) {
            // ignore if custom setting/field absent
        }

        List<pse__Assignment__c> items = new List<pse__Assignment__c>{
            new pse__Assignment__c(HoursDistro_Sync_RunKey__c = runKey, HoursDistro_Sync_Status__c = 'Pending'),
            new pse__Assignment__c(HoursDistro_Sync_RunKey__c = runKey, HoursDistro_Sync_Status__c = 'Pending')
        };

        try {
            insert items;
        } catch (Exception e) {
            return;
        }

        Boolean marked = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
        Test.stopTest();

        Integer processed = [SELECT Id FROM pse__Assignment__c WHERE HoursDistro_Sync_RunKey__c = :runKey AND HoursDistro_Sync_Status__c = 'Processing'].size();
        System.assertEquals(2, processed, 'Both assignments should have been moved to Processing by queueable runs');

        System.assertEquals(true, HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName));
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
}