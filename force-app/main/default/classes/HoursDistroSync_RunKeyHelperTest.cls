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
private class HoursDistroSync_RunKeyHelperTest {

    @isTest
    static void testGetRunKeyConsistencyAndFormat_ResourceRequest() {
        String obj = 'pse__Resource_Request__c';
        String rk1 = HoursDistroSync_RunKeyHelper.getRunKey(obj);
        String rk2 = HoursDistroSync_RunKeyHelper.getRunKey(obj);
        System.assertEquals(rk1, rk2, 'Run keys should be stable within the same transaction');
        System.assert(rk1.startsWith(obj + '_hrs_'), 'Run key should start with objectApiName + _hrs_');
    }

    @isTest static void testMarkEnqueuedAndClear_ResourceRequest() {
        String obj = 'pse__Resource_Request__c';
        // ensure clean state
        HoursDistroSync_RunKeyHelper.clearEnqueued(obj);

        Boolean first = HoursDistroSync_RunKeyHelper.markEnqueued(obj);
        Boolean second = HoursDistroSync_RunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, first, 'First markEnqueued should return true');
        System.assertEquals(false, second, 'Second markEnqueued in same transaction should return false');

        HoursDistroSync_RunKeyHelper.clearEnqueued(obj);
        Boolean third = HoursDistroSync_RunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, third, 'After clearEnqueued, markEnqueued should return true again');
    }

    @isTest
    static void testGetRunKeyConsistencyAndFormat_Assignment() {
        String obj = 'pse__Assignment__c';
        String rk1 = HoursDistroSync_RunKeyHelper.getRunKey(obj);
        String rk2 = HoursDistroSync_RunKeyHelper.getRunKey(obj);
        System.assertEquals(rk1, rk2, 'Run keys should be stable within the same transaction');
        System.assert(rk1.startsWith(obj + '_hrs_'), 'Run key should start with objectApiName + _hrs_');
    }

    @isTest static void testMarkEnqueuedAndClear_Assignment() {
        String obj = 'pse__Assignment__c';
        // ensure clean state
        HoursDistroSync_RunKeyHelper.clearEnqueued(obj);

        Boolean first = HoursDistroSync_RunKeyHelper.markEnqueued(obj);
        Boolean second = HoursDistroSync_RunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, first, 'First markEnqueued should return true');
        System.assertEquals(false, second, 'Second markEnqueued in same transaction should return false');

        HoursDistroSync_RunKeyHelper.clearEnqueued(obj);
        Boolean third = HoursDistroSync_RunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, third, 'After clearEnqueued, markEnqueued should return true again');
    }

    @isTest static void testIsEnabledDefaultsAndSettings() {
        // Remove any existing settings to validate default behavior
        try {
            List<HoursDistributionSettings__c> existing = [SELECT Id FROM HoursDistributionSettings__c];
            if (!existing.isEmpty()) delete existing;
        } catch (Exception e) {
            // ignore if settings object not present in test org
        }

        System.assertEquals(true, HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c'));
        System.assertEquals(true, HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c'));

        // Insert a settings record with explicit booleans and verify
        HoursDistributionSettings__c s = new HoursDistributionSettings__c();
        s.Resource_Request_Enable_HoursDistro_Sync__c = false;
        s.Assignment_Enable_HoursDistro_Sync__c = true;
        insert s;

        System.assertEquals(false, HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c'));
        System.assertEquals(true, HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c'));

        delete s;
    }

    @isTest static void testUnsupportedAndBlankAssertions() {
        // Unsupported object should throw our specific exception
        try {
            HoursDistroSync_RunKeyHelper.isEnabled('Account');
            System.assert(false, 'Expected UnsupportedObjectApiNameException for unsupported object');
        } catch (Exception e) {
            System.assert(e instanceof HoursDistroSync_RunKeyHelper.UnsupportedObjectApiNameException, 'Exception should be UnsupportedObjectApiNameException');
        }

        // Skip testing methods that assert on blank inputs to avoid uncatchable assertion failures
    }
}