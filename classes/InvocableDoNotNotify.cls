global class InvocableDoNotNotify {
    
    // Declare variables to be used with Flow and invocable method
    global class variables{
               
        @InvocableVariable(label='Record ID' required='true')
        public String recordId;
 }   
    
    // Invocable method to unlock a record and mark DNN as true
    @InvocableMethod(label='Check Do Not Notify')

    global static void doNotNotify (List <variables> passedData) {
        List<String> caseList = new List<String>();
        for (variables v : passedData ){
            	caseList.add(v.recordId);
        }
        List<Case> casesToUpdate = [SELECT Id,DO_NOT_NOTIFY__C FROM CASE WHERE Id IN:caseList];
        for (Case c : casesToUpdate){
            if(c.DO_NOT_NOTIFY__C == FALSE){
            c.DO_NOT_NOTIFY__C = TRUE;
            }
        }
        update casesToUpdate;
        }
}