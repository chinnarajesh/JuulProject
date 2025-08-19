global class InvocableCaseFieldsUpdate {
    
    // Declare variables to be used with Flow and invocable method
    global class variables{
               
        @InvocableVariable(label='Record ID' required='true')
        public String recordId;
        
        @InvocableVariable(label='Field Name' required='true')
        public String fieldName;
        
        @InvocableVariable(label='Field Value - Please assign the correct value here' required='false')
        public String fieldValue;
        
        @InvocableVariable(label='Is this a Boolean Field? - Enter Yes or No' required='true')
        public String isTrueOrFalse;

 }   
    
    // Invocable method to unlock a record and mark DNN as true
    @InvocableMethod(label='Update Fields')

    global static void updateFields (List <variables> passedData) {
        List<String> caseList = new List<String>();
        for (variables v : passedData ){
                caseList.add(v.recordId);
        }
        List<Case> casesToUpdate = [SELECT Id,DO_NOT_NOTIFY__C, Market_Outbound_Email1__c FROM CASE WHERE Id IN :caseList];
       
        // Loop through the 1 case
        for (Case c : casesToUpdate){
        
            //	Loop through the 1 record that contains 4 variables: recordId, fieldName, fieldValue, isTrueOrFalse
            for ( variables v : passedData)
            {   
                // If the field IS a boolean field 
               if ((v.isTrueOrFalse).toUpperCase() == 'YES'){
                    if ( (v.fieldValue).toUpperCase() == 'TRUE'){
							c.put(v.fieldName, TRUE);                                                                        		                         
                    } 
                    if ( (v.fieldValue).toUpperCase() == 'FALSE'){
                        c.put(v.fieldName, FALSE); 
                    }
                } 
                
                // If the field is NOT a Boolean Field
               if ((v.isTrueOrFalse).toUpperCase() == 'NO'){ 
					c.put(v.fieldName, v.fieldValue);
               }
            }           
        
        }
        
      update casesToUpdate;
        }
}