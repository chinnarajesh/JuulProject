global class InvocableUnlockRecord {
    
    // Declare variables to be used with Flow and invocable method
    global class variables{             
        @InvocableVariable(label='Record ID' required='true')
        public String recordId;
 }   
    
    // Invocable method to unlock a record and mark DNN as true
    @InvocableMethod(label='Unlock Case')

    global static void unlockCase (List <variables> passedData) {
        for (variables v : passedData ){
            if(Approval.isLocked(v.recordId)){
            Approval.unlock(v.recordId);
            }
        }
    }
}