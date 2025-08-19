/*************************************************************************************************
Trigger Name        : CaseTriggerVoiceMail
Version             : 1.0
Date Created        : 25-March2015
Function            : Trigger to set Account details based on phonenumber in subject 
Author              : Andrew
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* ---------------       -----------             ----------------------------------------------
**************************************************************************************************/
trigger CaseTriggerVoiceMail on Case (before insert) {
    Map<String,List<Case>> mapPhoneNumberToCase = new Map<String,List<Case>>();
    
    for(Case c : Trigger.New){
        if( String.isBlank(c.AccountId) && String.isBlank(c.contactId) &&  ! String.isBlank(c.subject) && (c.subject.startsWithIgnoreCase('voicemail from') || c.subject.startsWithIgnoreCase('INBOUND CALL'))){
            string phoneNumber = c.subject.replaceAll('[^0-9]+', '');
            if(phoneNumber.length() > 10){
                phoneNumber = phoneNumber.right(10);
            }
            if(! String.isBlank(phoneNumber)){
                if(mapPhoneNumberToCase.containsKey(phoneNumber)){
                    mapPhoneNumberToCase.get(phoneNumber).add(c);
                }else{
                    mapPhoneNumberToCase.put(phoneNumber, new List<Case>{c});
                }
            }
        }
    }
    
    if(! mapPhoneNumberToCase.isEmpty()){
        for(Account acc : [SELECT
                                Id, PersonContactId, Phone_Unformatted__c
                          FROM
                            Account
                          WHERE
                            Phone_Unformatted__c in :mapPhoneNumberToCase.keyset() and  Phone_Unformatted__c <> null limit 100000 ]){
            for(Case c : mapPhoneNumberToCase.get(acc.Phone_Unformatted__c)){
                c.contactId = acc.personContactId;
                c.AccountId = acc.id;
            }                       
        }
    }

}