global class JuulSalesOpsTrueOutOfStockBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Map<String, String> mapInputs =  new Map<String, String>();  
        JuulSalesOpsTrueOutOfStockBatch OOSBatch = new JuulSalesOpsTrueOutOfStockBatch(mapInputs);
        Database.executeBatch(OOSBatch, 200);
    }
}