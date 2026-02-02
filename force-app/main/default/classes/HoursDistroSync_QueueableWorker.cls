public with sharing class HoursDistroSync_QueueableWorker implements Queueable {
    private final String runKey;

    public HoursDistroSync_QueueableWorker(String runKey) {
        this.runKey = runKey;
    }

    public void execute(QueueableContext context) {
        Integer chunkSize = getChunkSize();
        try {
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
                // Use partial success to avoid blocking entire batch on one bad record
                Database.update(toUpdate, false);
            }

            // If there are still pending records for this runKey, chain another job
            AggregateResult ar = [SELECT COUNT(Id) cnt FROM pse__Resource_Request__c
                                  WHERE HoursDistro_Sync_RunKey__c = :runKey
                                  AND HoursDistro_Sync_Status__c = 'Pending'];
            Integer remaining = 0;
            if (ar != null) {
                remaining = Integer.valueOf(String.valueOf(ar.get('cnt')));
            }
            if (remaining > 0) {
                System.enqueueJob(new HoursDistroSync_QueueableWorker(runKey));
            }
        } catch (Exception e) {
            System.debug('HoursDistroSync_QueueableWorker error: ' + e);
        }
    }

    private Integer getChunkSize() {
        Integer defaultSize = 20;
        try {
            // Attempt to read the custom setting. If missing or invalid, fall back to default.
            HoursDistributionSettings__c s = [SELECT Resource_Request_Chunk_Size__c FROM HoursDistributionSettings__c LIMIT 1];
            if (s != null && s.Resource_Request_Chunk_Size__c != null) {
                // Field may be Number or Text; coerce to Integer
                return Integer.valueOf(String.valueOf(s.Resource_Request_Chunk_Size__c));
            }
        } catch (Exception ex) {
            // ignore and use default
        }
        return defaultSize;
    }
}