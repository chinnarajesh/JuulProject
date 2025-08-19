public with sharing class CaseTriggerHandler{
    /*Delete the contact created by zopim and replace it with Person Account*/
    private static FINAL Id caseRecordTypeId = getB2BcaseRecordType();
    public static void processCases(List<Case> triggerNew){
        List<Case> b2bCases = new List<Case>();
        List<Case> zopimCases = new List<Case>(); 
        for(Case cs : triggerNew){
            if(cs.RecordTypeId == caseRecordTypeId){
                b2bCases.add(cs);
            }else{
                zopimCases.add(cs);    
            }
        }
        if(!b2bCases.isEmpty()){
            processBusinessAccount(b2bCases) ;
        }
        if(!zopimCases.isEmpty()){
            processnonB2BZopim(zopimCases) ;   
        }
    }
    private static void processnonB2BZopim(List<Case> triggerNew){
        Map<Id,Case> mapOfContactIdCase =filterRecords(triggerNew);
        List<Contact> contacts =[
            SELECT id,Email,FirstName,LastName,isPersonAccount,
                Fax,HomePhone,LeadSource,MobilePhone,Phone,Birthdate,
                MailingCity,MailingState,MailingCountry 
            FROM Contact 
            WHERE id IN:mapOfContactIdCase.keySet()
        ];
        If(!contacts.isEmpty()){
            List<Contact> contactToBeDeleted = new List<Contact>();
            Set<String> emails = new Set<String>();
            Map<Id,Account> mapOfContactIdPersonAccount = new Map<Id,Account> (); 
            for(contact con : contacts){
                emails.add(con.email);
            }
            
            //get emails from account that already exists
            Map<String,Account> emailAccountMap = getEmailAccountMap(emails);
            
            for(contact con : contacts){
                Account acc = emailAccountMap.containsKey(con.email) ? emailAccountMap.get(con.email) : initAccount(con);
                mapOfContactIdPersonAccount.put(con.Id,acc);
                //if existing PA not found
                if(acc.Id == NULL){
                    contactToBeDeleted.add(con);
                }//if case having associated person Account.associate person's contact record with Case
                else if(acc.PersonContactId!=NULL)
                    mapOfContactIdCase.get(con.Id).contactId =acc.PersonContactId;
            }
            
            
            upsert mapOfContactIdPersonAccount.values();
            
            Map<Id,Account> accountMap = getAccountMap(mapOfContactIdPersonAccount.values());
            Id pRtypeId = getPersonAccountRecordTypeId();
            
            for(Id contactId : mapOfContactIdPersonAccount.keySet()){
                case cs = mapOfContactIdCase.get(contactId);
                Account acc = accountMap.get(mapOfContactIdPersonAccount.get(contactId).Id);
                acc.RecordTypeId = pRtypeId;
                cs.AccountId= acc.Id;
                cs.ContactId = acc.PersonContactId;
            }
            //delete contact created by zopim
            delete contactToBeDeleted;     
        }
    }
    
    public static void processCaseContacts(List<Case> triggerNew,List<Case>triggerOld){
        Set<Id> accIds = new Set<Id>();
        List<Account> personAccs = new List<Account>();
        if(trigger.isUpdate){
            for(Case cs : triggerNew){
                for(Case oldCase : triggerOld){
                    if(cs.RecordTypeId != caseRecordTypeId && string.isNotBlank(cs.AccountId) && oldCase.AccountId !=cs.AccountId ){
                        accIds.add(cs.AccountId); 
                    }    
                }
            }
        }
        else{            
            for(Case cs : triggerNew){
                if(cs.RecordTypeId != caseRecordTypeId && string.isNotBlank(cs.AccountId)){
                    accIds.add(cs.AccountId); 
                }    
            } 
        }
        if(!accIds.isEmpty()){
            personAccs =queryPersonAccounts(accIds);
        }
        if(!personAccs.isEmpty()){
            for(Case cs : triggerNew){
                if(cs.RecordTypeId != caseRecordTypeId && string.isNotBlank(cs.AccountId)){
                    for(Account acc :personAccs){
                        if(cs.AccountId == acc.Id){
                            cs.contactId = acc.PersonContactId;
                        }
                    }  
                }
            }    
        }             
    }  
      
    private static void processBusinessAccount(List<Case> triggerNewList){
        Map<Case,Contact> contactMap = new Map<Case,Contact>();
        List<Case> emailServices = new List<Case>();
        Set<String> emails = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        for(Case cs : triggerNewList){
            if(cs.SuppliedEmail !=NULL){
                emails.add(cs.SuppliedEmail.toLowerCase()) ;
                emailServices.add(cs);
                accIds.add(cs.AccountId);
            }
        }
        Map<String,Contact> matchingContactMap = getContacts(emails);
        Set<Id> personAccountIds = queryPersonAccountIds(accIds);
        for(Case cs : emailServices){
            cs.AccountId = personAccountIds.contains(cs.AccountId) ? null : cs.AccountId;
            cs.contactId = null;
            if(matchingContactMap.containsKey(cs.suppliedEmail.toLowerCase())){
                cs.contactId = matchingContactMap.get(cs.suppliedEmail.toLowerCase()).Id;
                cs.AccountId = matchingContactMap.get(cs.suppliedEmail.toLowerCase()).AccountId;
            }
            else{
                contactMap.put(
                    cs, new Contact(
                        LastName = cs.SuppliedName,
                        Email = cs.SuppliedEmail
                    )
                );            
            }   
        }
        if(!contactMap.isEmpty()){
            insert contactMap.values() ;
            for(Case cs : contactMap.keyset()){
                if(contactMap.get(cs) != NULL){
                    cs.ContactId = contactMap.get(cs).Id ;
                    System.debug('INSIDE###################'+cs.contactId );
                }
                System.debug('X###################'+cs.contactId );
                System.debug('X2###################'+cs.AccountId );
            }
        }        
    }    
    
    private static List<Account> queryPersonAccounts(Set<Id> accIds){
        return [SELECT Id,IsPersonAccount,PersonContactId FROM Account WHERE IsPersonAccount =true
                AND Id IN:accIds];
    }
    private static Set<Id> queryPersonAccountIds(Set<Id> accIds){
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE IsPersonAccount =true
            AND Id IN:accIds]){
                accountIds.add(acc.Id);                   
           }
        return accountIds ;    
    }
    
    private static Map<String,Account> getEmailAccountMap(Set<String> emails){
        Map<String,Account> accountMap = new Map<String,Account>();
        for(Account acc:[SELECT Id,PersonEmail,PersonContactId FROM Account WHERE PersonEmail IN:emails]){
            accountMap.put(acc.PersonEmail.toLowerCase(),acc);
        }
        return accountMap;
    }
    private static Map<String,Contact> getContacts(Set<String> emails){
        Map<String,Contact> conMap = new Map<String,Contact>();
        for(Contact con :[SELECT Id,Email,AccountId  FROM Contact WHERE Email IN:emails AND IspersonAccount=false]){
            conMap.put(con.Email.toLowerCase(),con);
        }
        return conMap;
    }
            
    private static Map<Id,Account> getAccountMap(List<Account> accounts){
        return new Map<Id,Account>([
            SELECT Id,PersonContactId
            FROM Account
            WHERE Id IN:accounts
        ]);
    }
    
    private static Map<Id,Case> filterRecords(List<Case> cases){
        Map<Id,Case> mapOfContactIdCase = new Map <Id,Case>();
        for(Case cs : cases){
            if(cs.contactId!=NULL && String.isNotBlank(cs.Description) && cs.Description.startsWith('Chat started on')){
                mapOfContactIdCase.put(cs.contactId,cs);
            }
        }
        return mapOfContactIdCase ;
    }  
    @TestVisible      
    private static Account initAccount(Contact con){
        Account acc = new Account(
            PersonEmail=con.Email,
            FirstName=con.FirstName,
            LastName=con.LastName,
            PersonBirthDate=con.Birthdate,
            PersonLeadSource=con.LeadSource,
            PersonMobilePhone=con.MobilePhone,
            Phone=con.Phone,
            Fax=con.Fax,
            PersonMailingCity=con.MailingCity,
            PersonMailingStreet=con.MailingState,
            PersonMailingCountry=con.MailingCountry,
            PersonMailingState=con.MailingState
        );
        return acc;
    }
    
    private static Id getPersonAccountRecordTypeId(){
        List<RecordType> recType=[
            SELECT Id,Name 
            FROM RecordType 
            WHERE SobjectType='Account' AND IsActive=true and IsPersonType=True
        ];
        if(!recType.isEmpty()){
            return recType[0].Id;
        }else{
            return null;
        }
    }
    
    private static Id getB2BcaseRecordType(){
        List<RecordType> recType=[
            SELECT Id,Name 
            FROM RecordType 
            WHERE SobjectType='Case' AND DeveloperName='B2B_Support_Case' 
        ];
        if(!recType.isEmpty()){
            return recType[0].Id;
        }else{
            return null;
        }
    }
    
    
}