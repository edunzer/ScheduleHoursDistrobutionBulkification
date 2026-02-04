public with sharing class HoursDistroSync_QueueableWorker implements Queueable {
    private final String runKey;
    private final String objectApiName;

    public HoursDistroSync_QueueableWorker(String runKey, String objectApiName) {
        System.assert(!String.isBlank(runKey), 'runKey is required');
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        this.runKey = runKey;
        this.objectApiName = objectApiName;
    }

    public void execute(QueueableContext context) {
        Integer chunkSize = getChunkSize(objectApiName);
        try {
            Integer remaining = 0;
            if (objectApiName == 'pse__Resource_Request__c') {
                List<pse__Resource_Request__c> batch = [SELECT Id FROM pse__Resource_Request__c
                                                       WHERE HoursDistro_Sync_RunKey__c = :runKey
                                                       AND HoursDistro_Sync_Status__c = 'Pending'
                                                       LIMIT :chunkSize FOR UPDATE];
                if (!batch.isEmpty()) {
                    List<pse__Resource_Request__c> toUpdate = new List<pse__Resource_Request__c>();
                    for (pse__Resource_Request__c r : batch) {
                        r.HoursDistro_Sync_Status__c = 'Processing';
                        toUpdate.add(r);
                    }
                    Database.update(toUpdate, false);
                }
                AggregateResult ar = [SELECT COUNT(Id) cnt FROM pse__Resource_Request__c
                                      WHERE HoursDistro_Sync_RunKey__c = :runKey
                                      AND HoursDistro_Sync_Status__c = 'Pending'];
                if (ar != null) remaining = Integer.valueOf(String.valueOf(ar.get('cnt')));
            } else if (objectApiName == 'pse__Assignment__c') {
                List<pse__Assignment__c> batch = [SELECT Id FROM pse__Assignment__c
                                                   WHERE HoursDistro_Sync_RunKey__c = :runKey
                                                   AND HoursDistro_Sync_Status__c = 'Pending'
                                                   LIMIT :chunkSize FOR UPDATE];
                if (!batch.isEmpty()) {
                    List<pse__Assignment__c> toUpdate = new List<pse__Assignment__c>();
                    for (pse__Assignment__c r : batch) {
                        r.HoursDistro_Sync_Status__c = 'Processing';
                        toUpdate.add(r);
                    }
                    Database.update(toUpdate, false);
                }
                AggregateResult ar = [SELECT COUNT(Id) cnt FROM pse__Assignment__c
                                      WHERE HoursDistro_Sync_RunKey__c = :runKey
                                      AND HoursDistro_Sync_Status__c = 'Pending'];
                if (ar != null) remaining = Integer.valueOf(String.valueOf(ar.get('cnt')));
            }

            if (remaining > 0) {
                System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey, objectApiName));
            }
        } catch (Exception e) {
            System.debug('HoursDistroSync_QueueableWorker error: ' + e);
        } finally {
            HoursDistroSync_RunKeyHelper.clearEnqueued(this.objectApiName);
        }
    }

    private Integer getChunkSize(String objectApiName) {
        Integer defaultSize = 20;
        try {
            if (objectApiName == 'pse__Assignment__c') {
                HoursDistributionSettings__c s = [SELECT Assignment_Chunk_Size__c FROM HoursDistributionSettings__c LIMIT 1];
                if (s != null && s.Assignment_Chunk_Size__c != null) {
                    return Integer.valueOf(String.valueOf(s.Assignment_Chunk_Size__c));
                }
            } else {
                HoursDistributionSettings__c s = [SELECT Resource_Request_Chunk_Size__c FROM HoursDistributionSettings__c LIMIT 1];
                if (s != null && s.Resource_Request_Chunk_Size__c != null) {
                    return Integer.valueOf(String.valueOf(s.Resource_Request_Chunk_Size__c));
                }
            }
        } catch (Exception ex) {
            // ignore and use default
        }
        return defaultSize;
    }
}