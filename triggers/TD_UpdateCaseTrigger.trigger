/**
* File Name: TD_UpdateCaseTrigger
* Description: Trigger that updates cases for Custom CasePop
* Copyright : Talkdesk, Inc. Copyright (c) 2017
* Author : Phillip Zeelig + Tiago Guerreiro
* Date: 10262017
**/ 
trigger TD_UpdateCaseTrigger on Task (before insert) {
  
    //Query to get all not closed case status from object case. Dynamic way in case if the client changes any values 
    //or add new values to the possible open cases.
    final List<CaseStatus> casesStatusOpen = [Select Id, MasterLabel From CaseStatus Where IsClosed = false];
    
    //Populate a list<String> with all the names found on case status. Ex: new, open etc
    List<String> casesStatusOpenLabels = new List<String>();
    for(CaseStatus status : casesStatusOpen)
        casesStatusOpenLabels.add(status.MasterLabel);

    String phone;
    String email;
    String callSid;
      for (Task t : Trigger.new) {
        if(t.status.equals('Not Started') && t.subject.contains('Talkdesk Grab Case:')){
          //Condition to remove the + sign of the beggining of number due sosl compatibility
          if(t.Description.contains('+')){
            phone = '00'+t.Description.removeStart('+') + ' OR ' + t.Description.removeStart('+');
          }else{
            //Search for "00number OR phone", otherwise "00" starting numbers will not be caught by sosl query 
            phone = '00'+ t.Description + ' OR ' + t.Description;
          }
          email = t.CallDisposition;
          callSid = t.Subject;
          t.status = 'Completed';
          }
    }
    if(String.isNotEmpty(phone) && String.isNotEmpty(email) && String.isNotEmpty(callSid)){
        
        List<Contact> Contacts = [FIND :phone IN PHONE FIELDS 
                                  RETURNING 
                                  CONTACT(Id)][0];
        
        System.debug(Contacts);
        List<Case> Cases = [
                            SELECT ID, td_last_agent__c, td_last_call_sid__c, status, ContactID 
                            FROM Case 
                            WHERE status IN :casesStatusOpenLabels AND ContactID IN :Contacts 
                            ORDER by LastModifiedDate DESC
                           ];
       
        System.debug(Cases);
        if(Cases.size()>0){
            for(Case c: Cases){
                c.td_last_agent__c = email;
                c.td_last_call_sid__c = callSid;
            }
        update(Cases);
      }
    }
}