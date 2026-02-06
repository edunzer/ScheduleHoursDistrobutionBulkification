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
        insert pc;
        return pc;
    }

    public static SObject createPermissionControlForProject(Id userId, Id projectId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Permission_Control__c')) return null;
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
        insert pc;
        return pc;
    }

    public static SObject createPermissionControlForResource(Id userId, Id resourceId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Permission_Control__c')) return null;
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
        insert pc;
        return pc;
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

    public static SObject createResourceRequest(Id accountId, Id projectId, Date startDate, Date endDate, Id regionId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Resource_Request__c')) return null;
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

    public static SObject createAssignment(Id contactId, Id projectId, Id scheduleId) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('pse__Assignment__c')) return null;
        SObject a = gd.get('pse__Assignment__c').newSObject();
        try { a.put('pse__Resource__c', contactId); } catch (Exception e) {}
        try { a.put('pse__Project__c', projectId); } catch (Exception e) {}
        try { a.put('pse__Schedule__c', scheduleId); } catch (Exception e) {}
        try { a.put('pse__Bill_Rate__c', 100); } catch (Exception e) {}
        insert a;
        return a;
    }
}
