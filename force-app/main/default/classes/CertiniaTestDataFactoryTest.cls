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
private class CertiniaTestDataFactoryTest {

    @isTest
    static void myUnitTest() {
        Test.startTest();
        Account a = CertiniaTestDataFactory.createAccount();
        System.assertNotEquals(null, a, 'Account should be created');
        System.assertNotEquals(null, a.Id, 'Account Id should be set');

        SObject region = CertiniaTestDataFactory.createRegion();
        if (region != null) System.assertNotEquals(null, (Id)region.get('Id'), 'Region Id should be set when object exists');

        Contact c = CertiniaTestDataFactory.createResourceContact(a.Id,  region == null ? null : (Id)region.get('Id'));
        System.assertNotEquals(null, c, 'Contact should be created');
        System.assertNotEquals(null, c.Id, 'Contact Id should be set');
        
        SObject proj = CertiniaTestDataFactory.createProject(a.Id, region == null ? null : (Id)region.get('Id'));
        if (proj != null) System.assertNotEquals(null, (Id)proj.get('Id'), 'Project Id should be set when object exists');

        // Create permission control for running user in the region to satisfy staffing validations
        SObject perm = CertiniaTestDataFactory.createPermissionControl(UserInfo.getUserId(), region == null ? null : (Id)region.get('Id'));
        if (perm != null) System.assertNotEquals(null, (Id)perm.get('Id'), 'PermissionControl Id should be set when object exists');
        
        // Also create permission controls scoped to the project and to the resource/contact
        SObject permProj = CertiniaTestDataFactory.createPermissionControlForProject(UserInfo.getUserId(), proj == null ? null : (Id)proj.get('Id'));
        if (permProj != null) System.assertNotEquals(null, (Id)permProj.get('Id'), 'PermissionControl (Project) Id should be set when object exists');

        SObject permRes = CertiniaTestDataFactory.createPermissionControlForResource(UserInfo.getUserId(), c == null ? null : c.Id);
        if (permRes != null) System.assertNotEquals(null, (Id)permRes.get('Id'), 'PermissionControl (Resource) Id should be set when object exists');

        

        SObject sched = CertiniaTestDataFactory.createSchedule();
        if (sched != null) System.assertNotEquals(null, (Id)sched.get('Id'), 'Schedule Id should be set when object exists');

        SObject rr = CertiniaTestDataFactory.createResourceRequest(a.Id, proj == null ? null : (Id)proj.get('Id'), Date.today(), Date.today().addDays(7), region == null ? null : (Id)region.get('Id'));
        if (rr != null) System.assertNotEquals(null, (Id)rr.get('Id'), 'ResourceRequest Id should be set when object exists');

        SObject asg = CertiniaTestDataFactory.createAssignment(c == null ? null : c.Id, proj == null ? null : (Id)proj.get('Id'), sched == null ? null : (Id)sched.get('Id'));
        if (asg != null) System.assertNotEquals(null, (Id)asg.get('Id'), 'Assignment Id should be set when object exists');
        Test.stopTest();
    }
}