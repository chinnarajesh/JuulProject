/*
 * System.schedule('Case Score Calculation Job (Hourly)', '0 0 * * * ?', new SchBatchCaseScoreCalculation());
 */

global class SchBatchCaseScoreCalculation implements Schedulable, Database.Batchable<sObject>{
    
     global void execute(SchedulableContext SC) {
    	Database.executeBatch(new SchBatchCaseScoreCalculation());
     }
     
     global Database.QueryLocator start(Database.BatchableContext BC){
     	String query = 'SELECT Id, Issue__c, Case_Score__c,Last_Customer_Activity_Score_Time__c, CreatedDate, Case_Score_Waiting_for_Reply__c '
      									+ ' , (Select MessageDate, Incoming From EmailMessages order by CreatedDate desc limit 1)   '
      									+ ' FROM Case '
      									+ ' WHERE isClosed = false ';
      	return Database.getQueryLocator(query);
    }
    
    

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   	 List<Case> caseRecordsToUpdate = new List<Case>();
     for(Case caseRecord : (List<Case>) scope){
     	if(this.updateCaseScore(caseRecord)){
     		caseRecordsToUpdate.add(caseRecord);
     	}
     }
     
     update caseRecordsToUpdate;
   }

   global void finish(Database.BatchableContext BC){
   	
   }
     
     
    
    private boolean updateCaseScore(Case caseRecord){
    	boolean isUpdated = false;
    	//If Case is not open today
    	if(caseRecord.createdDate.date() != Date.today()){
	    	//Initial Points + Case Open Since
	    	decimal caseInitialPoints = 0;
	    	if(String.isNotBlank(caseRecord.Issue__c) && Case_Issue__c.getAll().containsKey(caseRecord.Issue__c)){
	    		caseInitialPoints = Case_Issue__c.getInstance(caseRecord.Issue__c).Point_Value__c;
	    	}
	    	integer caseOpenSinceScore = decimal.valueOf((DateTime.now().getTime() - caseRecord.CreatedDate.getTime())/1000/60/60/24 ).intValue();
	    	isUpdated = (caseInitialPoints + caseOpenSinceScore) != caseRecord.Case_Score__c;
	    	caseRecord.Case_Score__c = caseInitialPoints + caseOpenSinceScore;
	    	//Since last Customer Reply's based points
	    	DateTime lastCustomerReplyTime = caseRecord.createdDate;
	    	//Select (Select CreatedDate, Incoming From EmailMessages) From Case
	    	for(EmailMessage email : caseRecord.EmailMessages){
	    		if(email.Incoming == true){
	    			lastCustomerReplyTime = email.MessageDate;
	    		}
	    	} 
	    	system.debug('---lastCustomerReplyTime ' + lastCustomerReplyTime);
	    	if(lastCustomerReplyTime != null){
	    		//Calculate Case score for customer 's waiting time
	    		decimal hoursSinceLastActivity = 0;
	    		if(caseRecord.Last_Customer_Activity_Score_Time__c >= lastCustomerReplyTime){
	    			//If this activity is already recorded
	    			hoursSinceLastActivity = (DateTime.now().getTime() - caseRecord.Last_Customer_Activity_Score_Time__c.getTime())/1000/60/60;
	    			
	    		}else if(caseRecord.Last_Customer_Activity_Score_Time__c != null){
	    			hoursSinceLastActivity = ( (DateTime.now().getTime() - lastCustomerReplyTime.getTime())/1000/60/60 );
	    		}else{
	    			//This activity is never recorded yet
	    			hoursSinceLastActivity = ( (DateTime.now().getTime() - lastCustomerReplyTime.getTime())/1000/60/60 )-24;
	    			
	    		}
	    		
	    		if(hoursSinceLastActivity >=6){
    				caseRecord.Last_Customer_Activity_Score_Time__c = DateTime.now();
    				caseRecord.Case_Score_Waiting_for_Reply__c = 1+ (caseRecord.Case_Score_Waiting_for_Reply__c == null ? 0 : caseRecord.Case_Score_Waiting_for_Reply__c);
    				isUpdated = true;
    			}
	    		
	    	}
    	}
		return isUpdated;    	
    	
    }
    
}