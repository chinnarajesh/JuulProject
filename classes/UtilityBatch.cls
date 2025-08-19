public class UtilityBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public Integer batchSize;
    public String mode;
    public String query;
    public String overrideQuery;
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.batchSize != null ? this.batchSize : 50);
    }

    public UtilityBatch (String m){
        System.debug('Running Utility Batch with Mode = ' + m );
        mode = m;       
    }

    public UtilityBatch ( String m, String q){
        System.debug('Running UtilityBatch with Mode = ' + m + ' with query ' + q);
        mode = m;
        query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){              
        System.debug('Override Query : ' + overrideQuery);
        System.debug('Query : ' + query);
        return Database.getQueryLocator(overrideQuery!=null ? overrideQuery : query);         
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){

      if(mode == 'Delete Sales Orders' || mode == 'Delete Document Details' || mode == 'Delete'){
        database.delete(scope);
      }

    }

    public void finish(Database.BatchableContext BC){
       

    }
}