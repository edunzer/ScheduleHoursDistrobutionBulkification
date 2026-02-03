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
                Integer successCount = 0;
                Integer failCount = 0;
                for (pse__Resource_Request__c r : batch) {
                    try {
                        r.HoursDistro_Sync_Status__c = 'Processing';
                        update r;
                        successCount++;
                    } catch (DmlException de) {
                        failCount++;
                        System.debug('HoursDistroSync_QueueableWorker: failed to mark Processing for Id=' + r.Id + ' error=' + de.getMessage());
                    }
                }
                System.debug('HoursDistroSync_QueueableWorker: processed chunk runKey=' + runKey + ' success=' + successCount + ' failed=' + failCount);
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
        Integer defaultSize = 10;
        try {
            // Attempt to read the custom setting. If missing or invalid, fall back to default.
            HoursDistributionSettings__c s = [SELECT Resource_Request_Chunk_Size__c FROM HoursDistributionSettings__c LIMIT 1];
            if (s != null && s.Resource_Request_Chunk_Size__c != null) {
                // Field may be Number or Text; coerce to Integer and enforce safe bounds
                Integer configured = Integer.valueOf(String.valueOf(s.Resource_Request_Chunk_Size__c));
                if (configured < 1) configured = 1;
                if (configured > 50) configured = 50;
                return configured;
            }
        } catch (Exception ex) {
            // ignore and use default
        }
        return defaultSize;
    }
}