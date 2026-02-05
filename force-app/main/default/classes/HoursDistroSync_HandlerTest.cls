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
private class HoursDistroSync_HandlerTest {

    @isTest
    static void testHandleBeforeUpdateSetsFieldsForResourceRequest() {
        pse__Resource_Request__c r = new pse__Resource_Request__c();
        List<pse__Resource_Request__c> listR = new List<pse__Resource_Request__c>{ r };

        HoursDistroSync_Handler.handleBeforeUpdate(listR, null);

        System.assertNotEquals(null, listR[0].get('HoursDistro_Sync_RunKey__c'));
        System.assertEquals('Pending', String.valueOf(listR[0].get('HoursDistro_Sync_Status__c')));
    }

    @isTest static void testHandleBeforeUpdateSetsFieldsForAssignment() {
        pse__Assignment__c a = new pse__Assignment__c();
        List<pse__Assignment__c> listA = new List<pse__Assignment__c>{ a };

        HoursDistroSync_Handler.handleBeforeUpdate(listA, null);

        System.assertNotEquals(null, listA[0].get('HoursDistro_Sync_RunKey__c'));
        System.assertEquals('Pending', String.valueOf(listA[0].get('HoursDistro_Sync_Status__c')));
    }

    @isTest static void testHandleAfterUpdateEnqueuesAndClears() {
        String objectApiName = 'pse__Resource_Request__c';
        // ensure clean enqueued state
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);

        pse__Resource_Request__c r = new pse__Resource_Request__c();
        List<pse__Resource_Request__c> listR = new List<pse__Resource_Request__c>{ r };

        Test.startTest();
        HoursDistroSync_Handler.handleAfterUpdate(listR, null);
        Test.stopTest();

        // After the handler enqueues and the queueable runs, the enqueued flag should be cleared
        Boolean canMarkAgain = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, canMarkAgain);
    }

    @isTest static void testHandleAfterUpdateEnqueuesAndClears_Assignment() {
        String objectApiName = 'pse__Assignment__c';
        HoursDistroSync_RunKeyHelper.clearEnqueued(objectApiName);

        pse__Assignment__c a = new pse__Assignment__c();
        List<pse__Assignment__c> listA = new List<pse__Assignment__c>{ a };

        Test.startTest();
        HoursDistroSync_Handler.handleAfterUpdate(listA, null);
        Test.stopTest();

        Boolean canMarkAgain = HoursDistroSync_RunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, canMarkAgain);
    }
}