/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        06-01-2020                     */
/* Class Name: ContactTriggerHelper                       */
/* Description: Helper for Contact Trigger  */
/**********************************************************************/
public class ContactTriggerHelper {
    public static String class_Name='ContactTriggerHelper';
    
  	//Method to create Alert and AccountOrGroupAlert records whenever an Buyer Contact's details(Name,Title,Email,Phone) get updated
    public static void createAlerts(Map<Id,Contact> newMapContact, Map<Id,Contact> oldMapContact){
        String method_Name='createAlerts';
        String operationType = 'Database.Insert_Failed';
        List<Database.Error> listError = new  List<Database.Error>();
        Set<Id> successRecords = new Set<Id>();
        List<Database.Error> alertGroupError = new  List<Database.Error>();
        Map<Id,List<Contact>> accountIdContact = new Map<Id,List<Contact>>();
        Map<Id,string> accountAlertBody = new Map<Id,string>();
        List<Alert__c> alertList = new List<Alert__c>();
        List<AccountOrGroupAlert__c> groupAlertList = new List<AccountOrGroupAlert__c>();
        Map<AccountOrGroupAlert__c,Alert__c> alertGroupAlertMap = new Map<AccountOrGroupAlert__c,Alert__c>();
        for(Id con :newMapContact.keySet()){
            if(newMapContact.get(con).Type__c == 'Buyer'){
                Contact newContact = newMapContact.get(con);
                Contact oldContact = oldMapContact.get(con);
                if((newContact.FirstName != oldContact.FirstName) || (newContact.LastName != oldContact.LastName) || (newContact.Salutation != oldContact.Salutation) || (newContact.Title != oldContact.Title) || (newContact.MobilePhone != oldContact.MobilePhone) || (newContact.Email != oldContact.Email))
                {	 
                   
                    string newSalutation='';
                    string newFirstName='';
                    string oldSalutation='';
                    string oldFirstName='';
                    string oldTitle='\'\'';
                    string newTitle='\'\'';
                    string oldEmail='\'\'';
                    string newEmail='\'\'';
                    string oldMobile='\'\'';
                    string newMobile='\'\'';
                    boolean titleChange = false;
                    boolean emailChange = false;
                    boolean mobileChange = false;
                    if(newContact.Salutation != null){
                        newSalutation = newContact.Salutation;
                    }
                    if(newContact.FirstName != null){
                        newFirstName = newContact.FirstName;
                    }
                    if(oldContact.Salutation != null){
                        oldSalutation = oldContact.Salutation;
                    }
                    if(oldContact.FirstName != null){
                        oldFirstName = oldContact.FirstName;
                    }
                    
                    String conName =newSalutation+' '+newFirstName+' '+newContact.LastName;
                    String conTitle =newContact.Title;
                    String conEmail =newContact.Email;
                    string conMobile =newContact.MobilePhone;
                    string alertBody ='';
                    
                    if(newContact.FirstName != oldContact.FirstName || newContact.LastName != oldContact.LastName || newContact.Salutation != oldContact.Salutation){
                        conName = oldSalutation+' '+oldFirstName+' '+oldContact.LastName+' was changed to '+newSalutation+' '+newFirstName+' '+newContact.LastName+'.';
                    }
                    if(newContact.Title != oldContact.Title){
                        if(oldContact.Title != null){
                            oldTitle =oldContact.Title;
                        }
                        if(newContact.Title !=null){
                            newTitle = newContact.Title;
                        }
                        titleChange = true;
                        conTitle = oldTitle+' was changed to '+newTitle+'.';
                    }
                    if(newContact.email != oldContact.email){
                        if(oldContact.email != null){
                            oldEmail =oldContact.Email;
                        }
                        if(newContact.email !=null){
                            newEmail = newContact.Email;
                        }
                        emailChange = true;
                        conEmail = oldEmail+' was changed to '+newEmail+'.';
                    }
                    if(newContact.MobilePhone != oldContact.MobilePhone){
                        if(oldContact.MobilePhone != null){
                            oldMobile = oldContact.MobilePhone;
                        }
                        if(newContact.MobilePhone !=null){ 
                            newMobile = newContact.MobilePhone;
                        }
                        mobileChange = true;
                        conMobile = oldMobile+' was changed to '+newMobile+'.';
                    }
                    //Get alert body for current contact
                    alertBody = getBody(conName,conTitle,conEmail,conMobile,titleChange,emailChange,mobileChange); 
                    
                    if(newContact.AccountId != null){
                        //Insert values into accountAlertBody Map which stores Alert record body respective to an Account
                        if(accountAlertBody.containsKey(newContact.AccountId)){
                            string listBody = accountAlertBody.get(newContact.AccountId);
                            listBody+= '\n'+alertBody;
                            accountAlertBody.put(newContact.AccountId,listBody);
                        }
                        else{
                            accountAlertBody.put(newContact.AccountId, alertBody);
                        } 
                        //Insert values into accountIdContact Map which stores Contact records respective to an Account
                        if(accountIdContact.containsKey(newContact.AccountId)){
                            List<Contact> listCon = accountIdContact.get(newContact.AccountId);
                            listCon.add(newContact);
                            accountIdContact.put(newContact.AccountId,listCon);
                        }else{
                            accountIdContact.put(newContact.AccountId,new List<Contact>{newContact});
                        }
                    }
                }
            }
        }
        
        //Create Alert and AlertGroup Record respective to account and Insert into alertGroupAlertMap.
        if(!accountIdContact.isEmpty()){
            for(Id i: accountIdContact.keySet()){
                List<Contact> relatedContacts = accountIdContact.get(i);
                String aBody = accountAlertBody.get(i);
                String body = +relatedContacts.size()+' Contact\'s buyer detail has been updated.'+'\n'+aBody;
                Integer bodySize = body.length();
                if(bodySize > 131072)
                {
                    body = body.substring(0,131072);
                    system.debug('Body Text Field limit reached');
                }                                                                            
                alertGroupAlertMap.put(new AccountOrGroupAlert__c(AccountId__c = i),new Alert__c(AlertType__c= 'Buyer Update',Subject__c ='Account Buyer Contact Details Updated.', Body__c = body));
            }
        }
        //Insert Alert Records 
        if(!alertGroupAlertMap.isEmpty()){
            List<Database.SaveResult> alertResults = Database.insert(alertGroupAlertMap.values(),false);
            for (Integer index = 0, size = alertResults.size(); index < size; index++) {
                if (!alertResults[index].isSuccess()) {
                    listError.addAll(alertResults[index].getErrors());
                }
                else{
                    successRecords.add(alertResults[index].id);
                }
            }
        }
        //Insert exceptions in Log__c object, If any
        if(listError.size()>0)
        {
            LogEventTriggerHandler.insertBatchLog(listError,class_Name,method_Name,'Alert__c',operationType);
        }
        if(successRecords.size()>0){
            for(AccountOrGroupAlert__c a:alertGroupAlertMap.keyset()){
                if(alertGroupAlertMap.get(a).Id !=null){
                    a.AlertId__c = alertGroupAlertMap.get(a).Id;
                    groupAlertList.add(a);
                }
            }
        }
        //Insert AccountOrGroupAlert records
        if(groupAlertList.size()>0){
            List<Database.SaveResult> alertGroupResults = Database.insert(groupAlertList,false);
            for (Integer index = 0, size = alertGroupResults.size(); index < size; index++) {
                if (!alertGroupResults[index].isSuccess()) {
                    alertGroupError.addAll(alertGroupResults[index].getErrors());
                }
            }
        }
        //Insert exceptions in Log__c object, If any
        if(alertGroupError.size()>0)
        {
            LogEventTriggerHandler.insertBatchLog(alertGroupError,class_Name,method_Name,'AccountOrGroupAlert__c',operationType);
        }
    }
    //Method to get alert body for each contact record
    public static string getBody(string name,string title,string email,string mobile,boolean titleChange,boolean emailChange,boolean mobileChange){
        string getalertBody ='';
        
        getalertBody+='\nName: '+name;
        if(titleChange)
        getalertBody+= '\nTitle: '+title;
        if(emailChange)
        getalertBody+='\nEmail: '+email;
        if(mobileChange)
        getalertBody += '\nMobile: '+mobile;
        system.debug('getalertBody'+getalertBody);  
        
        return getalertBody;
    }
}