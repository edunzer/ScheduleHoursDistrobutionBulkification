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
}