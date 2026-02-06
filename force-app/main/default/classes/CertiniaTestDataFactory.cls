@isTest
public class CertiniaTestDataFactory {

    public static SObject createRegion() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Region__c')) return null;
        SObject r = gd.get('pse__Region__c').newSObject();
        r.put('Name', 'TDRegion ' + Datetime.now().getTime());
        insert r;
        return r;
    }
    
    public static Account createAccount() {
        Account a = new Account(Name = 'TDAccount ' + Datetime.now().getTime());
        insert a;
        return a;
    }

    public static Contact createResourceContact(Id accountId, Id regionId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('Contact')) return null;
        // Ensure dependent account/region exist when nulls passed
        if (accountId == null) {
            Account a = createAccount();
            accountId = (a == null) ? null : a.Id;
        }
        if (regionId == null) {
            SObject r = createRegion();
            regionId = (r == null) ? null : (Id)r.get('Id');
        }

        SObject s = gd.get('Contact').newSObject();
        try { s.put('FirstName', 'TD'); } catch (Exception e) {}
        try { s.put('LastName', 'Resource ' + Datetime.now().getTime()); } catch (Exception e) {}
        try { if (accountId != null) s.put('AccountId', accountId); } catch (Exception e) {}
        // Try to set RecordType to 'PSA Resource' when available
        try {
            RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'PSA Resource' LIMIT 1];
            if (rt != null) s.put('RecordTypeId', rt.Id);
        } catch (Exception e) {
            // ignore if record type not present
        }
        try { if (regionId != null) s.put('pse__Region__c', regionId); } catch (Exception e) {}
        // Try to set managed-package resource flags if present
        try { s.put('pse__Is_Resource__c', true); } catch (Exception e) {}
        try { s.put('pse__Is_Resource_Active__c', true); } catch (Exception e) {}
        // Try to set resource type when available
        try { s.put('Okta_Active_The_Opus_Group_Email__c', 'Okta_Active_The_Opus_Group_Email__c'); } catch (Exception e) {}
        insert s;
        return (Contact)s;
    }

    public static SObject createProject(Id accountId, Id regionId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Proj__c')) return null;
        // Ensure dependent account/region exist when nulls passed
        if (accountId == null) {
            Account a = createAccount();
            accountId = (a == null) ? null : a.Id;
        }
        if (regionId == null) {
            SObject r = createRegion();
            regionId = (r == null) ? null : (Id)r.get('Id');
        }

        SObject p = gd.get('pse__Proj__c').newSObject();
        p.put('Name', 'TDProj ' + Datetime.now().getTime());
        try {
            p.put('pse__Account__c', accountId);
        } catch (Exception e) {}
        try {
            p.put('pse__Project_Type__c', 'Client');
        } catch (Exception e) {}
        try {
            if (regionId != null) p.put('pse__Region__c', regionId);
        } catch (Exception e) {}
        try {
            p.put('pse__Start_Date__c', Date.today().addDays(-1));
            p.put('pse__End_Date__c', Date.today().addDays(30));
        } catch (Exception e) {}
        insert p;
        return p;
    }

    public static SObject createPermissionControl(Id userId, Id regionId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Permission_Control__c')) return null;
        // Ensure dependent region exists when null passed
        if (regionId == null) {
            SObject r = createRegion();
            regionId = (r == null) ? null : (Id)r.get('Id');
        }
        // Ensure a User is specified when null passed (some orgs enforce this via validation)
        if (userId == null) {
            try { userId = UserInfo.getUserId(); } catch (Exception e) {}
        }

        SObject pc = gd.get('pse__Permission_Control__c').newSObject();
        try { if (userId != null) pc.put('pse__User__c', userId); } catch (Exception e) {}
        try { if (regionId != null) pc.put('pse__Region__c', regionId); } catch (Exception e) {}
        try { pc.put('pse__Cascading_Permission__c', true); } catch (Exception e) {}
        try { pc.put('pse__Resource_Request_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Skills_And_Certifications_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Staffing__c', true); } catch (Exception e) {}
        try { pc.put('pse__Skills_And_Certifications_View__c', true); } catch (Exception e) {}
        try { pc.put('pse__Timecard_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Expense_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Timecard_Ops_Edit__c', true); } catch (Exception e) {}
        try { pc.put('pse__Expense_Ops_Edit__c', true); } catch (Exception e) {}
        try { pc.put('pse__Edit_Task_Manager__c', true); } catch (Exception e) {}
        try { pc.put('pse__View_Task_Manager__c', true); } catch (Exception e) {}
        try { pc.put('pse__Billing__c', true); } catch (Exception e) {}
        try { pc.put('pse__Invoicing__c', true); } catch (Exception e) {}
        try {
            insert pc;
            return pc;
        } catch (Exception e) {
            System.debug('CertiniaTestDataFactory.createPermissionControl: insert failed: ' + e.getMessage());
            return null;
        }
    }

    public static SObject createPermissionControlForProject(Id userId, Id projectId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Permission_Control__c')) return null;
        // Ensure dependent project exists when null passed
        if (projectId == null) {
            SObject p = createProject(null, null);
            projectId = (p == null) ? null : (Id)p.get('Id');
        }

        // Ensure a User is specified when null passed (some orgs enforce this via validation)
        if (userId == null) {
            try { userId = UserInfo.getUserId(); } catch (Exception e) {}
        }

        SObject pc = gd.get('pse__Permission_Control__c').newSObject();
        try { if (userId != null) pc.put('pse__User__c', userId); } catch (Exception e) {}
        try { if (projectId != null) pc.put('pse__Project__c', projectId); } catch (Exception e) {}
        try { pc.put('pse__Cascading_Permission__c', true); } catch (Exception e) {}
        try { pc.put('pse__Resource_Request_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Skills_And_Certifications_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Staffing__c', true); } catch (Exception e) {}
        try { pc.put('pse__Skills_And_Certifications_View__c', true); } catch (Exception e) {}
        try { pc.put('pse__Timecard_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Expense_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Timecard_Ops_Edit__c', true); } catch (Exception e) {}
        try { pc.put('pse__Expense_Ops_Edit__c', true); } catch (Exception e) {}
        try { pc.put('pse__Edit_Task_Manager__c', true); } catch (Exception e) {}
        try { pc.put('pse__View_Task_Manager__c', true); } catch (Exception e) {}
        try { pc.put('pse__Billing__c', true); } catch (Exception e) {}
        try { pc.put('pse__Invoicing__c', true); } catch (Exception e) {}
        try {
            insert pc;
            return pc;
        } catch (Exception e) {
            System.debug('CertiniaTestDataFactory.createPermissionControlForProject: insert failed: ' + e.getMessage());
            return null;
        }
    }

    public static SObject createPermissionControlForResource(Id userId, Id resourceId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Permission_Control__c')) return null;
        // Ensure dependent resource/contact exists when null passed
        if (resourceId == null) {
            Account a = createAccount();
            SObject r = createRegion();
            Contact c = createResourceContact(a == null ? null : a.Id, r == null ? null : (Id)r.get('Id'));
            resourceId = (c == null) ? null : c.Id;
        }

        // Ensure a User is specified when null passed (some orgs enforce this via validation)
        if (userId == null) {
            try { userId = UserInfo.getUserId(); } catch (Exception e) {}
        }

        SObject pc = gd.get('pse__Permission_Control__c').newSObject();
        try { if (userId != null) pc.put('pse__User__c', userId); } catch (Exception e) {}
        try { if (resourceId != null) pc.put('pse__Resource__c', resourceId); } catch (Exception e) {}
        try { pc.put('pse__Cascading_Permission__c', true); } catch (Exception e) {}
        try { pc.put('pse__Resource_Request_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Skills_And_Certifications_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Staffing__c', true); } catch (Exception e) {}
        try { pc.put('pse__Skills_And_Certifications_View__c', true); } catch (Exception e) {}
        try { pc.put('pse__Timecard_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Expense_Entry__c', true); } catch (Exception e) {}
        try { pc.put('pse__Timecard_Ops_Edit__c', true); } catch (Exception e) {}
        try { pc.put('pse__Expense_Ops_Edit__c', true); } catch (Exception e) {}
        try { pc.put('pse__Edit_Task_Manager__c', true); } catch (Exception e) {}
        try { pc.put('pse__View_Task_Manager__c', true); } catch (Exception e) {}
        try { pc.put('pse__Billing__c', true); } catch (Exception e) {}
        try { pc.put('pse__Invoicing__c', true); } catch (Exception e) {}
        try {
            insert pc;
            return pc;
        } catch (Exception e) {
            System.debug('CertiniaTestDataFactory.createPermissionControlForResource: insert failed: ' + e.getMessage());
            return null;
        }
    }

    public static SObject createSchedule() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Schedule__c')) return null;
        SObject s = gd.get('pse__Schedule__c').newSObject();
        try {
            s.put('pse__Start_Date__c', Date.today());
            s.put('pse__End_Date__c', Date.today().addDays(7));
        } catch (Exception e) {}
        try { s.put('pse__Monday_Hours__c', 8); } catch (Exception e) {}
        try { s.put('pse__Tuesday_Hours__c', 8); } catch (Exception e) {}
        try { s.put('pse__Wednesday_Hours__c', 8); } catch (Exception e) {}
        try { s.put('pse__Thursday_Hours__c', 8); } catch (Exception e) {}
        try { s.put('pse__Friday_Hours__c', 8); } catch (Exception e) {}
        try { s.put('pse__Saturday_Hours__c', 0); } catch (Exception e) {}
        try { s.put('pse__Sunday_Hours__c', 0); } catch (Exception e) {}
        insert s;
        return s;
    }

    public static Map<String, Id> createAllDependencies(Id accountId, Id projectId, Id contactId, Id scheduleId, Id regionId) {
        Map<String, Id> ids = new Map<String, Id>();
        // Ensure account
        if (accountId == null) {
            Account a = createAccount();
            accountId = (a == null) ? null : a.Id;
        }
        // Ensure region
        if (regionId == null) {
            SObject r = createRegion();
            regionId = (r == null) ? null : (Id)r.get('Id');
        }
        // Ensure project
        if (projectId == null) {
            SObject p = createProject(accountId, regionId);
            projectId = (p == null) ? null : (Id)p.get('Id');
        }

        // After project exists, insert permission controls (order matters) and capture their Ids when available
        Id pcRegionId = null;
        Id pcProjectId = null;
        Id pcResourceId = null;
        try {
            SObject pcRegion = createPermissionControl(null, regionId);
            pcRegionId = (pcRegion == null) ? null : (Id)pcRegion.get('Id');
            if (pcRegion == null) System.debug('CertiniaTestDataFactory.createAllDependencies: createPermissionControl returned null for regionId=' + regionId);
        } catch (Exception e) {
            System.debug('CertiniaTestDataFactory.createAllDependencies: createPermissionControl threw: ' + e.getMessage());
        }
        try {
            SObject pcProject = createPermissionControlForProject(null, projectId);
            pcProjectId = (pcProject == null) ? null : (Id)pcProject.get('Id');
            if (pcProject == null) System.debug('CertiniaTestDataFactory.createAllDependencies: createPermissionControlForProject returned null for projectId=' + projectId);
        } catch (Exception e) {
            System.debug('CertiniaTestDataFactory.createAllDependencies: createPermissionControlForProject threw: ' + e.getMessage());
        }

        // Ensure contact/resource
        if (contactId == null) {
            SObject c = createResourceContact(accountId, regionId);
            contactId = (c == null) ? null : (Id)c.get('Id');
        }
        try {
            SObject pcResource = createPermissionControlForResource(null, contactId);
            pcResourceId = (pcResource == null) ? null : (Id)pcResource.get('Id');
            if (pcResource == null) System.debug('CertiniaTestDataFactory.createAllDependencies: createPermissionControlForResource returned null for contactId=' + contactId);
        } catch (Exception e) {
            System.debug('CertiniaTestDataFactory.createAllDependencies: createPermissionControlForResource threw: ' + e.getMessage());
        }

        // Ensure schedule
        if (scheduleId == null) {
            SObject s = createSchedule();
            scheduleId = (s == null) ? null : (Id)s.get('Id');
        }

        ids.put('accountId', accountId);
        ids.put('regionId', regionId);
        ids.put('projectId', projectId);
        ids.put('contactId', contactId);
        ids.put('scheduleId', scheduleId);
        ids.put('permissionControlRegionId', pcRegionId);
        ids.put('permissionControlProjectId', pcProjectId);
        ids.put('permissionControlResourceId', pcResourceId);
        return ids;
    }

    public static SObject createResourceRequest(Id accountId, Id projectId, Date startDate, Date endDate, Id regionId, Id contactId, Id scheduleId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Resource_Request__c')) return null;
        // Ensure required dependent records exist (createAllDependencies handles ordering and permission controls)
        Map<String, Id> deps = createAllDependencies(accountId, projectId, contactId, scheduleId, regionId);
        accountId = deps.get('accountId');
        projectId = deps.get('projectId');
        regionId = deps.get('regionId');
        contactId = deps.get('contactId');
        scheduleId = deps.get('scheduleId');

        SObject rr = gd.get('pse__Resource_Request__c').newSObject();
        try { rr.put('pse__Account__c', accountId); } catch (Exception e) {}
        try { rr.put('pse__Project_Type__c', 'Client'); } catch (Exception e) {}
        try { rr.put('pse__Project__c', projectId); } catch (Exception e) {}
        try { rr.put('pse__Start_Date__c', startDate); rr.put('pse__End_Date__c', endDate); } catch (Exception e) {}
        try { rr.put('pse__SOW_Hours__c', 10); } catch (Exception e) {}
        try { rr.put('pse__Requested_Bill_Rate__c', 100); } catch (Exception e) {}
        try {
            if (regionId != null) rr.put('pse__Region__c', regionId);
        } catch (Exception e) {}
        insert rr;
        return rr;
    }

    public static SObject createAssignment(Id contactId, Id projectId, Id scheduleId, Id accountId, Id regionId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Assignment__c')) return null;
        // Ensure dependent records exist (createAllDependencies handles creation and permission controls)
        Map<String, Id> deps = createAllDependencies(accountId, projectId, contactId, scheduleId, regionId);
        accountId = deps.get('accountId');
        regionId = deps.get('regionId');
        projectId = deps.get('projectId');
        contactId = deps.get('contactId');
        scheduleId = deps.get('scheduleId');

        SObject a = gd.get('pse__Assignment__c').newSObject();
        try { a.put('pse__Resource__c', contactId); } catch (Exception e) {}
        try { a.put('pse__Project__c', projectId); } catch (Exception e) {}
        try { a.put('pse__Schedule__c', scheduleId); } catch (Exception e) {}
        try { a.put('pse__Bill_Rate__c', 100); } catch (Exception e) {}
        insert a;
        return a;
    }
}
