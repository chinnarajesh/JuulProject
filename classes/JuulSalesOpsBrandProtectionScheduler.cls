global class JuulSalesOpsBrandProtectionScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        BatchConstantValues__c settingsConst = BatchConstantValues__c.getinstance('BatchBrandProtection');
        Integer batchSize =  Integer.valueOf(settingsConst.Scheduler_Batch_Size__c);
        JuulSalesOpsBatchBrandProtection BPBatch = new JuulSalesOpsBatchBrandProtection();
        Database.executeBatch(BPBatch, batchSize);
    }
}